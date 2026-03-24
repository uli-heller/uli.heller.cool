+++
date = '2026-03-15'
draft = false
title = 'Linux: Datenträger mit FIDO2-Stick "manuell" entschlüsseln'
categories = [ 'FIDO2' ]
tags = [ 'linux', 'ubuntu' ]
+++

<!--
Linux: Datenträger mit FIDO2-Stick "manuell" entschlüsseln'
===========================================================
-->

Neuere Versionen von SystemD erlauben es, einen FIDO2-Stick
für die Festplattenverschlüsselung zu verwenden.
Hier beschreibe ich meine Versuche, die Festplattenverschlüsselung
ohne SystemD zu Entschlüsseln.

<!--more-->

Vorarbeiten
-----------

In [Linux: Datenträger mit FIDO2-Stick verschlüsseln]({{< ref "blog/2026-03-14_luks-fido2" >}})
habe ich einen USB-Stick verschlüsselt mit meinem SoloKey und meinem YubiKey.

Hilfsskripte
------------

- [determine-token-id.sh](determine-token-id.sh) ... ermittelt die TokenID des eingesteckten FIDO2-Sticks für einen verschlüsselten Datenträger
- [determine-secret.sh](determine-secret.sh) ... ermittelt das Geheimnis des eingesteckten FIDO2-Sticks für einen verschlüsselten Datenträger

Entschlüsselungsablauf
----------------------

1. Gerätedatei für den verschlüsselten Datenträger ermitteln:
    ```
    $ lsblk -o name,fstype
    NAME                     FSTYPE
    ...
    sdc                      
    └─sdc1                   crypto_LUKS
    ...
    ```
2. Sicherstellen: Es ist genau ein FIDO2-Stick eingesteckt
3. Optional - TokenID ermitteln:  `sudo ./determine-token-id.sh /dev/sdc1` -> "0"
4. Geheimnis ermitteln (GEHEIM!):
    ```
    $ sudo ./determine-secret.sh /dev/sdc1
    Enter PIN for /dev/hidraw3: 
    +Yr59XYHhMHqcqXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=
    ```
5. Datenträger entsperren mit diesem Geheimnis:
    ```
    $ lsblk /dev/sdc1
    NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
    sdc1   8:33   1  20G  0 part 

    $ sudo cryptsetup luksOpen /dev/sdc1 crypt
    Geben Sie die Passphrase für »/dev/sdc1« ein: +Yr59XYHhMHqcqXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=

    $ lsblk /dev/sdc1
    NAME    MAJ:MIN RM SIZE RO TYPE  MOUNTPOINTS
    sdc1      8:33   1  20G  0 part  
    └─crypt 252:8    0  20G  0 crypt 
    ```
6. Aufräumen - Datenträger wieder sperren: `sudo cryptsetup luksClose crypt`

Erkenntnisse
------------

- Die Entschlüsselung klappt auch ohne SystemD
- Für die Verschlüsselung wird ein Geheimnis verwendet, das relativ problemlos ausgelesen werden kann
- Voraussetzung: "root" + physischer Zugriff auf den FIDO2-Stick + PIN des FIDO2-Sticks + Zugriff auf den verschlüsselten Datenträger

Versionen
---------

- Getestet unter Ubuntu-2404

Links
-----

- [Linux: Datenträger mit FIDO2-Stick verschlüsseln]({{< ref "blog/2026-03-14_luks-fido2" >}})
- [Github - bertogg - fido2luks](https://github.com/bertogg/fido2luks)
  - [keyscript.sh](keyscript.sh)

Historie
--------

- 2026-03-15: Erste Version
