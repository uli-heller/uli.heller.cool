#!/bin/bash
#

#
# Netzwerk-Brücken
#
lxc network create lxdhostonly ipv4.address=10.2.210.1/24 ipv4.nat=false ipv6.address=none
lxc network create lxdnat ipv4.address=10.38.231.1/24 ipv4.nat=true ipv6.address=none
lxc profile device set default eth0 network=lxdnat

#
# DNS
#
