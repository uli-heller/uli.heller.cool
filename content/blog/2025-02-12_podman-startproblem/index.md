+++
date = '2025-02-12'
draft = false
title = 'LXC/LXD: Podman-Startproblem - newuidmap: write to uid_map failed'
categories = [ 'LXC/LXD' ]
tags = [ 'lxc', 'lxd', 'docker', 'podman', 'linux', 'ubuntu' ]
+++

<!--
LXC/LXD: Podman-Startproblem - newuidmap: write to uid_map failed
=================================================================
-->

Beim Starten von Podman als Nicht-Root-Benutzer erscheint eine
Fehlermeldung wie diese:

```sh
ubuntu@podman-2404:~$ podman run hello-world
ERRO[0000] running `/usr/bin/newuidmap 508 0 1000 1 1 100000 65536`: newuidmap: write to uid_map failed: Operation not permitted 
Error: cannot set up namespace using "/usr/bin/newuidmap": exit status 1
```

Hier beschreibe ich Ursache und Korrektur!

<!--more-->

Ursache
-------

Das Problem tritt auf, wenn man

- die SNAP-Version von LXD verwendet
- isolierte Nutzerkennungen verwendet (security.idmap.isolated)
- Podman im Container als Nicht-Root verwendet

Test
----

Im Container:

```sh
ubuntu@podman-2404:~$ cat /proc/self/uid_map
        0    1589824     65536
```

Man sieht: Es stehen 65536 UIDs zur Verfügung im Container.
Für den Podman-Start braucht man zusätzliche UIDs!

Abhilfe
-------

Im LXC/LXD-Host:

```sh
root@lxd-host:~# lxc config set podman-2404 security.idmap.size=700000
root@lxd-host:~# lxc stop podman-2404
root@lxd-host:~# lxc start podman-2404
```

Danach klappt `podman run hello-world`!

Versionen
---------

- Getestet unter Ubuntu 20.04 mit LXD-6.2-bde4d03
  (Snap-Version)
- Getestet mit Ubuntu-24.04-Container und Podman-4.9.3+ds1-1ubuntu0.2

Links
-----

- [linuxcontainers.org - Unable to run rootless docker/podman under a (rootless) LXD container](https://discuss.linuxcontainers.org/t/unable-to-run-rootless-docker-podman-under-a-rootless-lxd-container/15276)

Historie
--------

- 2025-02-12: Erste Version
