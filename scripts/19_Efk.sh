## TODO NOT FINISHED/ NOT TESTED###


#get the loging expoter
cd /home/opc/soak8_lab/scripts
wget https://github.com/oracle/weblogic-logging-exporter/releases/download/v1.0.0/weblogic-logging-exporter-1.0.0.jar
wget https://repo1.maven.org/maven2/org/yaml/snakeyaml/1.23/snakeyaml-1.23.jar

#transfer into the server
cd /home/opc/soak8_lab/scripts
kubectl cp snakeyaml-1.23.jar soans/soainfra-adminserver:/u01/oracle/user_projects/domains/soainfra/
kubectl cp weblogic-logging-exporter-1.0.0.jar soans/soainfra-adminserver:/u01/oracle/user_projects/domains/soainfra/

#Get the setDomainEnv from server
cd /home/opc/soak8_lab/scripts
kubectl cp soans/soainfra-adminserver:/u01/oracle/user_projects/domains/soainfra/bin/setDomainEnv.sh /home/opc/soak8_lab/scripts/setDomainEnv.sh

#Echo the line
cd /home/opc/soak8_lab/scripts
classline=CLASSPATH=/u01/oracle/user_projects/domains/soainfra/weblogic-logging-exporter-1.0.0.jar:/u01/oracle/user_projects/domains/soainfra/snakeyaml-1.23.jar:\$\{CLASSPATH\}
echo $classline >> setDomainEnv.sh
echo "export CLASSPATH" >> setDomainEnv.sh

#Copy back to server
kubectl cp setDomainEnv.sh soans/soainfra-adminserver:/u01/oracle/user_projects/domains/soainfra/bin/setDomainEnv.sh

#Copy file to the domain folder in the weblogic server pod.
cd /home/opc/soak8_lab/scripts
kubectl cp WebLogicLoggingExporter.yaml soans/soainfra-adminserver:/u01/oracle/user_projects/domains/soainfra/config/

#deploy exporter startup class
cd /home/opc/soak8_lab/scripts
kubectl cp /home/opc/soak8_lab/scripts/exporterStartup.py soans/soainfra-adminserver:/u01/oracle/user_projects/
kubectl exec soainfra-adminserver -n soans -- /u01/oracle/oracle_common/common/bin/wlst.sh /u01/oracle/user_projects/exporterStartup.py -u weblogic -p Welcome1 -a soainfra-adminserver:7001

#Shut down server
echo "Shutting down server."
echo "kubectl get po -n soans"
echo "Make sure all server are shutdown"
kubectl patch domain soainfra -n soans --type='json' -p='[{"op": "replace", "path": "/spec/serverStartPolicy", "value": "NEVER" }]'

echo "Run below command to restart after all is shutdown"
echo "kubectl patch domain soainfra -n soans --type='json' -p='[{"op": "replace", "path": "/spec/serverStartPolicy", "value": "IF_NEEDED" }]"
#Retsrat server
#kubectl patch domain soainfra -n soans --type='json' -p='[{"op": "replace", "path": "/spec/serverStartPolicy", "value": "IF_NEEDED" }]'


#Check what is the node port for kibnana
#kubectl get svc
#Access the url via http://[workerip:[nodeport]]

