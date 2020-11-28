
# Purpose
1. The purpose of this lab excerise is to minc the same environment setup on premise.
2. We are using an external database as the soa repository.
3. We are installing k8 from scratch. In this lab however we are not creating a HA for master node. We can refer to K8 documentation on how to set it up.
4. For lab purpose we are using 1 master and 1 worker. Deployment are done in worker node as master are not tainted to run workload.
5. Since soa on k8 require a PV/PVC, in on prem context it will either a NFS or san storage etc. In this lab we are using Oracle Cloud File System to act as the NFS.


# 1. Prereq
1. Please follow the prereq to set your environment ready.  Follow the instruction on [prereq](https://github.com/wenjian80/soak8_labs/blob/main/tutorial/prereq.md)

2. You should already have your labinfo.txt fill up on hand. We will be referencing those info in these exercise.

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
TODO to explain steps

1. Excercise are running as root for lab purpose. Login to as opc, sudo su.
2. Clone this git project.
3. Create a folder call soak8_lab in both master and worker node in path /home/opc/
4. Winscp and copy the scripts folder into /home/opc/soak8_lab/scripts
5. sudo su 
6. chmod -R 777 /home/opc/soak8_lab


## Step 0: 0_InitialMachine_Config.sh
**[Run on master and worker node]**

1. This script need to run on both master and worker node.
2. We are setting up the yum repository in this script So the installation will make use the of the yum repository.

## Step 1: 1_Docker_Config.sh
**[Run on master and worker node]**

1. This script need to run on both master and worker node.
2. We are using docker  version 19.03.1.ol in this lab.

## Step 2: 2_KubeMaster_Firewall_Config.sh
**[Run on master node ONLY]**

1. **This script run on on master node ONLY.**
2. Kuberenetes require certain pre-req and firewall to communcation between master and worker nodes.  Refer to [K8 documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) for more details.
3. We are disabling the firewall on linux for lab purpose.

## Step 3: 3_KubeNode_Firewall_Config.sh
**[Run on worker node ONLY]**

1. **This script run on on worker node ONLY.**
2. Same as step 2. We are setting the pre-req for k8.

## Step 4: 4_KubeMaster_Kubernetes_Config.sh
**[Run on master node ONLY]**

 1. **This script run on on master node ONLY.** Once the prereq has been set. 

 2. We are running the steps to set up this node as the master
    node. 
    
 3. At the end of this script it will provide you a command for
    worker node to join the cluster and communicate to this master node.

![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/master_ready.JPG)

4. **You will need to copy the last output of the kubeadm join on step 5 for the worker node to join the cluster**

5. Run the below command to check if master is ready. Wait until it is ready before proceed step 5.

    kubectl get no

![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/workerready.JPG)

## Step 5: 5_KubeNode_Kubernetes_Config.sh
**[Run on worker node ONLY]**

 1. **This script run on on worker node ONLY.**
    **. Open and edit the script on the below line and change it to the previous output in step 4.**

    kubeadm join 10.0.0.9:6443[CHANGEIT] --token evksam.s0ucudqvgjwc7gia[CHANGEIT] --discovery-token-ca-cert-hash sha256:1628521d351fa4981c230e066b77a11c118d29f558ab867323f3d0ad1aeab6bb[CHANGEIT]

  
 2.  Once tyou have edit the script and run the command, you will see that your worker node has join the cluster.

![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/node_ready.JPG)

3. Now go in the master node and type the below command to check the status. You see see the worker node is ready.

     kubectl get po

![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/workerready.JPG)

## Step 6: 6_Check_Kubedns.sh
**[Run on master node ONLY]**

1. **This script run on on master node ONLY.**
2. This steps is to check if k8 networking is setup properly and the nodes can communicate via cluster ip and k8 networking.
3. You should see the below if all the k8 networking is running fine.

![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/dns.JPG)
 
## Step 7: 7_Kube_proxy.sh
**[Run on master node ONLY]**

1. **This script run on on master node ONLY.**
2. K8 dashboard is not deploy by default.
3. This script is to enabled the dashboard and create the RBAC for the dashboard.
4. It will print out a token for you to login to the dashboard.
5. Run the below command line

    kubectl proxy

![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/kubectlproxy.JPG)

5. And use the token to login to the dashbaord. The tunnel create in the prereq is use to tunnel to to the dashboard. Press Ctl+C to stop the proxy

http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login

## Step 8: 8_Git_helm.sh
**[Run on master node ONLY]**

1. **This script run on on master node ONLY.**
2. This script is to install Git and Helm 3.
3. Git is use to pull the git repo later to be use and helm is use to install various component via helm chart.

## Step 9: 9_Operator.sh
**[Run on master node ONLY]**

1. **This script run on on master node ONLY.**
2.  The script pull the necessary repo to install weblogic operator and scripts.
3. it also create the necessary k8 namespace to be used, such as soans, opns.
4. soans is the namespace to install soa, opns is the namespace to install operator.
5. You will have to specify -n command to get specific resource such as 


Get po for namespace soans

    kubectl get po -n soans


Get po for namespace opns

    kubectl get po -n opns


Get all resource all namespace

    kubectl get all -A

## Step 10: 10_Rcu.sh
**[Run on master node ONLY]**

1. **This script run on on master node ONLY.**
2. This script is to pull a image to run the soa rcu creation against an external database.
3. **You need to make change to the below before running the script**

### **Change database ip**

1. Open up your [database.yaml](https://github.com/wenjian80/soak8_labs/blob/main/scripts/database.yaml) and search for the ip. You are going to replace it.
2. Open up your labinfo.txt, find what is your database ip and change that in [database.yaml](https://github.com/wenjian80/soak8_labs/blob/main/scripts/database.yaml) 
3. The script is reference external database where by k8 will reference database.soans.svc.cluster.local in k8 network context. The conveention is [name].[namespace].svc.cluster.local
4. You need to change the below ip

     -addresses:
             -ip: 10.0.0.4[CHANGEIT]

### **Chnage username and password**
1. Open up [10_Rcu.sh](https://github.com/wenjian80/soak8_labs/blob/main/scripts/10_Rcu.sh), you need to replace $1 and $2 with your oracle account username and password
2. Open up your labinfo.txt, find what is your Oracle account username/password and replace it. This is the account to login to container-registry.oracle.com. You must accept the agreement otherwise it will have error.
3. You need to change the username and password

    --docker-username=$1[CHANGEIT] --docker-password=$2[CHANGEIT]

### **Change the database vcn name**
1. Open up [10_Rcu.sh](https://github.com/wenjian80/soak8_labs/blob/main/scripts/10_Rcu.sh), you need to replace the vcn domain naming with the naming you have jot down in your labinfo.txt.
2. pdb1 is the pdb database creation that we have provision the database.
3. You need to change the subnet dns naming that you have jotdown in your labinfo.txt

    PDB1.**subnet11251534.vcn11251534.oraclevcn.com[CHANGEIT]**

### **Script output**
The output of the script will be as such. It will take around 3-5min.

![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/rcu_complete.JPG)

## Step 11: 11_Soa_secret.sh
**[Run on master node ONLY]**

1. **This script run on on master node ONLY.**
2. This script is to create the necessary secret to be used in the later steps

## Step 12: 12_Mount_File.sh
**[Run on master and worker node]**

1. **This script run on on master node and worker node.**
2. This script is into nfs component in the OS. It also mount the file system into both master and worker node.
3. **You need to make change to the below before running the script**

### **Change the NFS ip**
1. Open up [12_Mount_File.sh](https://github.com/wenjian80/soak8_labs/blob/main/scripts/12_Mount_File.sh) and replace the [INPUT_ID].
2. Open up your labinfo,txt, input the nfs ip into here.

    #PUT FILE SYSTEM IP HERE
    #Eg sudo mount 10.0.0.5:/soashared /soashared
    sudo mount [INPUT_ID]:/soashared /soashared

## Step 13: 13_Soa_pv.sh
**[Run on master node ONLY]**

1. **This script run on on master node ONLY.**
2. **You need to make change to the below before running the script**
3. The script is using create-pv-pvc.sh to generate the yaml to create the pv and pvc.

### **Change the NFS ip**
1. Open up [create-pv-pvc-inputs.yaml](https://github.com/wenjian80/soak8_labs/blob/main/scripts/create-pv-pvc-inputs.yaml) and look for weblogicDomainStorageNFSServer to change the ip. You need to open up your labinfo.txt and replace the ip for your nfs ip.

weblogicDomainStorageNFSServer: [CHANGEIT]


### **Check output**
1. Afrter running the script run the below command to check 

    kubectl get pv,pvc -n soans

![enter image description here](https://github.com/wenjian80/soak8_labs/blob/main/img/pvpvc.JPG)


## Step 14: 14_Soa_DomainJob.sh
**[Run on master node ONLY]**

## Step 15: 15_Soa_DomainConfig.sh
**[Run on master node ONLY]**

## Step 16: 16_Traefik_LB.sh
**[Run on master node ONLY]**


## Step 17: 17_Prom_Gra.sh
**[Run on master node ONLY]**

## Step 18: 18_Prom_Setting.sh
**[Run on master node ONLY]**


# Reference Links

TODO


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTEyNzg1ODg0NjBdfQ==
-->