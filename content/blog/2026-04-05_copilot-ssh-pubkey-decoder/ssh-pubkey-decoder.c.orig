#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>

/* SK flag definitions from sk-api.h */
#define SSH_SK_USER_PRESENCE_REQD       0x01
#define SSH_SK_USER_VERIFICATION_REQD   0x04
#define SSH_SK_FORCE_OPERATION          0x10
#define SSH_SK_RESIDENT_KEY             0x20

/* SSH key type constants */
#define KEY_ECDSA_SK    -13
#define KEY_ED25519_SK  -14

/* Minimal structures for key parsing */
struct ssh_key {
    int type;
    uint8_t sk_flags;
};

/* Simple base64 decode (for reading key format) */
static const char b64_table[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/* Read a uint32 from buffer in network byte order */
static uint32_t read_uint32(const uint8_t *buf, size_t *offset)
{
    if (*offset + 4 > 1024) return 0;
    uint32_t val = (buf[*offset] << 24) |
                   (buf[*offset+1] << 16) |
                   (buf[*offset+2] << 8) |
                   buf[*offset+3];
    *offset += 4;
    return val;
}

/* Read a string from buffer (uint32 length + data) */
static int read_string(const uint8_t *buf, size_t buflen, 
                       size_t *offset, char *out, size_t outlen)
{
    uint32_t len;
    if (*offset + 4 > buflen) return -1;
    
    len = read_uint32(buf, offset);
    if (len > 1024 || *offset + len > buflen) return -1;
    if (len >= outlen) return -1;
    
    memcpy(out, buf + *offset, len);
    out[len] = '\0';
    *offset += len;
    return len;
}

/* Read a byte from buffer */
static uint8_t read_byte(const uint8_t *buf, size_t buflen, size_t *offset)
{
    if (*offset >= buflen) return 0;
    return buf[(*offset)++];
}

/* Parse OpenSSH public key format */
static int parse_public_key(const uint8_t *keydata, size_t keylen, 
                            struct ssh_key *key)
{
    size_t offset = 0;
    char keytype[256];
    char pubkey_type[256];
    uint32_t len;
    int i;
    
    /* Read key type string */
    if (read_string(keydata, keylen, &offset, keytype, sizeof(keytype)) <= 0) {
        return -1;
    }
    
    /* Check if this is a FIDO key */
    int is_sk = (strstr(keytype, "-sk") != NULL);
    
    if (!is_sk) {
        fprintf(stderr, "Error: Key is not a FIDO security key (not *-sk type)\n");
        return -1;
    }
    
    /* For SK keys, skip the public key part and read sk_flags and key_handle */
    /* Read public key blob length and skip it */
    if (offset + 4 > keylen) return -1;
    len = read_uint32(keydata, &offset);
    if (offset + len > keylen) return -1;
    offset += len; /* Skip public key blob */
    
    /* Read key_handle length and skip it */
    if (offset + 4 > keylen) return -1;
    len = read_uint32(keydata, &offset);
    if (offset + len > keylen) return -1;
    offset += len; /* Skip key_handle */
    
    /* Read sk_flags */
    if (offset >= keylen) {
        fprintf(stderr, "Error: Could not read sk_flags from key\n");
        return -1;
    }
    key->sk_flags = read_byte(keydata, keylen, &offset);
    
    return 0;
}

/* Decode base64 string to binary */
static size_t base64_decode(const char *b64, uint8_t *out, size_t outlen)
{
    size_t outpos = 0;
    uint32_t buf = 0;
    int bits = 0;
    
    while (*b64 && outpos < outlen) {
        char c = *b64++;
        const char *p = strchr(b64_table, c);
        
        if (!p && c != '=') continue;
        
        if (c == '=') break;
        
        buf = (buf << 6) | (p - b64_table);
        bits += 6;
        
        if (bits >= 8) {
            bits -= 8;
            out[outpos++] = (buf >> bits) & 0xff;
        }
    }
    
    return outpos;
}

/* Read and decode OpenSSH format public key file */
static int read_openssh_pubkey_file(const char *filename, uint8_t *keydata, 
                                     size_t *keylen)
{
    FILE *f = fopen(filename, "r");
    if (!f) {
        perror("fopen");
        return -1;
    }
    
    char line[4096];
    if (!fgets(line, sizeof(line), f)) {
        fprintf(stderr, "Error: Could not read key file\n");
        fclose(f);
        return -1;
    }
    fclose(f);
    
    /* Skip "ssh-ecdsa-sk" or "ssh-ed25519-sk" prefix */
    char *space = strchr(line, ' ');
    if (!space) {
        fprintf(stderr, "Error: Invalid key format\n");
        return -1;
    }
    
    /* Find the base64 part (between first and second space) */
    char *b64_start = space + 1;
    char *b64_end = strchr(b64_start, ' ');
    if (!b64_end) b64_end = strchr(b64_start, '\n');
    if (!b64_end) b64_end = b64_start + strlen(b64_start);
    
    size_t b64_len = b64_end - b64_start;
    char *b64_str = malloc(b64_len + 1);
    if (!b64_str) return -1;
    
    memcpy(b64_str, b64_start, b64_len);
    b64_str[b64_len] = '\0';
    
    /* Decode base64 */
    *keylen = base64_decode(b64_str, keydata, 4096);
    free(b64_str);
    
    if (*keylen == 0) {
        fprintf(stderr, "Error: Could not decode base64 key data\n");
        return -1;
    }
    
    return 0;
}

/* Main program */
int main(int argc, char *argv[])
{
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <public_key_file>\n", argv[0]);
        fprintf(stderr, "Example: %s ~/.ssh/id_ed25519_sk.pub\n", argv[0]);
        return 1;
    }
    
    uint8_t keydata[4096];
    size_t keylen;
    struct ssh_key key = {0};
    
    /* Read and parse the public key file */
    if (read_openssh_pubkey_file(argv[1], keydata, &keylen) != 0) {
        return 1;
    }
    
    /* Parse the key data */
    if (parse_public_key(keydata, keylen, &key) != 0) {
        return 1;
    }
    
    /* Decode and display sk_flags */
    printf("SK Flags (0x%02x):\n", key.sk_flags);
    printf("  0x01 (SSH_SK_USER_PRESENCE_REQD):     %s\n",
           (key.sk_flags & SSH_SK_USER_PRESENCE_REQD) ? "YES" : "NO");
    printf("  0x04 (SSH_SK_USER_VERIFICATION_REQD): %s\n",
           (key.sk_flags & SSH_SK_USER_VERIFICATION_REQD) ? "YES" : "NO");
    printf("  0x10 (SSH_SK_FORCE_OPERATION):        %s\n",
           (key.sk_flags & SSH_SK_FORCE_OPERATION) ? "YES" : "NO");
    printf("  0x20 (SSH_SK_RESIDENT_KEY):           %s\n",
           (key.sk_flags & SSH_SK_RESIDENT_KEY) ? "YES" : "NO");
    
    /* Print summary */
    printf("\nSummary:\n");
    if (key.sk_flags & SSH_SK_USER_PRESENCE_REQD) {
        printf("  ✓ User presence (touch) is REQUIRED\n");
    } else {
        printf("  ✗ User presence (touch) is NOT required\n");
    }
    
    if (key.sk_flags & SSH_SK_USER_VERIFICATION_REQD) {
        printf("  ✓ User verification (PIN/biometric) is REQUIRED\n");
    } else {
        printf("  ✗ User verification (PIN/biometric) is NOT required\n");
    }
    
    if (key.sk_flags & SSH_SK_RESIDENT_KEY) {
        printf("  ✓ This is a RESIDENT key (stored on the authenticator)\n");
    } else {
        printf("  ✗ This is NOT a resident key\n");
    }
    
    return 0;
}
