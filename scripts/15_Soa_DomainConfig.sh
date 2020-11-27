#Started the server using the output generated
cd /home/opc/soak8_lab/scripts/weblogic-domains/soainfra
kubectl apply -f domain.yaml

kubectl get all,domains -n soans

echo "After the command, issue kubectl get po -n soans -w and wait for server to be started"

echo "You can check the logs for admin server pod kubectl logs soainfra-adminserver -n soans --follow"