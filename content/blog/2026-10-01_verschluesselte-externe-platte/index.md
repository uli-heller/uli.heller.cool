+++
date = '2026-10-01'
draft = false
title = 'Linux: Externen Datenträger automatisch entschlüsseln'
categories = [ 'Verschlüsselung' ]
tags = [ 'crypto', 'linux', 'ubuntu' ]
+++

<!--
Linux: Externen Datenträger automatisch entschlüsseln
=====================================================
-->

Bei meinem Heimrechner habe ich externe Festplatten,
die per RAID1 und mit Verschlüsselung eingebunden sind.
Idealerweise funktioniert ein Neustart (Reboot)
ohne manuelle Eingriffe.

Defizite bei der Sicherheit nehme ich dazu erstmal in Kauf!

<!--more-->

Ausgangslage
------------

- Rechner mit Ubuntu-26.04 - /etc/lsb-release
  ```
  DISTRIB_ID=Ubuntu
  DISTRIB_RELEASE=26.04
  DISTRIB_CODENAME=resolute
  DISTRIB_DESCRIPTION="Ubuntu 26.04.1 LTS"
  ```
- 2x externe Platte, jeweils grob 12 TB
  - /dev/sda
  - /dev/sdb
- Beide Platten identisch partitioniert
  - Jeweils eine Partition
- Beide Platten als RAID1 miteinander verknüpft
  - /dev/sda - md127 - raid1
  - /dev/sdb - md127 - raid1
  - /proc/mdstat
    ```
    Personalities : [raid1] 
    md127 : active raid1 sdb[1] sda[0]
          11718753280 blocks super 1.2 [2/2] [UU]
          bitmap: 0/88 pages [0KB], 65536KB chunk
    
    unused devices: <none>
    ```
- Verschlüsselung auf dem RAID1-Bereich
- LVM im verschlüsselten Bereich

Übersicht mit `lsblk`:

```
$ lsblk
NAME                                        MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
sda                                           8:0    0  10,9T  0 disk
└─md127                                       9:127  0  10,9T  0 raid1
  └─terramaster                             252:2    0  10,9T  0 crypt
    └─terramaster--vg-terramaster--data--lv 252:3    0     4T  0 lvm   /terramaster-data
sdb                                           8:16   0  10,9T  0 disk
└─md127                                       9:127  0  10,9T  0 raid1
  └─terramaster                             252:2    0  10,9T  0 crypt
    └─terramaster--vg-terramaster--data--lv 252:3    0     4T  0 lvm   /terramaster-data
```

Manueller Ablauf
----------------

- Services/Container stoppen, die Daten der externen Platten nutzen
  - `incus stop immich`
  - ...
- `sudo reboot`
- `lsblk` -> sdb:md127, sdc:md127
- Sichtung: `cat /proc/mdstat` -> md127 ist OK, kein RESYNC
- `cryptsetup open /dev/md127 terramaster-crypt` -> Passphrase eingeben -> klappt!
- `vgscan` -> ubuntu-vg und terramaster-vg
- `lvdisplay` -> terramaster-lv wird angezeigt
- Einbinden:
  - `mkdir /terramaster-data`
  - `mount /dev/terramaster-vg/terramaster-data-lv /terramaster-data`
  - `ls -l /terramaster-data` -> klappt!
- Services/Container starten, die Daten der externen Platten nutzen
  - `incus start immich`
  - ...

Automatisierung
---------------

### Schlüsseldatei erzeugen

Die Schlüsseldatei hat bei mir den Namen ...
und muß einen sicheren Schlüssel enthalten, also
bspw. mit Zufallszahlen gefüllt sein:

- `mkdir /etc/luks-keys`
- `chown root:root /etc/luks-keys`
- `chmod 700 /etc/luks-keys`
- `openssl rand 256 >/etc/luks-keys/terramaster.key`
- `chown root:root /etc/luks-keys/terramaster.key`
- `chmod 600 /etc/luks-keys/terramaster.key`

Varianten:

