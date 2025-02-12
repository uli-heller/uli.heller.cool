+++
date = '2025-02-13'
draft = false
title = 'SSH: Anmeldeproblem mit Ubuntu-22.04'
categories = [ 'SSH' ]
tags = [ 'ssh', 'linux', 'ubuntu' ]
+++

<!--
SSH: Anmeldeproblem mit Ubuntu-22.04
====================================
-->

Ich nutze SSH-Schlüssel zum Anmelden auf diversen
Serverrechnern. Heute habe ich festgestellt, dass ich
mich mit meinem Laptop auf einem der Uraltrechner nicht
mehr anmelden kann.

<--more-->

Abgleich der SSH-Schlüssel
--------------------------

Erster Ansatz: Mir fehlt der richtige SSH-Schlüssel!

Kann ich ausschliessen!

- Arbeitsplatzrechner: `ssh -i $HOME/.ssh/uheller-rsa old-server` klappt
- Laptop: `ssh -i $HOME/.ssh/uheller-rsa old-server` klappt nicht!

Detaillierte Protokollierung
----------------------------

```sh
$ ssh -v -i $HOME/.ssh/uheller-rsa old-server
OpenSSH_8.9p1 Ubuntu-3ubuntu0.10, OpenSSL 3.0.2 15 Mar 2022
debug1: Reading configuration data /home/uheller/.ssh/config
...
debug1: rekey in after 134217728 blocks
debug1: get_agent_identities: bound agent to hostkey
debug1: get_agent_identities: agent returned 6 keys
debug1: Will attempt key: /home/uheller/.ssh/uheller-rsa RSA SHA256:h7Xg0Eg5bOp/L0HswSMtwxs0lbNX0hOtRmBqX5qjseg explicit agent
...
debug1: Next authentication method: publickey
debug1: Offering public key: /home/uheller/.ssh/uheller-rsa RSA SHA256:h7Xg0Eg5bOp/L0HswSMtwxs0lbNX0hOtRmBqX5qjseg explicit agent
debug1: send_pubkey_test: no mutual signature algorithm
...
```

Google-Suche
------------

[SSH-RSA key rejected with message "no mutual signature algorithm"](https://confluence.atlassian.com/bitbucketserverkb/ssh-rsa-key-rejected-with-message-no-mutual-signature-algorithm-1026057701.html)

Cause

The RSA SHA-1 hash algorithm is being quickly deprecated across operating systems and SSH clients because of various security vulnerabilities, with many of these technologies now outright denying the use of this algorithm.

Also: Ich sollte den RSA-Schlüssel wohl schnellstmöglich tauschen
durch einen moderneren!

Aktivierung von RSA
-------------------

```
$ ssh -o 'PubkeyAcceptedKeyTypes=+ssh-rsa' -i $HOME/.ssh/uheller-rsa old-server
Welcome to Ubuntu 14.04.6 LTS (GNU/Linux 4.4.0-148-generic x86_64)
#
```

Mit der Option "-o 'PubkeyAcceptedKeyTypes=+ssh-rsa'" klappt es!
Offenbar muß ich nicht nur den RSA-Schlüssel dringend tauschen,
sondern auch den "old-server" neu aufsetzen. Ist ja noch ein Uralt-Ubuntu,
das längst nicht mehr aktualisiert wird. Zum Glück ist der Server
üblicherweise ausgeschaltet!

Versionen
---------

- Getestet unter Ubuntu 20.04 - da klappt es problemlos
- Getestet unter Ubuntu 22.04 - da gibt es die Schwierigkeiten

Links
-----

- [SSH-RSA key rejected with message "no mutual signature algorithm"](https://confluence.atlassian.com/bitbucketserverkb/ssh-rsa-key-rejected-with-message-no-mutual-signature-algorithm-1026057701.html)

Historie
--------

- 2025-02-13: Erste Version
