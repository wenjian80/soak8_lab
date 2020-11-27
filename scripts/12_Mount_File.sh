# Mount file system
sudo yum install nfs-utils

sudo mkdir -p /soashared

#PUT FILE SYSTEM IP HERE
#Eg sudo mount 10.0.0.5:/soashared /soashared
sudo mount [INPUT_ID]:/soashared /soashared

df -h /soashared

#Need to create soa folder as pv and pvc later is referencing to it
sudo mkdir /soashared/soa
sudo chmod -Rf 777 /soashared/soa
