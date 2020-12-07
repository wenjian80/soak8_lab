cd /home/opc
git clone https://github.com/coreos/kube-prometheus.git

chmod -R 777 /home/opc/kube-prometheus

#Change to folder `kube-prometheus` and execute the following commands to create the namespace and CRDs, and then wait for their availability before creating the remaining resources.
cd kube-prometheus
kubectl create -f manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl create -f manifests/

#Kube-Prometheus requires all nodes to be labelled with `kubernetes.io/os=linux`. If a node is not labelled with this, then you need to label it using the following command:
kubectl label nodes --all kubernetes.io/os=linux

#To provide external access for Grafana/Prometheus/Alertmanager, you need to execute the following commands:
# 32100 is the external port for Grafana
# 32101 is the external port for Prometheus
# 32102 is the external port for Alertmanager
#http://158.101.19.71:32101/graph
#http://158.101.19.71:32100/login admin/admin

kubectl patch svc grafana -n monitoring --type=json -p '[{"op": "replace", "path": "/spec/type", "value": "NodePort" },{"op": "replace", "path": "/spec/ports/0/nodePort", "value": 32100 }]'
kubectl patch svc prometheus-k8s -n monitoring --type=json -p '[{"op": "replace", "path": "/spec/type", "value": "NodePort" },{"op": "replace", "path": "/spec/ports/0/nodePort", "value": 32101 }]'
kubectl patch svc alertmanager-main -n monitoring --type=json -p '[{"op": "replace", "path": "/spec/type", "value": "NodePort" },{"op": "replace", "path": "/spec/ports/0/nodePort", "value": 32102 }]'

#Generate the wls exporter war file
cd /home/opc/soak8_lab/scripts
wget https://github.com/oracle/weblogic-monitoring-exporter/releases/download/v1.2.0/get1.2.0.sh
chmod 777 get1.2.0.sh


rm -Rf /home/opc/soak8_lab/scripts/exporteradmin
rm -Rf /home/opc/soak8_lab/scripts/exporterosb
rm -Rf /home/opc/soak8_lab/scripts/exportersoa

cd /home/opc/soak8_lab/scripts
mkdir /home/opc/soak8_lab/scripts/exporteradmin
./get1.2.0.sh config.yaml
cp wls-exporter.war /home/opc/soak8_lab/scripts/exporteradmin

cd /home/opc/soak8_lab/scripts
mkdir /home/opc/soak8_lab/scripts/exporterosb
./get1.2.0.sh config-osb.yaml
cp wls-exporter.war /home/opc/soak8_lab/scripts/exporterosb

cd /home/opc/soak8_lab/scripts
mkdir /home/opc/soak8_lab/scripts/exportersoa
./get1.2.0.sh config-soa.yaml
cp wls-exporter.war /home/opc/soak8_lab/scripts/exportersoa

chmod 777 *

#Make directory in admin port so we can deploy
#Alyternatively we can deploy via console and upload the file
#Pod is mortal, so it will not be there after restart if we copy the /u01/
#So need to build into the image if possible otherwise
#/u01/oracle/user_projects is a shared directory mapped /soashared/soa
#alternatively we can copy over there. lazy to retest the script again.
kubectl exec soainfra-adminserver -n soans -- mkdir /u01/exporter
kubectl exec soainfra-adminserver -n soans -- mkdir /u01/exporter/admin
kubectl exec soainfra-adminserver -n soans -- mkdir /u01/exporter/osb
kubectl exec soainfra-adminserver -n soans -- mkdir /u01/exporter/soa
kubectl exec soainfra-adminserver -n soans -- ls /u01/exporter


kubectl cp /home/opc/soak8_lab/scripts/exporteradmin/wls-exporter.war soans/soainfra-adminserver:/u01/exporter/admin
echo "Check if admin file copy"
kubectl exec soainfra-adminserver -n soans -- ls /u01/exporter/admin

kubectl cp /home/opc/soak8_lab/scripts/exporterosb/wls-exporter.war soans/soainfra-adminserver:/u01/exporter/osb
echo "Check if osb file copy"
kubectl exec soainfra-adminserver -n soans -- ls /u01/exporter/osb