```
# openssl rand 256 >/etc/luks-keys/terramaster.key
  # erzeugt einen Schlüssel mit Binärdaten

# openssl rand 256 | base64 -w 0 >/etc/luks-keys/terramaster.key
  # erzeugt einen "lesbaren" Schlüssel

# openssl rand -hex 256 >/etc/luks-keys/terramaster.key
  # erzeugt einen "lesbaren" Schlüssel

# openssl rand -base64 256 >/etc/luks-keys/terramaster.key
  # erzeugt einen "lesbaren" Schlüssel
```

### UUID ermitteln

```
# lsblk -f
NAME                                      FSTYPE            FSVER    LABEL             UUID                                   FSAVAIL FSUSE% MOUNTPOINTS
...
sda                                       linux_raid_member 1.2      ulicsl:0          8a5816c3-efb2-4cf3-2556-372cfb3be138
└─md127                                   crypto_LUKS       2                          c894d62f-2556-4360-81c8-2f723d169d6e
  └─terramaster                           LVM2_member       LVM2 001                   MeLLZ4-RrYx-J0VK-tHR5-NUAC-wzZB-hJUUUU
    └─terramaster--vg-terramaster--data--lv
                                          btrfs                      terrramaster-data ac09c648-b10a-4232-a6f1-18884ba5d587      3,9T     3% /terramaster-data
sdb                                       linux_raid_member 1.2      ulicsl:0          8a5816c3-efb2-4cf3-2556-372cfb3be138
└─md127                                   crypto_LUKS       2                          c894d62f-2556-4360-81c8-2f723d169d6e
  └─terramaster                           LVM2_member       LVM2 001                   MeLLZ4-RrYx-J0VK-tHR5-NUAC-wzZB-hJUUUU
    └─terramaster--vg-terramaster--data--lv
                                          btrfs                      terrramaster-data ac09c648-b10a-4232-a6f1-18884ba5d587      3,9T     3% /terramaster-data
...
```

Die gesuchte UUID ist "c894d62f-2556-4360-81c8-2f723d169d6e".

### Schlüsseldatei aktivieren

```
# UUID=c894d62f-2556-4360-81c8-2f723d169d6e
# KEY_FILE=/etc/luks-keys/terramaster.key
# cryptsetup luksAddKey "/dev/disk/by-uuid/${UUID}" "${KEY_FILE}"
Enter any existing passphrase: (manuelles-entschlüsselungskennwort-eintippen)
```

### Automatische Entschlüsselung aktivieren

```
# UUID=c894d62f-2556-4360-81c8-2f723d169d6e
# KEY_FILE=/etc/luks-keys/terramaster.key
# echo >>/etc/crypttab "terramaster UUID=${UUID} ${KEY_FILE} luks,nofail"
```

Meine /etc/crypttab:

```
# <target name>	<source device>		<key file>	<options>
terramaster UUID=c894d62f-2556-4360-81c8-2f723d169d6e /etc/luks-keys/terramaster.key luks,nofail
```

### Automatisches Einbinden

Meine /etc/fstab:

```
...
#
# terramaster
#
/dev/mapper/terramaster--vg-terramaster--data--lv /terramaster-data btrfs defaults 0 1
```

Test:

```
# incus stop immich
# umount /terramaster-data
# systemctl daemon-reload
# mount /terramaster-data
# incus start immich
```

Schlusstest
-----------

```
# reboot
...
warten
Anmelden
Sichten

# df
  # /terramaster-data ist eingebunden
# incus ls
  # Alle Container laufen
```

Sicherheit
----------

Die "Sicherheit" der Daten auf den verschlüsselten externen Platten
ist eingeschränkt, weil die Entschlüsselung mit einer Datei erfolgen
kann, die im Klartext auf unverschlüsselten Platten liegt.

Solange niemand in meinen Rechner einbricht sind die Konsequenzen überschaubar!

Versionen
---------

- Getestet mit Ubuntu-2604

Links
-----

- [Linux: Datenträger mit FIDO2-Stick verschlüsseln]({{< ref "blog/2026-03-14_luks-fido2" >}})
- [Github - bertogg - fido2luks](https://github.com/bertogg/fido2luks)
  - [keyscript.sh](keyscript.sh)

Historie
--------

- 2026-10-01: Erste Version
