# fppss-deploy

[![Build Status](https://github.com/thomasstxyz/fppss-deploy/workflows/CI/badge.svg?event=push)](https://github.com/thomasstxyz/fppss-deploy/actions)

Infrastructure-as-Code for the "fppss-energy" application.

# Table of Contents
<!-- Regenerate this table of contents using https://github.com/ekalinin/github-markdown-toc -->
<!-- gh-md-toc --insert README.md -->
<!--ts-->
- [fppss-deploy](#fppss-deploy)
- [Table of Contents](#table-of-contents)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
  - [Creating a minikube cluster for local development](#creating-a-minikube-cluster-for-local-development)
  - [Creating an EKS cluster for production use](#creating-an-eks-cluster-for-production-use)
  - [Helm Install on existing cluster](#helm-install-on-existing-cluster)
  - [Uninstall](#uninstall)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->

<!--te-->

# Prerequisites

Install:

- [Terraform](https://www.terraform.io/downloads)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)
- [helm](https://helm.sh/docs/intro/install/)

# Usage

The terraform plan is meant to be applied on AWS to create an EKS cluster.
Once the cluster is provisioned, the "fppss-energy" application is installed via helm.

> Alternatively, the application may be installed on a minikube cluster for local development.

## Creating a minikube cluster for local development

Install [minikube](https://minikube.sigs.k8s.io/docs/start/) on your machine.

Start a local minikube cluster.

    minikube start

Run minikube tunnel.

    minikube tunnel --cleanup

> NOTE: You will need to enter a password, when Kubernetes creates the LoadBalancer route (after applying manifests).

## Creating an EKS cluster for production use

Change to terraform directory.

    cd config/terraform

Apply the terraform config.

    terraform apply -auto-approve

Retrieve the access credentials for your cluster and configure kubectl.

    aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)

Create an IAM role. Create a Kubernetes service account named aws-load-balancer-controller in the kube-system namespace for the AWS Load Balancer Controller and annotate the Kubernetes service account with the name of the IAM role.

    eksctl create iamserviceaccount \
        --region $(terraform output -raw region) \
        --cluster=$(terraform output -raw cluster_name) \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --role-name "AmazonEKSLoadBalancerControllerRole" \
        --attach-policy-arn=arn:aws:iam::$(aws sts get-caller-identity --query "Account" --output text):policy/AWSLoadBalancerControllerIAMPolicy \
        --approve

Add the eks-charts repository.

    helm repo add eks https://aws.github.io/eks-charts

Update your local repo to make sure that you have the most recent charts.

    helm repo update

Install the AWS Load Balancer Controller using Helm V3 or later.

    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=$(terraform output -raw cluster_name) \
        --set image.repository=602401143452.dkr.ecr.$(terraform output -raw region).amazonaws.com/amazon/aws-load-balancer-controller \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller 

> Note: You might have to adapt the image repository url if you face errors.

## Helm Install on existing cluster

Install the helm chart.

    helm install fppss-energy config/kubernetes/helm --values config/kubernetes/helm/values.yaml 

## Uninstall

Uninstall the helm chart.

    helm uninstall fppss-energy

Delete the iamserviceaccount.

    eksctl delete iamserviceaccount --region $(terraform output -raw region) --cluster=$(terraform output -raw cluster_name) --name=aws-load-balancer-controller

Clean up terraform infra.

    terraform destroy -auto-approve
