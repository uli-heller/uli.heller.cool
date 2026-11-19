+++
date = '2026-11-18'
draft = false
title = 'Linux: Verschlüsselter Hetzner-Rechner'
categories = [ 'Verschlüsselung' ]
tags = [ 'crypto', 'linux', 'ubuntu' ]
+++

<!--
Linux: Verschlüsselter Hetzner-Rechner
======================================
-->

Bereits seit vielen Jahren setze ich Rechner bei Hetzner
ein. Typischerweise bestelle ich "Dedicated Server"
und setze diese dann mit verschlüsselter Festplatte
und RAID1 auf.

Hier beschreibe ich das Neuaufsetzen, wie ich es im
November 2026 erledigt habe. Ablauf sollte grundsätzlich
wie bei älteren Beschreibungen sein mit Anpassungen
auf Ubutu-26.04.

<!--more-->

Änderungen zu früheren Varianten
--------------------------------

Für alle, die den Ablauf bereits aus früheren
Versuchen kennen, hier die wesentlichen Änderungen/Erkenntnisse:

- Die Datei /autosetup ist leicht anders aufgebaut
- Es gibt kein Ubuntu-Minimal mehr, nur noch Ubuntu-Base
- Pfade von DROPBEAR haben sich leicht geändert
- DROPBEAR kommt mit ED-25519 klar (geht wohl ab Ubuntu-22.04)
- Hetzner-Rettungssystem hat Probleme mit SSH-Schlüsseln im Format RSA-2048
- Es werden weiterhin die INITRAMFS-TOOLS verwendet und nicht DRACUT

Rettungssystem
--------------

Das Hetzner-Support-Team hat den Rechner mit neuen Platten
versehen und in's Rettungssystem hochgefahren. Ich habe
das Kennwort für SSH/root:

```
uli$ ssh -o PubkeyAuthentication=no 95.216.23.95
root@95.216.23.95's password: 12345
Linux rescue 6.12.67 #1 SMP Fri Jan 23 15:08:53 UTC 2026 x86_64

-------------------------------------------------------------------------------------------------------------------------

  Welcome to the Hetzner Rescue System.
...
```

Damit ich ein "normales" Rettungssystem habe, aktiviere ich es
via Hetzner-WebUI/Robot neu und starte den Rechner durch mit
Reset/HardwareReset!

Danach sehe ich Schlüsselwarnungen (klar!):

```
uli$ ssh 95.216.23.95
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
...
```

Nach deren Beseitigung klappt die Anmeldung im Rettungssystem
mittels SSH-Schlüssel.

Installation Minimal-Ubuntu
---------------------------

Zuerst installieren wir ein Minimal-Ubuntu.
Das Minimal-Ubuntu läuft ohne Verschlüsselung und
wird später in die verschlüsselten Plattenbereiche
umkopiert.

### Anmelden am Rettungssystem

```
uli$ ssh 95.216.23.95
Linux rescue 7.1.6 #1 SMP PREEMPT Wed Nov 11 10:29:54 UTC 2026 x86_64

---------------------------------------------------------------------

  Welcome to the Hetzner Rescue System.
...

root@rescue ~ # 
```

### Datei /autosetup

Eine Vorlage der Datei erhält man, indem man
direkt `installimage` aufruft. Am Ende wird
dann die Vorlage angezeigt.

Inhalt:

```
##  Hetzner Online GmbH - installimage - config

DRIVE1 /dev/nvme0n1
DRIVE2 /dev/nvme1n1

##  SOFTWARE RAID:
## activate software RAID?  < 0 | 1 >
SWRAID 1

## Choose the level for the software RAID < 0 | 1 | 10 >
SWRAIDLEVEL 1

###  BOOTLOADER:
#BOOTLOADER grub

##  HOSTNAME:
HOSTNAME ilmarinen

IPV4_ONLY yes

USE_KERNEL_MODE_SETTING no

##  PARTITIONS / FILESYSTEMS:
PART /boot  ext3     512M
PART lvm    vg0       all

LV vg0   swap   swap     swap         4G
LV vg0   root   /        ext4         10G

##  OPERATING SYSTEM IMAGE: (ls images)
IMAGE /root/.oldroot/nfs/install/../images/Ubuntu-2604-resolute-amd64-base.tar.zst
```

