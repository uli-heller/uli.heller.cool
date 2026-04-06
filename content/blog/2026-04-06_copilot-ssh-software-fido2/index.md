+++
date = '2026-04-06'
draft = false
title = 'Praxistests mit Copilot - SSH Software FIDO'
categories = [ 'KI' ]
tags = [ 'copilot' ]
+++

<!--
Praxistests mit Copilot - SSH Software FIDO
===========================================
-->

Dieser Artikel ist direkte Folge von meinen
ersten Tests gestern - [Praxistests mit Copilot - ssh-pubkey-decoder]({{< ref "blog/2026-04-05_copilot-ssh-pubkey-decoder" >}}).
Gestern wollte ich SSH-PubKeys auswerten und rausfinden, ob bei deren Verwendung
Dinge wie

- Knopfdruck ("user presence")
- PIN ("user verification")

angefordert werden. Es hat sich herausgestellt, dass diese Informationen im
PubKey nicht enthalten sind sondern via FIDO-Signatur beim Anmelden geprüft werden.

Idee: Wenn die Informationen via FIDO-Signatur an den Server übermittelt
werden, dann sollte es durch Modifikation des SSH-Clients möglich sein,
dem Server falsche FIDO-Parameter "vorzugaukeln".

Ich setze hierfür an der Stelle auf, an der ich gestern abgebrochen habe!
Also:

- Copilot im Browser, Copilot Free, Claude Haiku 4.5
- Github-Projekt: openssh-portable

<!--more-->

Ausgangspunkt: Erkenntnisse über FIDO-Signatur
----------------------------------------------

**Anfrage**:
Wenn die sk_flags im PubKey nicht enthalten sind und in authorized_keys nur der PubKey steht,
wie kann der OpenSSH-Server dann prüfen ob verify-required erfüllt ist?

[copilot-v11.md](copilot-v11.md)

Prüfung erfolgt via FIDO-Signatur.

Erster Test: FIDO-Signatur in Software
--------------------------------------

**Anfrage**:
Ändere die Implementierung vom SSH-Client für sk-ssh-ed25519@openssh.com so ab, dass:

- Kein Fido2-Key benötigt wird
- Die Handhabung der FIDO-Signatur in Software emuliert wird

[copilot-v12.md](copilot-v12.md), [v12](v12)

Zweiter Test: Beide SK-Varianten
--------------------------------

**Anfrage**:
Erweitere diese Lösung um sk-ecdsa-sha2-nistp256@openssh.com

[copilot-v13.md](copilot-v13.md), [v13](v13)

Leider funktioniert das Build-Skript nicht - Fehlermeldungen:

```
ssh-sk-software-extended.c:8:10: fatal error: includes.h: Datei oder Verzeichnis nicht gefunden
    8 | #include "includes.h"
      |          ^~~~~~~~~~~~
compilation terminated.
cc1: fatal error: ./crypto_api.c: Datei oder Verzeichnis nicht gefunden
compilation terminated.
```

Bitte korrigieren!


Versionen
---------

- Getestet unter Ubuntu-24.04 mit Online-Copilot und Claude Haiku 4.5

Links
-----

- [GitHub](https://github.com)
- [OpenSSH-Projekt](https://github.com/openssh/openssh-portable)

Historie
--------

- 2026-04-06: Erste Version
