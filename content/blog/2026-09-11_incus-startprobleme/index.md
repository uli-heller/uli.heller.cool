+++
date = '2026-09-11'
draft = false
title = 'INCUS: Startprobleme bei umgezogenen Containern'
categories = [ 'INCUS', 'LXC/LXD' ]
tags = [ 'incus', 'lxc', 'lxd' ]
+++

<!--
INCUS: Startprobleme bei umgezogenen Containern
===============================================
-->

Ich habe viele Container, die ich teilweise bereits seit Jahren
unter LXC/LXD betreibe. Aktuell ziehe ich sie alle nach INCUS
um. Leider gibt es bei einigen Startprobleme. Hier beschreibe
ich, wie ich sie analysiere und behebe!

<!--more-->

Ablauf des Umzugs
-----------------

Ich muß die Container umziehen, weil der LXC/LXD-Rechner gestört ist.
Viele Dinge funktionieren nicht mehr richtig, bspw.

- SSH-Anmeldung
- SystemD - `systemctl ...`
- LXC - `lxc ...`

Die Container selbst scheinen korrekt zu laufen.

Aufgrund der Störungen muß ich den Umzug "manuell" durchführen
via Kopieren der Container-Dateien:

```
# Schritt 1 - basierend auf einem Grundvorschlag von Gemini - stark überarbeitet
# KO-Rechner, LXD
LXD_PATH=/lxd
CONTAINER=anwesenheit
mkdir -p "${LXD_PATH}/containers-snapshots/${CONTAINER}"
btrfs subvolume snapshot -r "${LXD_PATH}/containers/${CONTAINER}" "${LXD_PATH}/containers-snapshots/${CONTAINER}/trx_hetzner-de-ryzen_$(date +%Y%m%d-%H%M%S)"

# Schritt 2 und 3 - basierend auf einem Grundvorschlag von Gemini - stark überarbeitet
# OK-Rechner, INCUS
INCUS_PATH=/incus
LXD_PATH=/lxd
CONTAINER=anwesenheit
incus copy ubuntu-2604 "${CONTAINER}"
incus stop -f "${CONTAINER}" 2>/dev/null
rm -rf "${INCUS_PATH}/containers/${CONTAINER}/rootfs/"*
time ssh  95.216.23.95 "tar --numeric-owner -czpf - -C \"${LXD_PATH}/containers-snapshots/${CONTAINER}/trx_hetzner-de-ryzen_\"*/rootfs/ ."\
  |tar --numeric-owner -xzpvf - -C "${INCUS_PATH}/containers/${CONTAINER}/rootfs/"

# "manchmal" müssen die UIDs/GIDs angepasst werden
OLD_UID="$(stat --format="%u" "${INCUS_PATH}/containers/${CONTAINER}/rootfs")"
OLD_GID="$(stat --format="%g" "${INCUS_PATH}/containers/${CONTAINER}/rootfs")"
test "${OLD_UID} ${OLD_GID}" != "0 0" && {
  /home/uli/bin/incus/incus-fuidshift.sh -r -u "0:${OLD_UID}" -g "0:${OLD_GID}" "${INCUS_PATH}/containers/${CONTAINER}"
}
```

Start nach dem Umzug
--------------------

Nach dem Umzug möchte ich den Container starten, leider klappt das nicht:

```
# incus start anwesenheit
Error: Failed to run: /usr/libexec/incus/incusd forklxc anwesenheit /var/lib/incus/containers /run/incus/anwesenheit/lxc.conf /var/log/incus/anwesenheit: exit status 1
Try `incus info --show-log anwesenheit` for more info

# incus info --show-log anwesenheit
Name: anwesenheit
Description: 
Status: STOPPED
Type: container
Architecture: x86_64
Created: 2026/09/11 06:27 CEST
Last Used: 1970/01/01 01:00 CET

Log (lxc.log):

lxc anwesenheit 20260911044141.534 ERROR    conf - ../src/lxc/conf.c:run_buffer:322 - Script exited with status 1
lxc anwesenheit 20260911044141.534 ERROR    start - ../src/lxc/start.c:lxc_init:844 - Failed to run lxc.hook.pre-start for container "anwesenheit"
lxc anwesenheit 20260911044141.534 ERROR    start - ../src/lxc/start.c:__lxc_start:2027 - Failed to initialize container "anwesenheit"
lxc anwesenheit 20260911044142.977 ERROR    lxccontainer - ../src/lxc/lxccontainer.c:wait_on_daemonized_start:870 - No such file or directory - Failed to receive the container state
```

