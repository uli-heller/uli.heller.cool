+++
date = '2025-02-06'
draft = false
title = 'LXC/LXD: Podman Compose'
categories = [ 'LXC/LXD' ]
tags = [ 'lxc', 'lxd', 'docker', 'podman', 'linux', 'ubuntu' ]
+++

<!--
LXC/LXD: Podman Compose
=======================
-->

Ich möchte ausprobieren, ob "podman compose"
grundsätzlich funktioniert und ob man dabei
ohne "root" klarkommt.

<!--more-->

Ausgangspunkt
-------------

Container mit Podman, bspw.

- [LXC/LXD: Podman im Container mit Ubuntu-24.04]({{- ref "/blog/2025-02-01_lxc-podman-2404" -}})
- [LXC/LXD: Podman im Container mit Ubuntu-22.04]({{- ref "/blog/2025-02-03_lxc-podman-2204" -}})

Sichten von [Github: podman-compose](https://github.com/containers/podman-compose).

"podman-compose" einspielen
---------------------------

### Vorgefertigtes Paket

```
lxc exec podman apt install podman-compose
```

Damit wird Version 1.0.6-1 eingespielt.

### Manuell

TODO: Noch nicht fertig!

- Herunterladen: [podman-compose-1.3.0.tar.gz](https://github.com/containers/podman-compose/archive/refs/tags/v1.3.0.tar.gz)
- Virencheck via Virustotal: OK
- LXC-Container starten: `lxc start podman`
- "podman-compose" in LXC-Container kopieren:
  - Entweder: `scp podman-compose-1.3.0.tar.gz ubuntu@podman.lxd:`
  - Oder: `lxc exec podman --user 1000 --group 1000 --cwd /home/ubuntu tee podman-compose-1.3.0.tar.gz >/dev/null <podman-compose-1.3.0.tar.gz`
- Auspacken:
  ```
  uheller:~$ lxc exec podman -- sudo -u ubuntu -i

  ubuntu@podman:~$ gzip -cd podman-compose-1.3.0.tar.gz|tar xf - podman-compose-1.3.0/podman_compose.py
  ubuntu@podman:~$ mkdir -p ~/.local/bin
  ubuntu@podman:~$ mv podman-compose-1.3.0/podman_compose.py ~/.local/bin
  ubuntu@podman:~$ ln -s podman-compose ~/.local/bin/podman_compose.py
  ```

Kurztest
--------

Übernommen aus [daemons-point.com: Docker mit docker-compose in LXD/LXC-Container](https://daemons-point.com/blog/2022/12/26/docker-compose-in-lxc-container/) und  [DigitalOcean: How To Install and Use Docker Compose on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04).

### Projektverzeichnis anlegen

```
ubuntu@podman:~$ mkdir -p compose-demo/app
```

### compose-demo/app/index.html

```html
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Docker Compose Demo</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/kognise/water.css@latest/dist/dark.min.css">
</head>
<body>

    <h1>This is a Docker Compose Demo Page.</h1>
    <p>This content is being served by an Nginx container.</p>

</body>
</html>
```

### compose-demo/docker-compose.yml

```yml
version: '3.7'
services:
  web:
    image: nginx:alpine
    ports:
      - "8000:80"
    volumes:
      - ./app:/usr/share/nginx/html
```

### Ausführen

```
ubuntu@podman:~$ cd compose-demo/
ubuntu@podman:~/compose-demo $ podman-compose up -d
```

Probleme
--------

### Error: short-name "nginx:alpine" did not resolve

```
ubuntu@podman:~/compose-demo$ podman-compose up -d
podman-compose version: 1.0.6
['podman', '--version', '']
using podman version: 4.9.3
** excluding:  set()
['podman', 'ps', '--filter', 'label=io.podman.compose.project=compose-demo', '-a', '--format', '{{ index .Labels "io.podman.compose.config-hash"}}']
['podman', 'network', 'exists', 'compose-demo_default']
['podman', 'network', 'create', '--label', 'io.podman.compose.project=compose-demo', '--label', 'com.docker.compose.project=compose-demo', 'compose-demo_default']
['podman', 'network', 'exists', 'compose-demo_default']
podman run --name=compose-demo_web_1 -d --label io.podman.compose.config-hash=1267f1fcc2605edffffac19ad9686d7cb3f189e3f1fa80ccc2e27e3d4d8b2e66 --label io.podman.compose.project=compose-demo --label io.podman.compose.version=1.0.6 --label PODMAN_SYSTEMD_UNIT=podman-compose@compose-demo.service --label com.docker.compose.project=compose-demo --label com.docker.compose.project.working_dir=/home/ubuntu/compose-demo --label com.docker.compose.project.config_files=docker-compose.yml --label com.docker.compose.container-number=1 --label com.docker.compose.service=web -v /home/ubuntu/compose-demo/app:/usr/share/nginx/html --net compose-demo_default --network-alias web -p 8000:80 nginx:alpine
Error: short-name "nginx:alpine" did not resolve to an alias and no unqualified-search registries are defined in "/etc/containers/registries.conf"
exit code: 125
podman start compose-demo_web_1
Error: no container with name or ID "compose-demo_web_1" found: no such container
exit code: 125
```

Versionen
---------

- Getestet unter Ubuntu 22.04 mit LXD-6.2-bde4d03
  (Snap-Version)
- Getestet mit Ubuntu-24.04 und Ubuntu-22.04-Containern
  jeweils mit Docker und Podman

Links
-----

- [LXC/LXD: Podman im Container mit Ubuntu-24.04]({{- ref "/blog/2025-02-01_lxc-podman-2404" -}})
- [LXC/LXD: Podman im Container mit Ubuntu-22.04]({{- ref "/blog/2025-02-03_lxc-podman-2204" -}})
- [Github - Ubuntu 24.04 AppArmor breaks pivot_root inside LXD containers](https://github.com/canonical/lxd/issues/13389)
- [daemons-point.com - Docker in LXD/LXC-Container](https://daemons-point.com/blog/2022/12/25/docker-in-lxc-container/)

Historie
--------

- 2025-02-05: Erste Version
