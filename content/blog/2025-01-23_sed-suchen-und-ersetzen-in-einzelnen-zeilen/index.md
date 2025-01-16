+++
date = '2025-01-23'
draft = false
title = 'SED: Suchen und Ersetzen in einzelnen Zeilen'
categories = [ 'SED' ]
tags = [ 'sed', 'linux' ]
+++

<!--
SED: Suchen und Ersetzen in einzelnen Zeilen
============================================
-->

Manchmal muß ich in Dateien bei einzelnen
Zeilen Zeichenketten suchen und ersetzen.

<!--more-->

Ausgangsdatei
-------------

[uli-blog.txt](uli-blog.txt):

```
Hugo, Hugo, Hugo!
Das ist dreimal Hugo
und damit Schluß!
```

Suchen und Ersetzen in gesamter Datei
-------------------------------------

Ich möchte in der Datei "uli-blog.txt" überall
die Zeichenkette "Hugo" durch "Heinz"
ersetzen:

```
$ sed -i -e "s/Hugo/Heinz/g" uli-blog.txt
$ cat uli-blog.txt
Heinz, Heinz, Heinz!
Das ist dreimal Heinz
und damit Schluß!
```

Suchen und Ersetzen nur in Komma-Zeilen
---------------------------------------

Ich möchte in der Datei "uli-blog.txt"
bei allen Zeilen mit Komma (",")
die Zeichenkette "Hugo" durch "Heinz"
ersetzen:

```
$ sed -i -e "/,/ s/Hugo/Heinz/g" uli-blog.txt
$ cat uli-blog.txt
Heinz, Heinz, Heinz!
Das ist dreimal Hugo
und damit Schluß!
```

Suchen und Ersetzen nur in Nicht-Komma-Zeilen
---------------------------------------

Ich möchte in der Datei "uli-blog.txt"
bei allen Zeilen ohne Komma (",")
die Zeichenkette "Hugo" durch "Heinz"
ersetzen:

```
$ sed -i -e "/,/! s/Hugo/Heinz/g" uli-blog.txt
$ cat uli-blog.txt
Hugo, Hugo, Hugo!
Das ist dreimal Heinz
und damit Schluß!
```

Suchen und Ersetzen nur in Zeile 2
----------------------------------

Ich möchte in der Datei "uli-blog.txt"
bei Zeile 2
die Zeichenkette "Hugo" durch "Heinz"
ersetzen:

```
$ sed -i -e "2 s/Hugo/Heinz/g" uli-blog.txt
$ cat uli-blog.txt
Hugo, Hugo, Hugo!
Das ist dreimal Heinz
und damit Schluß!
```

Suchen und Ersetzen in allen Zeilen außer Zeile 2
-------------------------------------------------

Ich möchte in der Datei "uli-blog.txt"
bei allen Zeilen außer Zeile 2
die Zeichenkette "Hugo" durch "Heinz"
ersetzen:

```
$ sed -i -e "2! s/Hugo/Heinz/g" uli-blog.txt
$ cat uli-blog.txt
Heinz, Heinz, Heinz!
Das ist dreimal Hugo
und damit Schluß!
```

Links
-----

TBD

Historie
--------

- 2025-01-23: Erste Version
