# Software FIDO2 Security Key Provider - ED25519 & ECDSA-P256

Erweiterte Software-Emulation für OpenSSH SK-Keys, die sowohl **ED25519-SK** als auch **ECDSA-P256-SK** unterstützt.

## Features

### ED25519-SK (sk-ssh-ed25519@openssh.com)
- ✅ Key-Generierung in Software
- ✅ Schnelle ED25519-Signaturen
- ✅ sk_flags-Simulation
- ✅ Counter-Verwaltung

### ECDSA-P256-SK (sk-ecdsa-sha2-nistp256@openssh.com)
- ✅ P256 (NIST) Elliptische Kurven
- ✅ ECDSA-Signaturen (SHA-256)
- ✅ OpenSSL-Integration
- ✅ SEC1 Public Key Format
- ✅ DER Private Key Storage
- ✅ sk_flags-Simulation
- ✅ Counter-Verwaltung

### Nicht unterstützt
- ❌ Resident Keys
- ❌ WebAuthn (attestation)
- ❌ ECDSA-SK Certificates (cert-v01)

## Installation & Verwendung

### 1. Kompilieren

```bash
./build-software-sk-extended.sh /path/to/openssh-portable