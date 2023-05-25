Prerequisites 

* Running the Github Action Workflows to create and configure infrastructure.
* An existing custom domain.
* Configure Azure DNS for your domain.
* A valid SSL certificate associated with your domain.
* A .pfx, .crt and .key file for your certificate.

To start with I am using a domain that I purchased from namecheap.com. I am using Azure DNS to host my domain. This setup is outside of the scope of this setup. If you want to learn how to use Azure DNS to host your domain take a look at this link.

I would advise creating a folder within the git clone called "secrets". This reference is already included in the .gitignore and will be a safe place to store your tls keys and certs.

Implementation 

If you have deployed the application through the GitHub Actions provided the colors application & NGINX ingress controller should already have been deployed by ArgoCD. You can verify this by running from the self-hosted Azure Container Instance:

kubectl get pods -n colors-api && kubectl get pods -n colors-web

The Terraform that provisions the FrontDoor should have created a connection for the backend to the PLS created in our NGINX manifest.

In this demo we will use Kuberenetes Secrets to handle our SSL termination. Ideally we would use Key Vault. I will make this change in the future.
We can create the Kuberentes secrets using (replacing my file names with yours): 

kubectl create secret tls test-tls --key owainonline.key --cert owain_online.crt -n ingress-nginx

We now need to modify and redeploy our ingress file to reflect our hostname. Open the ingress.yaml file in your chosen editor and replace the hostname fields that contain owain.online with your chosen domain name. ArgoCD will sync this 