+++
date = '2026-09-24'
draft = false
title = 'Git: Mehrere Fido2-Token hinterlegen mit automatischer Umschaltung'
categories = [ 'Git' ]
tags = [ 'git', 'ssh' ]
+++

<!--Git: Mehrere Fido2-Token hinterlegen mit automatischer Umschaltung-->
<!--==================================================================-->

Ich habe 2 Fido2-Token und jeweils einen SSH-Schlüssel damit erzeugt.
Mit den SSH-Schlüsseln greife ich auf Server zu, bspw. mit GIT oder
auch direkt mit SSH.

Hier beschreibe ich, wie ich meinen Arbeitsplatz so konfiguriere,
dass automatisch der SSH-Schlüssel verwendet wird, dessen Fido2-Token
eingesteckt ist.

<!--more-->

Vorbereitungen
--------------

Ich habe auf meinem Arbeitsplatz diese SSH-Schlüssel erzeugt und
in $HOME/.ssh abgelegt:

- uli.heller-yubikey_notouch und zugehörige .pub-Datei
- uli.heller-solokey_notouch und zugehörige .pub-Datei

Die .pub-Dateien habe ich in den "authorized_keys"-Dateien
meiner Server und auch auf dem GIT-Server hinterlegt.

Vorabtests
----------

Die nachfolgend beschriebenen Vorabtests
müssen alle klappen, sonst stimmt was mit den
Freischaltungen nicht! Bei den Tests müssen
die Fido2-Token eingesteckt sein!

### SSH

```
$ ssh -i ~/.ssh/uli.heller-yubikey_notouch -o IdentitiesOnly=true -o IdentityAgent=false -o PasswordAuthentication=false backup.heller.cool
  # Klappt - "backup.heller.cool" ist der Name meines Servers
$ ssh -i ~/.ssh/uli.heller-solokey_notouch -o IdentitiesOnly=true -o IdentityAgent=false -o PasswordAuthentication=false backup.heller.cool
  # Klappt - "backup.heller.cool" ist der Name meines Servers
```

### GIT

Nachfolgende Kommandos in einem Git-Repo-Verzeichnis ausführen!

```
$ git remote -v
origin	forgejo@forgejo.heller.cool:uli-heller/uli.heller.cool.git (fetch)
origin	forgejo@forgejo.heller.cool:uli-heller/uli.heller.cool.git (push)

$ GIT_SSH_COMMAND='ssh -v -i ~/.ssh/uli.heller-yubikey_notouch -o IdentitiesOnly=true -o IdentityAgent=false -o PasswordAuthentication=false' git fetch --all
  # Klappt
$ GIT_SSH_COMMAND='ssh -v -i ~/.ssh/uli.heller-solokey_notouch -o IdentitiesOnly=true -o IdentityAgent=false -o PasswordAuthentication=false' git fetch --all
  # Klappt
```

SSH-Konfiguration
-----------------

Diese Anpassungen in der Datei "~/.ssh/config" vornehmen:

```
#Host (servername) (git) ...
Host backup.heller.cool forgejo.heller.cool
  IdentitiesOnly  true
  # AddKeysToAgent false
  # IdentityAgent  false
  IdentityFile    ~/.ssh/uli.heller-yubikey_notouch
  IdentityFile    ~/.ssh/uli.heller-solokey_notouch
  PasswordAuthentication false
```

Die beiden "Agent"-Zeilen können bei Bedarf durch Entfernung der
Raute ('#') aktiviert werden, dann landen die Schlüssel
nicht im SSH-Agent und man muß jedesmal das Schlüssel-Kennwort
eintippen. Unkomfortabel aber sicherer!

Was bewirkt die obige Konfiguration?

- Es werden nur die angegeben Schlüsseldateien
- Zunächst wird die Yubikey-Schlüsseldatei ausprobiert
- Falls der Yubikey nicht eingesteckt ist, dann scheitert dies
- Falls der Yubikey eingesteckt ist, dann wird nach dem Schlüsselkennwort gefragt und die Anmeldung klappt potentiell - FERTIG OK
- Dann wird die Solokey-Schlüsseldatei ausprobiert
- Falls der Solokey nicht eingesteckt ist, dann scheitert dies
- Falls der Solokey eingesteckt ist, dann wird nach dem Schlüsselkennwort gefragt und die Anmeldung klappt potentiell - FERTIG OK
- Es wird keine Anmeldung via Kennwort durchgeführt - FERTIG KO

Nachtests
---------

Die nachfolgend beschriebenen Nachtests
müssen alle klappen. Dabei müssen die Fido2-Token
teilweise ausgesteckt sein.

### Beide Token eingesteckt

```
$ ssh backup.heller.cool
  # Muss klappen bei Eingabe des Kennwortes für den Yubikey-SSH-Schlüssel

$ git fetch --all
  # Muss klappen bei Eingabe des Kennwortes für den Yubikey-SSH-Schlüssel
```

### Nur Yubikey eingesteckt

```
$ ssh backup.heller.cool
  # Muss klappen bei Eingabe des Kennwortes für den Yubikey-SSH-Schlüssel

$ git fetch --all
  # Muss klappen bei Eingabe des Kennwortes für den Yubikey-SSH-Schlüssel
```

### Nur Solokey eingesteckt

```
$ ssh backup.heller.cool
  # Muss klappen bei Eingabe des Kennwortes für den Solokey-SSH-Schlüssel

$ git fetch --all
  # Muss klappen bei Eingabe des Kennwortes für den Solokey-SSH-Schlüssel
```

### Kein Token eingesteckt

```
$ ssh backup.heller.cool
  # Darf NICHT klappen! Es darf kein Kennwort angefordert werden!

$ git fetch --all
  # Darf NICHT klappen! Es darf kein Kennwort angefordert werden!
```

Links
-----

- [Github](https://github.com)
- [.ssh/config](https://linux.die.net/man/5/ssh_config)
- [ssh](https://linux.die.net/man/1/ssh)

Historie
--------

- 2026-09-24: Erste Version
