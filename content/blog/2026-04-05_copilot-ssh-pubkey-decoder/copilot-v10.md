V10
===

Anfrage
-------

Wie wird der pubkey von openssh gelesen und geparst?

Antwort
-------

## Wie OpenSSH einen Public-Key liest und parst

OpenSSH nutzt eine klare Architektur zum Lesen und Parsen von Public-Keys:

### **1. Entry Points - `sshkey_read()` (Zeile 1300)**

Dies ist die Hauptfunktion zum Lesen von Public-Keys aus Textformat (z.B. `authorized_keys`):

```c
int sshkey_read(struct sshkey *ret, char **cpp)
```

**Ablauf:**
1. **Type dekodieren** → `peek_type_nid()` liest "sk-ssh-ed25519@openssh.com"
2. **Base64 dekodieren** → `sshbuf_b64tod()` dekodiert die Base64-Daten
3. **Key parsen** → `sshkey_fromb()` parst die binären Daten

### **2. Binary-Parsing - `sshkey_from_blob_internal()` (Zeile 1991)**

Dies ist der **Kern-Parser** für binäre Key-Daten:

```c
static int sshkey_from_blob_internal(struct sshbuf *b, 
    struct sshkey **keyp, int allow_cert)
```

**Schritte:**
```c
// 1. Key-Type lesen
sshbuf_get_cstring(b, &ktype, NULL)  // "sk-ssh-ed25519@openssh.com"

// 2. Key-Type in enum umwandeln
type = sshkey_type_from_name(ktype)  // → KEY_ED25519_SK

// 3. Richtige Implementierung laden
impl = sshkey_impl_from_type(type)   // → ssh_ed25519_sk_impl

// 4. Typ-spezifischen Parser aufrufen
impl->funcs->deserialize_public(ktype, b, key)
```

### **3. SK-spezifisches Parsing - `sshkey_deserialize_sk()` (Zeile 1982)**

Für FIDO-Keys wird dies aufgerufen:

```c
int sshkey_deserialize_sk(struct sshbuf *b, struct sshkey *key)
{
    /* Parse additional security-key application string */
    if (sshbuf_get_cstring(b, &key->sk_application, NULL) != 0)
        return SSH_ERR_INVALID_FORMAT;
    return 0;
}
```

### **4. Kompletter Ablauf für SK-Keys**

Die komplette Public-Key-Struktur wird wie folgt geparst:

```
Binary Blob:
├─ Key-Type String    (length-prefixed) → "sk-ssh-ed25519@openssh.com"
├─ Public Key Data    (length-prefixed) → 32 bytes ED25519 pubkey
└─ SK-Application     (length-prefixed) → "ssh:"
```

**Aber:** Basierend auf den `sshkey_serialize_sk()` und `sshkey_deserialize_sk()` Funktionen, 

**der sk_flags werden NICHT in der Public-Key Struktur gespeichert** - sie sind nur in der **privaten Key-Datei** vorhanden!

### **5. Wo sk_flags wirklich sind**

Die sk_flags befinden sich nur in **privaten Schlüsseln**, wie in `sshkey_serialize_private_sk()` (Zeile 2522) gezeigt:

```c
int sshkey_serialize_private_sk(const struct sshkey *key, struct sshbuf *b)
{
    if ((r = sshbuf_put_cstring(b, key->sk_application)) != 0 ||
        (r = sshbuf_put_u8(b, key->sk_flags)) != 0 ||      // ← sk_flags hier!
        (r = sshbuf_put_stringb(b, key->sk_key_handle)) != 0 ||
        (r = sshbuf_put_stringb(b, key->sk_reserved)) != 0)
        return r;
    return 0;
}
```

**Fazit:** Die sk_flags sind in einem Public-Key NICHT enthalten. Sie sind nur in der **privaten Key-Datei** gespeichert. Der Public-Key im OpenSSH-Format (z.B. `id_ed25519_sk.pub`) enthält nur:
- Key-Type
- Public-Key-Material  
- sk_application