Ablegen auf dem Hetzner-Server:

1. Obigen Inhalt "kopieren"
2. Im Rettungssystem: `cat >/autosetup` (bleibt "hängen")
3. Zuvor kopierten Inhalt "einfügen"
4. Strg-D
5. Es erscheint wieder die Eingabeaufforderung

### Installieren

```
rescue:/# installimage
Found AUTOSETUP file '/autosetup'
Running unattended installimage installation ...
...
                  INSTALLATION COMPLETE
   You can now reboot and log in to your new system with
  the same password as you logged in to the rescue system.
```

### Neustart

```
rescue:/# reboot
```

### Anmelden am Minimal-Ubuntu

```
desktop:~$ ssh-keygen -f "/home/uli/.ssh/known_hosts" -R 95.216.23.95
desktop:~$ ssh root@95.216.23.95
...
root@ilmarinen ~ #
```

### Aktualisierungen einspielen und aufräumen

```
root@ilmarinen:/# apt update
root@ilmarinen:/# apt upgrade -<
# Dauert eine ganze Weile, es wird u.a. ein
# neuer Linux-Kernel installiert
#  7.0.0-43-generic

root@ilmarinen:/# apt-get clean
root@ilmarinen:/# reboot

desktop:~$ ssh root@95.216.23.95
root@ilmarinen:/# dpkg --get-selections linux*
linux-base					install
linux-firmware					install
linux-firmware-amd-graphics			install
...
linux-firmware-realtek				install
linux-image-7.0.0-22-generic			install
linux-image-7.0.0-43-generic			install
linux-image-generic				install
...

root@ilmarinen:/# apt purge `dpkg --get-selections linux*-22*|cut -f1`
```

### Entsperren per SSH vorbereiten

#### Busybox und Dropbear installieren

```
root@ilmarinen:/# apt install -y busybox dropbear-initramfs
root@ilmarinen:/# apt install -y joe
root@ilmarinen:/# apt clean
```

#### /etc/initramfs-tools/initramfs.conf anpassen

* Alt: `BUSYBOX=auto`
* Neu: `BUSYBOX=y`

#### /etc/dropbear/initramfs/authorized_keys

```
root@ilmarinen:/ # cp ~/.ssh/authorized_keys /etc/dropbear/initramfs/authorized_keys
```

Rettungssystem erneut starten
-----------------------------

