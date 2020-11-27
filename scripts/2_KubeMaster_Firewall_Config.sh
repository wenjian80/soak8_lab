# Install the ntp package

yum install ntp
systemctl start ntpd
systemctl enable ntpd
iptables -P FORWARD ACCEPT
swapoff -a
/usr/sbin/setenforce 0
iptables-save > /etc/sysconfig/iptables

# Firewall setup

firewall-cmd --add-masquerade --permanent
firewall-cmd --add-port=10250/tcp --permanent
firewall-cmd --add-port=8472/udp --permanent

firewall-cmd --add-port=6443/tcp --permanent


systemctl disable firewalld
systemctl stop firewalld

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
