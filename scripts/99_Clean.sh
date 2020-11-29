#Clean everything

#delete all po in soa ns
kubectl delete domain soainfra -n soans

#Check all pod terminated and delete
kubectl get po -n soans

#Remove contents in shared folder
rm -Rf /soashared/soa/*

#Sample for dropping schema
cd /home/opc/weblogic-kubernetes-operator/kubernetes/samples/scripts/create-rcu-schema
./drop-rcu-schema.sh -s SOA1 -t soaessosb -d database.soans.svc.cluster.local:1521/PDB1.subnet11251534.vcn11251534.oraclevcn.com -q WelcomE1234## -r WelcomE1234## -n soans

#Gte all the pv and pvc
#The pv and pvc has finalizers that need to be delete go edit the and remove finalizers 
kubectl get pv,pvc -A

#Remove the below 2 line
#  finalizers:
#  - kubernetes.io/pv-protection
kubectl edit pv soainfra-domain-pv -n soans

#Remove the below 2 line
#  finalizers:
#  - kubernetes.io/pv-protection
kubectl edit pvc soainfra-domain-pvc -n soans

#delete pv and pvc
kubectl delete pvc soainfra-domain-pvc -n soans
kubectl delete pv soainfra-domain-pv -n soans

#check what resoruces in soans namespace
kubectl get all -n soans

#check what namespace are there
kubectl get ns

#Just delete all namespace
kubectl delete ns soans

#List the helm and delete all of it
helm list -A
helm delete weblogic-operator -n opns

#todo clear traefik and monitoring namespace
kubectl delete ns traefik
kubectl delete ns monitoring
