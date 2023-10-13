#!/bin/bash

# script for sending double 802.1q frames with 
# native tools on Linux (we can use also scapy..)
ip link add link eth0 name eth0.1 type vlan id 1
ip link set eth0.1 up
ip link add link eth0.1 name eth0.1.20 type vlan id 20
ip link set eth0.1.20 up
ip addr add 10.0.20.250/24 dev eth0.1.20
arp -s 10.0.20.102 <client-MAC> -i eth0.1.20 #if mac not known use broadcast MAC