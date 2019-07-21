kubectl apply -f internal-k8s-service/deployment.yaml
kubectl expose deployment internal-service --port=80 --target-port=3001 --type=ClusterIP

kubectl create configmap internal-urls --from-literal INTERNALSERVICE=internal-service
kubectl apply -f proxy-service/deployment.yaml
kubectl expose deployment proxy-service --port=80 --target-port=3001 --type=ClusterIP

minikube addons enable ingress
kubectl apply -f proxy-service/ingress.yaml
echo "echo "$(minikube ip) practical.tangent.proxy" >> /etc/hosts" | sudo bash
echo "Waiting 10 seconds for pods to come up..."
sleep 10

curl practical.tangent.proxy