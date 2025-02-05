+++
date = '2025-02-09'
draft = false
title = 'Podman - Speicherplatz'
categories = [ 'Podman' ]
tags = [ 'podman', 'linux', 'ubuntu' ]
+++

<!--
Podman - Speicherplatz
======================
-->

Bei der Verwendung von Podman und PodmanCompose
werden Images heruntergeladen, gespeichert
und ausgeführt. Hier möchte ich untersuchen,
wo die Daten abliegen und wie ich sie bereinigen
kann.

<!--more-->

root
----

```
root@podman:~# podman image ls
REPOSITORY                     TAG         IMAGE ID      CREATED      SIZE
docker.io/library/hello-world  latest      74cc54e27dc4  2 weeks ago  27.1 kB

root@podman:~# podman container ps -a
CONTAINER ID  IMAGE                                 COMMAND     CREATED     STATUS                 PORTS       NAMES
ca7764721d89  docker.io/library/hello-world:latest  /hello      6 days ago  Exited (0) 6 days ago              brave_chatterjee
```

### Speicherort

/var/lib/containers/storage/overlay-images

### Aufräumen

```
root@podman:~# podman container prune -f
ca7764721d8926dc9110d211c032aeb2b97fc57dbc1ba6d5d48337429eb03351

root@podman:~# podman image rm hello-world
Untagged: docker.io/library/hello-world:latest
Deleted: 74cc54e27dc41bb10dc4b2226072d469509f2f22f1a3ce74f4a59661a1d44602
```

ubuntu
------

```
root@podman:~# sudo -u ubuntu -i podman image ls
REPOSITORY                     TAG         IMAGE ID      CREATED       SIZE
docker.io/library/hello-world  latest      74cc54e27dc4  2 weeks ago   27.1 kB
docker.io/library/nginx        alpine      93f9c72967db  2 months ago  48.5 MB
docker.io/library/ubuntu       latest      b1d9df8ab815  2 months ago  80.6 MB
```

### Speicherort

/home/ubuntu/.local/share/containers/storage/overlay

```
root@podman:~# du -hs /home/ubuntu/.local/share/containers/storage/overlay
133M	/home/ubuntu/.local/share/containers/storage/overlay
```

### Aufräumen

```
root@podman:~# sudo -u ubuntu -i podman container prune -f
f338e08c9e3ef1819938a5b8f75257d26cc9fb09ab0bb3c79f07aadcb79b6634
2d5e5e8aaaea19567c617ea810eb7f8a52a0e531172fce2387bf77cba2edf79f
3a9222cb719bafc9abf28c14cbdaf45fdb6de3eb87f0de8fb82922e794d95be8
78e5a68a19c0b4793743572519d0d471f0be8912fa2e0013a9b0a00468eddb7a
878f64eb0be7bdc1c9aaa8f45d199faecb4a2684fbad67c09e89c9f41e694c30

root@podman:~# sudo -u ubuntu -i podman image rm hello-world
Untagged: docker.io/library/hello-world:latest
Deleted: 74cc54e27dc41bb10dc4b2226072d469509f2f22f1a3ce74f4a59661a1d44602

root@podman:~# sudo -u ubuntu -i podman image rm nginx:alpine
Untagged: docker.io/library/nginx:alpine
Deleted: 93f9c72967dbcfaffe724ae5ba471e9568c9bbe67271f53266c84f3c83a409e3

root@podman:~# sudo -u ubuntu -i podman image rm ubuntu
Untagged: docker.io/library/ubuntu:latest
Deleted: b1d9df8ab81559494794e522b380878cf9ba82d4c1fb67293bcf931c3aa69ae4

root@podman:~# du -hs /home/ubuntu/.local/share/containers/storage/overlay
4.0K	/home/ubuntu/.local/share/containers/storage/overlay
```

Versionen
---------

- Getestet mit einem Ubuntu-24.04-Container
  und podman-4.9.3+ds1-1ubuntu0.2
  und podman-compose-1.0.6-1

Links
-----

- [LXC/LXD: Podman im Container mit Ubuntu-24.04]({{< ref "/blog/2025-02-01_lxc-podman-2404" >}})

Historie
--------

- 2025-02-09: Erste Version
