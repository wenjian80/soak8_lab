
#Eg sed 's/CHANGE/10.0.0.5/g' /home/opc/soak8_lab/scripts/soainfra-domain-pvc.yaml
#sed 's/CHANGE/[INPUT_ID]/g' /home/opc/soak8_lab/scripts/soainfra-domain-pv.yaml

#Refer to the below url to see the complete steps
#https://github.com/oracle/weblogic-kubernetes-operator/tree/master/kubernetes/samples/scripts/create-weblogic-domain-pv-pvc
#The output file has been generated in the labs.
#PLEASE CHANGE THE IP at above
#kubectl create -f  /home/opc/soak8_lab/scripts/soainfra-domain-pv.yaml
#kubectl create -f  /home/opc/soak8_lab/scripts/soainfra-domain-pvc.yaml



#PLEASE CHANGE THE IP in create-pv-pvc-inputs.yaml
cd /home/opc/weblogic-kubernetes-operator/kubernetes/samples/scripts/create-weblogic-domain-pv-pvc
./create-pv-pvc.sh -i /home/opc/soak8_lab/scripts/create-pv-pvc-inputs.yaml -o /home/opc/soak8_lab/scripts/ -e

#check pv and pvc status
kubectl get pvc -n soans
kubectl get pv -n soans

