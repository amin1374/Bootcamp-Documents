To install Kubernetes, we need to perform the following steps on the master (controller) and worker servers.

Worker & Master Node Commands
```
sudo apt update && sudo apt upgrade -y
sudo hostnamectl set-hostname master ---> for Master
sudo hostnamectl set-hostname worker ---> for Worker
```
Add Worker and Master IPs mutually in /etc/hosts of both Master and Worker nodes
Now, according to the document related to installing Kubernetes, we run the following script.
```
#!/bin/bash
# Install and configure prerequisites
## load the necessary modules for Containerd
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

## setup the required kernel/sysctl parameters
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

## Apply sysctl params without reboot
sudo sysctl –system
sudo swapoff -a 
```
Now, considering that the container run time in our mind is containerd, we need to install its package, for which there are several ways.
```
sudo apt-get update
sudo apt-get -y install containerd
```
The challenge I encountered, according to the explanations given in the links below, is that the installed package is incompatible with version 22.04 and requires some changes in its configuration file, which was installed and launched during the tests carried out, but did not have the necessary stability. Some pods on it were restarted intermittently, so I tested another method to solve this problem

![Alt text](image.png)

```
https://github.com/kubernetes/kubernetes/issues/110177#issuecomment-1161647736
```
Using Docker Engine

According to the explanation given in the Docker document, after setting the DNS breaker, we install the program package
Docker Engine depends on containerd and runc. Docker Engine bundles these dependencies as one bundle: containerd.io
```
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
According to the documents related to containerd, the last method was to install the latest version through the binaries of containerd and runc cni plugin files.

https://github.com/containerd/containerd/blob/main/docs/getting-started.md

According to the description, all the exact steps were executed in both master and worker nodes.

`Step 1: Installing containers`

Download the containerd-<VERSION>-<OS>-<ARCH>.tar.gz archive from https://github.com/containerd/containerd/releases, verify its sha256sum, and extract it under /usr/local:
```
$ tar Cxzvf /usr/local containerd-1.6.2-linux-amd64.tar.gz
bin/
bin/containerd-shim-runc-v2
bin/containerd-shim
bin/ctr
bin/containerd-shim-runc-v1
bin/containerd
bin/containerd-stress
```
download the containerd.service unit file from https://raw.githubusercontent.com/containerd/containerd/main/containerd.service into /usr/local/lib/systemd/system/containerd.service
```
systemctl daemon-reload
systemctl enable --now containerd
```
Of course, some operating systems may not have all the paths mentioned, so folders that did not exist were created manually.
Now, according to the explanation given on the mentioned site, it is necessary to make changes in the config file
Containerd
Therefore, the following steps were taken.
```
sudo mkdir -p /etc/containerd
```
```
containerd config default | sudo tee /etc/containerd/config.toml
```
Edit the file and go to the section related to the containerd plugin in the corresponding file and the value
```
`SystemdCgroup = false`
```
We change it to true.
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
             BinaryName = ""
             CriuImagePath = ""
             CriuPath = ""
             CriuWorkPath = ""
             IoGid = 0
             IoUid = 0
             NoNewKeyring = false
             NoPivotRoot = false
             Root = ""
             ShimCgroup = ""
    SystemdCgroup = true
Now we restart the relevant service.
```
sudo systemctl restart containerd
```
After solving the problem, go through the rest of the steps related to the installation of the requirements, which include the installation of runc and the cni plugin.

Download the runc.<ARCH> binary from https://github.com/opencontainers/runc/releases , verify its sha256sum, and install it as /usr/local/sbin/runc.
```
install -m 755 runc.amd64 /usr/local/sbin/runc
```
## Install Cni Plugin

Download the cni-plugins-<OS>-<ARCH>-<VERSION>.tgz archive from https://github.com/containernetworking/plugins/releases , verify its sha256sum, and extract it under /opt/cni/bin:

mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.3.0.tgz
./
./macvlan
./static
./vlan
./portmap
./host-local
./vrf
./bridge
./tuning
./firewall
./host-device
./sbr
./loopback
./dhcp
./ptp
./ipvlan
./bandwidth

## Installed Version on This Document
```
Cni =1.3.0
Runc=1.1.9
Containerd=1.7.5
```
Finally, the latest version of Kubernetes, which is now version 1.28.1, was installed according to the description of the relevant document.

## Kubernetes package repositories

These instructions are for Kubernetes 1.28.
```
    1. Update the apt package index and install packages needed to use the Kubernetes apt repository:

    2. sudo apt-get update

    3. # apt-transport-https may be a dummy package; if so, you can skip that package

    4. sudo apt-get install -y apt-transport-https ca-certificates curl

    5. Download the public signing key for the Kubernetes package repositories. The same signing key is used for all repositories so you can disregard the version in the URL:

    6. curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    7. Add the appropriate Kubernetes apt repository:

    8. # This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list

    9. echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

    10. Update the apt package index, install kubelet, kubeadm and kubectl, and pin their version:

    11. sudo apt-get update
    12. sudo apt-get install -y kubelet kubeadm kubectl
    13. sudo apt-mark hold kubelet kubeadm kubectl

