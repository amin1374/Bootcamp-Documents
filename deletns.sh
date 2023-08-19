
#!/bin/bash

# 1. حذف دو namespace با نام‌های ns1 و ns2
sudo ip netns delete ns1
sudo ip netns delete ns2
echo "دو namespace با نام‌های ns1 و ns2 حذف شدند."

# 2. حذف اتصال شبکه مجازی بین دو namespace
sudo ip link delete veth1
echo "اتصال شبکه مجازی بین دو namespace حذف شد."

# 3. حذف تنظیمات آدرس IP برای هر طرف اتصال شبکه
sudo ip addr del 192.168.1.1/24 dev veth1
sudo ip addr del 192.168.1.2/24 dev veth2
echo "تنظیمات آدرس IP برای هر طرف اتصال شبکه حذف شد."

# 4. غیرفعال کردن هر طرف اتصال شبکه
sudo ip link set veth1 down
sudo ip link set veth2 down
echo "هر طرف اتصال شبکه غیرفعال شد."
