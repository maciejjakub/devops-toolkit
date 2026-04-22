Create a basic AKS cluster in KodeKloud playground environment. Set up istio ingress and deploy basic hello-kubernetes deployment, exposing it to the internet using azure kubernetes public load balancer. Deploy this way:

```
cd aks
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

Deploy second step
```
cd ingress
terraform apply
```