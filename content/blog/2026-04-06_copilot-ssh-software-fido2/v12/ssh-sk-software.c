/* $OpenSSH: ssh-sk-software.c,v 1.0 2026/04/06 00:00:00 uli Exp $ */
/*
 * Software FIDO2 Security Key Provider for OpenSSH
 * Emulates FIDO2 authentication without hardware
 * For sk-ssh-ed25519@openssh.com keys only
 */

#include "includes.h"

#ifdef ENABLE_SK

#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

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

/* Simple state for simulating touch and verification */
typedef struct {
    uint8_t flags;           /* SK flags (USER_PRESENCE_REQD, USER_VERIFICATION_REQD, etc) */
    uint32_t counter;        /* Signature counter */
    char application[256];   /* Application string (e.g., "ssh:") */
    uint8_t public_key[32];  /* ED25519 public key */
    uint8_t private_key[64]; /* ED25519 secret key (32 bytes seed + 32 bytes pk) */
} SoftwareKey;

/* Map of key handles to software keys (simplified: just one key) */
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

/*
 * Enroll a new security key (generate key pair)
 */
int
sk_enroll(uint32_t alg, const uint8_t *challenge, size_t challenge_len,
    const char *application, uint8_t flags, const char *pin,
    struct sk_option **options, struct sk_enroll_response **enroll_response)
{
    struct sk_enroll_response *resp = NULL;
    int r = SSH_SK_ERR_GENERAL;

    if (alg != SSH_SK_ED25519) {
        debug_f("unsupported algorithm: %d (only ED25519 supported)", alg);
        return SSH_SK_ERR_UNSUPPORTED;
    }

    if (application == NULL || *application == '\0') {
        debug_f("missing application");
        return SSH_SK_ERR_GENERAL;
    }

    debug_f("Software FIDO2: enrolling ED25519 key");
    debug_f("  application: %s", application);
    debug_f("  flags: 0x%02x", flags);
    debug_f("  challenge_len: %zu", challenge_len);

    /* Allocate response structure */
    if ((resp = calloc(1, sizeof(*resp))) == NULL) {
        debug_f("calloc failed");
        return SSH_SK_ERR_GENERAL;
    }

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
    resp->flags = flags;

    /* Store for later use during signing */
    g_software_key.flags = flags;
    g_software_key.counter = 1;
    strlcpy(g_software_key.application, application, sizeof(g_software_key.application));
    memcpy(g_software_key.public_key, resp->public_key, 32);
    memcpy(g_software_key.private_key, resp->key_handle, 64);
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
 * This is where we emulate the FIDO2 signing process
 */
int
sk_sign(uint32_t alg, const uint8_t *message, size_t message_len,
    const char *application, const uint8_t *key_handle, size_t key_handle_len,
    uint8_t flags, const char *pin, struct sk_option **options,
    struct sk_sign_response **sign_response)
{
    struct sk_sign_response *resp = NULL;
    unsigned char sig[64];
    unsigned long long siglen;
    int r = SSH_SK_ERR_GENERAL;

    if (alg != SSH_SK_ED25519) {
        debug_f("unsupported algorithm: %d (only ED25519 supported)", alg);
        return SSH_SK_ERR_UNSUPPORTED;
    }

    if (key_handle_len != 64) {
        debug_f("invalid key_handle_len: %zu (expected 64)", key_handle_len);
        return SSH_SK_ERR_GENERAL;
    }

    debug_f("Software FIDO2: signing with ED25519 key");
    debug_f("  application: %s", application);
    debug_f("  message_len: %zu", message_len);
    debug_f("  requested_flags: 0x%02x", flags);
    debug_f("  counter: %u", g_software_key.counter);

    /* Allocate response structure */
    if ((resp = calloc(1, sizeof(*resp))) == NULL) {
        debug_f("calloc failed");
        return SSH_SK_ERR_GENERAL;
    }

    /* Allocate signature buffer (64 bytes for ED25519) */
    if ((resp->sig_r = malloc(64)) == NULL) {
        debug_f("malloc sig_r failed");
        goto out;
    }

    /*
     * Sign the message using ED25519
     * The actual FIDO2 flow would be more complex, but we emulate it here
     */
    if (crypto_sign_ed25519(sig, &siglen, message, message_len,
        (unsigned char *)key_handle) != 0) {
        debug_f("crypto_sign_ed25519 failed");
        goto out;
    }

    /* Copy signature to response */
    if (siglen != 64) {
        debug_f("unexpected signature length: %llu (expected 64)", siglen);
        goto out;
    }
    memcpy(resp->sig_r, sig, 64);
    resp->sig_r_len = 64;

    /*
     * Set flags according to the request
     * In a real FIDO2 device, the authenticator would return flags indicating:
     * - Whether user presence was verified (touch)
     * - Whether user verification was performed (PIN/biometric)
     * - Whether this is a backup eligible credential
     * 
     * We simulate this based on what was requested during enrollment
     */
    resp->flags = g_software_key.flags & (SSH_SK_USER_PRESENCE_REQD | SSH_SK_USER_VERIFICATION_REQD);
    
    /* If the key was enrolled with specific flags, we return them */
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
    debug_f("  signature_len: %zu", resp->sig_r_len);
    debug_f("  counter: %u", resp->counter);
    debug_f("  response_flags: 0x%02x", resp->flags);

    *sign_response = resp;
    return 0;

out:
    if (resp != NULL) {
        free(resp->sig_r);
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
    return 0; /* Return success but with no keys */
}

#endif /* ENABLE_SK */