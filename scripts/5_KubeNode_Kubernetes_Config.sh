# Install the kubeadm package and its dependencies

echo "Step 1"
/sbin/iptables -P FORWARD ACCEPT

/usr/sbin/setenforce 0

iptables-save > /etc/sysconfig/iptables


#sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
#modprobe br_netfilter 


echo "Step 2"
#Add the external kubernetes repository (run as root)
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

echo "Step 3"
### install kubernetes
### to install Kubernetes 1.18.4-1 version pass VERSION as 1.18.4-1. Change VERSION accrodingly
### Tested and recommended to use VERSION=1.18.4-1 
VERSION=1.18.4-1
### The Kubernetes directory will be used for the /var/lib/kubelet file system and persistent volume storage.
### Make sure that /scratch/kubelet also has sufficient space for kubelet
mkdir /kubelet
ln -s /kubelet /var/lib/kubelet
### Install kubelet, kubeadm and kubectl
yum install -y kubelet-$VERSION kubeadm-$VERSION kubectl-$VERSION --disableexcludes=kubernetes
### enable kubelet service so that it auto-restart on reboot
systemctl enable --now kubelet

echo "Step 4"
#Ensure net.bridge.bridge-nf-call-iptables is set to 1 in your sysctl to avoid traffic routing issues ( run as root user)
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

echo "Step 5"
# Replace the IP address and port, 192.0.2.10:6443, with the IP address and port that is used by the API Server (the master node). Note that the default port is 6443
# Replace the --token value, 8tipwo.tst0nvf7wcaqjcj0, with a valid token for the master node.
# Replace the --discovery-token-ca-cert-hash value, f2a5b22b658683c3634459c8e7617c9d6c080c72dd149f3eb903445efe9d8346, with the correct SHA256 CA certificate hash that is used to sign the token certificate for the master node.

#UNCOMMENT AND CHANGE
#kubeadm join 10.241.115.219:6443 --token fir4cq.oumv9ihetyt8csh5 --discovery-token-ca-cert-hash sha256:8234ebc9213809d43e85977fccad748094368428fff5be1aac2c914aae5f1e30 --ignore-preflight-errors=Swap
#kubeadm join 10.0.0.9:6443 --token evksam.s0ucudqvgjwc7gia --discovery-token-ca-cert-hash sha256:1628521d351fa4981c230e066b77a11c118d29f558ab867323f3d0ad1aeab6bb