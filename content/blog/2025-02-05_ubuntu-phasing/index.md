root@ubuntu-2404:~# apt update
Hit:1 http://archive.ubuntu.com/ubuntu noble InRelease
Hit:2 http://archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:3 http://archive.ubuntu.com/ubuntu noble-backports InRelease
Hit:4 http://archive.ubuntu.com/ubuntu noble-security InRelease
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
14 packages can be upgraded. Run 'apt list --upgradable' to see them.
root@ubuntu-2404:~# apt upgrade -y
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Calculating upgrade... Done
The following upgrades have been deferred due to phasing:
  libnss-systemd libpam-systemd libsystemd-shared libsystemd0 libudev1 systemd
  systemd-dev systemd-resolved systemd-sysv systemd-timesyncd
The following packages have been kept back:
  libnetplan1 netplan-generator netplan.io python3-netplan
0 upgraded, 0 newly installed, 0 to remove and 14 not upgraded.
N: Some packages may have been kept back due to phasing.


Never-Include-Phased-Updates
----------------------------

... funktioniert nicht

root@ubuntu-2404:~# apt -o APT::Get::Never-Include-Phased-Updates=true upgrade -y
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Calculating upgrade... Done
The following upgrades have been deferred due to phasing:
  libnss-systemd libpam-systemd libsystemd-shared libsystemd0 libudev1 systemd
  systemd-dev systemd-resolved systemd-sysv systemd-timesyncd
The following packages have been kept back:
  libnetplan1 netplan-generator netplan.io python3-netplan
0 upgraded, 0 newly installed, 0 to remove and 14 not upgraded.
N: Some packages may have been kept back due to phasing.
root@ubuntu-2404:~# apt -o APT::Get::Never-Include-Phased-Updates=true -o Update-Manager::Never-Include-Phased-Updates upgrade -y
E: Option Update-Manager::Never-Include-Phased-Updates: Configuration item specification must have an =<val>.
root@ubuntu-2404:~# apt -o APT::Get::Never-Include-Phased-Updates=true -o Update-Manager::Never-Include-Phased-Updates=true upgrade -y
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Calculating upgrade... Done
The following upgrades have been deferred due to phasing:
  libnss-systemd libpam-systemd libsystemd-shared libsystemd0 libudev1 systemd
  systemd-dev systemd-resolved systemd-sysv systemd-timesyncd
The following packages have been kept back:
  libnetplan1 netplan-generator netplan.io python3-netplan
0 upgraded, 0 newly installed, 0 to remove and 14 not upgraded.
N: Some packages may have been kept back due to phasing.

apt policy ...
--------------

root@ubuntu-2404:~# apt policy systemd
systemd:
  Installed: 255.4-1ubuntu8.4
  Candidate: 255.4-1ubuntu8.5
  Version table:
     255.4-1ubuntu8.5 500 (phased 40%)
        500 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages
 *** 255.4-1ubuntu8.4 100
        100 /var/lib/dpkg/status
     255.4-1ubuntu8 500
        500 http://archive.ubuntu.com/ubuntu noble/main amd64 Packages

root@ubuntu-2404:~# apt policy libudev1
libudev1:
  Installed: 255.4-1ubuntu8.4
  Candidate: 255.4-1ubuntu8.5
  Version table:
     255.4-1ubuntu8.5 500 (phased 40%)
        500 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages
 *** 255.4-1ubuntu8.4 100
        100 /var/lib/dpkg/status
     255.4-1ubuntu8 500
        500 http://archive.ubuntu.com/ubuntu noble/main amd64 Packages
