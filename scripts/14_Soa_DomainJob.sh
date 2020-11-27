#Create a Kubernetes job that will start up a utility Oracle SOA Suite container and run offline WLST scripts to create the domain on the shared storage.
cd /home/opc/fmw-kubernetes/OracleSOASuite/kubernetes/create-soa-domain/domain-home-on-pv
./create-domain.sh -i /home/opc/soak8_lab/scripts/create-domain-inputs.yaml -o /home/opc/soak8_lab/scripts/

#Refer to the below url to see the complete steps
#https://oracle.github.io/fmw-kubernetes/soa-domains/installguide/create-soa-domains/
#The output file has been generated in the labs.
#PLEASE CHANGE THE DATABASE URL
#./create-domain.sh -i /home/opc/soak8_lab/scripts/create-domain-inputs.yaml -o /home/opc/soak8_lab/scripts/