```
Now, considering that the cluster installation process must be done by `kubeadm`, we enter other commands in the master node.

Note that network should be done by Calico. According to the Calico document, pod-network-cidr=192.168.0.0/16 was inserted in the command.
```
sudo kubeadm init --apiserver-advertise-address=37.32.26.241 --pod-network-cidr=192.168.0.0/16
```
After completing the installation process, the given commands were entered.
To start using your cluster, you need to run the following as a regular user:
```
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
Also, the token for starting the Worker node is given here, which we save and put in the Worker node after the installation and setup of the cluster network is completed. Of course, it is possible to receive the token later.

Now we go to network installation and install calico according to the mentioned description.
```
https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart#install-calico
```
![Alt text](image-2.png)

Finally, all pods should be in the following state.
![Alt text](image-3.png)

After installing and setting up the master network and also installing the mentioned packages, the cluster is ready, it is enough to join the Worker node to the Master, and the corresponding command must be executed in the Worker node.

According to the explanation given in the document related to Kubernetes, we need to open the placed ports in the Master Worker nodes, which we open the ports with iptable
| Node | Port | Protocol | Description |
|---|---|---|---|
| Master | 6443 | TCP | Kubernetes API server |
| Master | 2379-2380 | TCP | etcd server client API |
| Master | 10250 | TCP | Kubelet API |
| Master | 10251 | TCP | kube-scheduler |
| Master | 10257 | TCP | kube-controller-manager |
| Master | 10255 | TCP | CRI-managed container runtime (Docker) |
| Worker | 10250 | TCP | Kubelet API |
| Worker | 30000-32767 | TCP | NodePort Services |

Example command
```
sudo iptables -A INPUT -p tcp --dport 6463 -j ACCEPT
```
Note that the changes made in iptables are not permanent and if the vm is restarted for any reason, all the items will be deleted, use the following package to save it permanently.
```
sudo apt install iptables-persistent
```
Also, in case of creating a pod with several replicas, in order to prevent the creation of a pod on the master node, execute the following command, and by executing this scheduler command, it will create a new pod on other workers.
```
kubectl taint nodes master node-role.kubernetes.io/master:NoSchedule
```

References
```
https://kubernetes.io/docs/reference/networking/ports-and-protocols/
https://kubernetes.io/docs/setup/production-environment/container-runtimes/
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm
https://www.tecmint.com/set-permanent-dns-nameservers-in-ubuntu-debian
https://deploy.equinix.com/blog/installing-and-deploying-kubernetes-on-ubuntu
https://github.com/containerd/containerd/blob/main/docs/getting-started.md
https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart
https://linuxconfig.org/how-to-make-iptables-rules-persistent-after-reboot-on-linux
```