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

### AWS

Change to terraform directory.

    cd config/terraform

Apply the terraform config.

    terraform apply -auto-approve

Retrieve the access credentials for your cluster and configure kubectl.

    aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)

## Apply the manifests on the cluster

Install the helm chart.

    helm install fppss-energy config/kubernetes/helm --values config/kubernetes/helm/values.yaml 

## Clean up

Uninstall the helm chart.

    helm uninstall fppss-energy
