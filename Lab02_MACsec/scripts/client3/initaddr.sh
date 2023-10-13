#!/bin/bash

ip link set dev eth0 address c0:c0:c0:c0:c0:c0
ip addr add 10.0.0.3/24 dev eth0