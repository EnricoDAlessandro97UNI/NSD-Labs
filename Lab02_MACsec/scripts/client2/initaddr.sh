#!/bin/bash

ip link set dev eth0 address b0:b0:b0:b0:b0:b0
ip addr add 10.0.0.2/24 dev eth0