echo "Check if soa file copy"
kubectl cp /home/opc/soak8_lab/scripts/exportersoa/wls-exporter.war soans/soainfra-adminserver:/u01/exporter/soa
kubectl exec soainfra-adminserver -n soans -- ls /u01/exporter/soa

#deploy wls exporter 
kubectl cp /home/opc/soak8_lab/scripts/manageApplication.py soans/soainfra-adminserver:/u01/
kubectl exec soainfra-adminserver -n soans -- /u01/oracle/oracle_common/common/bin/wlst.sh /u01/manageApplication.py -u weblogic -p Welcome1 -a soainfra-adminserver:7001 -n wls-exporter-admin -f "/u01/exporter/admin/wls-exporter.war" -t AdminServer
kubectl exec soainfra-adminserver -n soans -- /u01/oracle/oracle_common/common/bin/wlst.sh /u01/manageApplication.py -u weblogic -p Welcome1 -a soainfra-adminserver:7001 -n wls-exporter-osb -f "/u01/exporter/osb/wls-exporter.war" -t osb_cluster
kubectl exec soainfra-adminserver -n soans -- /u01/oracle/oracle_common/common/bin/wlst.sh /u01/manageApplication.py -u weblogic -p Welcome1 -a soainfra-adminserver:7001 -n wls-exporter-soa -f "/u01/exporter/soa/wls-exporter.war" -t soa_cluster

#TO TEST
#kubectl exec soainfra-adminserver -n soans -- mkdir /u01/oracle/user_projects/exporter
#kubectl exec soainfra-adminserver -n soans -- mkdir /u01/oracle/user_projects/exporter/admin
#kubectl exec soainfra-adminserver -n soans -- mkdir /u01/oracle/user_projects/exporter/osb
#kubectl exec soainfra-adminserver -n soans -- mkdir /u01/oracle/user_projects/exporter/soa
#kubectl exec soainfra-adminserver -n soans -- ls /u01/oracle/user_projects/exporter


#kubectl cp /home/opc/soak8_lab/scripts/exporteradmin/wls-exporter.war soans/soainfra-adminserver:/u01/oracle/user_projects/exporter/admin
#echo "Check if admin file copy"
#kubectl exec soainfra-adminserver -n soans -- ls /u01/oracle/user_projects/exporter/admin

#kubectl cp /home/opc/soak8_lab/scripts/exporterosb/wls-exporter.war soans/soainfra-adminserver:/u01/oracle/user_projects/exporter/osb
#echo "Check if osb file copy"
#kubectl exec soainfra-adminserver -n soans -- ls /u01/oracle/user_projects/exporter/osb

#echo "Check if soa file copy"
#kubectl cp /home/opc/soak8_lab/scripts/exportersoa/wls-exporter.war soans/soainfra-adminserver:/u01/oracle/user_projects/exporter/soa
#kubectl exec soainfra-adminserver -n soans -- ls /u01/oracle/user_projects/exporter/soa


#deploy wls exporter 
#kubectl cp /home/opc/soak8_lab/scripts/manageApplication.py soans/soainfra-adminserver:/u01/oracle/user_projects/
#kubectl exec soainfra-adminserver -n soans -- /u01/oracle/oracle_common/common/bin/wlst.sh /u01/oracle/user_projects/manageApplication.py -u weblogic -p Welcome1 -a soainfra-adminserver:7001 -n wls-exporter-admin -f "/u01/oracle/user_projects/exporter/admin/wls-exporter.war" -t AdminServer
#kubectl exec soainfra-adminserver -n soans -- /u01/oracle/oracle_common/common/bin/wlst.sh /u01/oracle/user_projects/manageApplication.py -u weblogic -p Welcome1 -a soainfra-adminserver:7001 -n wls-exporter-osb -f "/u01/oracle/user_projects/exporter/osb/wls-exporter.war" -t osb_cluster
#kubectl exec soainfra-adminserver -n soans -- /u01/oracle/oracle_common/common/bin/wlst.sh /u01/oracle/user_projects/manageApplication.py -u weblogic -p Welcome1 -a soainfra-adminserver:7001 -n wls-exporter-soa -f "/u01/oracle/user_projects/exporter/soa/wls-exporter.war" -t soa_cluster


echo "Login to weblogic console you will see 3 wls-exporter deployed"
echo "http://[Workerip]:30305/console/login/LoginForm.jsp"

