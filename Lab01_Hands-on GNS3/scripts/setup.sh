#!/bin/bash

ip addr add 10.0.0.3/24 dev enp0s8
ip link set enp0s8 up