# fppss-deploy

# Deploy

## Provision Kubernetes cluster

### Minikube

Install [minikube](https://minikube.sigs.k8s.io/docs/start/) on your machine.

Start a local minikube cluster.

    minikube start

Run minikube tunnel.

    minikube tunnel --cleanup

> NOTE: You will need to enter a password, when Kubernetes creates the LoadBalancer route (after applying manifests).

## Apply the manifests on the cluster

Install the helm chart.

    helm install fppss-energy config/kubernetes/helm --values config/kubernetes/helm/values.yaml 

## Clean up

Uninstall the helm chart.

    helm uninstall fppss-energy
