#!/bin/bash

cd /home/opc/

#git clone https://github.com/oracle/weblogic-kubernetes-operator.git  -b release/3.0.1
git clone https://github.com/oracle/weblogic-kubernetes-operator.git  -b release/3.1.1

#git clone https://github.com/oracle/fmw-kubernetes.git -b release/20.3.3
git clone https://github.com/oracle/fmw-kubernetes.git -b release/21.1.2


kubectl create namespace opns
kubectl create namespace soans

kubectl create serviceaccount -n opns  op-sa

chmod -R 777 /home/opc/weblogic-kubernetes-operator

chmod -R 777 /home/opc/fmw-kubernetes/

cd /home/opc/weblogic-kubernetes-operator

#No Efk
#helm install weblogic-operator kubernetes/charts/weblogic-operator  --namespace opns --set serviceAccount=op-sa --set "domainNamespaces={}" --set "javaLoggingLevel=FINE" --wait

#Enabled EFK
helm install weblogic-operator kubernetes/charts/weblogic-operator  --namespace opns --set elkIntegrationEnabled=true --set serviceAccount=op-sa --set "domainNamespaces={}" --set "javaLoggingLevel=FINE" --wait

kubectl get pods -n opns

kubectl get all -n opns

#kubectl logs -n opns -c weblogic-operator deployments/weblogic-operator


#Refer to https://oracle.github.io/fmw-kubernetes/soa-domains/installguide/prepare-your-environment/#set-up-the-code-repository-to-deploy-oracle-soa-suite-domains
#Certain releases may change
#TO CHANGE ALL PATH IN REST OF THE SCRIPTS

WORKDIR=/home/opc/
export WORKDIR=/home/opc/

mv -f ${WORKDIR}/weblogic-kubernetes-operator/kubernetes/samples/scripts/create-soa-domain  ${WORKDIR}/weblogic-kubernetes-operator/kubernetes/samples/scripts/create-soa-domain_backup
cp -rf ${WORKDIR}/fmw-kubernetes/OracleSOASuite/kubernetes/create-soa-domain  ${WORKDIR}/weblogic-kubernetes-operator/kubernetes/samples/scripts/

mv -f ${WORKDIR}/weblogic-kubernetes-operator/kubernetes/samples/scripts/common  ${WORKDIR}/weblogic-kubernetes-operator/kubernetes/samples/scripts/common_backup
cp -rf ${WORKDIR}/fmw-kubernetes/OracleSOASuite/kubernetes/common  ${WORKDIR}/weblogic-kubernetes-operator/kubernetes/samples/scripts/

mv -f ${WORKDIR}/weblogic-kubernetes-operator/kubernetes/samples/scripts/create-rcu-schema  ${WORKDIR}/weblogic-kubernetes-operator/kubernetes/samples/scripts/create-rcu-schema_backup
cp -rf ${WORKDIR}/fmw-kubernetes/OracleSOASuite/kubernetes/create-rcu-schema  ${WORKDIR}/weblogic-kubernetes-operator/kubernetes/samples/scripts/

mv -f ${WORKDIR}/weblogic-kubernetes-operator/kubernetes/samples/charts/ingress-per-domain  ${WORKDIR}/weblogic-kubernetes-operator/kubernetes/samples/charts/ingress-per-domain_backup
cp -rf ${WORKDIR}/fmw-kubernetes/OracleSOASuite/kubernetes/ingress-per-domain  ${WORKDIR}/weblogic-kubernetes-operator/kubernetes/samples/charts/

cp -rf ${WORKDIR}/fmw-kubernetes/OracleSOASuite/kubernetes/imagetool-scripts  ${WORKDIR}/weblogic-kubernetes-operator/kubernetes/samples/scripts/

cp -rf ${WORKDIR}/fmw-kubernetes/OracleSOASuite/kubernetes/charts  ${WORKDIR}/weblogic-kubernetes-operator/kubernetes/samples/scripts/


#Deployed EFK
cd /home/opc/weblogic-kubernetes-operator/kubernetes/samples/scripts/elasticsearch-and-kibana/
kubectl apply -f elasticsearch_and_kibana.yaml

#Check efk po in default namespace
kubectl get po

