# Software FIDO2 Security Key Provider für OpenSSH

Diese Implementierung emuliert einen FIDO2-Authenticator vollständig in Software, ohne dass echter Hardware benötigt wird.

## Features

- ✅ ED25519-SK Key-Generierung
- ✅ Software-basierte Signatur
- ✅ Simulation von sk_flags (USER_PRESENCE_REQD, USER_VERIFICATION_REQD)
- ✅ Signatur-Counter (verhindert Replay-Attacks)
- ✅ Vollständig OpenSSH-kompatibel
- ❌ ECDSA-SK nicht unterstützt (nur ED25519)
- ❌ Resident Keys nicht unterstützt

## Verwendung

### 1. Key generieren (mit echter Hardware oder Software-Provider)

```bash
ssh-keygen -t ed25519-sk -f ~/.ssh/id_ed25519_sk -N ""