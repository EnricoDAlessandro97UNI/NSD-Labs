#!/bin/bash

ip link set dev eth0 address a0:a0:a0:a0:a0:a0
ip addr add 10.0.0.1/24 dev eth0