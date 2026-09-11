+++
date = '2026-09-12'
draft = false
title = 'INCUS: Ausgehende Verbindungen'
categories = [ 'INCUS' ]
tags = [ 'incus' ]
+++

<!--
INCUS: Ausgehende Verbindungen
==============================
-->

Ich habe viele Container. Ich möchte, dass diese möglichst
abgeschottet laufen. Deshalb sollen die Container möglichst
wenig Möglichkeiten für ausgehende Verbindungen haben!

<!--more-->

Hostonly-Container
------------------

Einige meiner Container werden mit einem Hostonly-Netzwerk
betrieben. Diese Container können keinerlei ausgehende Verbindungen
aufbauen.

Hostonly-Container verwenden als Netzwerkschnittstelle "eth0".

NAT-Container
-------------

Einige meiner Container werden mit einem NAT-Netzwerk
betrieben. Diese Container können beliebige ausgehende Verbindungen
aufbauen. Notwendig bspw. für SMTP-Server, die Mails an
beliebige Rechner schicken können sollen.

Klar: Bei SMTP kann man sich noch Gedanken zu Einschränkungen
bzgl. des TCP-Ports machen. Vorerst zurückgestellt!

NAT-Container verwenden als Netzwerkschnittstelle "eth1".

Irgendwas-dazwischen-Container
------------------------------

### Test mit eth0 (hostonly)

- Container als Hostonly-Container konfigurieren
  -> alle ausgehenden Verbindungen sind blockiert
- ACL anlegen: Zugriff auf smtp.mailbox.org Port 465 erlauben:
  ```
  CONTAINER=test-outgoing
  ACL_NAME="${CONTAINER}-network-acl"
  DESTINATION_IP="$(getent ahostsv4 smtp.mailbox.org|head -1|cut -d " " -f 1)"
  # 185.97.174.196
  incus network acl create "${ACL_NAME}"
  incus network acl rule add "${ACL_NAME}" egress action=allow protocol=tcp destination="${DESTINATION_IP}/32" destination_port=465
  ```
- ACL für Container aktivieren
  ```
  CONTAINER=test-outgoing
  ACL_NAME="${CONTAINER}-network-acl"
  incus config device set "${CONTAINER}" eth0 security.acls="${ACL_NAME}"
  ```
- Leider klappt nun der SSH-Zugriff auf den Container nicht mehr!
- ACL erweitern um eingehenden SSH-Zugriff:
  ```
  incus network acl rule add "${ACL_NAME}" ingress action=allow protocol=tcp destination_port=22
  ```
- Nun klappt der eingehende SSH-Zugriff!
- Ausgehender Zugriff auf smtp.mailbox.org:465 klappt nicht!
  ```
  connect to smtp.mailbox.org port 465 (tcp) timed out: Operation now in progress
  ```
- ACL entfernen:
  ```
  incus config device unset "${CONTAINER}" eth0 security.acls
  incus network acl remove "${ACL_NAME}"
  ```

### Test mit eth2 (nat)

- Container als Variante von NAT-Containern konfigurieren mit eth2 statt eth1
  -> alle ausgehenden Verbindungen sind erlaubt
- ACL anlegen: Zugriff auf smtp.mailbox.org Port 465 erlauben:
  ```
  CONTAINER=test-outgoing
  ACL_NAME="${CONTAINER}-network-acl"
  DESTINATION_IP="$(getent ahostsv4 smtp.mailbox.org|head -1|cut -d " " -f 1)"
  # 185.97.174.196
  incus network acl create "${ACL_NAME}"
  incus network acl rule add "${ACL_NAME}" egress action=allow protocol=tcp destination="${DESTINATION_IP}/32" destination_port=465
  ```
- ACL für Container aktivieren
  ```
  incus config device set "${CONTAINER}" eth2 security.acls="${ACL_NAME}"
  ```
- Klappen ausgehende Verbindungen zu smtp.mailbox.org?
  ```
  nc -zvw5 185.97.174.196 465 #-> smtp.mailbox.org [185.97.174.196] 465 (submissions) open
  ```
- Es klappt!

Links
-----

- [LXC/LXD: Hetzner-Server hat eine Plattenstörung]({{< ref "/blog/2026-09-09_hetzner-crash" >}})

Versionen
---------

Getestet mit

- Ubuntu 24.04 LTS
- incus-7.0.1

Historie
--------

- 2026-09-12: Erste Version
