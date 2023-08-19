#!/bin/bash

# 1. Create two namespaces named ns1 and ns2
sudo ip netns add ns1
sudo ip netns add ns2
echo "Two namespaces named ns1 and ns2 have been created."

# 2. Create a virtual network connection between the two namespaces
sudo ip link add veth1 type veth peer name veth2
sudo ip link set veth1 netns ns1
sudo ip link set veth2 netns ns2
echo "A virtual network connection between the two namespaces has been created."

# 3. Set IP addresses for each side of the network connection
sudo ip netns exec ns1 ip addr add 192.168.1.1/24 dev veth1
sudo ip netns exec ns2 ip addr add 192.168.1.2/24 dev veth2
echo "IP addresses have been set for each side of the network connection."

# 4. Activate each side of the network connection
sudo ip netns exec ns1 ip link set veth1 up
sudo ip netns exec ns2 ip link set veth2 up
echo "Each side of the network connection has been activated."

# 5. Test the network connection using ping between the two namespaces
sudo ip netns exec ns1 ping 192.168.1.2
echo "The network connection has been tested using ping between the two namespaces."
sudo ip netns exec ns1 ping google.com
