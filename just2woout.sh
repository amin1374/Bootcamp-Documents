#!/bin/bash

# 1. Create two namespaces named ns1 and ns2
sudo ip netns add ns1
sudo ip netns add ns2
echo "Two namespaces named ns1 and ns2 have been created."

# 2. Create a virtual network connection between the two namespaces
sudo ip link add veth1 type veth peer name veth2
sudo ip link set veth1 netns ns1
sudo ip link set veth2 netns ns2
echo "A virtual network connection has been created between the two namespaces."

# 3. Configure IP addresses for each side of the network connection
sudo ip netns exec ns1 ip addr add 192.168.1.1/24 dev veth1
sudo ip netns exec ns2 ip addr add 192.168.1.2/24 dev veth2
echo "IP addresses have been configured for each side of the network connection."

# 4. Enable the network connection on each side
sudo ip netns exec ns1 ip link set veth1 up
sudo ip netns exec ns2 ip link set veth2 up
echo "The network connection on each side has been enabled."

# 5. Set up access restrictions between the two namespaces
sudo ip netns exec ns1 iptables -A OUTPUT -o veth1 -j ACCEPT
sudo ip netns exec ns1 iptables -A INPUT -i veth1 -j ACCEPT
sudo ip netns exec ns2 iptables -A OUTPUT -o veth2 -j ACCEPT
sudo ip netns exec ns2 iptables -A INPUT -i veth2 -j ACCEPT
echo "Access restrictions between the two namespaces have been set up."

# 6. Disable forwarding between the two namespaces
sudo ip netns exec ns1 sysctl -w net.ipv4.ip_forward=0
sudo ip netns exec ns2 sysctl -w net.ipv4.ip_forward=0
echo "Forwarding between the two namespaces has been disabled."

# 7. Test ping between the two namespaces
sudo ip netns exec ns1 ping -c 5 192.168.1.2
sudo ip netns exec ns2 ping -c 5 192.168.1.1

# 8. Test external network access with ping to Google
sudo ip netns exec ns1 ping -c 5 8.8.8.8

# 9. Delete the namespaces and the virtual network connection
sudo ip netns delete ns1
sudo ip netns delete ns2
sudo ip link delete veth1
echo "The two namespaces and the virtual network connection have been deleted."

# 10. Delete the access restrictions between the two namespaces
sudo ip netns exec ns1 iptables -D OUTPUT -o veth1 -j ACCEPT
sudo ip netns exec ns1 iptables -D INPUT -i veth1 -j ACCEPT
sudo ip netns exec ns2 iptables -D OUTPUT -o veth2 -j ACCEPT
sudo ip netns exec ns2 iptables -D INPUT -i veth2 -j ACCEPT
echo "The access restrictions between the two namespaces have been deleted."
