Wie wird PubkeyAuthOptions touch-required geprüft?
==================================================

I'll search for how the `touch-required` option in PubkeyAuthOptions is checked in the OpenSSH repository.Jetzt schaue ich mir die spezifische Stelle an, wo die Option geprüft wird:Jetzt hole ich mir noch die Details aus der auth2-pubkey.c Datei für eine vollständige Antwort:Basierend auf dem OpenSSH-Code wird `PubkeyAuthOptions touch-required` wie folgt geprüft:

## Zusammenfassung

Die `touch-required`-Option wird an **zwei Stellen** geprüft:

### 1. **Server-Konfiguration (sshd_config)** – in `servconf.c`
```c
case sPubkeyAuthOptions:
    intptr = &options->pubkey_auth_options;
    value = 0;
    while ((arg = argv_next(&ac, &av)) != NULL) {
        if (strcasecmp(arg, "touch-required") == 0)
            value |= PUBKEYAUTH_TOUCH_REQUIRED;
        // ...
    }
```

Die Option wird als **Bitflag** `PUBKEYAUTH_TOUCH_REQUIRED` gespeichert.

### 2. **Authentifizierungsprüfung** – in `auth2-pubkey.c` (Zeilen 235-248)

```c
req_presence = (options.pubkey_auth_options &
    PUBKEYAUTH_TOUCH_REQUIRED) ||
    !authopts->no_require_user_presence;

if (req_presence && (sig_details->sk_flags &
    SSH_SK_USER_PRESENCE_REQD) == 0) {
    error("public key %s signature for %s%s from "
        "%.128s port %d rejected: user presence "
        "(authenticator touch) requirement not met");
    authenticated = 0;
    goto done;
}
```

## Logik

1. **`req_presence`** wird gesetzt auf `true`, wenn:
   - Die Server-Konfiguration `touch-required` enthält (**OR**)
   - Die authorized_keys Optionen **nicht** `no-touch-required` enthalten

2. Falls `req_presence=true`, wird überprüft, ob das **Signatur-Flag** `SSH_SK_USER_PRESENCE_REQD` gesetzt ist
3. Wenn das Flag **nicht** gesetzt ist → **Authentifizierung abgelehnt** mit Error-Nachricht

Dies gilt nur für FIDO-Authentifikator-Algorithmen (`ecdsa-sk`, `ed25519-sk`).
