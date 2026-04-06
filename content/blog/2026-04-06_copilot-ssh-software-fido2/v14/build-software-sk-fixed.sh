#!/bin/bash

# Build script for software FIDO2 provider
# Properly integrates with OpenSSH build system

set -e

REPO_PATH="${1:-.}"
OUTPUT_LIB="libssh-sk-software.so"

# Check if we're in OpenSSH repository
if [ ! -f "$REPO_PATH/openssh-portable.spec" ] && [ ! -f "$REPO_PATH/configure" ]; then
    echo "Error: $REPO_PATH doesn't look like an OpenSSH repository"
    echo "Usage: $0 /path/to/openssh-portable"
    exit 1
fi

echo "Building software FIDO2 provider..."
echo "  Repository: $REPO_PATH"
echo "  Output: $OUTPUT_LIB"
echo "  Features:"
echo "    - ED25519-SK (ssh-sk-ed25519@openssh.com)"
echo "    - ECDSA-P256-SK (sk-ecdsa-sha2-nistp256@openssh.com)"
echo ""

# Check if configure script exists, if not run autoreconf
if [ ! -f "$REPO_PATH/configure" ]; then
    echo "Running autoreconf..."
    cd "$REPO_PATH"
    autoreconf -fi
    cd -
fi

# Run configure if not already done
if [ ! -f "$REPO_PATH/config.h" ]; then
    echo "Running configure..."
    cd "$REPO_PATH"
    ./configure --with-openssl --enable-sk
    cd -
fi

# Extract OpenSSH compiler settings
cd "$REPO_PATH"

# Get the CC and CFLAGS from configure
CC=$(grep "^CC=" config.status 2>/dev/null | cut -d= -f2 | tr -d "'\"" | head -1)
CC=${CC:-gcc}

# Get CFLAGS from Makefile or use defaults
CFLAGS="-fPIC -Wall"
if [ -f "Makefile" ]; then
    CFLAGS=$(grep "^CFLAGS=" Makefile | cut -d= -f2- | head -1)
    CFLAGS="$CFLAGS -fPIC"
fi

# Additional flags for SK provider
CFLAGS="$CFLAGS -DENABLE_SK -DWITH_OPENSSL"

# Find OpenSSL
OPENSSL_CFLAGS=""
OPENSSL_LIBS=""
if command -v pkg-config &> /dev/null; then
    OPENSSL_CFLAGS=$(pkg-config --cflags openssl 2>/dev/null || echo "")
    OPENSSL_LIBS=$(pkg-config --libs openssl 2>/dev/null || echo "-lcrypto")
else
    OPENSSL_LIBS="-lcrypto"
fi

echo "Compiler: $CC"
echo "CFLAGS: $CFLAGS"
echo "OpenSSL CFLAGS: $OPENSSL_CFLAGS"
echo "OpenSSL LIBS: $OPENSSL_LIBS"
echo ""

cd -

# Create a standalone version without dependencies on includes.h
cat > /tmp/ssh-sk-software-standalone.c << 'STANDALONE_EOF'
/* $OpenSSH: ssh-sk-software.c,v 1.1 2026/04/06 00:00:00 uli Exp $ */
/*
 * Software FIDO2 Security Key Provider for OpenSSH
 * Standalone version - no dependency on OpenSSH headers
 */

#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/types.h>

#ifdef WITH_OPENSSL
#include <openssl/ec.h>
#include <openssl/ecdsa.h>
#include <openssl/evp.h>
#include <openssl/bn.h>
#include <openssl/sha.h>
#endif

/* SK API definitions from sk-api.h */
#define SSH_SK_VERSION_MAJOR 0x00030000
#define SSH_SK_VERSION_MAJOR_MASK 0xffff0000

#define SSH_SK_ED25519          0x00
#define SSH_SK_ECDSA            0x01

#define SSH_SK_USER_PRESENCE_REQD       0x01
#define SSH_SK_USER_VERIFICATION_REQD   0x04

#define SSH_SK_ERR_GENERAL              -1
#define SSH_SK_ERR_UNSUPPORTED          1
#define SSH_SK_ERR_PIN_REQUIRED         2
#define SSH_SK_ERR_DEVICE_NOT_FOUND     3

