# Practical 

## 1. Service accessible internally to k8s 
I have create a docker image `nishaaltailor/internal-k8s-service` that is running a simple `Express.`js server.

I created a deployment called `internal-service` of this in Kubernetes: 

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: internal-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: internal-service
  template:
    metadata:
      labels:
        app: internal-service
    spec:
      containers:
      - name: internal-service
        image: nishaaltailor/internal-k8s-service:latest
        ports:
        - containerPort: 3001
```

Next, I exposed this service internally using `ClusterIP` by mapping port `3001` to `80`:

```
kubectl expose deployment internal-service --port=80 --target-port=3001 --type=ClusterIP
```

## 2. Proxy service
I have created a docker image that is running a simple `Express.js` server, using `axios` as the `http` client. This acts as a proxy to the `internal-service`. The proxy service loads the endpoint for the internal service via environment variables. The environment variable is populated from a config map, `internal-urls`:

```
kubectl create configmap internal-urls --from-literal INTERNALSERVICE=internal-service
```

I then created a deployment `proxy-service`, and declaring an environment variable form the configmap `internal-urls`:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: proxy-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: proxy-service
  template:
    metadata:
      labels:
        app: proxy-service
    spec:
      containers:
      - name: proxy-service
        image: nishaaltailor/internal-k8s-service:latest
        ports:
        - containerPort: 3001
        envFrom:
        - configMapRef:
            name: internal-urls
```

Next, I exposed the deployment using service of type `ClusterIP`, `proxy-service`:

```
kubectl expose deployment proxy-service --port=80 --target-port=3001 --type=ClusterIP
```

## 3. Exposing the `proxy-service` external to the cluster

Firstly, I enabled `ingress` on the minikube cluster:
```
minikube addons enable ingress
```

I then created an ingress rule for the host `practical.tangent.proxy`

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: proxy-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: practical.tangent.proxy
    http:
      paths:
      - path: /
        backend:
          serviceName: proxy-service
          servicePort: 80
```

Now, to resolve `practical.tangent.proxy` locally, we need to add the following to `/etc/hosts`:
```
192.168.99.100 practical.tangent.proxy
```

Where `192.168.99.100` is the IP of Minikube which can be obtained by running the following:
```
minikube ip
```

Finally I access the internal service via the proxy service by running:
```
curl practical.tangent.proxy
```

Expected output:
```
Hello from service exposed internally to k8s cluster via ClusterIP
```

## 4. Do you want to run this on your Minikube cluster? 

Simply run the following script (Assuming your kubeconfig is pointing to the Minikube cluster):
```
./practical.sh
```
To clean up the resources on Minikube, run the following script:
```
./delete-all.sh
```