1. In der [Web-Oberfläche von Hetzner](https://robot.your-server.de/server)  das Rettungssystem aktivieren
   Achtung: Richtigen SSH-Schlüssel aktivieren!

2. Neustart: `ssh root@95.216.23.95 reboot`

Verschlüsselung einrichten
--------------------------

### Anmelden am Rettungssystem

```
desktop:~$ ssh-keygen -f "/home/uli/.ssh/known_hosts" -R 95.216.23.95
desktop:~$ ssh root@95.216.23.95
rescue:/#
```

Hinweis: Hier hatte ich massive Probleme.
Mein "üblicher" SSH-Schlüssel hat nicht funktioniert!
Erst mit einem Wechsel von RSA-2048 auf ED25519 256
hat's funktioniert.

### Basis-Ubuntu einbinden

```
rescue:/# vgscan -v
  Found volume group "vg0" using metadata type lvm2
rescue:/# vgchange -a y
  2 logical volume(s) in volume group "vg0" now active
rescue:/# mount /dev/mapper/vg0-root /mnt
```

### Basis-Ubuntu kopieren

```
# Resync unterbrechen
rescue:/# echo 0 >/proc/sys/dev/raid/speed_limit_max
rescue:/# mkdir /oldroot
rescue:/# cp -a /mnt/. /oldroot/.
# Resync fortsetzen
rescue:/# echo 200000 >/proc/sys/dev/raid/speed_limit_max
```

### Basis-Ubuntu "ausbinden"

```
rescue:/# umount /mnt
```

### Unverschlüsselte LVM-Volume-Group löschen

```
rescue:/# vgremove vg0
Do you really want to remove volume group "vg0" containing 2 logical volumes? [y/n]: y
Do you really want to remove active logical volume vg0/swap? [y/n]: y
  Logical volume "swap" successfully removed
Do you really want to remove active logical volume vg0/root? [y/n]: y
  Logical volume "root" successfully removed
  Volume group "vg0" successfully removed
```

### Sichtung Plattenstatus

```
root@rescue / # cat /proc/mdstat 
Personalities : [raid1] 
md1 : active raid1 nvme0n1p2[0] nvme1n1p2[1]
      499449152 blocks super 1.2 [2/2] [UU]
      [=====>...............]  resync = 29.3% (146482304/499449152) finish=29.3min speed=200056K/sec
      bitmap: 3/4 pages [12KB], 65536KB chunk

md0 : active raid1 nvme0n1p1[0] nvme1n1p1[1]
      523264 blocks super 1.2 [2/2] [UU]

unused devices: <none>
```

Hierbei ist:

* md0: /boot
* md1: Volume für LVM

### MD1 verschlüsseln

```
rescue:/# cryptsetup --cipher aes-xts-plain64 --key-size 256 --hash sha256 --iter-time=10000 luksFormat /dev/md1
WARNING: Device /dev/md1 already contains a 'LVM2_member' superblock signature.

WARNING!
========
This will overwrite data on /dev/md1 irrevocably.

Are you sure? (Type uppercase yes): YES
Enter passphrase for /dev/md1: {meinKennwort}
Verify passphrase: {meinKennwort}
# .. dauert etwas

rescue:/# cryptsetup luksOpen /dev/md1 cryptroot
Enter passphrase for /dev/md1: {meinKennwort}

rescue:/# pvcreate /dev/mapper/cryptroot
  Physical volume "/dev/mapper/cryptroot" successfully created.
  
rescue:/# vgcreate vg0 /dev/mapper/cryptroot
  Volume group "vg0" successfully created
  
rescue:/# lvcreate -n swap -L4G vg0
  Logical volume "swap" created.
  
rescue:/# lvcreate -n root -L20G vg0
  Logical volume "root" created.
  
rescue:/# mkfs.ext4 /dev/vg0/root
mke2fs 1.47.2 (1-Jan-2025)
Creating filesystem with 5242880 4k blocks and 1310720 inodes
Filesystem UUID: 412b4a7f-b860-4448-8297-07dd916352e5
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done   

rescue:/# mkswap /dev/vg0/swap
Setting up swapspace version 1, size = 4 GiB (4294963200 bytes)
no label, UUID=6211c76d-b85d-4142-b92a-c3fe48accf09
```

### Verschlüsselte Plattenbereiche einbinden

```
rescue:/# mount /dev/vg0/root /mnt
```

### Basis-Ubuntu  in verschlüsselten Plattenbereich kopieren

```
# Resync unterbrechen
rescue:/# echo 0 >/proc/sys/dev/raid/speed_limit_max
rescue:/# cp -a /oldroot/. /mnt/.
# Resync fortsetzen
rescue:/# echo 200000 >/proc/sys/dev/raid/speed_limit_max
```

### Finale Installation einbinden

```
rescue:/# mount /dev/md0 /mnt/boot
rescue:/# mount --bind /dev /mnt/dev
rescue:/# mount --bind /sys /mnt/sys
rescue:/# mount --bind /proc /mnt/proc
rescue:/# chroot /mnt
final:/#
```

### /etc/crypttab

```
# <target name> <source device>         <key file>      <options>
cryptroot /dev/md1 none luks
```

### initramfs neu schreiben

```
final:/# update-initramfs -u
update-initramfs: Generating /boot/initrd.img-7.0.0-43-generic
```

### GRUB neu schreiben

```
final:/# update-grub
Sourcing file `/etc/default/grub'
Sourcing file `/etc/default/grub.d/hetzner.cfg'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-7.0.0-43-generic
Found initrd image: /boot/initrd.img-7.0.0-43-generic
Adding boot menu entry for UEFI Firmware Settings ...
done
```

### Finale Installation ausbinden

```
final:/# exit
rescue:/# umount /mnt/boot /mnt/proc /mnt/sys /mnt/dev
rescue:/# umount /mnt
rescue:/# sync
```

### Neustart

```
rescue:/# reboot
```

### Schlüsseleingabe beim Boot-Vorgang

```
desktop:~$ ssh -o UserKnownHostsFile=/dev/null root@95.216.23.95
The authenticity of host '95.216.23.95 (95.216.23.95)' can't be established.
ED25519 key fingerprint is SHA256:AOBMKLdQxqzZ+JHVEMU9t4So3njf6XbXf4qemUl6twI.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '95.216.23.95' (ED25519) to the list of known hosts.
To unlock root partition, and maybe others like swap, run `cryptroot-unlock`.


BusyBox v1.37.0 (Ubuntu 1:1.37.0-7ubuntu1) built-in shell (ash)
Enter 'help' for a list of built-in commands.

# cryptroot-unlock
Please unlock disk cryptroot (/dev/md1): {meinKennwort}
Error: Timeout reached while waiting for PID 350.
# Connection to 95.216.23.95 closed by remote host.
Connection to 95.216.23.95 closed.
```

### Anmelden am gestarteten Rechner

```
desktop:~$ ssh-keygen -f "/home/uli/.ssh/known_hosts" -R 95.216.23.95
desktop:~$ ssh root@95.216.23.95
The authenticity of host '95.216.23.95 (95.216.23.95)' can't be established.
ED25519 key fingerprint is SHA256:DLjdqBs02x+cvrxbOk4z/HxWSYwWM2XnEKtqTB2kDB4.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '95.216.23.95' (ED25519) to the list of known hosts.
Welcome to Ubuntu 26.04.1 LTS (GNU/Linux 7.0.0-43-generic x86_64)
...
root@ilmarinen ~ # 
```

#### Zweigeteilten Schlüssel in LUKS hinterlegen

Der bislang verwendete LUKS-Schlüssel reicht aus, um
die Festplatte des Hetzner-Rechners zu entsperren.
Das finde ich nur "halbgut", weil eine Veröffentlichung
dieses Schlüssels die Sicherheit vom Hetzner-Rechner
ein wenig "aufweicht".

Idee: Der Schlüssel wird zweigeteilt. Ein Teil wird auf
dem Hetzner-Rechner gespeichert und den anderen
Teil muß man via SSH "beisteuern". Damit kann jeder Teil
alleine die Festplattenverschlüsselung nicht komplett
aufweichen.

- Teil1: Fiat500
- Trenner: _
- Teil2: vAlD6ZFNJNXqzZ3AyrcBUu8V7xA= (`openssl rand -base64 20`)

```
desktop:~$ ssh root@95.216.23.95
ilmarinen:/# cryptsetup luksAddKey /dev/md1
Enter any existing passphrase: {meinKennwort}
Enter new passphrase for key slot: Fiat500_vAlD6ZFNJNXqzZ3AyrcBUu8V7xA=
Verify passphrase: Fiat500_vAlD6ZFNJNXqzZ3AyrcBUu8V7xA=
```

#### Entsperrskript hinterlegen

/etc/initramfs-tools/unlock-disks.sh:

```
#!/bin/sh
(cat; echo -n "_{geheimerZweiterTeil}")|tr -d "\r\n"|cryptroot-unlock
```

/etc/initramfs-tools/hooks/unlock-disks-hook:

```
#!/bin/sh
#
#
# This is an example hook script.  It will be run by 'mkinitramfs'
# when it creates the image.  It's job is to decide which files to
# install, then install them into the staging area, where the
# initramfs is being created.  This happens when a new 'linux-image'
# package is installed, or when the administrator runs 'mkinitramfs'
# by hand to update an initramfs image.
#
#  CONFDIR -- usually /etc/initramfs-tools, can be set on mkinitramfs
#         command line.
#
#  DESTDIR -- The staging directory where we are building the image.
#
# see initramfs-tools(8)

#
# List the soft prerequisites here.  This is a space separated list of
# names, of scripts that are in the same directory as this one, that
# must be run before this one can be.
#
PREREQ=""
prereqs()
{
    echo "$PREREQ"
}

case $1 in
# get pre-requisites
prereqs)
    prereqs
    exit 0
    ;;
esac


# You can do anything you need to from here on.
#

# Source the optional 'hook-functions' scriptlet, if you need the
# functions defined within it.  Read it to see what is available to
# you.  It contains functions for copying dynamically linked program
# binaries, and kernel modules into the DESTDIR.
#
. /usr/share/initramfs-tools/hook-functions

copy_file binary "${CONFDIR}/unlock-disks.sh" "/bin"

exit 0
```

* Zugriffsrechte anpassen:
  * `chmod 700 /etc/initramfs-tools/unlock-disks.sh`
  * `chmod +x /etc/initramfs-tools/hooks/unlock-disks-hook`
* Initramfs neu erzeugen: `update-initramfs -u`

#### Boot-Vorgang testen

```
desktop:~$ ssh root@95.216.23.95
ilmarinen:/# reboot
Connection to 95.216.23.95 closed by remote host.
Connection to 95.216.23.95 closed.

desktop:~$ echo "Fiat500"|ssh -o UserKnownHostsFile=knownHosts-boot root@95.216.23.95 /bin/unlock-disks.sh
The authenticity of host '95.216.23.95 (95.216.23.95)' can't be established.
ED25519 key fingerprint is SHA256:AOBMKLdQxqzZ+JHVEMU9t4So3njf6XbXf4qemUl6twI.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '95.216.23.95' (ED25519) to the list of known hosts.
Please unlock disk cryptroot
Error: Timeout reached while waiting for PID 351.
desktop:~$

desktop:~$ ssh root@95.216.23.95
Welcome to Ubuntu 26.04.1 LTS (GNU/Linux 7.0.0-43-generic x86_64)
...
ilmarinen:/#
```

#### Weitere SSH-Schlüssel für den Boot-Vorgang freischalten

* Datei "etc/dropbear/initramfs/authorized_keys" erweitern um den PubKey:
  
  ```
    ...
    command="/bin/unlock-disks.sh" ssh-ed25519 AAAAB3NzaC1yc2EAAAA... Gerd Mueller
  ```
* Initramfs neu erzeugen: `update-initramfs -u`
* Ersten Schlüsselteil ("Fiat500") an den Inhaber des Schlüssels übermitteln
* Entsperrkommando an den Inhaber des Schlüssels übermitteln: `echo "Fiat500"|ssh -o UserKnownHostsFile=knownHosts-boot root@95.216.23.95`


################################

Aufräumaktion
-------------

### Schrott-LXD-Pakete entfernen

```
apt purge -y lxd-agent-loader
apt purge -y lxd-installer
apt autoremove -y
```

### Diverse SNAPs entfernen

```
snap list
snap remove lxd
snap remove core26
snap remove snapd
snap list
```

Am Ende wird angezeigt: "No snaps are installed yet. Try 'snap install hello-world'."

Versionen
---------

- Getestet mit Ubuntu-2604

Links
-----

- [Hetzner-Docs - Installimage](https://docs.hetzner.com/robot/dedicated-server/operating-systems/installimage)
- [Web-Oberfläche von Hetzner](https://robot.your-server.de/server)

Historie
--------

- 2026-11-18: Erste Version
