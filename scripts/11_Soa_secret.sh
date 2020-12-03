#Operator to watch soans namespace
cd /home/opc/weblogic-kubernetes-operator
helm upgrade --reuse-values --namespace opns --set "domainNamespaces={soans}" --wait weblogic-operator kubernetes/charts/weblogic-operator

 

#Create a Kubernetes secret containing the Administration Server credentials (username : weblogic and password: Welcome1) in the same Kubernetes namespace as the domain (soans):
cd /home/opc/weblogic-kubernetes-operator/kubernetes/samples/scripts/create-weblogic-domain-credentials
./create-weblogic-credentials.sh -u weblogic -p Welcome1 -n soans -d soainfra -s soainfra-domain-credentials


#Create a Kubernetes secret for the RCU in the same Kubernetes namespace as the domain (soans) with below details: Schema user : SOA1 Schema password : Oradoc_db1
#DB sys user password : Oradoc_db1 Domain name : soainfra Domain Namespace : soans Secret name : soainfra-rcu-credentials
cd /home/opc/weblogic-kubernetes-operator/kubernetes/samples/scripts/create-rcu-credentials
./create-rcu-credentials.sh -u SOA1 -p WelcomE1234## -a sys -q WelcomE1234## -d soainfra -n soans -s soainfra-rcu-credentials

