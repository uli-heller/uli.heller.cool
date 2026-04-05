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

/* Minimal structures for key parsing */
struct ssh_key {
    int type;
    uint8_t sk_flags;
};

/* Simple base64 decode (for reading key format) */
static const char b64_table[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/* Read a uint32 from buffer in network byte order */
static uint32_t read_uint32(const uint8_t *buf, size_t buflen, size_t *offset)
{
    if (*offset + 4 > buflen) {
        return 0;
    }
    uint32_t val = ((uint32_t)buf[*offset] << 24) |
                   ((uint32_t)buf[*offset+1] << 16) |
                   ((uint32_t)buf[*offset+2] << 8) |
                   ((uint32_t)buf[*offset+3]);
    *offset += 4;
    return val;
}

/* Read a string from buffer (uint32 length + data) */
static int read_string(const uint8_t *buf, size_t buflen, 
                       size_t *offset, uint8_t *out, size_t outlen)
{
    uint32_t len;
    if (*offset + 4 > buflen) {
        return -1;
    }
    
    len = read_uint32(buf, buflen, offset);
    
    if (len > outlen || *offset + len > buflen) {
        return -1;
    }
    
    memcpy(out, buf + *offset, len);
    *offset += len;
    return len;
}

/* Read a byte from buffer */
static uint8_t read_byte(const uint8_t *buf, size_t buflen, size_t *offset)
{
    if (*offset >= buflen) {
        return 0;
    }
    return buf[(*offset)++];
}

/* Parse OpenSSH public key format for SK keys */
static int parse_public_key(const uint8_t *keydata, size_t keylen, 
                            struct ssh_key *key)
{
    size_t offset = 0;
    uint8_t keytype_buf[256];
    uint32_t len;
    
    printf("=== Parsing SSH SK Key Structure ===\n");
    printf("Total data length: %zu bytes\n\n", keylen);
    
    /* Read key type string */
    printf("Step 1: Reading key type string...\n");
    if (read_string(keydata, keylen, &offset, keytype_buf, sizeof(keytype_buf)) <= 0) {
        fprintf(stderr, "Error: Could not read key type string\n");
        return -1;
    }
    printf("  Key Type: %s\n", (char*)keytype_buf);
    printf("  Offset after key type: %zu\n\n", offset);
    
    /* Check if this is a FIDO key */
    int is_sk = (strstr((char*)keytype_buf, "sk-") != NULL);
    
    if (!is_sk) {
        fprintf(stderr, "Error: Key is not a FIDO security key (not sk-* type)\n");
        return -1;
    }
    
    printf("  ✓ This is a FIDO security key\n\n");
    
    /* Step 2: Read public key blob */
    printf("Step 2: Reading public key blob...\n");
    if (offset + 4 > keylen) {
        fprintf(stderr, "Error: Not enough data for public key blob length\n");
        return -1;
    }
    len = read_uint32(keydata, keylen, &offset);
    printf("  Public key blob length: %u bytes\n", len);
    printf("  Offset before blob: %zu\n", offset);
    
    if (offset + len > keylen) {
        fprintf(stderr, "Error: Public key blob exceeds buffer\n");
        return -1;
    }
    
    /* For ED25519-SK, the public key blob is the raw 32-byte public key */
    printf("  Skipping %u bytes of public key data\n", len);
    offset += len; /* Skip public key blob */
    printf("  Offset after blob: %zu\n\n", offset);
    
    /* Step 3: Read key_handle */
    printf("Step 3: Reading key handle (variable length)...\n");
    if (offset + 4 > keylen) {
        fprintf(stderr, "Error: Not enough data for key handle length\n");
        return -1;
    }
    len = read_uint32(keydata, keylen, &offset);
    printf("  Key handle length: %u bytes\n", len);
    printf("  Offset before key handle: %zu\n", offset);
    
    if (offset + len > keylen) {
        fprintf(stderr, "Error: Key handle exceeds buffer\n");
        return -1;
    }
    
    printf("  Key handle data (hex): ");
    for (uint32_t i = 0; i < len && i < 16; i++) {
        printf("%02x ", keydata[offset + i]);
    }
    if (len > 16) printf("...");
    printf("\n");
    
    offset += len; /* Skip key_handle */
    printf("  Offset after key handle: %zu\n", offset);
    printf("  Remaining bytes: %zu\n\n", keylen - offset);
    
    /* Step 4: Try to read sk_flags - it should be the next byte */
    printf("Step 4: Reading sk_flags...\n");
    printf("  Current offset: %zu, keylen: %zu\n", offset, keylen);
    printf("  Remaining bytes: %zu\n", keylen - offset);
    
    /* Print hex dump of remaining data */
    if (offset < keylen) {
        printf("  Remaining data (hex): ");
        for (size_t i = offset; i < keylen && i < offset + 20; i++) {
            printf("%02x ", keydata[i]);
        }
        printf("\n");
    }
    
    if (offset >= keylen) {
        fprintf(stderr, "Error: No data left for sk_flags\n");
        fprintf(stderr, "  This might indicate the key format is different than expected\n");
        fprintf(stderr, "  Expected at least 1 byte remaining, found 0\n");
        return -1;
    }
    
    key->sk_flags = read_byte(keydata, keylen, &offset);
    printf("  sk_flags read: 0x%02x\n", key->sk_flags);
    printf("  Offset after sk_flags: %zu\n\n", offset);
    
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
    
    /* Skip the key type prefix */
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
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <public_key_file_or_key_string>\n", argv[0]);
        fprintf(stderr, "Example: %s ~/.ssh/id_ed25519_sk.pub\n", argv[0]);
        fprintf(stderr, "Or:      %s \"sk-ssh-ed25519@openssh.com AAAAGnNr...\"\n", argv[0]);
        return 1;
    }
    
    uint8_t keydata[4096];
    size_t keylen;
    struct ssh_key key = {0};
    
    /* Check if argument is a string key or a file */
    FILE *test = fopen(argv[1], "r");
    int is_file = (test != NULL);
    if (test) fclose(test);
    
    if (is_file) {
        /* Read from file */
        if (read_openssh_pubkey_file(argv[1], keydata, &keylen) != 0) {
            return 1;
        }
    } else {
        /* Parse from command line argument directly */
        printf("Parsing key from command line argument\n\n");
        
        /* Find the base64 part (between first and second space) */
        char *space = strchr(argv[1], ' ');
        if (!space) {
            fprintf(stderr, "Error: Invalid key format (no space found)\n");
            return 1;
        }
        
        char *b64_start = space + 1;
        char *b64_end = strchr(b64_start, ' ');
        if (!b64_end) b64_end = b64_start + strlen(b64_start);
        
        size_t b64_len = b64_end - b64_start;
        char *b64_str = malloc(b64_len + 1);
        if (!b64_str) return 1;
        
        memcpy(b64_str, b64_start, b64_len);
        b64_str[b64_len] = '\0';
        
        printf("Base64 length: %zu characters\n\n", b64_len);
        
        /* Decode base64 */
        keylen = base64_decode(b64_str, keydata, 4096);
        free(b64_str);
        
        if (keylen == 0) {
            fprintf(stderr, "Error: Could not decode base64 key data\n");
            return 1;
        }
    }
    
    /* Parse the key data */
    if (parse_public_key(keydata, keylen, &key) != 0) {
        return 1;
    }
    
    printf("=== SK Flags Decoded ===\n");
    printf("Raw value: 0x%02x\n\n", key.sk_flags);
    
    printf("Flag Details:\n");
    printf("  0x01 (SSH_SK_USER_PRESENCE_REQD):     %s\n",
           (key.sk_flags & SSH_SK_USER_PRESENCE_REQD) ? "YES ✓" : "NO");
    printf("  0x04 (SSH_SK_USER_VERIFICATION_REQD): %s\n",
           (key.sk_flags & SSH_SK_USER_VERIFICATION_REQD) ? "YES ✓" : "NO");
    printf("  0x10 (SSH_SK_FORCE_OPERATION):        %s\n",
           (key.sk_flags & SSH_SK_FORCE_OPERATION) ? "YES ✓" : "NO");
    printf("  0x20 (SSH_SK_RESIDENT_KEY):           %s\n",
           (key.sk_flags & SSH_SK_RESIDENT_KEY) ? "YES ✓" : "NO");
    
    printf("\n=== Summary ===\n");
    if (key.sk_flags & SSH_SK_USER_PRESENCE_REQD) {
        printf("✓ User presence (touch) is REQUIRED\n");
    } else {
        printf("✗ User presence (touch) is NOT required\n");
    }
    
    if (key.sk_flags & SSH_SK_USER_VERIFICATION_REQD) {
        printf("✓ User verification (PIN/biometric) is REQUIRED\n");
    } else {
        printf("✗ User verification (PIN/biometric) is NOT required\n");
    }
    
    if (key.sk_flags & SSH_SK_RESIDENT_KEY) {
        printf("✓ This is a RESIDENT key (stored on the authenticator)\n");
    } else {
        printf("✗ This is NOT a resident key\n");
    }
    
    return 0;
}
