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

### Nitrokey - PIN

[Nitrokey - PIN](https://docs.nitrokey.com/de/nitrokeys/nitrokey3/set-pins)

### DuckDB + Webassembly = WhatTheDuck

[DuckDB + Webassembly = WhatTheDuck](https://www.i-programmer.info/news/84-database/17726-duckdb-webassembly-whattheduck.html)

Run DuckDB inside your browser thanks to Webassembly. When is that useful?

Running a database instance inside a browser is nothing new.
I've already explored the idea in Running PostgreSQL Inside Your Browser With PGLite where I explained:

PGlite is a WASM Postgres build packaged into a TypeScript client library that enableyou to run Postgres in the browser with no need to install any other dependencies.

The concept here is the same. You get a local first application
disposable application without the hassle of having to set up anything.

Usually when I want to quickly load CSV files, store them in tables and perform SQL queries on the data, I use DBeaver where I setup the DuckDB driver as well the in-memory database and then load the CSV with "create table as".￼

Instead, with WhatTheDuck you just upload your files and are ready to go.

### Detecting the use of "curl | bash" server side

Meine Einschätzung: Schwierig zu beschreiben, schwierig ein Beispiel
umzusetzen!

- [Detecting the use of "curl | bash" server side](https://www.reddit.com/r/linux/comments/92tt8s/detecting_the_use_of_curl_bash_server_side/?rdt=59648)
- [https://www.idontplaydarts.com](https://www.idontplaydarts.com/2016/04/detecting-curl-pipe-bash-server-side/) - Zertifikat abgelaufen
- [The Dangers of curl | bash](https://lukespademan.com/blog/the-dangers-of-curlbash/)

### Copycat - A library for intercepting system calls

[Copycat](https://github.com/vimpostor/copycat)

A library for intercepting system calls.

This library allows you to overwrite system calls of arbitrary binaries in an intuitive way.
For example the following snippet tricks `cat` into opening another file than was given:
```bash
echo "a" > /tmp/a
echo "b" > /tmp/b
COPYCAT="/tmp/a /tmp/b" copycat -- cat /tmp/a # this will print "b"
# Success! cat was tricked into opening /tmp/b instead of /tmp/a
```

Internally `copycat` uses a modern [Seccomp Notifier](https://man7.org/linux/man-pages/man2/seccomp_unotify.2.html) implementation to reliably intercept system calls.
This is more elegant and much faster than usual `ptrace`-based implementations. However due to this relatively new Linux Kernel feature, `copycat` only works on **Linux 5.9** or higher. Additionally, due to a [Linux kernel bug not notifying the supervisor when a traced child terminates](https://lore.kernel.org/all/20240628021014.231976-2-avagin@google.com/), it is recommended to use **Linux 6.11** or higher.

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

### Anzeige einer Webseite mit abgelaufenen Zertifikat

- Alle Chrome-Prozesse stoppen
- Neuen Chrome-Prozess starten via Kommandozeile: `google-chrome-stable --ignore-certificate-errors`
- Diverse Warnungen ignorieren
- Nun klappts: [https://www.idontplaydarts.com](https://www.idontplaydarts.com/2016/04/detecting-curl-pipe-bash-server-side/) - Zertifikat abgelaufen
- Getestet mit Google-Chrome Version Version 131.0.6778.204 (Offizieller Build) (64-Bit)

<!--
Veröffentlichungen:

- [Chrome: Webseite mit abgelaufenem Zertifikat anzeigen]({{- ref "/blog/2025-01-17_chrome-abgelaufenes-zertifikat" -}})
-->

<!--
Links
-----

- [PROOT: Dateisysteme ohne "roo]({{- ref "/blog/2025-01-07_proot-dateisystem-ohne-root" -}})
- [PROOT: Probleme bei langen Dateinamen]({{- ref "/blog/2025-01-10_proot-dateiname-maxlen" -}})
- [Chrome: Webseite mit abgelaufenem Zertifikat anzeigen]({{- ref "/blog/2025-01-17_chrome-abgelaufenes-zertifikat" -}})
-->

Historie
--------

- 2025-01-06: PROOT ist erledigt
- 2025-01-01: Erste Version
