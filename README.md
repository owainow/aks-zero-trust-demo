# Azure Kubernetes Service - Zero Trust Demo
A repository containing the files to setup and configure an AKS Zero Trust Demo


## Contents

| File/folder       | Description                                |
|-------------------|--------------------------------------------|
| `README.md`       | This README file. |
| `.github/workflows`    | Workflow files for GitHub Actions. |
| `Cluster`    | Contains mainfests for cluster configuration via Flux |
| `Setup`    | Contains scripts to asssit in creation of demo, walkthrough included in this README. |
| `Terraform` | Contains the intial and post deployment Terraform files used by GitHub actions. |
| `LICENSE`         | The license for the sample. |

## Features

| Feature       | Description                                |
|-------------------|--------------------------------------------|
| `SSL Termination`       | Use NGINX to terminate SSL on the Ingress Controller before using mTLS internally. |
| `Oauth2 Proxy`    | Use Oauth2 Proxy with a sidecar architecture to preform authentication on individual microservices. |
| `Istio MTLS`    | Contains mainfests for cluster configuration via Flux. |
| `GitOps - Limit Cluster Access`    | Limit access to cluster through no User registration and deploying through ARGO.   |
| `Image Scanning using Azure Container Registry` | Use Defender for Containers to scan ACR images for vunrabilites at Push and Pull. |
| `Confidential Compute`         | Use confidential compute and software attestation to deploy to trusted execution enviroments. |
| `Calico Network Policies`         | Use confidential compute and software attestation to deploy to trusted execution enviroments. |

## Roadmap

| Feature       | Description                                |
|-------------------|--------------------------------------------|
| `FIPS enabled nodepools`       | Utilise FIPS enabled nodepools. |
| `Workload Identity`       | Use workload identity to restrict access to Azure resources. |
| `Firewall Egress`       | Setup Azure Firewall to process egress traffic. |
| `Full Gatekeeper demo`       | Show examples of using Gatekeeper in AKS. |
| `APIM Intergration`    | Utilising APIM for JWT validation forwarding requests through PLS. |
| `App Armor`    | Demonstrate use of App Armor|
| `End to End software supply chain`    | Showcase using Azure services to faciliate an end to end secure software supply chain. |




## Pre-Requisites 

It is reccomended that this repository is forked to allow creation and setup of your own self-hosted runners for the second stage of the infrastructure configuration. 
You will also need to create your own secrets to use through the workflow. I have created a setup script that creates and outputs most of the secrets required to run this creation of this demo. Some demos have other configuration elements or secrets that are required that can't be included in this demo repoistory such as SSL certificates. 

Once you have run the setup script please add the corresponding values into your GitHub Actions secrets which can be found under the Settings blade in the repository. The secrets required for intial deployment are shown below.

![image](https://github.com/owainow/aks-zero-trust-demo/assets/48108258/0eec7f90-250a-4cc7-96e6-56a4427d2a48)

It is worth noting there is some duplication due to differnet workflow plugin tools. The Azure_Credentials secret is the full JSON output of the SP creation.
