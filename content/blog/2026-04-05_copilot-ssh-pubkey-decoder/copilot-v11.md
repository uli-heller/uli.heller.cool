V11
===

Anfrage
-------

Wenn die sk_flags im PubKey nicht enthalten sind und in authorized_keys nur der PubKey steht,
wie kann der OpenSSH-Server dann prüfen ob verify-required erfüllt ist?

Antwort
-------

Das ist eine **ausgezeichnete Frage**! Sie haben einen wichtigen Punkt identifiziert.

Lassen Sie mich das klären:Ausgezeichnete Beobachtung! Sie haben die Antwort selbst gefunden - **die sk_flags sind NICHT in der Public-Key-Struktur in `authorized_keys` gespeichert**. Aber OpenSSH kann sie trotzdem prüfen! Wie?

## Die Antwort: FIDO Signature Details

Schauen Sie sich die kritischen Zeilen in `auth2-pubkey.c` (Zeilen 230-264) an:

```c
if (authenticated == 1 && sig_details != NULL) {
    auth2_record_info(authctxt, "signature count = %u",
        sig_details->sk_counter);
    debug_f("sk_counter = %u, sk_flags = 0x%02x",
        sig_details->sk_counter, sig_details->sk_flags);
    
    req_presence = (options.pubkey_auth_options &
        PUBKEYAUTH_TOUCH_REQUIRED) ||
        !authopts->no_require_user_presence;
    
    if (req_presence && (sig_details->sk_flags &
        SSH_SK_USER_PRESENCE_REQD) == 0) {
        error("public key %s signature for %s%s from "
            "%.128s port %d rejected: user presence "
            "(authenticator touch) requirement "
            "not met", ...);
        authenticated = 0;
    }
    
    req_verify = (options.pubkey_auth_options &
        PUBKEYAUTH_VERIFY_REQUIRED) ||
        authopts->require_verify;
    
    if (req_verify && (sig_details->sk_flags &
        SSH_SK_USER_VERIFICATION_REQD) == 0) {
        error("public key %s signature for %s%s from "
            "%.128s port %d rejected: user "
            "verification requirement not met", ...);
        authenticated = 0;
    }
}
```

## Der Mechanismus:

### **1. sk_flags kommen aus der SIGNATUR, nicht aus dem Key!**

Die `sig_details->sk_flags` werden nicht aus dem Public-Key gelesen, sondern aus den **FIDO/WebAuthn-Signature-Details**, die der Authenticator **bei der Unterzeichnung** liefert.

```c
struct sshkey_sig_details {
    uint32_t sk_counter;    /* U2F signature counter */
    uint8_t sk_flags;       /* U2F signature flags (vom Authenticator!) */
};
```

### **2. Ablauf bei der Authentifizierung:**

```
1. Client sendet Public-Key
   └─ Public-Key in authorized_keys wird geprüft
   └─ KEINE sk_flags im Public-Key

2. Client sendet SIGNATUR (mit FIDO-Daten)
   └─ mm_sshkey_verify() wird aufgerufen
   └─ FIDO-SDK extrahiert sk_flags aus der Signatur
   └─ Diese werden in sig_details->sk_flags gespeichert

3. Server prüft sk_flags aus der Signatur:
   ├─ Wenn require_verify=true in authorized_keys ODER
   │  PUBKEYAUTH_VERIFY_REQUIRED in sshd_config
   │  → DANN muss sig_details->sk_flags & SSH_SK_USER_VERIFICATION_REQD
   │
   └─ Wenn no_require_user_presence=false UND
      PUBKEYAUTH_TOUCH_REQUIRED
      → DANN muss sig_details->sk_flags & SSH_SK_USER_PRESENCE_REQD
```

### **3. Wo kommen die Signature-Flags her?**

Die `sk_flags` in der Signatur stammen vom **FIDO-Authenticator selbst** bei jeder Signatur! Der Authenticator gibt an:
- "Hat der Benutzer tatsächlich den Key berührt?"
- "Hat der Benutzer tatsächlich das Passwort/Biometrie eingegeben?"

## **Der Schlüssel: `authorized_keys` Optionen**

In der `authorized_keys` kann man folgende Optionen setzen:

```bash
# require-user-verification=yes|no|force
# no-user-presence-check (auch: no-require-user-presence)

sk-ssh-ed25519@openssh.com AAAA... require-user-verification=yes
sk-ssh-ed25519@openssh.com AAAA... no-require-user-presence
```

Diese Optionen werden in `authopts` gespeichert:

```c
req_verify = (options.pubkey_auth_options &
    PUBKEYAUTH_VERIFY_REQUIRED) ||
    authopts->require_verify;  // ← Aus authorized_keys

if (req_presence && (sig_details->sk_flags &
    SSH_SK_USER_PRESENCE_REQD) == 0) {
    // Abstoßen!
}
```

## **Zusammenfassung:**

Die sk_flags **im Public-Key** sind nicht notwendig, weil:

1. **Der Public-Key** dient nur zur Schlüsselidentifikation
2. **Die FIDO-Signatur** enthält die aktuellen sk_flags vom Authenticator
3. **Der Server prüft** bei jeder Anmeldung die Signature-Flags gegen die Anforderungen in `authorized_keys` oder `sshd_config`

Das ist eigentlich **eleganter**: Die Anforderungen werden nicht mit dem Public-Key gespeichert, sondern flexibel pro Schlüssel in `authorized_keys` konfiguriert oder global in `sshd_config`. Der Authenticator liefert die aktuellen Flags mit jeder Signatur.