typedef struct {
    char *name;
    char *value;
    uint8_t required;
} sk_option;

typedef struct {
    uint8_t flags;
    uint8_t *public_key;
    size_t public_key_len;
    uint8_t *key_handle;
    size_t key_handle_len;
    uint8_t *signature;
    size_t signature_len;
    uint8_t *attestation_cert;
    size_t attestation_cert_len;
    uint8_t *authdata;
    size_t authdata_len;
} sk_enroll_response;

typedef struct {
    uint8_t flags;
    uint8_t *sig_r;
    size_t sig_r_len;
    uint8_t *sig_s;
    size_t sig_s_len;
    uint32_t counter;
} sk_sign_response;

typedef struct {
    uint32_t (*sk_api_version)(void);
    int (*sk_enroll)(uint32_t, const uint8_t *, size_t, const char *,
        uint8_t, const char *, sk_option **,
        sk_enroll_response **);
    int (*sk_sign)(uint32_t, const uint8_t *, size_t, const char *,
        const uint8_t *, size_t, uint8_t, const char *, sk_option **,
        sk_sign_response **);
    int (*sk_load_resident_keys)(const char *, sk_option **,
        void ***, size_t *);
} SoftwareProvider;

/* ED25519 reference implementation */
#define ED25519_SEED_LEN 32
#define ED25519_PUBLIC_KEY_LEN 32
#define ED25519_SECRET_KEY_LEN 64

void crypto_sign_ed25519_seed_keypair(unsigned char *pk,
    unsigned char *sk, const unsigned char *seed);
int crypto_sign_ed25519(unsigned char *sig, unsigned long long *siglen_p,
    const unsigned char *m, unsigned long long mlen,
    const unsigned char *sk);

/* Global state */
static uint32_t g_sk_counter = 1;

typedef struct {
    uint8_t flags;
    uint32_t counter;
    char application[256];
    int alg;
    uint8_t ed25519_public_key[32];
    uint8_t ed25519_private_key[64];
#ifdef WITH_OPENSSL
    EC_KEY *ec_key;
#endif
} SoftwareKey;

static SoftwareKey g_software_key = {0};
static int g_software_key_initialized = 0;

/* ============ API FUNCTIONS ============ */

uint32_t
sk_api_version(void)
{
    return SSH_SK_VERSION_MAJOR;
}

#ifdef WITH_OPENSSL
static int
generate_ecdsa_p256_key(EC_KEY **ec_key_out)
{
    EC_KEY *ec_key = NULL;
    EC_GROUP *ec_group = NULL;
    
    if ((ec_group = EC_GROUP_new_by_curve_name(NID_X9_62_prime256v1)) == NULL) {
        fprintf(stderr, "EC_GROUP_new_by_curve_name failed\n");
        return SSH_SK_ERR_GENERAL;
    }
    
    if ((ec_key = EC_KEY_new()) == NULL) {
        fprintf(stderr, "EC_KEY_new failed\n");
        EC_GROUP_free(ec_group);
        return SSH_SK_ERR_GENERAL;
    }
    
    if (EC_KEY_set_group(ec_key, ec_group) != 1) {
        fprintf(stderr, "EC_KEY_set_group failed\n");
        EC_KEY_free(ec_key);
        EC_GROUP_free(ec_group);
        return SSH_SK_ERR_GENERAL;
    }
    
    if (EC_KEY_generate_key(ec_key) != 1) {
        fprintf(stderr, "EC_KEY_generate_key failed\n");
        EC_KEY_free(ec_key);
        EC_GROUP_free(ec_group);
        return SSH_SK_ERR_GENERAL;
    }
    
    EC_GROUP_free(ec_group);
    *ec_key_out = ec_key;
    return 0;
}

