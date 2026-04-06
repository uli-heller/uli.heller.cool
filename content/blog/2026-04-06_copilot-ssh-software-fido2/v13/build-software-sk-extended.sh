#!/bin/bash

# Build script for extended software FIDO2 provider
# Supports ED25519-SK and ECDSA-P256-SK keys

set -e

REPO_PATH="${1:-.}"
OUTPUT_LIB="libssh-sk-software.so"

echo "Building extended software FIDO2 provider..."
echo "  Repository: $REPO_PATH"
echo "  Output: $OUTPUT_LIB"
echo "  Features:"
echo "    - ED25519-SK (ssh-sk-ed25519@openssh.com)"
echo "    - ECDSA-P256-SK (sk-ecdsa-sha2-nistp256@openssh.com)"
echo ""

# Compiler flags
CFLAGS="-shared -fPIC -Wall -Wextra"
CFLAGS="$CFLAGS -I$REPO_PATH"
CFLAGS="$CFLAGS -I$REPO_PATH/openbsd-compat"
CFLAGS="$CFLAGS -DENABLE_SK"
CFLAGS="$CFLAGS -DWITH_OPENSSL"
CFLAGS="$CFLAGS -DHAVE_CLOCK_GETTIME"
CFLAGS="$CFLAGS -DHAVE_TIMEGM"
CFLAGS="$CFLAGS -DHAVE_GETRRSETBYNAME"
CFLAGS="$CFLAGS -DHAVE_STAT_NSEC"
CFLAGS="$CFLAGS -DHAVE_ADDR_V4MAPPED"

# Libraries
LIBS="-lc -lcrypto"

# Compile
gcc $CFLAGS -o "$OUTPUT_LIB" \
    ssh-sk-software-extended.c \
    "$REPO_PATH/crypto_api.c" \
    $LIBS

if [ $? -eq 0 ]; then
    echo "✓ Build successful!"
    echo ""
    echo "Library information:"
    nm "$OUTPUT_LIB" | grep -E "sk_api_version|sk_enroll|sk_sign|sk_load" | head -10
    echo ""
    echo "To use this provider with OpenSSH client:"
    echo ""
    echo "  # Generate ED25519-SK key:"
    echo "  export SSH_SK_PROVIDER=./libssh-sk-software.so"
    echo "  ssh-keygen -t ed25519-sk -f ~/.ssh/id_ed25519_sk"
    echo ""
    echo "  # Generate ECDSA-P256-SK key:"
    echo "  ssh-keygen -t ecdsa-sk -f ~/.ssh/id_ecdsa_sk"
    echo ""
    echo "  # Use for authentication:"
    echo "  ssh -I ./libssh-sk-software.so user@host"
else
    echo "✗ Build failed!"
    exit 1
fi