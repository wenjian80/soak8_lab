# Kube Porxy dashbaord

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
#kubectl apply -f recommended_dashboard.yaml
kubectl apply -f dashboard-admin.yaml

echo "Token to login to dashboard"
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')


#Run kubectl proxy
#Access k8 dashboard http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login