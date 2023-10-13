#!/bin/bash

ip link add link eth0 macsec0 type macsec
ip macsec add macsec0 tx sa 0 pn 1 on key 02 12345678901234567890123456789012
ip macsec add macsec0 rx address a0:a0:a0:a0:a0:a0 port 1
ip macsec add macsec0 rx address a0:a0:a0:a0:a0:a0 port 1 sa 0 pn 1 on key 01 09876543210987654321098765432109
ip link set macsec0 up
ip addr add 10.100.0.2/24 dev macsec0
# with this conf only integrity is on
# to encrypt: ip link set macsec0 type macsec encrypt on
# for antireply: ip link set macsec0 type macsec replay on 
# to test the configuration: ping 10.100.0.3 (check wireshark)