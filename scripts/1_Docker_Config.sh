# Install Docker Engine on the machine

docker_version="19.03.1.ol"
yum install docker-engine-$docker_version

systemctl enable docker
systemctl start docker

#docker login container-registry.oracle.com -u $1 -p $2

#export KUBE_REPO_PREFIX=container-registry.oracle.com/kubernetes
#echo 'export KUBE_REPO_PREFIX=container-registry.oracle.com/kubernetes' 


