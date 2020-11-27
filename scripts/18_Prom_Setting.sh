cd /home/opc/soak8_lab/scripts

kubectl apply -f prometheus-roleBindingSpecificNamespaces.yaml
kubectl apply -f prometheus-roleSpecificNamespaces.yaml
kubectl create -f wls-exporter.yaml