+++
date = '2025-05-18'
draft = false
title = 'Shell-Skripte wandeln in Binärdatei mit BUNSTER'
categories = [ 'linux' ]
tags = [ 'linux', 'ubuntu', 'debian' ]
+++

<!--
Shell-Skripte wandeln in Binärdatei
===================================
-->

Ich bin zufällig über
[dieses Video (Stop Releasing Shell Scripts. Do This Instead)](https://www.youtube.com/watch?v=R69FnBT00ew&t=337s)
gestolpert. Darin wird das Werkzeug BUNSTER vorgestellt.
Das wandelt Shell-Skripte in ausführbare Binärdateien.
Hier meine Erfahrungen.

<!-- more -->

## Herunterladen und installieren

Grobablauf:

- Passende Version von [Github - Bunster - Releases](https://github.com/yassinebenaid/bunster/releases/) herunterladen
  (ich verwende bunster_linux_amd64.tar.gz)
- Virencheck
- Auspacken

Also:

```
VERSION="v0.13.0"
INSTALL_DIR="${HOME}/mySoftware/bunster-${VERSION}"
curl -L https://github.com/yassinebenaid/bunster/releases/download/${VERSION}/bunster_linux-amd64.tar.gz >"bunster-${VERSION}_linux-amd64.tar.gz"
# virus check
mkdir "${INSTALL_DIR}"
gzip -cd "bunster-${VERSION}_linux-amd64.tar.gz"|( cd "${INSTALL_DIR}" && tar -xf - )
"${INSTALL_DIR}/bunster" --version
# shows "bunster version v0.12.1"
```

## Kurztest

Skript (Quelle: [Github GIST](https://gist.githubusercontent.com/d48/3501047/raw/791b8f2130851bd0312bbca26cc61938a45a0665/facebook-login.sh), ablegen unter /tmp/login.sh):

```bash
#!/bin/bash

EMAIL='YOUR_EMAIL' # edit this
PASS='YOUR_PASSWORD' # edit this

COOKIES='cookies.txt'
USER_AGENT='Firefox/3.5'

curl -X POST 'https://github.com/login' --verbose --user-agent $USER_AGENT --data-urlencode "name=${EMAIL}" --data-urlencode "pass=${PASS}" --cookie $COOKIES --cookie-jar $COOKIES
curl -X GET 'https://github.com/dashboard/pulls' --verbose --user-agent $USER_AGENT --cookie $COOKIES --cookie-jar $COOKIES
```

Wandeln:

```
"${INSTALL_DIR}/bunster" build /tmp/login.sh -o /tmp/login
```

Sichten - `ls -ln /tmp/login*` liefert:

```
-rwxrwxr-x 1 1000 1000 3233729 Mai 18 08:01 /tmp/login
-rw-rw-r-- 1 1000 1000     430 Mai 18 08:00 /tmp/login.sh
```

Test - `tmp/login` liefert:

```
Note: Unnecessary use of -X or --request, POST is already inferred.
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
...
```

Scheint zu klappen!

Geheimnisse
-----------

Im Video [Youtube - Stop Releasing Shell Scripts. Do This Instead](https://www.youtube.com/watch?v=R69FnBT00ew&t=337s)
wird die Wandlung vorgeschlagen, um Geheimnisse zu verstecken. Ein kurzer Test zeigt, dass das nicht gut klappt (klar!):

```
$ strings /tmp/login|grep YOUR_EMAIL
YOUR_EMAILUSER_AGENT/dev/stdinreaddirentpidfd_openpidfd_waitembed: %v
$ strings /tmp/login|grep YOUR_PASSWORD
...anynotnl -> YOUR_PASSWORDstop signal:...
```

Die Geheimnisse stecken also auch im Binärprogramm, sie sind nur schwieriger zu finden!
Ich denke, ich würde sie im Fall der Fälle finden auch ohne sie zu kennen.

Links
-----

- [Github - Bunster](https://github.com/yassinebenaid/bunster)
- [Youtube - Stop Releasing Shell Scripts. Do This Instead](https://www.youtube.com/watch?v=R69FnBT00ew&t=337s)

Versionen
---------

- Getestet mit Ubuntu 24.04.2 LTS

Historie
--------

- 2025-05-18: Erste Version
