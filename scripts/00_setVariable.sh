#Pls update your variables here

#Update the below based on "Database private ip" in your labinfo.txt
DATABASEIP=put ip here
#DATABASEIP=10.0.0.4

#Update the below based on "Oracle account username/password" in your labinfo.txt
USERID=put uid here
PASSWORD=put pwd phere
#UID=wenjian80@gmail.com
#PWD=Welcome_1234#


#Update the below based on "Database subnet" in your labinfo.txt
SUBNET=put subnet here
#SUBNET=subnet11251534.vcn11251534.oraclevcn.com

#Update the below based on "NFS IP" in your labinfo.txt
NFSIP=put ip here
#NFSIP=10.0.0.6

#Changes in 10_Rcu.sh 
sed -i 's/UIDCHANGE/$USERID/g' 10_Rcu.sh 
sed -i 's/PWDCHANGE/$PASSWORD/g' 10_Rcu.sh 
sed -i 's/VCNCHANGE/$SUBNET/g' 10_Rcu.sh 

#Changes in database.yaml 
sed -i 's/IPCHANGE/$DATABASEIP/g' database.yaml 

#Changes in 12_Mount_File.sh 
sed -i 's/IPCHANGE/$NFSIP/g' 12_Mount_File.sh 

#Changes in create-pv-pvc-inputs.yaml
sed -i 's/IPCHANGE/$NFSIP/g' create-pv-pvc-inputs.yaml

#Changes in create-domain-inputs.yaml
sed -i 's/VCNCHANGE/$SUBNET/g' create-domain-inputs.yaml