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

Always include
--------------

root@ubuntu-2404:~# apt -o APT::Get::Always-Include-Phased-Updates=true -o Update-Manager::Always-Include-Phased-Updates=true upgrade -y
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Calculating upgrade... Done
The following package was automatically installed and is no longer required:
  python3-netifaces
Use 'apt autoremove' to remove it.
The following NEW packages will be installed:
  ethtool systemd-hwe-hwdb udev
The following packages will be upgraded:
  libnetplan1 libnss-systemd libpam-systemd libsystemd-shared libsystemd0
  libudev1 netplan-generator netplan.io python3-netplan systemd systemd-dev
  systemd-resolved systemd-sysv systemd-timesyncd
14 upgraded, 3 newly installed, 0 to remove and 0 not upgraded.
Need to get 9379 kB of archives.
After this operation, 11.9 MB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libnss-systemd amd64 255.4-1ubuntu8.5 [159 kB]
Get:2 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 systemd-sysv amd64 255.4-1ubuntu8.5 [11.9 kB]
Get:3 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 systemd-timesyncd amd64 255.4-1ubuntu8.5 [35.3 kB]
Get:4 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 systemd-resolved amd64 255.4-1ubuntu8.5 [296 kB]
Get:5 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 systemd-dev all 255.4-1ubuntu8.5 [104 kB]
Get:6 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libpam-systemd amd64 255.4-1ubuntu8.5 [235 kB]
Get:7 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 systemd amd64 255.4-1ubuntu8.5 [3471 kB]
Get:8 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libsystemd-shared amd64 255.4-1ubuntu8.5 [2069 kB]
Get:9 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libsystemd0 amd64 255.4-1ubuntu8.5 [433 kB]
Get:10 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libudev1 amd64 255.4-1ubuntu8.5 [175 kB]
Get:11 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 netplan-generator amd64 1.1.1-1~ubuntu24.04.1 [60.8 kB]
Get:12 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 python3-netplan amd64 1.1.1-1~ubuntu24.04.1 [24.3 kB]
Get:13 http://archive.ubuntu.com/ubuntu noble/main amd64 ethtool amd64 1:6.7-1build1 [229 kB]
Get:14 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 udev amd64 255.4-1ubuntu8.5 [1874 kB]
Get:15 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 netplan.io amd64 1.1.1-1~ubuntu24.04.1 [68.5 kB]
Get:16 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libnetplan1 amd64 1.1.1-1~ubuntu24.04.1 [131 kB]
Get:17 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 systemd-hwe-hwdb all 255.1.4 [3200 B]
Fetched 9379 kB in 6s (1469 kB/s)                                              
(Reading database ... 18117 files and directories currently installed.)
Preparing to unpack .../0-libnss-systemd_255.4-1ubuntu8.5_amd64.deb ...
Unpacking libnss-systemd:amd64 (255.4-1ubuntu8.5) over (255.4-1ubuntu8.4) ...
Preparing to unpack .../1-systemd-sysv_255.4-1ubuntu8.5_amd64.deb ...
Unpacking systemd-sysv (255.4-1ubuntu8.5) over (255.4-1ubuntu8.4) ...
Preparing to unpack .../2-systemd-timesyncd_255.4-1ubuntu8.5_amd64.deb ...
Unpacking systemd-timesyncd (255.4-1ubuntu8.5) over (255.4-1ubuntu8.4) ...
Preparing to unpack .../3-systemd-resolved_255.4-1ubuntu8.5_amd64.deb ...
Unpacking systemd-resolved (255.4-1ubuntu8.5) over (255.4-1ubuntu8.4) ...
Preparing to unpack .../4-systemd-dev_255.4-1ubuntu8.5_all.deb ...
Unpacking systemd-dev (255.4-1ubuntu8.5) over (255.4-1ubuntu8.4) ...
Preparing to unpack .../5-libpam-systemd_255.4-1ubuntu8.5_amd64.deb ...
Unpacking libpam-systemd:amd64 (255.4-1ubuntu8.5) over (255.4-1ubuntu8.4) ...
Preparing to unpack .../6-systemd_255.4-1ubuntu8.5_amd64.deb ...
Unpacking systemd (255.4-1ubuntu8.5) over (255.4-1ubuntu8.4) ...
Preparing to unpack .../7-libsystemd-shared_255.4-1ubuntu8.5_amd64.deb ...
Unpacking libsystemd-shared:amd64 (255.4-1ubuntu8.5) over (255.4-1ubuntu8.4) ...
Preparing to unpack .../8-libsystemd0_255.4-1ubuntu8.5_amd64.deb ...
Unpacking libsystemd0:amd64 (255.4-1ubuntu8.5) over (255.4-1ubuntu8.4) ...
Setting up libsystemd0:amd64 (255.4-1ubuntu8.5) ...
(Reading database ... 18117 files and directories currently installed.)
Preparing to unpack .../libudev1_255.4-1ubuntu8.5_amd64.deb ...
Unpacking libudev1:amd64 (255.4-1ubuntu8.5) over (255.4-1ubuntu8.4) ...
Setting up libudev1:amd64 (255.4-1ubuntu8.5) ...
(Reading database ... 18117 files and directories currently installed.)
Preparing to unpack .../0-netplan-generator_1.1.1-1~ubuntu24.04.1_amd64.deb ...
Adding 'diversion of /lib/systemd/system-generators/netplan to /lib/systemd/syst
em-generators/netplan.usr-is-merged by netplan-generator'
Unpacking netplan-generator (1.1.1-1~ubuntu24.04.1) over (1.0.1-1ubuntu2~24.04.1
) ...
Preparing to unpack .../1-python3-netplan_1.1.1-1~ubuntu24.04.1_amd64.deb ...
Unpacking python3-netplan (1.1.1-1~ubuntu24.04.1) over (1.0.1-1ubuntu2~24.04.1) 
...
Selecting previously unselected package ethtool.
Preparing to unpack .../2-ethtool_1%3a6.7-1build1_amd64.deb ...
Unpacking ethtool (1:6.7-1build1) ...
Selecting previously unselected package udev.
Preparing to unpack .../3-udev_255.4-1ubuntu8.5_amd64.deb ...
Unpacking udev (255.4-1ubuntu8.5) ...
Preparing to unpack .../4-netplan.io_1.1.1-1~ubuntu24.04.1_amd64.deb ...
Unpacking netplan.io (1.1.1-1~ubuntu24.04.1) over (1.0.1-1ubuntu2~24.04.1) ...
Preparing to unpack .../5-libnetplan1_1.1.1-1~ubuntu24.04.1_amd64.deb ...
Unpacking libnetplan1:amd64 (1.1.1-1~ubuntu24.04.1) over (1.0.1-1ubuntu2~24.04.1
) ...
Selecting previously unselected package systemd-hwe-hwdb.
Preparing to unpack .../6-systemd-hwe-hwdb_255.1.4_all.deb ...
Unpacking systemd-hwe-hwdb (255.1.4) ...
Setting up systemd-dev (255.4-1ubuntu8.5) ...
Setting up libnetplan1:amd64 (1.1.1-1~ubuntu24.04.1) ...
Setting up libsystemd-shared:amd64 (255.4-1ubuntu8.5) ...
Setting up python3-netplan (1.1.1-1~ubuntu24.04.1) ...
Setting up ethtool (1:6.7-1build1) ...
Setting up systemd (255.4-1ubuntu8.5) ...
/usr/lib/tmpfiles.d/static-nodes-permissions.conf:18: Failed to resolve group 'k
vm': No such process
/usr/lib/tmpfiles.d/static-nodes-permissions.conf:19: Failed to resolve group 'k
vm': No such process
/usr/lib/tmpfiles.d/static-nodes-permissions.conf:20: Failed to resolve group 'k
vm': No such process
Setting up systemd-timesyncd (255.4-1ubuntu8.5) ...
Setting up udev (255.4-1ubuntu8.5) ...
Creating group 'input' with GID 994.
Creating group 'sgx' with GID 993.
Creating group 'kvm' with GID 992.
Creating group 'render' with GID 991.
systemd-udevd.service is a disabled or a static unit, not starting it.
Setting up systemd-hwe-hwdb (255.1.4) ...
Setting up netplan-generator (1.1.1-1~ubuntu24.04.1) ...
Removing 'diversion of /lib/systemd/system-generators/netplan to /lib/systemd/sy
stem-generators/netplan.usr-is-merged by netplan-generator'
Setting up systemd-resolved (255.4-1ubuntu8.5) ...
Setting up systemd-sysv (255.4-1ubuntu8.5) ...
Setting up libnss-systemd:amd64 (255.4-1ubuntu8.5) ...
Setting up netplan.io (1.1.1-1~ubuntu24.04.1) ...
Setting up libpam-systemd:amd64 (255.4-1ubuntu8.5) ...
Processing triggers for dbus (1.14.10-4ubuntu4.1) ...
Processing triggers for libc-bin (2.39-0ubuntu8.3) ...

apt policy ...
--------------

root@ubuntu-2404:~# apt policy systemd
systemd:
  Installed: 255.4-1ubuntu8.5
  Candidate: 255.4-1ubuntu8.5
  Version table:
 *** 255.4-1ubuntu8.5 500 (phased 40%)
        500 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages
        100 /var/lib/dpkg/status
     255.4-1ubuntu8 500
        500 http://archive.ubuntu.com/ubuntu noble/main amd64 Packages


root@ubuntu-2404:~# apt policy libudev1
libudev1:
  Installed: 255.4-1ubuntu8.5
  Candidate: 255.4-1ubuntu8.5
  Version table:
 *** 255.4-1ubuntu8.5 500 (phased 40%)
        500 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages
        100 /var/lib/dpkg/status
     255.4-1ubuntu8 500
        500 http://archive.ubuntu.com/ubuntu noble/main amd64 Packages