Die Fehlermeldungen sind relativ allgemein und nichtssagend!

Analyse mit JOURNALCTL
----------------------

Für die Analyse benötige ich zwei Terminalfenster.

Fenster-1:

```
# journalctl -eu incus -f
...
Sep 11 06:41:42 hetzner-de-ryzen startup[243455]: time="2026-09-11T06:41:42+02:00" level=error msg="Failed starting instance" action=start created="2026-09-11 04:27:43.917785809 +0000 UTC" ephemeral=false instance=anwesenheit instanceType=container project=default stateful=false used="1970-01-01 00:00:00 +0000 UTC"
Sep 11 06:41:42 hetzner-de-ryzen startup[243455]: time="2026-09-11T06:41:42+02:00" level=warning msg="Failed to close connection" err="close unix /var/lib/incus/unix.socket->@: use of closed network connection"
```

Fenster-2 - Kommando ausführen und Ausgaben in Fenster-1 beonachten:

```
# incus start anwesenheit
```

Neue Zeilen Fenster-1:

```
Sep 11 06:48:19 hetzner-de-ryzen startup[243455]: time="2026-09-11T06:48:19+02:00" level=warning msg="Failed to close file" err="close /var/lib/incus/containers/anwesenheit/rootfs/etc/hosts: file already closed"
Sep 11 06:48:19 hetzner-de-ryzen startup[243455]: time="2026-09-11T06:48:19+02:00" level=warning msg="Failed to close file" err="close /var/lib/incus/containers/anwesenheit/rootfs/etc/machine-id: file already closed"
Sep 11 06:48:19 hetzner-de-ryzen startup[243455]: time="2026-09-11T06:48:19+02:00" level=error msg="The start hook failed" err="Failed to check template file: statat var/lib/dbus/machine-id: path escapes from parent" instance=anwesenheit
Sep 11 06:48:19 hetzner-de-ryzen startup[243455]: time="2026-09-11T06:48:19+02:00" level=error msg="Failed starting instance" action=start created="2026-09-11 04:27:43.917785809 +0000 UTC" ephemeral=false instance=anwesenheit instanceType=container project=default stateful=false used="1970-01-01 00:00:00 +0000 UTC"
Sep 11 06:48:19 hetzner-de-ryzen startup[243455]: time="2026-09-11T06:48:19+02:00" level=warning msg="Failed to close connection" err="close unix /var/lib/incus/unix.socket->@: use of closed network connection"
```

Man sieht, dass es Probleme mit "machine-id" gibt:

- /etc/machine-id
- var/lib/dbus/machine-id

Sichtung "machine-id"
---------------------

```
# cd .../containers/anwesenheit/rootfs

# ls -l etc/machine-id var/lib/dbus/machine-id
-r--r--r-- 1 root root  0 Sep 11 06:48 etc/machine-id
lrwxrwxrwx 1 root root 15 Dec 18  2021 var/lib/dbus/machine-id -> /etc/machine-id
```

Eventuell liegt der Fehler am absoluten Link!

Korrekturversuch und Test
-------------------------

Korrekturversuch:

```
# rm -f var/lib/dbus/machine-id
# ln -s ../../../etc/machine-id var/lib/dbus/machine-id
```

Start-Test:

```
# incus start anwesenheit
  # Klappt!
```

Links
-----

- [LXC/LXD: Hetzner-Server hat eine Plattenstörung]({{< ref "/blog/2026-09-09_hetzner-crash" >}})

Versionen
---------

Getestet mit

- Ubuntu 24.04 LTS
- incus-7.0.1
- lxd-6.9

Historie
--------

- 2026-09-11: Erste Version