static int
get_ecdsa_p256_public_key(EC_KEY *ec_key, uint8_t **pub_key_out, size_t *pub_len_out)
{
    const EC_GROUP *group = NULL;
    const EC_POINT *pub_point = NULL;
    uint8_t *pub_key = NULL;
    size_t pub_len;
    
    if ((group = EC_KEY_get0_group(ec_key)) == NULL ||
        (pub_point = EC_KEY_get0_public_key(ec_key)) == NULL) {
        fprintf(stderr, "failed to get public key point\n");
        return SSH_SK_ERR_GENERAL;
    }
    
    pub_len = EC_POINT_point2oct(group, pub_point,
        POINT_CONVERSION_UNCOMPRESSED, NULL, 0, NULL);
    
    if (pub_len == 0) {
        fprintf(stderr, "EC_POINT_point2oct failed to get length\n");
        return SSH_SK_ERR_GENERAL;
    }
    
    if ((pub_key = malloc(pub_len)) == NULL) {
        fprintf(stderr, "malloc public_key failed\n");
        return SSH_SK_ERR_GENERAL;
    }
    
    if (EC_POINT_point2oct(group, pub_point,
        POINT_CONVERSION_UNCOMPRESSED, pub_key, pub_len, NULL) == 0) {
        fprintf(stderr, "EC_POINT_point2oct failed\n");
        free(pub_key);
        return SSH_SK_ERR_GENERAL;
    }
    
    *pub_key_out = pub_key;
    *pub_len_out = pub_len;
    return 0;
}

static int
get_ecdsa_p256_private_key_der(EC_KEY *ec_key, uint8_t **priv_key_out, size_t *priv_len_out)
{
    unsigned char *der = NULL;
    int der_len;
    
    der_len = i2d_ECPrivateKey(ec_key, NULL);
    if (der_len <= 0) {
        fprintf(stderr, "i2d_ECPrivateKey failed to get length\n");
        return SSH_SK_ERR_GENERAL;
    }
    
    if ((der = malloc(der_len)) == NULL) {
        fprintf(stderr, "malloc failed\n");
        return SSH_SK_ERR_GENERAL;
    }
    
    unsigned char *p = der;
    if (i2d_ECPrivateKey(ec_key, &p) != der_len) {
        fprintf(stderr, "i2d_ECPrivateKey failed\n");
        free(der);
        return SSH_SK_ERR_GENERAL;
    }
    
    *priv_key_out = der;
    *priv_len_out = der_len;
    return 0;
}
#endif

int
sk_enroll(uint32_t alg, const uint8_t *challenge, size_t challenge_len,
    const char *application, uint8_t flags, const char *pin,
    sk_option **options, sk_enroll_response **enroll_response)
{
    sk_enroll_response *resp = NULL;
    int r = SSH_SK_ERR_GENERAL;

    if (application == NULL || *application == '\0') {
        fprintf(stderr, "missing application\n");
        return SSH_SK_ERR_GENERAL;
    }

    fprintf(stderr, "Software FIDO2: enrolling key (alg=%d, app=%s, flags=0x%02x)\n",
        alg, application, flags);

    if ((resp = calloc(1, sizeof(*resp))) == NULL) {
        fprintf(stderr, "calloc failed\n");
        return SSH_SK_ERR_GENERAL;
    }

    switch (alg) {
    case SSH_SK_ED25519:
        if ((resp->public_key = malloc(32)) == NULL ||
            (resp->key_handle = malloc(64)) == NULL) {
            fprintf(stderr, "malloc failed\n");
            goto out;
        }

        /* Generate random seed */
        arc4random_buf(resp->key_handle, 32);
        
        /* Create keypair from seed */
        crypto_sign_ed25519_seed_keypair(resp->public_key,
            (unsigned char *)resp->key_handle, resp->key_handle);

        memcpy(resp->key_handle + 32, resp->public_key, 32);

        resp->public_key_len = 32;
        resp->key_handle_len = 64;
        
        g_software_key.alg = SSH_SK_ED25519;
        memcpy(g_software_key.ed25519_public_key, resp->public_key, 32);
        memcpy(g_software_key.ed25519_private_key, resp->key_handle, 64);
        break;

#ifdef WITH_OPENSSL
    case SSH_SK_ECDSA:
        if ((r = generate_ecdsa_p256_key(&g_software_key.ec_key)) != 0) {
            fprintf(stderr, "generate_ecdsa_p256_key failed\n");
            goto out;
        }

        if ((r = get_ecdsa_p256_public_key(g_software_key.ec_key,
            &resp->public_key, &resp->public_key_len)) != 0) {
            fprintf(stderr, "get_ecdsa_p256_public_key failed\n");
            goto out;
        }

        if ((r = get_ecdsa_p256_private_key_der(g_software_key.ec_key,
            &resp->key_handle, &resp->key_handle_len)) != 0) {
            fprintf(stderr, "get_ecdsa_p256_private_key_der failed\n");
            goto out;
        }

        g_software_key.alg = SSH_SK_ECDSA;
        fprintf(stderr, "ECDSA P256 key generated (pub=%zu, handle=%zu)\n",
            resp->public_key_len, resp->key_handle_len);
        break;
#endif

    default:
        fprintf(stderr, "unsupported algorithm: %d\n", alg);
        return SSH_SK_ERR_UNSUPPORTED;
    }

    resp->flags = flags;
    g_software_key.flags = flags;
    g_software_key.counter = 1;
    strlcpy(g_software_key.application, application, sizeof(g_software_key.application));
    g_software_key_initialized = 1;

    fprintf(stderr, "Enrollment successful\n");
    *enroll_response = resp;
    return 0;

out:
    if (resp != NULL) {
        free(resp->public_key);
        free(resp->key_handle);
        free(resp);
    }
    return SSH_SK_ERR_GENERAL;
}

