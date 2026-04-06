/* $OpenSSH: ssh-sk-software.c,v 1.1 2026/04/06 00:00:00 uli Exp $ */
/*
 * Software FIDO2 Security Key Provider for OpenSSH
 * Emulates FIDO2 authentication without hardware
 * Supports both sk-ssh-ed25519@openssh.com and sk-ecdsa-sha2-nistp256@openssh.com
 */

#include "includes.h"

#ifdef ENABLE_SK

#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#ifdef WITH_OPENSSL
#include <openssl/ec.h>
#include <openssl/ecdsa.h>
#include <openssl/evp.h>
#include <openssl/bn.h>
#include <openssl/sha.h>
#endif

#include "log.h"
#include "misc.h"
#include "sshbuf.h"
#include "sshkey.h"
#include "ssherr.h"
#include "digest.h"
#include "crypto_api.h"

#include "sk-api.h"

/* Global counter for signature counter field */
static uint32_t g_sk_counter = 1;

/*
 * Software Key Storage
 * Supports both ED25519 and ECDSA-P256 keys
 */
typedef struct {
    uint8_t flags;                      /* SK flags (USER_PRESENCE_REQD, etc) */
    uint32_t counter;                   /* Signature counter */
    char application[256];              /* Application string (e.g., "ssh:") */
    int alg;                            /* Algorithm: SSH_SK_ED25519 or SSH_SK_ECDSA */
    
    /* ED25519-specific */
    uint8_t ed25519_public_key[32];
    uint8_t ed25519_private_key[64];
    
    /* ECDSA-P256-specific */
#ifdef WITH_OPENSSL
    EC_KEY *ec_key;                     /* ECDSA P256 key pair */
#endif
} SoftwareKey;

static SoftwareKey g_software_key = {0};
static int g_software_key_initialized = 0;

/*
 * API version - required by OpenSSH
 */
uint32_t
sk_api_version(void)
{
    return SSH_SK_VERSION_MAJOR;
}

#ifdef WITH_OPENSSL
/*
 * Generate ECDSA P256 key pair
 */
static int
generate_ecdsa_p256_key(EC_KEY **ec_key_out)
{
    EC_KEY *ec_key = NULL;
    EC_GROUP *ec_group = NULL;
    
    if ((ec_group = EC_GROUP_new_by_curve_name(NID_X9_62_prime256v1)) == NULL) {
        debug_f("EC_GROUP_new_by_curve_name failed");
        return SSH_SK_ERR_GENERAL;
    }
    
    if ((ec_key = EC_KEY_new()) == NULL) {
        debug_f("EC_KEY_new failed");
        EC_GROUP_free(ec_group);
        return SSH_SK_ERR_GENERAL;
    }
    
    if (EC_KEY_set_group(ec_key, ec_group) != 1) {
        debug_f("EC_KEY_set_group failed");
        EC_KEY_free(ec_key);
        EC_GROUP_free(ec_group);
        return SSH_SK_ERR_GENERAL;
    }
    
    /* Generate key pair */
    if (EC_KEY_generate_key(ec_key) != 1) {
        debug_f("EC_KEY_generate_key failed");
        EC_KEY_free(ec_key);
        EC_GROUP_free(ec_group);
        return SSH_SK_ERR_GENERAL;
    }
    
    EC_GROUP_free(ec_group);
    *ec_key_out = ec_key;
    return 0;
}

/*
 * Extract ECDSA public key in SEC1 format (uncompressed point)
 */
