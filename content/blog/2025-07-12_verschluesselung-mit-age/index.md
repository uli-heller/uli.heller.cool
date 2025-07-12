+++
date = '2025-07-12'
draft = false
title = 'Verschlüsselung mit AGE'
categories = [ 'Verschlüsselung' ]
tags = [ 'verschlüsselung', 'ubuntu', 'linux' ]
+++

<!--Verschlüsselung mit AGE-->
<!--=======================-->

Ich verwende "manchmal" gerne SSH-Schlüssel für die
Verschlüsselung. Für Schüssel vom Typ RSA geht das
mit OPENSSL, bei ED25519 mit AGE.

<!--more-->

AGE installieren
----------------

```
sudo apt update
sudo apt upgrade
sudo apt install -y age
```

SSH-Schlüssel anlegen
---------------------

```
ssh-keygen -t ed25519 -f $HOME/uheller-ed25519 -C "SSH-Schluessel fuer AGE-Verschluesselung
```

Testdatei anlegen
-----------------

```
echo "Dies ist mein geheimer Inhalt" >$HOME/geheime-datei-unverschluesselt
```

Testdatei verschlüsseln
-----------------------

```
age -R $HOME/uheller-ed25519.pub $HOME/geheime-datei-unverschluesselt >$HOME/geheime-datei-verschluesselt
```

Testdatei entschlüsseln
-----------------------

```
age -d -i $HOME/uheller-ed25519 $HOME/geheime-datei-verschluesselt >$HOME/geheime-datei-entschluesselt
```

Links
-----

- [Github - AGE](https://github.com/FiloSottile/age)

Historie
--------

- 2025-07-12: Erste Version
