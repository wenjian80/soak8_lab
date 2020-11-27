cd /home/opc/

git clone https://github.com/oracle/weblogic-kubernetes-operator.git  -b release/3.0.1

git clone https://github.com/oracle/fmw-kubernetes.git -b release/20.3.3

kubectl create namespace opns
kubectl create namespace soans

kubectl create serviceaccount -n opns  op-sa

chmod -R 777 /home/opc/weblogic-kubernetes-operator

chmod -R 777 /home/opc/fmw-kubernetes/

cd /home/opc/weblogic-kubernetes-operator

helm install weblogic-operator kubernetes/charts/weblogic-operator  --namespace opns --set serviceAccount=op-sa --set "domainNamespaces={}" --set "javaLoggingLevel=FINE" --wait


kubectl get pods -n opns

kubectl get all -n opns

#kubectl logs -n opns -c weblogic-operator deployments/weblogic-operator