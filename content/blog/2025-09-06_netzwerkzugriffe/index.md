+++
date = '2025-09-06'
draft = false
title = 'Netzwerkzugriffe eines Programms ermitteln'
categories = [ 'linux' ]
tags = [ 'linux', 'ubuntu', 'debian' ]
+++

<!--
Netzwerkzugriffe eines Programms ermitteln
==========================================
-->

Einer meiner Kunden verwendet eine betreute MongoDB-Instanz ("Atlas").
Leider klappen mit der [MONGOSH](https://www.mongodb.com/docs/mongodb-shell/) die Zugriffe nicht. Ich erhalte
Zeitüberschreitungen (Timeouts). Die Gründe sind unklar!
Zur Analyse muß ich rausfinden, welche Netzwerkzugriffe versucht werden!

<!--more-->

Problembeschreibung
-------------------

Beim Versuch, eine Verbindung zur MongoDB-Instanz aufzubauen,
erhalte ich eine Fehlermeldung:

```
$ mongosh "mongodb+srv://(zensiert).mongodb.net?authSource=%24external&authMechanism=MONGODB-X509" --apiVersion 1 --tls --tlsCertificateKeyFile my-certificate.pem
MongoServerSelectionError: Server selection timed out after 30000 ms. It looks like this is a MongoDB Atlas cluster. Please ensure that your Network Access List allows connections from your IP.
```

Vermutung: Irgendwas mit dem Routing stimmt nicht! Die Zugriffe auf die MongoDB-Instanz werden nicht
über das Kunden-VPN geroutet! Sollte einfach zu korrigieren sein!

Also: Ermittlung der IP-Adressen

```
$ nslookup (zensiert).mongodb.net
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
*** Can't find (zensiert).mongodb.net: No answer
```

So einfach geht es nicht! Entgegen der naheliegenden Vermutung
versucht MONGOSH nicht direkt eine Verbindung zu "(zensiert).mongodb.net"
aufzubauen. Irgendwas anderes scheitert!

Ermittlung der Netzwerkzugriffe
-------------------------------

Zur Lösung muß ich zunächst ermitteln, welche
Netzwerkzugriffe die MONGOSH durchführt und welche
nicht klappen. Der Artikel
[StackOverflow - How to monitor all network traffic from a specific process in linux?](https://stackoverflow.com/questions/73332461/how-to-monitor-all-network-traffic-from-a-specific-process-in-linux)
gibt Hinweise:

```
$ strace -f -e trace=network -s 1000 0mongosh "mongodb+srv://(zensiert).mongodb.net?authSource=%24external&authMechanism=MONGODB-X509" --apiVersion 1 --tls --tlsCertificateKeyFile my-certificate.pem
strace: Process 4063243 attached
strace: Process 4063244 attached
...
[pid 4063242] socket(AF_INET, SOCK_STREAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 18
[pid 4063242] connect(18, {sa_family=AF_INET, sin_port=htons(27017), sin_addr=inet_addr("120.130.141.142")}, 16) = -1 EINPROGRESS (Vorgang ist jetzt in Bearbeitung)
MongoServerSelectionError: Server selection timed out after 30000 ms. It looks like this is a MongoDB Atlas cluster. Please ensure that your Network Access List allows connections from your IP.
...
```

Man sieht, dass der Zugriff auf die IP-Adresse "120.130.141.142" nicht klappt!

Routing-Korrektur und Schlusstest
---------------------------------

Routing-Korrektur:

```
$ sudo route add 120.130.141.142 gw 192.168.1.1
# VPN-Gateway ----------------------^^^^^^^^^^^
```

Schlusstest:

```
$ mongosh "mongodb+srv://(zensiert).mongodb.net?authSource=%24external&authMechanism=MONGODB-X509" --apiVersion 1 --tls --tlsCertificateKeyFile my-certificate.pem
Current Mongosh Log ID:	68bbdb411a4591f0ccfa334f
Connecting to:		mongodb+srv://(zensiert).mongodb.net/...
Using MongoDB:		7.0.23 (API Version 1)
Using Mongosh:		2.5.7

For mongosh info see: https://www.mongodb.com/docs/mongodb-shell/

Warning: Found ~/.mongorc.js, but not ~/.mongoshrc.js. ~/.mongorc.js will not be loaded.
  You may want to copy or rename ~/.mongorc.js to ~/.mongoshrc.js.
Atlas (zensiert)-shard-0 [primary] test> 
```

Es klappt - perfekt!

Links
-----

- [MONGOSH](https://www.mongodb.com/docs/mongodb-shell/) ... Mongodb-Shell
- [StackOverflow - How to monitor all network traffic from a specific process in linux?](https://stackoverflow.com/questions/73332461/how-to-monitor-all-network-traffic-from-a-specific-process-in-linux)

Versionen
---------

- Getestet mit Ubuntu 24.04.3 LTS

Historie
--------

- 2025-09-06: Erste Version
