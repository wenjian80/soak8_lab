# Check dns network in kubernetes

kubectl apply -f https://k8s.io/examples/admin/dns/busybox.yaml

sleep 10s

kubectl exec -ti busybox -- nslookup kubernetes.default
