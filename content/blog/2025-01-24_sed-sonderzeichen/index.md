+++
date = '2025-01-24'
draft = false
title = 'SED: Suchen und Ersetzen mit "Sonderzeichen"'
categories = [ 'SED' ]
tags = [ 'sed', 'linux' ]
+++

<!--
SED: Suchen und Ersetzen mit "Sonderzeichen"
============================================
-->

Manchmal muß ich in Dateien 
Zeichenketten suchen und ersetzen.
Das geht mit SED und Kommandos wie
`sed -i -e s/suche/ersetze/ dateiname`.
Kompliziert wird's, wenn in der Such- oder
Ersatzzeichenkette ein Schrägstrich enthalten ist.

<!--more-->

Einfache Ersetzung
------------------

```
$ SUCHE="Ernie"
$ ERSETZE="Bert"
$ echo "Ernie war da"|sed -e "s/${SUCHE}/${ERSETZE}/"
Bert war da
```

Ersetzung mit Schrägstrich
--------------------------

```
$ SUCHE="Apfel/Birne"
$ ERSETZE="Kirsche/Erdbeere"
$ echo "Ich esse gerne Apfel/Birne"|sed -e "s/${SUCHE}/${ERSETZE}/"
sed: -e Ausdruck #1, Zeichen 15: Unbekannte Option für »s«
```

Das klappt wohl nicht!

```
$ maskiere () { echo "$1"|sed -e "s,/,\\\/,g"; }
$ SUCHE="$(maskiere "Apfel/Birne")"
$ ERSETZE="$(maskiere "Kirsche/Erdbeere")"
$ echo "Ich esse gerne Apfel/Birne"|sed -e "s/${SUCHE}/${ERSETZE}/"
Ich esse gerne Kirsche/Erdbeere
```

Viel besser!

Ersetzen mit weiteren "Sonderzeichen"
-------------------------------------

Insbesondere:

- "/"
- "(" und ")"

Unklar:

- "[" und "]"
- "\"

Das geht mit:

```
$ maskiere () { echo "$1"|sed -e "s,\([/()]\),\\\\\1,g"; }
```

Lösungsvorschlag aus StackOverflow
----------------------------------

[StackOverflow - Escape a string for a sed replace pattern](https://stackoverflow.com/questions/407523/escape-a-string-for-a-sed-replace-pattern):

```
$ maskiere_suche () { echo "$1" | sed -e 's/[]\/$*.^[]/\\&/g'; }
$ maskiere_ersetze () { echo "$1" | sed -e  's/[\/&]/\\&/g'; }
$ SUCHE="$(maskiere_suche "Ein [Text] mit &Sonder(Zeichen)")"
$ ERSETZE="$(maskiere_ersetze "/meine/ Ersetzung&")"
$ echo "Dies ist Ein [Text] mit &Sonder(Zeichen)"|sed -e "s/${SUCHE}/${ERSETZE}/g"
Dies ist /meine/ Ersetzung&
```

Links
-----

- [StackOverflow - Escape a string for a sed replace pattern](https://stackoverflow.com/questions/407523/escape-a-string-for-a-sed-replace-pattern)

Historie
--------

- 2025-01-24: Erste Version
