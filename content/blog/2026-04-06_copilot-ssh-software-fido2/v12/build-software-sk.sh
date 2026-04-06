#!/bin/bash

# Build script for software FIDO2 provider
# This creates a shared library that OpenSSH can use

set -e

REPO_PATH="${1:-.}"
OUTPUT_LIB="libssh-sk-software.so"

echo "Building software FIDO2 provider..."
echo "  Repository: $REPO_PATH"
echo "  Output: $OUTPUT_LIB"

# Compile the software security key provider
gcc -shared -fPIC -Wall \
    -I"$REPO_PATH" \
    -I"$REPO_PATH/openbsd-compat" \
    -DENABLE_SK \
    -DHAVE_CLOCK_GETTIME \
    -DHAVE_TIMEGM \
    -DHAVE_GETRRSETBYNAME \
    -DHAVE_STAT_NSEC \
    -DHAVE_ADDR_V4MAPPED \
    -o "$OUTPUT_LIB" \
    ssh-sk-software.c \
    "$REPO_PATH/crypto_api.c" \
    -lc

echo "Build successful!"
echo ""
echo "To use this provider with OpenSSH client:"
echo "  ssh -I libssh-sk-software.so -i ~/.ssh/id_ed25519_sk user@host"
echo ""
echo "Or set as default provider:"
echo "  export SSH_SK_PROVIDER=./libssh-sk-software.so"