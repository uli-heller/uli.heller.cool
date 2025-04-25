#!/bin/bash
#

#
# Isolierten Benutzerkennungen
#
for es in /etc/subuid /etc/subgid; do
  for u in root; do
    grep "^${u}:100000:1000000000" "${es}" >/dev/null && continue
    if grep "^${u}:" "${es}" >/dev/null 2>&1; then
      sed -i -e "s/^${u}:.*/${u}:100000:1000000000" "${es}"
    else
      echo "${u}:100000:1000000000" >>"${es}"
    fi
  done
done
incus profile set default security.idmap.isolated=true
systemctl restart incus.service

#
# Netzwerk-Brücken
#
incus network info incushostonly >/dev/null 2>&1 || {
  incus network create incushostonly ipv4.address=10.2.210.1/24 ipv4.nat=false ipv6.address=none
}
incus network info incusnat >/dev/null 2>&1 || {
  incus network create incusnat ipv4.address=10.38.231.1/24 ipv4.nat=true ipv6.address=none
}
incus profile device set default eth0 network=incusnat

incus network info incusbr0 >/dev/null 2>&1 && {
  incus network delete incusbr0
}

#
# DNS
#
for bridge in incushostonly incusnat; do
ipaddress="$(incus network get ${bridge} ipv4.address|cut -d "/" -f 1)"
cat >/etc/systemd/system/incus-dns-${bridge}.service <<EOF
[Unit]
Description=INCUS per-link DNS configuration for ${bridge}
BindsTo=sys-subsystem-net-devices-${bridge}.device
After=sys-subsystem-net-devices-${bridge}.device

[Service]
Type=oneshot
ExecStart=/usr/bin/resolvectl dns ${bridge} ${ipaddress}
ExecStart=/usr/bin/resolvectl domain ${bridge} ~incus
ExecStart=/usr/bin/resolvectl dnssec ${bridge} off
ExecStart=/usr/bin/resolvectl dnsovertls ${bridge} off
ExecStopPost=/usr/bin/resolvectl revert ${bridge}
RemainAfterExit=yes

[Install]
WantedBy=sys-subsystem-net-devices-${bridge}.device
EOF
systemctl daemon-reload
systemctl enable --now incus-dns-${bridge}
done