static int
get_ecdsa_p256_public_key(EC_KEY *ec_key, uint8_t **pub_key_out, size_t *pub_len_out)
{
    const EC_GROUP *group = NULL;
    const EC_POINT *pub_point = NULL;
    uint8_t *pub_key = NULL;
    size_t pub_len;
    
    if ((group = EC_KEY_get0_group(ec_key)) == NULL ||
        (pub_point = EC_KEY_get0_public_key(ec_key)) == NULL) {
        debug_f("failed to get public key point");
        return SSH_SK_ERR_GENERAL;
    }
    
    /* Get the length of the SEC1 encoded point */
    pub_len = EC_POINT_point2oct(group, pub_point,
        POINT_CONVERSION_UNCOMPRESSED, NULL, 0, NULL);
    
    if (pub_len == 0) {
        debug_f("EC_POINT_point2oct failed to get length");
        return SSH_SK_ERR_GENERAL;
    }
    
    if ((pub_key = malloc(pub_len)) == NULL) {
        debug_f("malloc public_key failed");
        return SSH_SK_ERR_GENERAL;
    }
    
    /* Encode the public key point */
    if (EC_POINT_point2oct(group, pub_point,
        POINT_CONVERSION_UNCOMPRESSED, pub_key, pub_len, NULL) == 0) {
        debug_f("EC_POINT_point2oct failed");
        free(pub_key);
        return SSH_SK_ERR_GENERAL;
    }
    
    *pub_key_out = pub_key;
    *pub_len_out = pub_len;
    return 0;
}

/*
 * Serialize ECDSA private key to DER for key_handle
 */
static int
get_ecdsa_p256_private_key_der(EC_KEY *ec_key, uint8_t **priv_key_out, size_t *priv_len_out)
{
    unsigned char *der = NULL;
    int der_len;
    
    /* Get DER length */
    der_len = i2d_ECPrivateKey(ec_key, NULL);
    if (der_len <= 0) {
        debug_f("i2d_ECPrivateKey failed to get length");
        return SSH_SK_ERR_GENERAL;
    }
    
    if ((der = malloc(der_len)) == NULL) {
        debug_f("malloc failed");
        return SSH_SK_ERR_GENERAL;
    }
    
    /* Encode to DER */
    unsigned char *p = der;
    if (i2d_ECPrivateKey(ec_key, &p) != der_len) {
        debug_f("i2d_ECPrivateKey failed");
        free(der);
        return SSH_SK_ERR_GENERAL;
    }
    
    *priv_key_out = der;
    *priv_len_out = der_len;
    return 0;
}
#endif /* WITH_OPENSSL */

/*
 * Enroll (generate) a new security key
 */
int
sk_enroll(uint32_t alg, const uint8_t *challenge, size_t challenge_len,
    const char *application, uint8_t flags, const char *pin,
    struct sk_option **options, struct sk_enroll_response **enroll_response)
{
    struct sk_enroll_response *resp = NULL;
    int r = SSH_SK_ERR_GENERAL;

    if (application == NULL || *application == '\0') {
        debug_f("missing application");
        return SSH_SK_ERR_GENERAL;
    }

    debug_f("Software FIDO2: enrolling key");
    debug_f("  algorithm: %d (%s)", alg,
        alg == SSH_SK_ED25519 ? "ED25519" :
        alg == SSH_SK_ECDSA ? "ECDSA-P256" : "UNKNOWN");
    debug_f("  application: %s", application);
    debug_f("  flags: 0x%02x", flags);
    debug_f("  challenge_len: %zu", challenge_len);

    /* Allocate response structure */
    if ((resp = calloc(1, sizeof(*resp))) == NULL) {
        debug_f("calloc failed");
        return SSH_SK_ERR_GENERAL;
    }

