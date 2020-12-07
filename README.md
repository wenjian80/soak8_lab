
# Disclaimer

1. Please refer to [documentation](https://github.com/wenjian80/soak8_labs#oracle-reference-links) for proper steps.
2. The scripts provided are just a reference.

# Purpose
1. The purpose of this lab excerise is to minc the same environment setup on premise, although the exact steps can be also run in OKE (Oracle Cloud Kubenetes Engine)
2. We are using an external database as the soa repository.
3. We are installing k8 from scratch. In this lab however we are not creating a HA for master node. We can refer to K8 documentation on how to set it up.
4. For lab purpose we are using 1 master and 1 worker. Deployment are done in worker node as master are not tainted to run workload.
5. Since soa on k8 require a PV/PVC, in on prem context it will either a NFS or san storage etc. In this lab we are using Oracle Cloud File System to act as the NFS.
6. For lab purpose, i have build an image and upload to docker hub so we are pulling straight from docker hub registry. In real life we are pulling and tagging into our own registry. Refer to [docker images](https://github.com/oracle/docker-images), [wls docker sample](https://github.com/wenjian80/wlsdockersample) for more details on building own image as well as patching etc.
7. The official supported image is via this [here](https://oracle.github.io/fmw-kubernetes/soa-domains/installguide/prepare-your-environment/#obtain-the-oracle-soa-suite-docker-image), however in this lab we are just pulling from docker hub. The image is public so therefore no secret is required. 
8. All the command have been compress into scripts for easy execution, you can take a look all the scripts to see what is doing as there are comments in the scripts. 
9. At this point of writing this document, it is using all the prereq as mentioned in [prereq](https://github.com/wenjian80/soak8_lab#2-version-tested), other than K8/Docker/Helm we are pulling WebLogic operator 3.0.1 and fmw soa script 20.3.3. Refer to [FMW SOA K8](https://oracle.github.io/fmw-kubernetes/soa-domains/installguide/prerequisites/) and [Release Notes](https://oracle.github.io/fmw-kubernetes/soa-domains/release-notes/) to check what is the latest version that is supported and pull the relevant branch.
10. We are using [20.3.3](https://github.com/oracle/fmw-kubernetes/tree/release/20.3.3/OracleSOASuite/kubernetes)  branch at the point of writing this document. Perhaps a new version will be release when you reading this document, 
11. Take a look [K8/Wls_Operator 101](https://github.com/wenjian80/soak8_lab/tree/main/slides) to understand the concept of k8 and the operator,


# 1. Prereq
1. Please follow the prereq to set your environment ready.  Follow the instruction on [prereq](https://github.com/wenjian80/soak8_lab/blob/main/prereq.md)
2. You should already have your labinfo.txt fill up on hand. We will be referencing those info in these exercise.
3. Open up the script to look at the various command before executing. 
4. Do follow the steps carefully and look at the instruction on 
	- To run script on master or worker node or both
	- To Change the parameters in the script
	
# 2. Version Tested
1.  [Oracle Linux 7.9 OCI Iaas Image](https://docs.cloud.oracle.com/en-us/iaas/images/)
2. [Docker version 19.03.1.ol](https://docs.docker.com/engine/release-notes/)
3. [Kubernetes 1.18.4-1](https://kubernetes.io/docs/setup/)
4. [Helm 3.4.1](https://helm.sh/)
5. [Oracle Dbaas 19.9.0.0.0](https://docs.oracle.com/en/database/oracle/oracle-database/)
6. [Weblogic Operator 3.0.1 ](https://github.com/oracle/weblogic-kubernetes-operator.git)
7. [FMW Kubernetes 20.3.3 ](https://github.com/oracle/fmw-kubernetes.git)
8. [Kube-Prometheus 0.6.0](https://github.com/prometheus-operator/kube-prometheus/tree/master)
9. [Oracle SOA 12.2.1.4 container registry ](https://container-registry.oracle.com/pls/apex/f?p=113:4:106885074376611:::4:P4_REPOSITORY,AI_REPOSITORY,AI_REPOSITORY_NAME,P4_REPOSITORY_NAME,P4_EULA_ID,P4_BUSINESS_AREA_ID:252,252,Oracle%20SOA%20Suite,Oracle%20SOA%20Suite,1,0&cs=3xzEuKbyTjyKLe-4Re2u8kpgzYt9IeGor4rR9qoIDbXZAjmMArQ6_1td_9Ms5dAmFpfbfEjpHiKmLbB9VfMsTBQ)
10. [Traefik chart 1.87.7/ App 1.7.26](https://github.com/helm/charts/blob/master/stable/traefik/Chart.yaml) 

# 3. Lab steps

Below are the steps you need to run
1. [Clone all lab materials [Run on master and worker]](https://github.com/wenjian80/soak8_lab#clone-all-lab)
2. [Replace the settings with your environment [Run on master and worker]](https://github.com/wenjian80/soak8_lab#replace-the-settings-with-your-environment)
3. [Step 00: Set Parameters  [Run on master and worker]](https://github.com/wenjian80/soak8_lab#step-00-set-parameters)
4. [Step 0: 0_InitialMachine_Config.sh [Run on master and worker]](https://github.com/wenjian80/soak8_lab#step-0-0_initialmachine_configsh)
5. [Step 1: 1_Docker_Config.sh [Run on master and worker]](https://github.com/wenjian80/soak8_lab#step-1-1_docker_configsh)
6. [Step 2: 2_KubeMaster_Firewall_Config.sh [Run only on master]](https://github.com/wenjian80/soak8_lab#step-2-2_kubemaster_firewall_configsh)
7. [Step 3: 3_KubeNode_Firewall_Config.sh [Run only worker]](https://github.com/wenjian80/soak8_lab#step-3-3_kubenode_firewall_configsh)
8. [Step 4: 4_KubeMaster_Kubernetes_Config.sh [Run only master]](https://github.com/wenjian80/soak8_lab#step-4-4_kubemaster_kubernetes_configsh)
9. [Step 5: 5_KubeNode_Kubernetes_Config.sh [Run only worker]](https://github.com/wenjian80/soak8_lab#step-5-5_kubenode_kubernetes_configsh)
10. [Step 6: 6_Check_Kubedns.sh [Run only master]](https://github.com/wenjian80/soak8_lab#step-6-6_check_kubednssh)
11. [Step 7: 7_Kube_proxy.sh [Run only master]](https://github.com/wenjian80/soak8_lab#step-7-7_kube_proxysh)
12. [Step 8: 8_Git_helm.sh [Run only master]](https://github.com/wenjian80/soak8_lab#step-8-8_git_helmsh)
13. [Step 9: 9_Operator.sh [Run only master]](https://github.com/wenjian80/soak8_lab#step-9-9_operatorsh)
14. [Step 10: 10_Rcu.sh [Run only master]](https://github.com/wenjian80/soak8_lab#step-10-10_rcush)
15. [Step 11: 11_Soa_secret.sh [Run only master]](https://github.com/wenjian80/soak8_lab#step-11-11_soa_secretsh)
16. [Step 12: 12_Mount_File.sh [Run on master and worker]](https://github.com/wenjian80/soak8_lab#step-12-12_mount_filesh)
17. [Step 13: 13_Soa_pv.sh [Run only master]](https://github.com/wenjian80/soak8_lab#step-13-13_soa_pvsh)
18. [Step 14: 14_Soa_DomainJob.sh [Run only master]](https://github.com/wenjian80/soak8_lab#step-14-14_soa_domainjobsh)
19. [Step 15: 15_Soa_DomainConfig.sh [Run only master]](https://github.com/wenjian80/soak8_lab#step-15-15_soa_domainconfigsh)
20. [ Step 16: 16_Traefik_LB.sh [Run only master]](https://github.com/wenjian80/soak8_lab#step-16-16_traefik_lbsh)
21. [Step 17: 17_Efk.sh [Run only master]](https://github.com/wenjian80/soak8_lab#step-17-17_efksh)
22. [Step 18: 18_Prom_Gra.sh [Run only master]](https://github.com/wenjian80/soak8_lab#step-18-18_prom_grash)
23. [Step 19: 19_Prom_Setting.sh [Run only master]](https://github.com/wenjian80/soak8_lab#step-19-19_prom_settingsh)


###  Clone all lab 
 materials
### Steps to follow
It will take you around 1 Hour to run finished the excercise.

```
#Steps to follow
#Read below for exact instruction

#Go to https://github.com/wenjian80/soak8_lab and download as zip to local machine so you can take a llok att he scripts.

#login master
sudo su
yum install git
cd /home/opc
git clone https://github.com/wenjian80/soak8_lab
chmod -R 777 /home/opc/soak8_lab

#login worker
sudo su
yum install git
cd /home/opc
git clone https://github.com/wenjian80/soak8_lab
chmod -R 777 /home/opc/soak8_lab
```

1. Exercise are running as root for lab purpose. Login to as opc, sudo su.
2. Download this git project as zip on your local machine.
3. Login to your master and worker node
4. Create a folder call soak8_lab in both master and worker node in path /home/opc/
5. Winscp and copy the scripts folder into /home/opc/soak8_lab/scripts
6. sudo su 
7. chmod -R 777 /home/opc/soak8_lab
8. All these scripts are referencing and the path in /home/opc/soak8_lab and /home/opc/soak8_lab/scripts , so pls follow the naming.


### Replace the settings with your environment

Open up your labinfo.txt and get the information on hand.

1) Login to both master and worker node.
2) Open up [00_setVariable.sh](https://github.com/wenjian80/soak8_lab/blob/main/scripts/00_setVariable.sh) and update your settings


```
vi 00_setVariable.sh

#Update the below based on "Database private ip" in your labinfo.txt
DATABASEIP=put ip here
#DATABASEIP=10.0.0.4

#This is not required as we are pulling from public docker hub
#Update the below based on "Oracle account username/password" in your labinfo.txt
#USERID=put uid here
#PASSWORD=put pwd phere
#USERID=wenjian80@gmail.com
#PASSWORD=Welcome_1234#


#Update the below based on "Database subnet" in your labinfo.txt
SUBNET=put subnet here
#SUBNET=subnet11251534.vcn11251534.oraclevcn.com

#Update the below based on "NFS IP" in your labinfo.txt
NFSIP=put ip here
#NFSIP=10.0.0.6

# save the file
#Check content again
more 00_setVariable.sh
```

## Step 00: Set Parameters
Replace the settings with your environment

**[Run on master and worker node]**

**Steps to follow**
```
#Steps to follow
#Read below for exact instruction

#login master
sudo su
cd /home/opc/soa_k8lab/scripts
vi 00_setVariable.sh
#make sure all your settings is correct
./00_setVariable.sh

#login worker
sudo su
cd /home/opc/soa_k8lab/scripts
vi 00_setVariable.sh
#make sure all your settings is correct
./00_setVariable.sh
```

1. This script need to run on both master and worker node.
2. We are setting up the parameters for your environment.

## Step 0: 0_InitialMachine_Config.sh
**[Run on master and worker node]**

**Steps to follow**
```
#Steps to follow
#Read below for exact instruction

#login master
sudo su
cd /home/opc/soa_k8lab/scripts
./0_InitialMachine_Config.sh

#login worker
sudo su
cd /home/opc/soa_k8lab/scripts
./0_InitialMachine_Config.sh
```

1. This script need to run on both master and worker node.
2. We are setting up the yum repository in this script So the installation will make use the of the yum repository.




## Step 1: 1_Docker_Config.sh
**[Run on master and worker node]**

**Steps to follow**
```
#Steps to follow
#Read below for exact instruction

#login master
sudo su
cd /home/opc/soa_k8lab/scripts
./1_Docker_Config.sh

#login worker
sudo su
cd /home/opc/soa_k8lab/scripts
./1_Docker_Config.sh
```

 Refer to [K8 documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) for more details.
 
1. This script need to run on both master and worker node.
2. We are using docker  version 19.03.1.ol in this lab.



## Step 2: 2_KubeMaster_Firewall_Config.sh
**[Run on master node ONLY]**

### Steps to follow
```
#Steps to follow
#Read below for exact instruction

#login master
sudo su
cd /home/opc/soa_k8lab/scripts
./2_KubeMaster_Firewall_Config.sh
```

 Refer to [K8 documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) for more details.
 
1. **This script run on on master node ONLY.**
2. Kuberenetes require certain pre-req and firewall to communcation between master and worker nodes.  Refer to [K8 documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) for more details.
3. We are disabling the firewall on linux for lab purpose.




## Step 3: 3_KubeNode_Firewall_Config.sh
**[Run on worker node ONLY]**

### Steps to follow
```
#Steps to follow
#Read below for exact instruction

#login worker
sudo su
cd /home/opc/soa_k8lab/scripts
./3_KubeNode_Firewall_Config.sh
```

 Refer to [K8 documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) for more details.
 
1. **This script run on on worker node ONLY.**
2. Same as step 2. We are setting the pre-req for k8.




## Step 4: 4_KubeMaster_Kubernetes_Config.sh
**[Run on master node ONLY]**

### Steps to follow
```
#Steps to follow
#Read below for exact instruction

#login master
sudo su
cd /home/opc/soa_k8lab/scripts
./4_KubeMaster_Kubernetes_Config.sh

#Check master node ready
kubectl get no

#Copy the join command to use in step 5
```

 Refer to [K8 documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) for more details.
 
 1. **This script run on on master node ONLY.** Once the prereq has been set. 
 2. We are running the steps to set up this node as the master
    node.     
 3. At the end of this script it will provide you a command for
    worker node to join the cluster and communicate to this master node.

![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/master_ready.JPG)

4. **You will need to copy the last output of the kubeadm join on step 5 for the worker node to join the cluster**

5. Run the below command to check if master is ready. Wait until it is ready before proceed step 5.

```
kubectl get no
```
![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/workerready.JPG)





## Step 5: 5_KubeNode_Kubernetes_Config.sh
**[Run on worker node ONLY]**

### Steps to follow
```
#Steps to follow
#Read below for exact instruction

#Login worker
sudo su
#Open the 5_KubeNode_Kubernetes_Config.sh and add the join command

cd /home/opc/soa_k8lab/scripts
./5_KubeNode_Kubernetes_Config.sh

#Check worker node ready
kubectl get no
```

 Refer to [K8 documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) for more details.
 
 1. **This script run on on worker node ONLY.**
    **. Open and edit the script on the below line and change it to the previous output in step 4.**

    kubeadm join 10.0.0.9:6443[CHANGEIT] --token evksam.s0ucudqvgjwc7gia[CHANGEIT] --discovery-token-ca-cert-hash sha256:1628521d351fa4981c230e066b77a11c118d29f558ab867323f3d0ad1aeab6bb[CHANGEIT]

  
 2.  Once tyou have edit the script and run the command, you will see that your worker node has join the cluster.

![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/node_ready.JPG)

3. Now go in the master node and type the below command to check the status. You see see the worker node is ready.

```
kubectl get po
```

![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/workerready.JPG)




## Step 6: 6_Check_Kubedns.sh
**[Run on master node ONLY]**

### Steps to follow
 ```
#Steps to follow
#Read below for exact instruction

#Login master
sudo su
cd /home/opc/soa_k8lab/scripts
./6_Check_Kubedns.sh
```

Refer to [Debugging Dns](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/) for more details

1. **This script run on on master node ONLY.**
2. This steps is to check if k8 networking is setup properly and the nodes can communicate via cluster ip and k8 networking.
3. You should see the below if all the k8 networking is running fine.

![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/dns.JPG)
 



## Step 7: 7_Kube_proxy.sh
**[Run on master node ONLY]**

### Steps to follow
 ```
#Steps to follow
#Read below for exact instruction

#Login master
sudo su
cd /home/opc/soa_k8lab/scripts
./7_Kube_proxy.sh

#After which run kubectl proxy
kubectl proxy

#Open broswer to http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
```

Refer to [K8 Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) for more details

1. **This script run on on master node ONLY.**
2. K8 dashboard is not deploy by default.
3. This script is to enabled the dashboard and create the RBAC for the dashboard.
4. It will print out a token for you to login to the dashboard.
5. Run the below command line

```
kubectl proxy
```
![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/kubectlproxy.JPG)

5. And use the token to login to the dashbaord. The tunnel create in the prereq is use to tunnel to to the dashboard. Press Ctl+C to stop the proxy

http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login




## Step 8: 8_Git_helm.sh
**[Run on master node ONLY]**

### Steps to follow
 ```
#Steps to follow
#Read below for exact instruction

#Login master
sudo su
cd /home/opc/soa_k8lab/scripts
./8_Git_helm.sh

```

1. **This script run on on master node ONLY.**
2. This script is to install Git and Helm 3.
3. Git is use to pull the git repo later to be use and helm is use to install various component via helm chart.




## Step 9: 9_Operator.sh
**[Run on master node ONLY]**

### Steps to follow
 ```
#Steps to follow
#Read below for exact instruction

#Login master
sudo su
cd /home/opc/soa_k8lab/scripts
./9_Operator.sh

#see all resource and pod
kubectl get po -n soans
kubectl get all -A

#Check operator is running befroe proceed
kubectl get po -n opns

```

Refer to  [prepare your Oracle SOA Suite in Kubernetes environment](https://oracle.github.io/fmw-kubernetes/soa-domains/installguide/prepare-your-environment/) for more details.

1. **This script run on on master node ONLY.**
2.  The script pull the necessary repo to install weblogic operator and scripts.
3. it also create the necessary k8 namespace to be used, such as soans, opns.
4. soans is the namespace to install soa, opns is the namespace to install operator.
5. You will have to specify -n command to get specific resource such as 


Get po for namespace soans
```
kubectl get po -n soans
```

Get po for namespace opns
```
kubectl get po -n opns
```

Get all resource all namespace
```
kubectl get all -A
```


## Step 10: 10_Rcu.sh
**[Run on master node ONLY]**

### Steps to follow
 ```
#Steps to follow
#Read below for exact instruction

#Login master
sudo su
#Your Parameters should have been in step 00, double check again
#grep -na "ip" database.yaml
#Eg sed -i 's/IPCHANGE/10.0.0.4/g' database.yaml


#This section is not required since we are pulling for public docker hub.
#Your Parameters should have been in step 00, double check again
#grep -na "docker-username" 10_Rcu.sh
#grep -na "docker-password" 10_Rcu.sh
#Eg sed -i 's/UIDCHANGE/wenjian80@gmail.com/g' 10_Rcu.sh 
#Eg sed -i 's/PWDCHANGE/Welcome_1234#/g' 10_Rcu.sh


#Your Parameters should have been in step 00, double check again
#grep -na "PDB1" 10_Rcu.sh
#Eg sed -i 's/VCNCHANGE/subnet11251534.vcn11251534.oraclevcn.com/g' 10_Rcu.sh

cd /home/opc/soa_k8lab/scripts
./10_Rcu.sh

#Please wait for the script to finish. Refer to below for the output you should be seeing.
#It will wait a while to pull the contaier to start. While it is waiting , open a new window to master node and run the below to check the progress and if there is any error.
kubectl describe po rcu -n soans

```


Refer to  [prepare your Oracle SOA Suite in Kubernetes environment](https://oracle.github.io/fmw-kubernetes/soa-domains/installguide/prepare-your-environment/) for more details.

1. **This script run on on master node ONLY.**
2. This script is to pull a image to run the soa rcu creation against an external database.
3. **You need to make change to the below before running the script**

### **Change database ip**

1. Open up your [database.yaml](https://github.com/wenjian80/soak8_labs/blob/main/scripts/database.yaml) and search for the ip. You are going to replace it.
2. Open up your labinfo.txt, find what is your database ip and change that in [database.yaml](https://github.com/wenjian80/soak8_labs/blob/main/scripts/database.yaml) 
3. The script is reference external database where by k8 will reference database.soans.svc.cluster.local in k8 network context. The conveention is [name].[namespace].svc.cluster.local
4. You need to change the below ip

```
     -addresses:
             -ip: IPCHANGE
```
5. You can run the below to change the ip or open up to edit it.

```
sed -i 's/IPCHANGE/[YOURIP]/g' database.yaml
Eg  sed -i 's/IPCHANGE/10.0.0.1/g' database.yaml
Eg sed -i 's/IPCHANGE/10.0.0.4/g' database.yaml
```
### **Chnage username and password**
1. Open up [10_Rcu.sh](https://github.com/wenjian80/soak8_labs/blob/main/scripts/10_Rcu.sh), you need to replace $1 and $2 with your oracle account username and password
2. Open up your labinfo.txt, find what is your Oracle account username/password and replace it. This is the account to login to container-registry.oracle.com. You must accept the agreement otherwise it will have error.
3. You need to change the username and password
```
--docker-username=UIDCHANGE --docker-password=PWDCHANGE
```
4. You can use the below command to change or open up and edit it

```
Eg sed -i 's/UIDCHANGE/a.a@a.com/g' 10_Rcu.sh
Eg sed -i 's/PWDCHANGE/Acs@#!_/g' 10_Rcu.sh

Eg sed -i 's/UIDCHANGE/wenjian80@gmail.com/g' 10_Rcu.sh
Eg sed -i 's/PWDCHANGE/Welcome_1234#/g' 10_Rcu.sh
*My password here is just a temp, no there is nothing to hack if you want to use this :)
```

## **Change the database vcn name**
1. Open up [10_Rcu.sh](https://github.com/wenjian80/soak8_labs/blob/main/scripts/10_Rcu.sh), you need to replace the vcn domain naming with the naming you have jot down in your labinfo.txt.
2. pdb1 is the pdb database creation that we have provision the database.
3. You need to change the subnet dns naming that you have jotdown in your labinfo.txt
```
PDB1.VCNCHANGE
```
4. You can use the below command to change or open up and edit it

```
sed -i 's/VCNCHANGE/aaa.aaa.comEg sed -i 's/VCNCHANGE/[Your vcn]/g' 10_Rcu.sh
Eg sed -i 's/VCNCHANGE/aaa.aaa.com.com/g' 10_Rcu.sh
Eg sed -i 's/VCNCHANGE/subnet11251534.vcn11251534.oraclevcn.com/g' 10_Rcu.sh
```
### **Script output**
The output of the script will be as such. It will take around 3-5min.

![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/rcu_complete.JPG)




## Step 11: 11_Soa_secret.sh
**[Run on master node ONLY]**

### Steps to follow
 ```
#Steps to follow
#Read below for exact instruction

#Login master
sudo su
cd /home/opc/soa_k8lab/scripts
./11_Soa_secret.sh

```

Refer to  [prepare your Oracle SOA Suite in Kubernetes environment](https://oracle.github.io/fmw-kubernetes/soa-domains/installguide/prepare-your-environment/) for more details.

1. **This script run on on master node ONLY.**
2. This script is to create the necessary secret to be used in the later steps

## Step 12: 12_Mount_File.sh
**[Run on master and worker node]**

### Steps to follow
 ```
#Steps to follow
#Read below for exact instruction

#Login master
sudo su
#Your Parameters should have been in step 00, double check again
#grep -na "mount" 12_Mount_File.sh
#Eg sed -i 's/IPCHANGE/10.0.0.6/g' 12_Mount_File.sh


cd /home/opc/soa_k8lab/scripts
./12_Mount_File.sh

#Login worker
sudo su
#Your Parameters should have been in step 00, double check again
#grep -na "mount" 12_Mount_File.sh
#Eg sed -i 's/IPCHANGE/10.0.0.6/g' 12_Mount_File.sh


cd /home/opc/soa_k8lab/scripts
./12_Mount_File.sh

```

Refer to  [prepare your Oracle SOA Suite in Kubernetes environment](https://oracle.github.io/fmw-kubernetes/soa-domains/installguide/prepare-your-environment/) for more details.

1. **This script run on on master node and worker node.**
2. This script is into nfs component in the OS. It also mount the file system into both master and worker node.
3. **You need to make change to the below before running the script**

### **Change the NFS ip**
1. Open up [12_Mount_File.sh](https://github.com/wenjian80/soak8_labs/blob/main/scripts/12_Mount_File.sh) and replace the IPCHANGE.
2. Open up your labinfo,txt, input the nfs ip into here.

```
    #PUT FILE SYSTEM IP HERE
    #Eg sudo mount 10.0.0.5:/soashared /soashared
	sudo mount IPCHANGE:/soashared /soashared
```
3. You can run the below to change the ip or open up to edit it.

```
sed -i 's/IPCHANGE/[YOURIP]/g' 12_Mount_File.sh
Eg  sed -i 's/IPCHANGE/10.0.0.1/g' 12_Mount_File.sh
Eg  sed -i 's/IPCHANGE/10.0.0.6/g' 12_Mount_File.sh

```
## Step 13: 13_Soa_pv.sh
**[Run on master node ONLY]**

### Steps to follow
 ```
#Steps to follow
#Read below for exact instruction

#Login master
sudo su
#Your Parameters should have been in step 00, double check again
#grep -na "weblogicDomainStorageNFSServer" create-pv-pvc-inputs.yaml
#Eg  sed -i 's/IPCHANGE/10.0.0.6/g' create-pv-pvc-inputs.yaml

cd /home/opc/soa_k8lab/scripts
./13_Soa_pv.sh

kubectl get pv,pvc -n soans

```

Refer to  [prepare your Oracle SOA Suite in Kubernetes environment](https://oracle.github.io/fmw-kubernetes/soa-domains/installguide/prepare-your-environment/) for more details.

1. **This script run on on master node ONLY.**
2. **You need to make change to the below before running the script**
3. The script is using create-pv-pvc.sh to generate the yaml to create the pv and pvc.

### **Change the NFS ip**
1. Open up [create-pv-pvc-inputs.yaml](https://github.com/wenjian80/soak8_labs/blob/main/scripts/create-pv-pvc-inputs.yaml) and look for weblogicDomainStorageNFSServer to change the ip. You need to open up your labinfo.txt and replace the ip for your nfs ip.

```
# The server name or ip address of the NFS server to use for the persistent storage.
# The following line must be uncomment and customized if weblogicDomainStorateType is NFS:
weblogicDomainStorageNFSServer: IPCHANGE
```
2. You can run the below to change the ip or open up to edit it.

```
sed -i 's/IPCHANGE/[YOURIP]/g' create-pv-pvc-inputs.yaml
Eg  sed -i 's/IPCHANGE/10.0.0.1/g' create-pv-pvc-inputs.yaml
Eg  sed -i 's/IPCHANGE/10.0.0.6/g' create-pv-pvc-inputs.yaml

```
### **Check output**
1. Afrter running the script run the below command to check 
```
kubectl get pv,pvc -n soans
```
![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/pvpvc.JPG)


## Step 14: 14_Soa_DomainJob.sh
**[Run on master node ONLY]**

### Steps to follow
 ```
#Steps to follow
#Read below for exact instruction

#Login master
sudo su
#Your Parameters should have been in step 00, double check again
#grep -na "rcuDatabaseURL" create-domain-inputs.yaml
#Eg sed -i 's/VCNCHANGE/subnet11251534.vcn11251534.oraclevcn.com/g' create-domain-inputs.yaml
#Check contents if it is change
#more create-domain-inputs.yaml

cd /home/opc/soa_k8lab/scripts
./14_Soa_DomainJob.sh

#open a new session and look at the job logs
kubectl get po -n soans
kubectl logs [name of the job pod] -n soans --follow

```

Refer to  [prepare your Oracle SOA Suite in Kubernetes environment](https://oracle.github.io/fmw-kubernetes/soa-domains/installguide/prepare-your-environment/) for more details.

1. **This script run on on master node ONLY.**
2. **You need to make change to the below before running the script**
3.  This script will create a job inside k8 to create the necessary files in the shared storage. it make use of create-domain.sh  to generate the yaml files in weblogic-domains folder under /home/opc/soak8_lab/scripts/weblogic-domains

## **Change the database vcn name**
1. Open up [create-domain-inputs.yaml)](https://github.com/wenjian80/soak8_labs/blob/main/scripts/create-domain-inputs.yaml), you need to replace the vcn domain naming with the naming you have jot down in your labinfo.txt.
2. pdb1 is the pdb database creation that we have provision the database.
3. You need to change the subnet dns naming that you have jotdown in your labinfo.txt
```
# The database URL
rcuDatabaseURL: database.soans.svc.cluster.local:1521/PDB1.VCNCHANGE
```
4. You can use the below command to change or open up and edit it

```
Eg sed -i 's/VCNCHANGE/aaa.aaa.com.com/g' create-domain-inputs.yaml
Eg sed -i 's/VCNCHANGE/subnet11251534.vcn11251534.oraclevcn.com/g' create-domain-inputs.yaml
```

## Step 15: 15_Soa_DomainConfig.sh
**[Run on master node ONLY]**

### Steps to follow
 ```
#Steps to follow
#Read below for exact instruction

#Login master
sudo su
cd /home/opc/soa_k8lab/scripts
./15_Soa_DomainConfig.sh

#watch the pod, ctrl c to stop
#a job will be spin to introspect the namespace and spin up the servers.
kubectl get po -n soans -w

#tail the logs for admin server to see if is started
kubectl logs soainfra-adminserver -n soans --follow

#you should see admin, soa amd osb started before proceed to next steps
#Refer to sample image below
kubectl get po -n soans

#Wait for admin, soa and osb to be started before proceed to next step, because steps 17 are deploying exporter using wlst into the server.
```

Refer to  [prepare your Oracle SOA Suite in Kubernetes environment](https://oracle.github.io/fmw-kubernetes/soa-domains/installguide/prepare-your-environment/) for more details.

1. **This script run on on master node ONLY.**
2.  Once you run the script it will start up the servers.
```
echo "After the command, issue kubectl get po -n soans -w and wait for server to be started"

echo "You can check the logs for admin server pod kubectl logs soainfra-adminserver -n soans --follow"
```

Below is the output you should see, when all server started

```
kubectl get po -n soans
```
![enter image description here](https://github.com/wenjian80/soak8_lab/blob/main/img/soa_started.JPG)
## Step 16: 16_Traefik_LB.sh
**[Run on master node ONLY]**

### Steps to follow
 ```
#Steps to follow
#Read below for exact instruction

#Login master
sudo su
cd /home/opc/soa_k8lab/scripts
./16_Traefik_LB.sh

#Access http://[workernodeip]:30305/console/ to wls console

```

Refer to  [prepare your Oracle SOA Suite in Kubernetes environment](https://oracle.github.io/fmw-kubernetes/soa-domains/installguide/prepare-your-environment/) for more details.

1. **This script run on on master node ONLY.**
2. Once you finish the script the traefik will as a webserver/LB to access the weblogic.
3. You can access the weblogic console via the below url.
4. The user name is weblogic/Welcome1 
5. The username and password was defined earlier in [1_Soa_secret.sh](https://github.com/wenjian80/soak8_labs/blob/main/scripts/11_Soa_secret.sh)
```
http://[workernodeip]:30305/console/
```

## Step 17: 17_Efk.sh
**[Run on master node ONLY]**

### Steps to follow

 ```
#Steps to follow
#Read below for exact instruction

#Login master
sudo su
cd /home/opc/soa_k8lab/scripts
./19_Efk.sh

#Follow below instruction

#Wait for all pod to shit down

#After all pod is shut down restart using below command
#kubectl patch domain soainfra -n soans --type='json' -p='[{"op": "replace", "path": "/spec/serverStartPolicy", "value": "IF_NEEDED" }]'
```


1. These script is a condense version which automate all the command listed in [efk.md](https://github.com/wenjian80/soak8_lab/blob/main/efk.md)
2. The EFK has already been enabled and installed in [9_Operator.sh](https://github.com/wenjian80/soak8_lab/blob/main/scripts/9_Operator.sh)
```
#Enabled EFK
helm install weblogic-operator kubernetes/charts/weblogic-operator  --namespace opns --set elkIntegrationEnabled=true --set serviceAccount=op-sa --set "domainNamespaces={}" --set "javaLoggingLevel=FINE" --wait

#Deployed EFK
cd /home/opc/weblogic-kubernetes-operator/kubernetes/samples/scripts/elasticsearch-and-kibana/
kubectl apply -f elasticsearch_and_kibana.yaml
```
3. Run below command the check the  node port of  kibana. The below example show the kibana is running a node port 30824. You can access the kibana via http://[workerip]:[nodeport]

```
[root@k8master opc]# kubectl get svc
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
elasticsearch   ClusterIP   10.97.235.142   <none>        9200/TCP,9300/TCP   5m57s
kibana          NodePort    10.99.255.48    <none>        5601:30824/TCP      5m57s
kubernetes      ClusterIP   10.96.0.1       <none>        443/TCP             14m

```
4. Enabled logging for operator
5. Create index pattern in Kibana 
6. We need to create an index pattern in Kibana for the logs to be available in the dashboard.
Create an index pattern "wls*" in Kibana > Management. After the server starts, you will be able to see the log data from the weblogic servers in the Kibana dashboard.

![enter image description here](https://github.com/wenjian80/soak8_lab/blob/main/img/startup3.png)


## Step 18: 18_Prom_Gra.sh
**[Run on master node ONLY]**

### Steps to follow
 ```
#Steps to follow
#Read below for exact instruction

#Login master
sudo su
cd /home/opc/soak8_lab/scripts
./17_Prom_Gra.sh

```

1. **This script run on on master node ONLY.**
2. These script is a condense version which automate all the command listed in [promgraph.md](https://github.com/wenjian80/soak8_lab/blob/main/promgraph.md) 
3. Once the script is excuted login to your weblogic console and check the deployment. You will see 3 exporter deployed.
4. The user name is weblogic/Welcome1 
5. The username and password was defined earlier in [1_Soa_secret.sh](https://github.com/wenjian80/soak8_labs/blob/main/scripts/11_Soa_secret.sh)
```
http://[workerip]:30305/console
```

## Step 19: 19_Prom_Setting.sh
**[Run on master node ONLY]**

### Steps to follow
 ```
#Steps to follow
#Read below for exact instruction

#Login master
sudo su
cd /home/opc/soa_k8lab/scripts
./18_Prom_Setting.sh


#Accessing Prometheus
http://[workernodeip]:32101/graph

#Accessing Grafana (admin/admin as default username and password)
http://[workernodeip]:32100/login 


```

1. **This script run on on master node ONLY.**
2. These script is a condense version which automate all the command listed in [promgraph.md](https://github.com/wenjian80/soak8_labs/blob/main/tutorial/promgraph.md) 
3. Once the script are execute you can access prom and grapha via the below url.
```
Prometheus
http://[workernodeip]:32101/graph

Grafana (admin/admin as default username and password)
http://[workernodeip]:32100/login 
```

## **Import dashboard**
1. Import [weblogic_dashboard](https://github.com/wenjian80/soak8_labs/blob/main/scripts/weblogic_dashboard.json) into Grafana 
2. Login to Grafana click on Managed->Import and choose the json to import.

![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/graphana.JPG)



7. [Weblogic Operator doc](https://oracle.github.io/weblogic-kubernetes-operator/userguide/introduction/introduction/)
8. [Weblogic Operator git](https://github.com/oracle/weblogic-kubernetes-operator)
9. [FMW Soa Operator doc](https://oracle.github.io/fmw-kubernetes/soa-domains/)
10. [Fmw Soa Operator git](https://github.com/oracle/fmw-kubernetes)
11. [Oracle fmw docker images](https://github.com/oracle/docker-images)
12. [Weblogic Monitoring Exporter](https://github.com/oracle/weblogic-monitoring-exporter)
13. [Weblogic Deployment tooling](https://github.com/oracle/weblogic-deploy-tooling)
14. [Weblogic logging exporter](https://github.com/oracle/weblogic-logging-exporter)
15. [Weblogic image tool](https://github.com/oracle/weblogic-image-tool)
16. [Oracle Blog Production Support](https://blogs.oracle.com/integration/announcing-oracle-soa-suite-on-containers-kubernetes-for-production-workloads)

Slack support

-   oracle-weblogic.slack.com
-   [https://weblogic-slack-inviter.herokuapp.com/](https://weblogic-slack-inviter.herokuapp.com/)



<!--stackedit_data:
eyJoaXN0b3J5IjpbLTI5NDMwNDMzMV19
-->