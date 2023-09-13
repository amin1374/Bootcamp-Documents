#!/bin/bash

# 1. ایجاد دو namespace با نام‌های ns1 و ns2
sudo ip netns add ns1
sudo ip netns add ns2
echo "دو namespace با نام‌های ns1 و ns2 ایجاد شدند."

# 2. ایجاد اتصال شبکه مجازی بین دو namespace
sudo ip link add veth1 type veth peer name veth2
sudo ip link set veth1 netns ns1
sudo ip link set veth2 netns ns2
echo "اتصال شبکه مجازی بین دو namespace ایجاد شد."

# 3. تنظیم آدرس IP برای هر طرف اتصال شبکه
sudo ip netns exec ns1 ip addr add 192.168.1.1/24 dev veth1
sudo ip netns exec ns2 ip addr add 192.168.1.2/24 dev veth2
echo "آدرس IP برای هر طرف اتصال شبکه تنظیم شد."

# 4. فعال کردن هر طرف اتصال شبکه
sudo ip netns exec ns1 ip link set veth1 up
sudo ip netns exec ns2 ip link set veth2 up
echo "هر طرف اتصال شبکه فعال شد."

# 5. تنظیم محدودیت دسترسی بین دو namespace
sudo ip netns exec ns1 iptables -A OUTPUT -o veth1 -j ACCEPT
sudo ip netns exec ns1 iptables -A INPUT -i veth1 -j ACCEPT
sudo ip netns exec ns2 iptables -A OUTPUT -o veth2 -j ACCEPT
sudo ip netns exec ns2 iptables -A INPUT -i veth2 -j ACCEPT
echo "محدودیت دسترسی بین دو namespace تنظیم شد."

# 6. غیرفعال کردن فورواردینگ بین دو namespace
sudo ip netns exec ns1 sysctl -w net.ipv4.ip_forward=0
sudo ip netns exec ns2 sysctl -w net.ipv4.ip_forward=0
echo "فورواردینگ بین دو namespace غیرفعال شد."
