Create a basic AKS cluster in KodeKloud playground environment. Deploy this way:

```
az login
```
Provide username & passoword and choose default subcription. Then apply with terraform:
```
terraform apply
```

To fetch kubeconfig with azure cli and store it locally:
```
az aks get-credentials --resource-group <your-rg-name> --name lab-aks
```

Install simple kubernetes 'hello-world' exposing web server through public load balancer:
```
git clone https://github.com/paulbouwer/hello-kubernetes.git
cd hello-kubernetes/deploy/helm/hello-kubernetes
helm install --create-namespace --namespace hello-kubernetes hello-world .
kubectl get svc hello-kubernetes-hello-world -n hello-kubernetes -o 'jsonpath={ .status.loadBalancer.ingress[0].ip }'
```

to do: set up an ingress controller to allow multiple services be hosted on a single public ip