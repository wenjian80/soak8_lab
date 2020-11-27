kubectl create namespace traefik

helm repo add stable https://charts.helm.sh/stable

cd /home/opc/weblogic-kubernetes-operator
helm install traefik-operator  stable/traefik  --namespace traefik --values kubernetes/samples/charts/traefik/values.yaml --set  "kubernetes.namespaces={traefik}" --wait

kubectl get svc -n traefik
 
#Configure Traefik to manage Ingresses created in this namespace:
helm upgrade --reuse-values --set "kubernetes.namespaces={traefik,soans}" --wait traefik-operator stable/traefik --namespace traefik

#Generate sample cert for ssl 
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/tls1.key -out /tmp/tls1.crt -subj "/CN=*"
kubectl -n soans create secret tls soainfra-tls-cert --key /tmp/tls1.key --cert /tmp/tls1.crt

cd /home/opc/fmw-kubernetes/OracleSOASuite/
helm install soainfra-ingress  kubernetes/ingress-per-domain  --namespace soans --values /home/opc/soak8_lab/scripts/ingress_domainvalues.yaml 

kubectl describe ingress soainfra-traefik -n soans

#http://158.101.19.71:30305/console/login/LoginForm.jsp