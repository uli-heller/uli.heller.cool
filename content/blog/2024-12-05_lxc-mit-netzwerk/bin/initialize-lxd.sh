#!/bin/bash
#

#
# Isolierten Benutzerkennungen
#
for es in /etc/subuid /etc/subgid; do
  for u in lxd root; do
    grep "^${u}:" "${es}" >/dev/null 2>&1 || {
      echo "${u}:100000:1000000000" >>"${es}"
    }
  done
done
systemctl restart "$(systemctl |grep -o '[\s][^\s]*lxd\.daemon\.service')"

#
# Netzwerk-Brücken
#
lxc network create lxdhostonly ipv4.address=10.2.210.1/24 ipv4.nat=false ipv6.address=none
lxc network create lxdnat ipv4.address=10.38.231.1/24 ipv4.nat=true ipv6.address=none
lxc profile device set default eth0 network=lxdnat

#
# DNS
#
for bridge in lxdhostonly lxdnat; do
ipaddress="$(lxc network get ${bridge} ipv4.address)"
cat >/etc/systemd/system/lxd-dns-${bridge}.service <<EOF
[Unit]
Description=LXD per-link DNS configuration for ${bridge}
BindsTo=sys-subsystem-net-devices-${bridge}.device
After=sys-subsystem-net-devices-${bridge}.device

[Service]
Type=oneshot
ExecStart=/usr/bin/resolvectl dns ${bridge} ${ipaddress}
ExecStart=/usr/bin/resolvectl domain ${bridge} ~lxd
ExecStart=/usr/bin/resolvectl dnssec ${bridge} off
ExecStart=/usr/bin/resolvectl dnsovertls ${bridge} off
ExecStopPost=/usr/bin/resolvectl revert ${bridge}
RemainAfterExit=yes

[Install]
WantedBy=sys-subsystem-net-devices-${bridge}.device
EOF
systemctl daemon-reload
systemctl enable --now lxd-dns-${bridge}
done
