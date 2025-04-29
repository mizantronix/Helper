# commands 

echo "mizantronix ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/mizantronix
apt install -y software-properties-common apt-transport-https ca-certificates gnupg2 gpg sudo net-tools
swapoff -a

# nano /etc/fstab
# here you need to remove/comment swap.img

rm /swap.img
reboot

####

modprobe overlay -v
modprobe br_netfilter -v
echo "overlay" >> /etc/modules
echo "br_netfilter" >> /etc/modules
echo 1 > /proc/sys/net/ipv4/ip_forward

# nano /etc/sysctl.conf
# here you need to add net.ipv4.ip_forward = 1

sysctl -p
reboot 

####

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
apt update 
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

export OS="xUbuntu_22.04"
export VERSION=1.28

curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | apt-key add -
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

apt update

apt install -y cri-o cri-o-runc
systemctl start crio
systemctl enable crio
systemctl status crio

# auth keys

# master - kubeadm init --pod-network-cidr=10.100.0.0/16 --dry-run
# worker - kubeadm join ip --token token