int
sk_sign(uint32_t alg, const uint8_t *message, size_t message_len,
    const char *application, const uint8_t *key_handle, size_t key_handle_len,
    uint8_t flags, const char *pin, sk_option **options,
    sk_sign_response **sign_response)
{
    sk_sign_response *resp = NULL;
    int r = SSH_SK_ERR_GENERAL;

    fprintf(stderr, "Software FIDO2: signing (alg=%d, app=%s, msglen=%zu)\n",
        alg, application, message_len);

    if ((resp = calloc(1, sizeof(*resp))) == NULL) {
        fprintf(stderr, "calloc failed\n");
        return SSH_SK_ERR_GENERAL;
    }

    switch (alg) {
    case SSH_SK_ED25519: {
        unsigned char sig[64];
        unsigned long long siglen;

        if (key_handle_len != 64) {
            fprintf(stderr, "invalid key_handle_len: %zu\n", key_handle_len);
            goto out;
        }

        if ((resp->sig_r = malloc(64)) == NULL) {
            fprintf(stderr, "malloc failed\n");
            goto out;
        }

        if (crypto_sign_ed25519(sig, &siglen, message, message_len,
            (unsigned char *)key_handle) != 0) {
            fprintf(stderr, "crypto_sign_ed25519 failed\n");
            goto out;
        }

        if (siglen != 64) {
            fprintf(stderr, "unexpected signature length: %llu\n", siglen);
            goto out;
        }

        memcpy(resp->sig_r, sig, 64);
        resp->sig_r_len = 64;
        break;
    }

#ifdef WITH_OPENSSL
    case SSH_SK_ECDSA: {
        EC_KEY *ec_key = NULL;
        EVP_PKEY *pkey = NULL;
        unsigned char hash[32];
        unsigned char sig[256];
        unsigned int siglen;
        const BIGNUM *sig_r = NULL, *sig_s = NULL;
        ECDSA_SIG *ecdsa_sig = NULL;

        const unsigned char *p = key_handle;
        ec_key = d2i_ECPrivateKey(NULL, &p, key_handle_len);
        if (ec_key == NULL) {
            fprintf(stderr, "d2i_ECPrivateKey failed\n");
            goto out;
        }

        SHA256(message, message_len, hash);

        if ((pkey = EVP_PKEY_new()) == NULL) {
            fprintf(stderr, "EVP_PKEY_new failed\n");
            EC_KEY_free(ec_key);
            goto out;
        }

        if (EVP_PKEY_set1_EC_KEY(pkey, ec_key) != 1) {
            fprintf(stderr, "EVP_PKEY_set1_EC_KEY failed\n");
            EVP_PKEY_free(pkey);
            EC_KEY_free(ec_key);
            goto out;
        }

        if (EVP_PKEY_sign(pkey, sig, &siglen, hash, sizeof(hash)) != 1) {
            fprintf(stderr, "EVP_PKEY_sign failed\n");
            EVP_PKEY_free(pkey);
            EC_KEY_free(ec_key);
            goto out;
        }

        if ((ecdsa_sig = d2i_ECDSA_SIG(NULL, (const unsigned char **)&sig, siglen)) == NULL) {
            fprintf(stderr, "d2i_ECDSA_SIG failed\n");
            EVP_PKEY_free(pkey);
            EC_KEY_free(ec_key);
            goto out;
        }

        ECDSA_SIG_get0(ecdsa_sig, &sig_r, &sig_s);

        if ((resp->sig_r = malloc(32)) == NULL ||
            (resp->sig_s = malloc(32)) == NULL) {
            fprintf(stderr, "malloc failed\n");
            free(resp->sig_r);
            ECDSA_SIG_free(ecdsa_sig);
            EVP_PKEY_free(pkey);
            EC_KEY_free(ec_key);
            goto out;
        }

        int r_len = BN_bn2bin(sig_r, resp->sig_r);
        int s_len = BN_bn2bin(sig_s, resp->sig_s);

        if (r_len <= 0 || r_len > 32 || s_len <= 0 || s_len > 32) {
            fprintf(stderr, "invalid sig lengths: r=%d, s=%d\n", r_len, s_len);
            free(resp->sig_r);
            free(resp->sig_s);
            ECDSA_SIG_free(ecdsa_sig);
            EVP_PKEY_free(pkey);
            EC_KEY_free(ec_key);
            goto out;
        }

        if (r_len < 32) {
            memmove(resp->sig_r + (32 - r_len), resp->sig_r, r_len);
            memset(resp->sig_r, 0, 32 - r_len);
        }
        if (s_len < 32) {
            memmove(resp->sig_s + (32 - s_len), resp->sig_s, s_len);
            memset(resp->sig_s, 0, 32 - s_len);
        }

        resp->sig_r_len = 32;
        resp->sig_s_len = 32;

        ECDSA_SIG_free(ecdsa_sig);
        EVP_PKEY_free(pkey);
        EC_KEY_free(ec_key);
        break;
    }
#endif

    default:
        fprintf(stderr, "unsupported algorithm: %d\n", alg);
        return SSH_SK_ERR_UNSUPPORTED;
    }

    resp->flags = g_software_key.flags & (SSH_SK_USER_PRESENCE_REQD | SSH_SK_USER_VERIFICATION_REQD);
    resp->counter = g_software_key.counter++;

    fprintf(stderr, "Signature successful (flags=0x%02x, counter=%u)\n",
        resp->flags, resp->counter);

    *sign_response = resp;
    return 0;

out:
    if (resp != NULL) {
        free(resp->sig_r);
        free(resp->sig_s);
        free(resp);
    }
    return SSH_SK_ERR_GENERAL;
}

