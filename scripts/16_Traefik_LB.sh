kubectl create namespace traefik

cd /home/opc/weblogic-kubernetes-operator
helm repo add traefik https://containous.github.io/traefik-helm-chart
 
helm install traefik  traefik/traefik --namespace traefik --values kubernetes/samples/scripts/charts/traefik/values.yaml --set  "kubernetes.namespaces={traefik}" --set "service.type=NodePort" --wait

kubectl get all -n traefik
 
#Configure Traefik to manage Ingresses created in this namespace:
helm upgrade traefik traefik/traefik --namespace traefik  --reuse-values --set "kubernetes.namespaces={traefik,soans}"

#Generate sample cert for ssl 
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/tls1.key -out /tmp/tls1.crt -subj "/CN=*"
kubectl -n soans create secret tls soainfra-tls-cert --key /tmp/tls1.key --cert /tmp/tls1.crt

cd /home/opc/fmw-kubernetes/OracleSOASuite/
helm install soainfra-ingress  kubernetes/ingress-per-domain  --namespace soans --values /home/opc/soak8_lab/scripts/ingress_domainvalues.yaml 

kubectl describe ingress soainfra-traefik -n soans

#http://158.101.19.71:30305/console/login/LoginForm.jsp