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
### Get the nslookup IP address of master node to use with apiserver-advertise-address during Setting up Kubernetes master
ip_addr=`nslookup $(hostname -f) | grep -m2 Address | tail -n1| awk -F: '{print $2}'| tr -d " "`  
echo $ip_addr

#Setting up the Master node - To be run from  master node
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$ip_addr --ignore-preflight-errors=Swap

# Create the .kube subdirectory in your home directory
mkdir -p $HOME/.kube

# Create a copy of the Kubernetes admin.conf file in the .kube directory

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# Change the ownership of the file to match your regular user profile

sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Export the path to the file for the KUBECONFIG environment variable

export KUBECONFIG=$HOME/.kube/config

# Verify that you can use the kubectl command

kubectl get pods -n kube-system


# Get Token

token=`kubeadm token list | cut -d ' ' -f1`

# Get SSl 

output=`openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'`
output="SSL : "$output

# Display Token and SSL

echo $token

echo $output


#Install a pod network add-on: flannel (so that your pods can communicate with each other)
#Note : If you are using different cidr block other than default value of 10.244.0.0/16, then update kube-flannel.yml with correct cidr address before deploying into Cluster
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.12.0/Documentation/kube-flannel.yml
