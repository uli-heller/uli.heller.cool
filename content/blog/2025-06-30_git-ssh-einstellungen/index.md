+++
date = '2025-06-30'
draft = false
title = 'Git: SSH-Einstellungen anpassen'
categories = [ 'Git' ]
tags = [ 'git' ]
+++

<!--Git: SSH-Einstellungen anpassen-->
<!--===============================-->

Manchmal möchte ich "spezielle" SSH-Einstellungen
beim Ausführen von GIT-Kommandos verwenden, bspw.
um zu testen ob ein neuer SSH-Schlüssel bei Github
funktioniert.

Bislang ist dann immer "Google" mein Freund.
Jetzt schreib ich mir's mal auf, eventuell finde
ich es dann schneller!

<!--more-->

Wann wird SSH bei GIT verwendet?
--------------------------------

SSH wird bei GIT primär verwendet, wenn Kommunikation
mit einem zentralen Git-Repo erfolgt und eine entsprechende
"Remote-URL" hinterlegt ist- Die "Remote-URL" kann man sich
mit `git remote -v` anzeigen lassen:

- "git@github.com" -> das ist eine Remote-URL, die SSH verwendet
- "https://github.com" -> das ist eine Remote-URL, die kein SSH verwendet sondern HTTPS

Kommunikation mit einem zentralen Git-Repo erfolgt beispielsweise
bei diesen Git-Kommandos:

- `git clone ...`
- `git push ...`
- `git fetch ...`
- `git pull ...`

Welche SSH-Einstellungen werden verwendet?
------------------------------------------

Per Standard liegen die Einstellungen in der Datei "$HOME/.ssh/config".
Details zu den Einstellunge sind den Anleitungen zu SSH zu entnehmen!

Wie überschreibe ich die SSH-Einstellung?
-----------------------------------------

Wenn ich bspw. die Verwendung eines bestimmten SSH-Schlüssels erzwingen will,
so führe ich

- statt: `git fetch --all`
- dies aus: `GIT_SSH_COMMAND='ssh -v -i $HOME/.ssh/uheller-privkey -o IdentitiesOnly=yes -o IdentityAgent=none' git fetch --all`

Klappt wunderbar!

Links
-----

- [Github](https://github.com)
- [.ssh/config](https://linux.die.net/man/5/ssh_config)
- [ssh](https://linux.die.net/man/1/ssh)

Historie
--------

- 2025-06-30: Erste Version
