# Change rights and sed special chracter

sudo su

chmod -R 777 /home/opc/soak8_lab/

sed -i -e "s/^M//" /home/opc/soak8_lab/scripts/*.sh
sed -i -e 's/\r$//' /home/opc/soak8_lab/scripts/*.sh

sed -i -e "s/^M//" /home/opc/soak8_lab/scripts/*.yaml
