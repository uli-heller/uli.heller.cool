---
date: 2025-01-01
draft: false
title: 'Ideen-Sammlung'
categories:
  - Ideen
tags:
  - ideen
toc: true
---

<!--Ideen-Sammlung-->
<!--==============-->

Sammlung von Verweisen und Ideen,
die ich mir mal anschauen sollte.
Wahrscheinlich völlig unbrauchbar
für jeden außer mich selbst!

<!--more-->

Offene Ideen
------------

### [GitFourchette](https://gitfourchette.org/)

Oberfläche für Git, geschrieben in Python und Qt.
Auch als AppImage.

The comfortable Git UI for Linux.

A comfortable way to explore and understand your Git repositories
Powerful tools to stage code, create commits, and manage branches
Snappy and intuitive Qt UI designed to fit in snugly with KDE Plasma
Learn more on GitFourchette’s homepage at gitfourchette.org.

https://github.com/jorio/gitfourchette

### [Demystifying git submodules](https://www.cyberdemon.org/2024/03/20/submodules.html)

Artikel über die Handhabung von Submodulen + Hinweise
für bessere Konfiguration des Git-Projektes.

Throughout my career, I have found git submodules to be a pain. Because I did
not understand them, I kept getting myself into frustrating situations.

So, I finally sat down and learned how git tracks submodules. Turns out, it’s
not complex at all. It’s just different from how git tracks regular files.
It’s just one more thing you have to learn.

In this article, I’ll explain exactly what I needed to know in order to work
with submodules without inflicting self-damage.

### [jaq - Ersatz für JQ](https://github.com/01mf02/jaq/tree/v2.0.0)

jaq (pronounced /ʒaːk/, like Jacques1) is a clone of the JSON data processing
tool jq. jaq aims to support a large subset of jq's syntax and operations.

You can try jaq online on the jaq playground. Instructions for the playground
can be found here.

### [Hurl - Run and Test HTTP Requests](https://hurl.dev/)

Hurl is a command line tool that runs HTTP requests defined in a simple plain
text format.

It can chain requests, capture values and evaluate queries on headers and body
response. Hurl is very versatile: it can be used for both fetching data and
testing HTTP sessions.

Hurl makes it easy to work with HTML content, REST / SOAP / GraphQL APIs, or
any other XML / JSON based APIs.

### [Frood - an Alpine initramfs NAS](https://words.filippo.io/dispatches/frood)

My NAS, frood, has a bit of a weird setup. It’s just one big initramfs
containing a whole Alpine Linux system. It’s delightful and I am not sure why
it’s not more common.

### [XRechnung und ZUGFeRD mit LibreOffice - YouTube](https://m.youtube.com/watch?v=VDYWG_PZfPE)

hallo in diesem Video nur ganz kurz
gezeigt eine einfache und vor allem
kostenlose Möglichkeit xrechnungen zu
erstellen

Erledigte Ideen
---------------

### [Proot - chroot, mount --bind, and binfmt_misc without privilege/setup](https://proot-me.github.io/)

PRoot is a user-space implementation of chroot, mount --bind, and binfmt_misc. 
This means that users don't need any privileges or setup to do things like 
using an arbitrary directory as the new root filesystem, making files 
accessible somewhere else in the filesystem hierarchy, or executing programs 
built for another CPU architecture transparently through QEMU user-mode. Also, 
developers can use PRoot as a generic Linux process instrumentation engine 
thanks to its extension mechanism, see CARE for an example. Technically PRoot 
relies on ptrace, an unprivileged system-call available in every Linux kernel.

<!--
Veröffentlichungen:

- [PROOT: Dateisysteme ohne "roo]({{- ref "/blog/2025-01-07_proot-dateisystem-ohne-root" -}})
- [PROOT: Probleme bei langen Dateinamen]({{- ref "/blog/2025-01-10_proot-dateiname-maxlen" -}})
-->

<!--
Links
-----

- [PROOT: Dateisysteme ohne "roo]({{- ref "/blog/2025-01-07_proot-dateisystem-ohne-root" -}})
- [PROOT: Probleme bei langen Dateinamen]({{- ref "/blog/2025-01-10_proot-dateiname-maxlen" -}})
-->

Historie
--------

- 2025-01-06: PROOT ist erledigt
- 2025-01-01: Erste Version