    switch (alg) {
    case SSH_SK_ED25519:
        /* Generate ED25519 key pair */
        if ((resp->public_key = malloc(32)) == NULL) {
            debug_f("malloc public_key failed");
            goto out;
        }
        if ((resp->key_handle = malloc(64)) == NULL) {
            debug_f("malloc key_handle failed");
            goto out;
        }

        /* Generate random ED25519 key pair */
        arc4random_buf(resp->key_handle, 32); /* 32 bytes seed */
        
        /* Create ED25519 key from seed */
        crypto_sign_ed25519_seed_keypair(resp->public_key,
            (unsigned char *)resp->key_handle, resp->key_handle);

        /* The actual private key is the seed + public key (64 bytes total) */
        memcpy(resp->key_handle + 32, resp->public_key, 32);

        resp->public_key_len = 32;
        resp->key_handle_len = 64;
        
        /* Store for later use */
        g_software_key.alg = SSH_SK_ED25519;
        memcpy(g_software_key.ed25519_public_key, resp->public_key, 32);
        memcpy(g_software_key.ed25519_private_key, resp->key_handle, 64);
        break;

#ifdef WITH_OPENSSL
    case SSH_SK_ECDSA:
        /* Generate ECDSA P256 key pair */
        if ((r = generate_ecdsa_p256_key(&g_software_key.ec_key)) != 0) {
            debug_f("generate_ecdsa_p256_key failed");
            goto out;
        }

        /* Extract public key in SEC1 format */
        if ((r = get_ecdsa_p256_public_key(g_software_key.ec_key,
            &resp->public_key, &resp->public_key_len)) != 0) {
            debug_f("get_ecdsa_p256_public_key failed");
            goto out;
        }

        /* Serialize private key to DER for key_handle */
        if ((r = get_ecdsa_p256_private_key_der(g_software_key.ec_key,
            &resp->key_handle, &resp->key_handle_len)) != 0) {
            debug_f("get_ecdsa_p256_private_key_der failed");
            goto out;
        }

        g_software_key.alg = SSH_SK_ECDSA;
        debug_f("  ECDSA P256 key generated");
        debug_f("  public_key_len: %zu (SEC1 uncompressed point)", resp->public_key_len);
        debug_f("  key_handle_len: %zu (DER format)", resp->key_handle_len);
        break;
#endif /* WITH_OPENSSL */

    default:
        debug_f("unsupported algorithm: %d", alg);
        return SSH_SK_ERR_UNSUPPORTED;
    }

    resp->flags = flags;

    /* Store common fields */
    g_software_key.flags = flags;
    g_software_key.counter = 1;
    strlcpy(g_software_key.application, application, sizeof(g_software_key.application));
    g_software_key_initialized = 1;

    debug_f("Key enrollment successful");
    debug_f("  public_key_len: %zu", resp->public_key_len);
    debug_f("  key_handle_len: %zu", resp->key_handle_len);

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

/*
 * Sign a challenge with the security key
 */
int
sk_sign(uint32_t alg, const uint8_t *message, size_t message_len,
    const char *application, const uint8_t *key_handle, size_t key_handle_len,
    uint8_t flags, const char *pin, struct sk_option **options,
    struct sk_sign_response **sign_response)
{
    struct sk_sign_response *resp = NULL;
    int r = SSH_SK_ERR_GENERAL;

    if (application == NULL || *application == '\0') {
        debug_f("missing application");
        return SSH_SK_ERR_GENERAL;
    }

    debug_f("Software FIDO2: signing with key");
    debug_f("  algorithm: %d (%s)", alg,
        alg == SSH_SK_ED25519 ? "ED25519" :
        alg == SSH_SK_ECDSA ? "ECDSA-P256" : "UNKNOWN");
    debug_f("  application: %s", application);
    debug_f("  message_len: %zu", message_len);
    debug_f("  requested_flags: 0x%02x", flags);

    /* Allocate response structure */
    if ((resp = calloc(1, sizeof(*resp))) == NULL) {
        debug_f("calloc failed");
        return SSH_SK_ERR_GENERAL;
    }

