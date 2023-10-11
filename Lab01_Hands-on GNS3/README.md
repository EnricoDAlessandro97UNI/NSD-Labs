# Hands-on GNS3

## Step 1
Fare il setup della macchina virtuale Lubuntu mediante il network manager (scripts/lubuntu/setup.sh):
```
sudo ip addr add 10.0.0.3/24 dev enp0s8
sudo ip link set enp0s8 up
```