int
sk_load_resident_keys(const char *pin, sk_option **options,
    void ***rks, size_t *nrks)
{
    fprintf(stderr, "Software FIDO2: resident keys not supported\n");
    *rks = NULL;
    *nrks = 0;
    return 0;
}
STANDALONE_EOF

# Compile with standalone version
echo "Compiling software FIDO2 provider..."
$CC \
    -shared -fPIC -Wall \
    -I"$REPO_PATH" \
    -I"$REPO_PATH/openbsd-compat" \
    $CFLAGS \
    $OPENSSL_CFLAGS \
    -o "$OUTPUT_LIB" \
    /tmp/ssh-sk-software-standalone.c \
    "$REPO_PATH/crypto_api.c" \
    -lc $OPENSSL_LIBS

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Build successful!"
    echo ""
    echo "Library information:"
    nm "$OUTPUT_LIB" 2>/dev/null | grep -E "sk_api_version|sk_enroll|sk_sign" | head -5
    echo ""
    echo "To use this provider with OpenSSH client:"
    echo ""
    echo "  # Set as default provider:"
    echo "  export SSH_SK_PROVIDER=./$OUTPUT_LIB"
    echo ""
    echo "  # Generate ED25519-SK key:"
    echo "  ssh-keygen -t ed25519-sk -f ~/.ssh/id_ed25519_sk"
    echo ""
    echo "  # Generate ECDSA-P256-SK key:"
    echo "  ssh-keygen -t ecdsa-sk -f ~/.ssh/id_ecdsa_sk"
    echo ""
    echo "  # Use for authentication:"
    echo "  ssh -I ./$OUTPUT_LIB user@host"
else
    echo "✗ Build failed!"
    exit 1
fi
