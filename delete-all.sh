kubectl delete deployment.apps/internal-service deployment.apps/proxy-service
kubectl delete configmap internal-urls                                       
kubectl delete service/internal-service service/proxy-service              