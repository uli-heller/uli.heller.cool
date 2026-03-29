+++
date = '2026-03-28'
draft = false
title = 'Copilot-CLI in einem Container'
categories = [ 'KI' ]
tags = [ 'copilot' ]
+++

<!--
Copilot-CLI in einem Container
==============================
-->

Seit einiger Zeit verwende ich [Copilot-CLI](https://github.com/github/copilot-cli) zur Unterstützung meiner
Arbeit bei einem meiner Kunden. Streng genomen ist Copilot-CLI eine
Kundenvorgabe und aktuell soll so viel wie möglich mit Copilot-CLI
gemacht werden.

Meine Beobachtung: Man schaltet dann mehr und
mehr das Hirn aus und läßt zunehmend mehr Aktionen direkt
von Copilot-CLI ausführen. Das sorgt für wachsendes Umbehagen
wenn nicht klar ist, auf welche Daten Copilot-CLI zugreifen kann.

Idee: Ich betreibe den Copilot-CLI in einem Container!

<!--more-->

Vorarbeiten
-----------

- Grundcontainer mit Ubuntu-Basisinstallation: ubuntu-26.04
- Copilot-CLI herunterladen: [copilot-1.0.12-linux-x64.tar.gz](https://github.com/github/copilot-cli/releases/download/v1.0.12/copilot-linux-x64.tar.gz)
- Virencheck

Container initialisieren
------------------------

- Arbeitsplatzrechner: Container kopieren und starten
  - `incus copy ubuntu-2604 uli-copilot-cli`
  - `incus start uli-copilot-cli`
- Copilot-CLI in Container kopieren: `incus file push copilot-1.0.12-linux-x64.tar.gz uli-copilot-cli/home/ubuntu/copilot-1.0.12-linux-x64.tar.gz`
- Kommandozeile im Container starten: `incus exec uli-copilot-cli bash`
- Copilot-CLI im Container auspacken und ausführbar machen:
  - `sudo -u ubuntu -i`
    - `mkdir bin`
    - `gzip -cd copilot-1.0.12-linux-x64.tar.gz|(cd bin; tar xf -)`
    - `echo "PATH=\"\${PATH}:\${HOME}/bin"\" >>"${HOME}/.bashrc"`
    - `exit`
- Testaufruf con Copilot-CLI im Container:
  ```
  # sudo -u ubuntu -i
  
  ubuntu@uli-copilot-cli:~$ copilot
  ...
  (some more or less nice looking output shows up - press Esc twice to exit)
  Total usage est:        0 Premium requests
  API time spent:         0s
  Total session time:     57s
  Total code changes:     +0 -0
  
  Resume any session with copilot --resume
  
  ubuntu@uli-copilot-cli:~$
  ```

Copilot-CLI initialisieren
--------------------------

- Kommandozeile im Container: `incus exec uli-copilot-cli -- sudo -u ubuntu -i`
- Testverzeichnis anlegen und reinwechseln: `mkdir copilot-test && cd copilot-test`
- Copilot-CLI im Container starten: `copilot --no-mouse`
  - Confirm folder trust - 2. Yes, and remember this folder for future sessions
  - `/login`
    - 1. GitHub.com -> one-time code wird angezeigt
    - Browser: [https://github.com/login/device](https://github.com/login/device)
      -> one-time code eintippen
    - Browser: Authorize -> "Congratulations"
    - GithHub MCP Server: Connected
  - Unten rechts: Claude Haiku 4.5 <-- verwendetes Modell
  - `/model` -> Modell-Liste wird angezeigt
    - Claude Haiku 4.5 (default)
    - GPT-5 mini
    - GPT-4.1
  - Erkenntnis: Es stehen sehr eingeschränkte Modelle zur Verfügung, sofern man die Gratis-Variante von Copilot verwendet!
    Wenn man sich in GitHub mit einem Konto anmeldet, das eine kommerzielle Copilot-Lizent hat, dann stehen diese Modelle
    zur Verfügung:
    - Claude Sonnet 4.6 (default) ✓        1x
    - Claude Sonnet 4.5                    1x
    - Claude Haiku 4.5                  0.33x
    - Claude Opus 4.6                      3x
    - Claude Opus 4.5                      3x
    - Claude Sonnet 4                      1x
    - GPT-5.4                              1x
    - GPT-5.3-Codex                        1x
    - GPT-5.2                              1x
    - GPT-5.1-Codex-Max                    1x
    - GPT-5 mini                           0x
    - GPT-4.1                              0x

Test: Klappt die Erstellung eines Puppet-Moduls?
------------------------------------------------

- Voraussetzung: Copilot-CLI ist gestartet, Modell "Claude Haiku 4.5" ist angewählt
- Prompt: erstelle ein module für puppetenterprise welches einen apache httpd, einen tomcat
  und eine webapp innerhalb des tomcats auf einem Rechner installiert
- Schluss-Statistik:
  ```
  Total usage est:        1 Premium request
   API time spent:         17s
   Total session time:     7m 34s
   Total code changes:     +772 -0
   Breakdown by AI model:
    claude-haiku-4.5         92.5k in, 2.2k out, 60.7k cached (Est. 1 Premium request)
  
   Resume this session with:
     copilot --resume=4a787838-532c-4de2-b73a-3d99b0e1463f
  ```
- [copilot-conversation.md](copilot-conversation.md)
- Erzeugtes Modul: [webserver_stack/README.md](webserver_stack/README.md)
  - [webserver_stack/examples/advanced.pp](webserver_stack/examples/advanced.pp)
  - [webserver_stack/examples/init.pp](webserver_stack/examples/init.pp)
  - [webserver_stack/files/tomcat.service](webserver_stack/files/tomcat.service)
  - [webserver_stack/files/web.xml](webserver_stack/files/web.xml)
  - [webserver_stack/manifests/apache.pp](webserver_stack/manifests/apache.pp)
  - [webserver_stack/manifests/init.pp](webserver_stack/manifests/init.pp)
  - [webserver_stack/manifests/reverse_proxy.pp](webserver_stack/manifests/reverse_proxy.pp)
  - [webserver_stack/manifests/tomcat.pp](webserver_stack/manifests/tomcat.pp)
  - [webserver_stack/manifests/webapp.pp](webserver_stack/manifests/webapp.pp)
  - [webserver_stack/metadata.json](webserver_stack/metadata.json)
  - [webserver_stack/README.md](webserver_stack/README.md)
  - [webserver_stack/templates/index.jsp.epp](webserver_stack/templates/index.jsp.epp)
  - [webserver_stack/templates/reverse_proxy.conf.epp](webserver_stack/templates/reverse_proxy.conf.epp)
  - [webserver_stack/templates/server.xml.epp](webserver_stack/templates/server.xml.epp)
- Kurzsichtung:
  - Es werden alte Versionen verwendet, bspw Ubuntu 18.04 und 20.04 oder Tomcat 9
  - Grundstruktur sieht OK aus

Zugriff auf ein einzelnes Projektverzeichnis
--------------------------------------------

- Ausgangspunkt: "Außerhalb" liegt ein Projekt ab, welches mit dem Copilot-Container geteilt werden soll!
- Ermitteln: Welche Nutzerkennung wird außerhalb verwendet?
  - `id -u` -> 9032
  - `id -g` -> 9032
- Ziel: Diese Nutzerkennung brauchen wir auch innerhalb vom Copilot-Container!
  - "root" im Container: `incus exec uli-copilot-cli bash`
  - Gruppenkennung ändern: `groupmod -g 9032 ubuntu`
  - Nutzerkennung ändern: `usermod -u 9032 -g 9032 ubuntu`
  - Dateien anpassen:
    - `find / -user 1000|xargs -r chown 9032`
    - `find / -group 1000|xargs -r chgrp 9032`
  - Kontrolle: `ls -l /home` -> "drwxr-x--- 1 ubuntu ubuntu 262 Mar 28 17:47 ubuntu"
- Auswahl: Welches Projektverzeichnis soll im Container verwendet werden?
  - /home/uheller/git/test-project
- Zugriff freigeben: `incus config device add uli-copilot-cli git-test-project disk source=/home/uheller/git/test-project path=/home/ubuntu/test-project shift=true`
  - Klappt nicht mit incus-6.0 und Linux >= 6.9 (Error: Failed to start device "git-test-project": Required idmapping abilities not available)
  - Klappt mit incus-6.23.0
- Nachkontrolle: Ist das Proijektverzheichnis sichtbar innerhalb vom Copilot-Container?
  - `incus exec uli-copilot-cli -- sudo -u ubuntu -i`
  - `ls` -> test-project
  - `ls -l test-project|head -5` -> passt! Dateien "gehören" ubuntu.ubuntu

Versionen
---------

- Getestet unter Ubuntu-2404 mit einem Container basierend auf Ubuntu-2604
  und Copilot-CLI-1.0.12

Links
-----

- [Copilot-CLI](https://github.com/github/copilot-cli)
- [Simos Xenitellis - How to share a folder between a host and a container in Incus](https://blog.simos.info/how-to-share-a-folder-between-a-host-and-a-container-in-incus/)
- [Arch - SOLVED Unable to use idmapping in incus with linux 6.9](https://bbs.archlinux.org/viewtopic.php?id=295933)
- [Github/Incus - Linux 6.9+ idmapping abilities are required but aren't supported on system](https://github.com/lxc/incus/issues/882)

Historie
--------

- 2026-03-29: Mehr Hinweise zum Problem mit "shift=true"
- 2026-03-28: Erste Version