    switch (alg) {
    case SSH_SK_ED25519: {
        unsigned char sig[64];
        unsigned long long siglen;

        if (key_handle_len != 64) {
            debug_f("invalid key_handle_len: %zu (expected 64)", key_handle_len);
            goto out;
        }

        /* Allocate signature buffer (64 bytes for ED25519) */
        if ((resp->sig_r = malloc(64)) == NULL) {
            debug_f("malloc sig_r failed");
            goto out;
        }

        /* Sign the message using ED25519 */
        if (crypto_sign_ed25519(sig, &siglen, message, message_len,
            (unsigned char *)key_handle) != 0) {
            debug_f("crypto_sign_ed25519 failed");
            goto out;
        }

        if (siglen != 64) {
            debug_f("unexpected signature length: %llu (expected 64)", siglen);
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

        /* Reconstruct EC_KEY from DER-encoded key_handle */
        const unsigned char *p = key_handle;
        ec_key = d2i_ECPrivateKey(NULL, &p, key_handle_len);
        if (ec_key == NULL) {
            debug_f("d2i_ECPrivateKey failed");
            goto out;
        }

        /* Hash the message with SHA-256 */
        SHA256(message, message_len, hash);

        /* Create EVP_PKEY from EC_KEY */
        if ((pkey = EVP_PKEY_new()) == NULL) {
            debug_f("EVP_PKEY_new failed");
            EC_KEY_free(ec_key);
            goto out;
        }

        if (EVP_PKEY_set1_EC_KEY(pkey, ec_key) != 1) {
            debug_f("EVP_PKEY_set1_EC_KEY failed");
            EVP_PKEY_free(pkey);
            EC_KEY_free(ec_key);
            goto out;
        }

        /* Sign with ECDSA */
        if (EVP_PKEY_sign(pkey, sig, &siglen, hash, sizeof(hash)) != 1) {
            debug_f("EVP_PKEY_sign failed");
            EVP_PKEY_free(pkey);
            EC_KEY_free(ec_key);
            goto out;
        }

        /* Parse DER signature to extract r and s */
        if ((ecdsa_sig = d2i_ECDSA_SIG(NULL, (const unsigned char **)&sig, siglen)) == NULL) {
            debug_f("d2i_ECDSA_SIG failed");
            EVP_PKEY_free(pkey);
            EC_KEY_free(ec_key);
            goto out;
        }

        /* Extract r and s components */
        ECDSA_SIG_get0(ecdsa_sig, &sig_r, &sig_s);

        /* Allocate space for r (32 bytes for P256) */
        if ((resp->sig_r = malloc(32)) == NULL) {
            debug_f("malloc sig_r failed");
            ECDSA_SIG_free(ecdsa_sig);
            EVP_PKEY_free(pkey);
            EC_KEY_free(ec_key);
            goto out;
        }

        /* Allocate space for s (32 bytes for P256) */
        if ((resp->sig_s = malloc(32)) == NULL) {
            debug_f("malloc sig_s failed");
            free(resp->sig_r);
            resp->sig_r = NULL;
            ECDSA_SIG_free(ecdsa_sig);
            EVP_PKEY_free(pkey);
            EC_KEY_free(ec_key);
            goto out;
        }

        /* Convert BIGNUMs to binary (32 bytes each for P256) */
        int r_len = BN_bn2bin(sig_r, resp->sig_r);
        int s_len = BN_bn2bin(sig_s, resp->sig_s);

        if (r_len <= 0 || r_len > 32 || s_len <= 0 || s_len > 32) {
            debug_f("invalid signature component lengths: r=%d, s=%d", r_len, s_len);
            free(resp->sig_r);
            free(resp->sig_s);
            resp->sig_r = resp->sig_s = NULL;
            ECDSA_SIG_free(ecdsa_sig);
            EVP_PKEY_free(pkey);
            EC_KEY_free(ec_key);
            goto out;
        }

        /* Pad with zeros if necessary */
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
#endif /* WITH_OPENSSL */

    default:
        debug_f("unsupported algorithm: %d", alg);
        return SSH_SK_ERR_UNSUPPORTED;
    }

    /* Set flags according to enrollment */
    resp->flags = g_software_key.flags & (SSH_SK_USER_PRESENCE_REQD | SSH_SK_USER_VERIFICATION_REQD);

    if (g_software_key.flags & SSH_SK_USER_PRESENCE_REQD) {
        resp->flags |= SSH_SK_USER_PRESENCE_REQD;
        debug_f("  returned flag: USER_PRESENCE_REQD");
    }
    if (g_software_key.flags & SSH_SK_USER_VERIFICATION_REQD) {
        resp->flags |= SSH_SK_USER_VERIFICATION_REQD;
        debug_f("  returned flag: USER_VERIFICATION_REQD");
    }

    /* Increment counter for next signature */
    resp->counter = g_software_key.counter++;

    debug_f("Signature successful");
    debug_f("  sig_r_len: %zu", resp->sig_r_len);
    if (resp->sig_s_len > 0)
        debug_f("  sig_s_len: %zu", resp->sig_s_len);
    debug_f("  counter: %u", resp->counter);
    debug_f("  response_flags: 0x%02x", resp->flags);

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

/*
 * Load resident keys (not implemented for software emulation)
 */
int
sk_load_resident_keys(const char *pin, struct sk_option **options,
    struct sk_resident_key ***rks, size_t *nrks)
{
    debug_f("Software FIDO2: resident keys not supported");
    *rks = NULL;
    *nrks = 0;
    return 0;
}

#endif /* ENABLE_SK */