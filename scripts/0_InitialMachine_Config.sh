# https://docs.oracle.com/en/operating-systems/oracle-linux/kubernetes/ol_about_kubernetes.html
# Yum Configuration

yum-config-manager --enable ol7_addons

# Setting up UEK R5

yum-config-manager --disable ol7_UEKR4
yum-config-manager --enable ol7_UEKR5
yum update

