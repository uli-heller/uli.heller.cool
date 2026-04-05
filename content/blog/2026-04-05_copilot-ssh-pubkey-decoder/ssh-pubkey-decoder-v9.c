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

/* Simple base64 decode (for reading key format) */
static const char b64_table[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/* Read a uint32 from buffer in network byte order */
static uint32_t read_uint32(const uint8_t *buf, size_t offset)
{
    uint32_t val = ((uint32_t)buf[offset] << 24) |
                   ((uint32_t)buf[offset+1] << 16) |
                   ((uint32_t)buf[offset+2] << 8) |
                   ((uint32_t)buf[offset+3]);
    return val;
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
    
    char *space = strchr(line, ' ');
    if (!space) {
        fprintf(stderr, "Error: Invalid key format\n");
        return -1;
    }
    
    char *b64_start = space + 1;
    char *b64_end = strchr(b64_start, ' ');
    if (!b64_end) b64_end = strchr(b64_start, '\n');
    if (!b64_end) b64_end = b64_start + strlen(b64_start);
    
    size_t b64_len = b64_end - b64_start;
    char *b64_str = malloc(b64_len + 1);
    if (!b64_str) return -1;
    
    memcpy(b64_str, b64_start, b64_len);
    b64_str[b64_len] = '\0';
    
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
    size_t offset = 0;
    uint32_t len;
    
    /* Check if argument is a string key or a file */
    FILE *test = fopen(argv[1], "r");
    int is_file = (test != NULL);
    if (test) fclose(test);
    
    if (is_file) {
        if (read_openssh_pubkey_file(argv[1], keydata, &keylen) != 0) {
            return 1;
        }
    } else {
        printf("Parsing key from command line argument\n\n");
        
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
        
        keylen = base64_decode(b64_str, keydata, 4096);
        free(b64_str);
        
        if (keylen == 0) {
            fprintf(stderr, "Error: Could not decode base64 key data\n");
            return 1;
        }
    }
    
    printf("=== SSH SK Key Structure Parsing ===\n");
    printf("Total decoded size: %zu bytes\n\n", keylen);
    
    /* Step 1: Read key type string */
    printf("Step 1: Key type string\n");
    printf("  Offset %zu: length = %u\n", offset, read_uint32(keydata, offset));
    len = read_uint32(keydata, offset);
    offset += 4;
    printf("  Offset %zu-%zu: \"%.*s\"\n", offset, offset + len - 1, len, keydata + offset);
    offset += len;
    
    /* Step 2: Read public key blob */
    printf("\nStep 2: Public key blob\n");
    printf("  Offset %zu: length = %u\n", offset, read_uint32(keydata, offset));
    len = read_uint32(keydata, offset);
    offset += 4;
    printf("  Offset %zu-%zu: (%u bytes)\n", offset, offset + len - 1, len);
    offset += len;
    
    /* Step 3: Read sk_application string */
    printf("\nStep 3: SK application string\n");
    printf("  Offset %zu: length = %u\n", offset, read_uint32(keydata, offset));
    len = read_uint32(keydata, offset);
    offset += 4;
    printf("  Offset %zu-%zu: \"%.*s\"\n", offset, offset + len - 1, len, keydata + offset);
    offset += len;
    
    /* Step 4: Read sk_flags (SINGLE BYTE!) */
    printf("\nStep 4: SK FLAGS (1 BYTE)\n");
    printf("  Offset %zu: 0x%02x\n", offset, keydata[offset]);
    uint8_t sk_flags = keydata[offset];
    offset += 1;
    
    /* Step 5: Read key_handle blob */
    printf("\nStep 5: Key handle blob\n");
    printf("  Offset %zu: length = %u\n", offset, read_uint32(keydata, offset));
    len = read_uint32(keydata, offset);
    offset += 4;
    printf("  Offset %zu-%zu: (%u bytes opaque data)\n", offset, offset + len - 1, len);
    offset += len;
    
    /* Step 6: Read sk_reserved blob (if present) */
    if (offset < keylen) {
        printf("\nStep 6: SK reserved blob\n");
        printf("  Offset %zu: length = %u\n", offset, read_uint32(keydata, offset));
        len = read_uint32(keydata, offset);
        offset += 4;
        printf("  Offset %zu-%zu: (%u bytes opaque data)\n", offset, offset + len - 1, len);
        offset += len;
    }
    
    printf("\n=== SK Flags Decoded ===\n");
    printf("Raw value: 0x%02x (%u in decimal)\n\n", sk_flags, sk_flags);
    
    printf("Flag Details:\n");
    printf("  0x01 (SSH_SK_USER_PRESENCE_REQD):     %s\n",
           (sk_flags & SSH_SK_USER_PRESENCE_REQD) ? "YES ✓" : "NO");
    printf("  0x04 (SSH_SK_USER_VERIFICATION_REQD): %s\n",
           (sk_flags & SSH_SK_USER_VERIFICATION_REQD) ? "YES ✓" : "NO");
    printf("  0x10 (SSH_SK_FORCE_OPERATION):        %s\n",
           (sk_flags & SSH_SK_FORCE_OPERATION) ? "YES ✓" : "NO");
    printf("  0x20 (SSH_SK_RESIDENT_KEY):           %s\n",
           (sk_flags & SSH_SK_RESIDENT_KEY) ? "YES ✓" : "NO");
    
    printf("\n=== Summary ===\n");
    if (sk_flags & SSH_SK_USER_PRESENCE_REQD) {
        printf("✓ User presence (touch) is REQUIRED\n");
    } else {
        printf("✗ User presence (touch) is NOT required\n");
    }
    
    if (sk_flags & SSH_SK_USER_VERIFICATION_REQD) {
        printf("✓ User verification (PIN/biometric) is REQUIRED\n");
    } else {
        printf("✗ User verification (PIN/biometric) is NOT required\n*

