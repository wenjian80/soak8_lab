#create a database service to communicate to external database
kubectl create -f /home/opc/soak8_lab/scripts/database.yaml -n soans

#show external database created
kubectl get all

#create a secret to pull from container registry. All agreement to be to check first
#PLEASE CHANGE THE USERNAME AND PASSWORD
kubectl create secret docker-registry conregsecret --docker-server=container-registry.oracle.com --docker-username=UIDCHANGE --docker-password=PWDCHANGE --docker-email='boon.jian.lim@oracle.com' -n soans

#create rcu against the dbaas
#PLEASE CHANGE THE subnet name "subnet11251534.vcn11251534.oraclevcn.com"
cd /home/opc/weblogic-kubernetes-operator/kubernetes/samples/scripts/create-rcu-schema
#cd /home/opc/fmw-kubernetes/OracleSOASuite/kubernetes/create-rcu-schema
./create-rcu-schema.sh -s SOA1 -t soaessosb -d database.soans.svc.cluster.local:1521/PDB1.VCNCHANGE -p conregsecret -i container-registry.oracle.com/middleware/soasuite:12.2.1.4 -n soans -q WelcomE1234## -r WelcomE1234##

#Sample for dropping schema
#cd /home/opc/weblogic-kubernetes-operator/kubernetes/samples/scripts/create-rcu-schema
#cd /home/opc/fmw-kubernetes/OracleSOASuite/kubernetes/create-rcu-schema
#./drop-rcu-schema.sh -s SOA1 -t soaessosb -d database.soans.svc.cluster.local:1521/PDB1.VCNCHANGE -q WelcomE1234## -r WelcomE1234## -n soans