#Pls update your variables here
TODO

#Change the ip to "Database private ip" in your labinfo.txt
DATABASEIP=[put ip here]

#Change the ip to "Oracle account username/password" in your labinfo.txt
UID=[put ip here]
PWD=[put ip here]


#change your database ip in database.yaml 
#Change the ip to "Database private ip" in your labinfo.txt
#Eg sed -i 's/IPCHANGE/$DATABASEIP/g' database.yaml 
#Check contents if it is change 
#more database.yaml 

#change your username and password in 10_Rcu.sh 
#Change your username and password in "Oracle account username/password"
#Eg sed -i 's/UIDCHANGE/wenjian80@gmail.com/g' 10_Rcu.sh 
#Eg sed -i 's/PWDCHANGE/Welcome_1234#/g' 10_Rcu.sh 
#Check contents if it is change 
#more 10_Rcu.sh 

#change your database vcn in 10_Rcu.sh 
#Change the subnet in "Database subnet"
#Eg sed -i 's/VCNCHANGE/subnet11251534.vcn11251534.oraclevcn.com/g' 10_Rcu.sh 
#Check contents if it is change 
#more 10_Rcu.sh

#Change the ip in 12_Mount_File.sh 
#Change the ip to "NFS ip" in your labinfo.txt
#Eg sed -i 's/IPCHANGE/10.0.0.6/g' 12_Mount_File.sh 
#Check contents if it is change 
#more 12_Mount_File.sh
