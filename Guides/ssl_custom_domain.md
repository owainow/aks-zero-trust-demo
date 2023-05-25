<p><font size="4"><li-image width="752" height="299" alt="1678111633831.png" align="center" id="470897i396C7A113C22752F" size="large" sourceType="new"></li-image></font></p>
<p>&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">Recently I have noticed an increase in questions from customers pertaining to different security practices for AKS deployments. I have decided to create a series of blogs covering some of the common ways to increase cluster security. I have plans for blog posts regarding Azure AD user authentication on micro services, utilizing Open Service Mesh and Network Policies to implement internal cluster networking security and the different options regarding metrics, alerting and telemetry for AKS clusters.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">Today however I will start by discussing using Azure Front Door, Private Link Service and NGINX Ingress Controller to create a secure ingress to private back end services with SSL termination.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">Before we jump into the use case &amp; implementation its important to understand the various components if unfamiliar. I will speak about benefits of certain technologies as I go through but it is worth taking a quick look at these links as a level set if you need it:</font></p>
<p>&nbsp;</p>
<ul>
<li><font size="4"><strong>Azure Front Door -<span>&nbsp;</span></strong><a href="https://learn.microsoft.com/en-us/azure/frontdoor/front-door-overview" target="_blank" rel="noopener">https://learn.microsoft.com/en-us/azure/frontdoor/front-door-overview</a></font></li>
<li><font size="4"><strong>Azure DNS -<span>&nbsp;</span></strong><a href="https://learn.microsoft.com/en-us/azure/dns/dns-overview" target="_blank" rel="noopener">https://learn.microsoft.com/en-us/azure/dns/dns-overview</a></font></li>
<li><font size="4"><strong>Azure Private Endpoints -<span>&nbsp;</span></strong><a href="https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview" target="_blank" rel="noopener">https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview</a></font></li>
<li><font size="4"><strong>Azure Private Link Service -<span>&nbsp;</span></strong><a href="https://learn.microsoft.com/en-us/azure/private-link/private-link-service-overview" target="_blank" rel="noopener">https://learn.microsoft.com/en-us/azure/private-link/private-link-service-overview</a></font></li>
<li><font size="4"><strong>Azure Load Balancer -<span>&nbsp;</span></strong><a href="https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview" target="_blank" rel="noopener">https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview</a></font></li>
<li><font size="4"><strong>Nginx Ingress Controller -<span>&nbsp;</span></strong><a href="https://docs.nginx.com/nginx-ingress-controller/intro/overview/" target="_blank" rel="noopener">https://docs.nginx.com/nginx-ingress-controller/intro/overview/</a></font></li>
<li><font size="4"><strong>Azure Kubernetes Service -<span>&nbsp;</span></strong><a href="https://azure.microsoft.com/en-us/products/kubernetes-service" target="_blank" rel="noopener">https://azure.microsoft.com/en-us/products/kubernetes-service</a></font></li>
</ul>
<p>&nbsp;</p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<hr />
<h2 class="reader-text-block__heading1"><font size="6">Use Case</font></h2>
<p>&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">A common pattern when deploying AKS is to protect your cluster by having restrictive network access. This could mean deploying your cluster with<span>&nbsp;</span><a href="https://learn.microsoft.com/en-us/azure/aks/private-clusters" target="_blank" rel="noopener">a private API server</a><span>&nbsp;</span>or using a private VNET &amp; fronting your applications with a public gateway. In this case we will be using an internal AKS cluster deployed in its own VNET without a public load balancer.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">This will mean the only public IP address will be the Kubernetes API server (which is mainly for ease of setup and demo). If you did decide to use a private api server nothing would change apart from requiring a bastion within your VNET to create resources on your cluster.</font></p>
<p class="reader-text-block__paragraph"><font size="4">In this example we will be fronting our AKS cluster directly with Azure Front Door which will use private link service to ensure a secure connection to our internal Azure load balancer.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">This will ensure that once requests are routed to our Front Door all subsequent traffic is private and being routed through the Azure Backbone network.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">We will also handle SSL Termination with our NGINX Ingress Controller. This allows us to use our own custom certificates to secure our connection and abstract the SSL termination from our application, reducing developer workload and the processing burden on backend services.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<hr />
<h2 class="reader-text-block__heading1"><font size="6"><strong>Implementation - Setup</strong></font></h2>
<p>&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">To start with I am using a domain that I purchased from namecheap.com. I am using Azure DNS to host my domain. This setup is outside of the scope of this blog. If you want to learn how to use Azure DNS to host your domain<span>&nbsp;</span><a href="https://learn.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns#:~:text=In%20the%20Azure%20portal%2C%20enter,DNS%20zones%2C%20select%20%2B%20Create.&amp;text=Select%20your%20Azure%20subscription.&amp;text=Select%20OK." target="_blank" rel="noopener">take a look at this link.</a></font></p>
<p class="reader-text-block__paragraph"><font size="4">I also will store my secrets as Kubernetes secrets without mounting a Key Vault. I will cover using Key Vault for Kubernetes secrets in a later blog post. Using built in Kubernetes secrets in production is not advised.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<h3 class="reader-text-block__heading2"><font size="5">Prerequisites</font></h3>
<p>&nbsp;</p>
<ul>
<li><font size="4"><a href="https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal?tabs=azure-cli" target="_blank" rel="noopener">Create an Azure Kubernetes Service Cluster.</a></font></li>
<li><font size="4">An existing custom domain.</font></li>
<li><font size="4"><a href="https://learn.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns" target="_blank" rel="noopener">Configure Azure DNS for your domain.</a></font></li>
<li><font size="4">A valid SSL certificate associated with your domain.</font></li>
<li><font size="4">A .pfx, .crt and .key file for your certificate.</font></li>
</ul>
<p><li-wrapper></li-wrapper></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<hr />
<h2 class="reader-text-block__heading1"><font size="6">Implementation - Configuration</font></h2>
<p>&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">These configuration files are available at the following Repo:<span>&nbsp;</span><a href="https://github.com/owainow/ssl-termination-private-aks" target="_blank" rel="noopener">https://github.com/owainow/ssl-termination-private-aks</a></font></p>
<h3 class="reader-text-block__heading2">&nbsp;</h3>
<h3 class="reader-text-block__heading2"><font size="5">Azure Kubernetes Service</font></h3>
<p>&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">With our existing Azure Kubernetes cluster up and running we can begin to configure the cluster.</font></p>
<p class="reader-text-block__paragraph"><font size="4">To start with we need to connect to our cluster. The commands required to connect to your specific cluster can be found conveniently in the Azure Portal under the connect tab in overview.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4"><li-image width="999" height="231" alt="AKS-Connect.png" align="inline" id="470898i7F97B9DF86E37917" size="large" sourceType="new"></li-image></font></p>
<div class="reader-image-block reader-image-block--full-width lia-align-center">
<figure class="reader-image-block__figure">
<div class="ivm-image-view-model   ">
<div class="ivm-view-attr__img-wrapper ivm-view-attr__img-wrapper--use-img-tag display-flex
        
        ">
<p>&nbsp;</p>
</div>
</div>
<figcaption class="display-block mt2 full-width text-body-small-open t-sans text-align-center t-black--light"><font size="4">Azure Kubernetes Servie overview tile</font></figcaption>
</figure>
</div>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">The first thing we need to deploy is our example application. The image I am deploying is a very simple API I created that supports a couple of different request methods. The image is public so feel free to use in for your testing purposes. The important thing to know about this application is that it is only configured for HTTP on port 80.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<pre class="reader-text-block__code"><font size="4">apiVersion: v1
kind: Namespace
metadata:
&nbsp; labels:
&nbsp; &nbsp; app.kubernetes.io/name: platforms
&nbsp; name: platforms
---
apiVersion: apps/v1
kind: Deployment
metadata:
&nbsp; name: platforms-depl


spec:
&nbsp; replicas: 1
&nbsp; selector:
&nbsp; &nbsp; matchLabels:
&nbsp; &nbsp; &nbsp; app: platform-service
&nbsp; template:
&nbsp; &nbsp; metadata:
&nbsp; &nbsp; &nbsp; labels:
&nbsp; &nbsp; &nbsp; &nbsp; app: platform-service
&nbsp; &nbsp; spec:
&nbsp; &nbsp; &nbsp; containers:
&nbsp; &nbsp; &nbsp; &nbsp;- name: platform-image
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;image: owain.azurecr.io/platforms:latest
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;imagePullPolicy: Always
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;resources:
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; requests:
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; memory: "64Mi"
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; cpu: "250m"
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; limits:
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; memory: "128Mi"
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
&nbsp; name: platforms-clusterip-srv
spec:
&nbsp; type: ClusterIP
&nbsp; selector:
&nbsp; &nbsp; app: platform-service
&nbsp; ports:
&nbsp; - name: platform-service-http
&nbsp; &nbsp; protocol: TCP
&nbsp; &nbsp; port: 80
&nbsp; &nbsp; targetPort: 80</font></pre>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">As this is the first apply command i'll also include it as a snippet. From now on you can assume any YAML will have been applied in the same way.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<pre class="reader-text-block__code"><font size="4">kubectl apply -f platforms-depl.yaml</font></pre>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">We can confirm the application is up and running by switching to the "platforms" namespace (If you don't already use<span>&nbsp;</span><a href="https://github.com/ahmetb/kubectx" target="_blank" rel="noopener">kubens</a><span>&nbsp;</span>for namespace switching it can be a great time saver) and running kubectl get pods.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4"><li-image width="675" height="275" alt="Application_running.png" align="center" id="470899i8E6D6D5115352083" size="large" sourceType="new"></li-image></font></p>
<div class="reader-image-block reader-image-block--full-width lia-align-center">
<figure class="reader-image-block__figure">
<div class="ivm-image-view-model   ">
<div class="ivm-view-attr__img-wrapper ivm-view-attr__img-wrapper--use-img-tag display-flex
        
        ">
<p>&nbsp;</p>
</div>
</div>
<figcaption class="display-block mt2 full-width text-body-small-open t-sans text-align-center t-black--light"><font size="4">Checking pod is running.</font><br /><br /></figcaption>
</figure>
</div>
<p class="reader-text-block__paragraph"><font size="4">We also now have to create the NGINX ingress controller. There are<span>&nbsp;</span><a href="https://kubernetes.github.io/ingress-nginx/deploy/" target="_blank" rel="noopener">multiple ways to install NGINX ingress controller</a>.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">I added the manifest recommended when deploying on Azure which can be found here:<span>&nbsp;</span><a href="https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml" target="_blank" rel="noopener">https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml</a></font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">This allows us to make a couple of changes required for this deployment. The first is to change the NGINX ingress service. The first thing we add under service is the annotation to create the service as an internal load balancer.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">We do that by adding the following annotation to the service:</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<pre class="reader-text-block__code"><font size="4">apiVersion: v1
kind: Service
metadata:
&nbsp; annotations:
&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-load-balancer-internal: "true"</font></pre>
<p class="reader-text-block__paragraph"><font size="4">We can then leverage a feature that is currently in public preview that allows us<span>&nbsp;</span><a href="https://cloud-provider-azure.sigs.k8s.io/topics/pls-integration/" target="_blank" rel="noopener">to create and configure a private link service from our NGINX ingress controller</a><span>&nbsp;</span>manifest.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">It is worth noting that public preview means that support is "best effort" until its full release. If you do encounter any issues using this feature please raise them<span>&nbsp;</span><a href="https://github.com/kubernetes-sigs/cloud-provider-azure/issues/new" target="_blank" rel="noopener">here.</a></font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">Underneath our internal annotation we now add the following:</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<pre class="reader-text-block__code"><font size="4">&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-pls-create: "true
&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-pls-ip-configuration-ip-address: "10.224.10.224"
&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-pls-ip-configuration-ip-address-count: "1"
&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-pls-ip-configuration-subnet: "default"
&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-pls-name: "aks-pls"
&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-pls-proxy-protocol: "false"
&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-pls-visibility: '*'"</font></pre>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">As NGINX Ingress Controller currently<span>&nbsp;</span><a href="https://github.com/kubernetes/ingress-nginx/issues/6590" target="_blank" rel="noopener">doesn't support any annotations to prevent HTTP communication to the controller itself</a><span>&nbsp;</span>I have also added the optional step to disable port 80 for the service to ensure no HTTP traffic is accepted. This means the service within your NGINX yaml manifest should look like the following:</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<pre class="reader-text-block__code"><font size="4">apiVersion: v1
kind: Service
metadata:
&nbsp; annotations:
&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-load-balancer-internal: "true"
&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-pls-create: "true"
&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-pls-ip-configuration-ip-address: "10.224.10.224"
&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-pls-ip-configuration-ip-address-count: "1"
&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-pls-ip-configuration-subnet: "default"
&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-pls-name: "aks-pls"
&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-pls-proxy-protocol: "false"
&nbsp; &nbsp; &nbsp; service.beta.kubernetes.io/azure-pls-visibility: '*'
&nbsp; labels:
&nbsp; &nbsp; app.kubernetes.io/component: controller
&nbsp; &nbsp; app.kubernetes.io/instance: ingress-nginx
&nbsp; &nbsp; app.kubernetes.io/name: ingress-nginx
&nbsp; &nbsp; app.kubernetes.io/part-of: ingress-nginx
&nbsp; &nbsp; app.kubernetes.io/version: 1.5.1
&nbsp; name: ingress-nginx-controller
&nbsp; namespace: ingress-nginx
spec:
&nbsp; externalTrafficPolicy: Local
&nbsp; ipFamilies:
&nbsp; - IPv4
&nbsp; ipFamilyPolicy: SingleStack
&nbsp; ports:
&nbsp;# - appProtocol: http
&nbsp;# &nbsp; name: http
&nbsp;# &nbsp; port: 80
&nbsp;# &nbsp; protocol: TCP
&nbsp;# &nbsp;targetPort: http
&nbsp; - appProtocol: https
&nbsp; &nbsp; name: https
&nbsp; &nbsp; port: 443
&nbsp; &nbsp; protocol: TCP
&nbsp; &nbsp; targetPort: https
&nbsp; selector:
&nbsp; &nbsp; app.kubernetes.io/component: controller
&nbsp; &nbsp; app.kubernetes.io/instance: ingress-nginx
&nbsp; &nbsp; app.kubernetes.io/name: ingress-nginx
&nbsp; type: LoadBalancer</font></pre>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">Before applying this manifest we need to create our TLS secret. We can do that with a command similar to the following, replace my key and certificate filename with your own.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<pre class="reader-text-block__code"><font size="4">kubectl create secret tls test-tls --key owainonline.key --cert owain_online.crt -n platforms</font></pre>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">The final change we now can make to our NGINX yaml manifest is to add an argument to the nginx-Ingress-Controller pod itself. We need to add the "Default SSL Certificate" as otherwise NGINX by default will use a fake certificate that it creates itself. Under the container arguments add the following:</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<pre class="reader-text-block__code"><font size="4">&nbsp; &nbsp; &nbsp; &nbsp; - --default-ssl-certificate=platforms/test-tls<li-image width="999" height="285" alt="pls-creation.png" align="center" id="470900iBC86B1470C6026D8" size="large" sourceType="new"></li-image></font></pre>
<p>&nbsp;</p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">We can now apply the entire NGINX manifest and view all of the resources that are created.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<pre class="reader-text-block__code"><font size="4">kubectl apply -f pls-nginx.yaml</font></pre>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">After a couple of minutes if we navigate to Private Link Service in the Azure portal we will see our AKS-PLS that has been created with 0 connections. Take note of the alias we will use that in a second when we configure Azure Front Door.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">The last manifest we need to apply is our actual ingress crd. This file will tell NGINX where to route requests. The Ingress object looks as follows:</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<pre class="reader-text-block__code"><font size="4">apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
&nbsp; name: ingress-srv
&nbsp; namespace: platforms
&nbsp; annotations:
&nbsp; &nbsp; kuberentes.io/ingress.class: nginx
&nbsp; &nbsp; nginx.ingress.kubernetes.io/use-regex: 'true'
&nbsp; &nbsp; nginx.ingress.kubernetes.io/affinity: "cookie"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"

&nbsp; labels:
&nbsp; &nbsp; app: platform-service


spec: 
&nbsp; ingressClassName: nginx
&nbsp; tls:
&nbsp; &nbsp;- hosts: 
&nbsp; &nbsp; &nbsp;- owain.online
&nbsp; &nbsp; &nbsp;secretName: test-tls


&nbsp; rules: 
&nbsp; &nbsp; - host: owain.online
&nbsp; &nbsp; - http: 
&nbsp; &nbsp; &nbsp; &nbsp; paths:
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; - path: /api/platforms
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; pathType: Prefix
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; backend: 
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; service: 
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; name: platforms-clusterip-srv
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; port: 
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; number: 80</font></pre>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">It is worth noting here by default when you add a TLS block to your NGINX ingress "ssl-redirect" is true by default. I include it here for visibility. Once we apply this manifest we can describe the resource with:</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<pre class="reader-text-block__code"><font size="4">kubectl describe ing ingress-srv -n platforms</font></pre>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">The output should look similar to this:</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4"><li-image width="680" height="442" alt="describe-ing.png" align="center" id="470901i502297A01A45DBDE" size="large" sourceType="new"></li-image></font></p>
<div class="reader-image-block reader-image-block--full-width lia-align-center">
<figure class="reader-image-block__figure">
<div class="ivm-image-view-model   ">
<div class="ivm-view-attr__img-wrapper ivm-view-attr__img-wrapper--use-img-tag display-flex
        
        ">
<p>&nbsp;</p>
</div>
</div>
<figcaption class="display-block mt2 full-width text-body-small-open t-sans text-align-center t-black--light"><font size="4">Ingress description</font></figcaption>
</figure>
<p>&nbsp;</p>
</div>
<p class="reader-text-block__paragraph"><font size="4">Here we can see that our routing rules have been successfully created but most importantly that our TLS block is configured where it states "test-tls terminates owain.online".</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">To start with lets check the internal IP of the service:</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<pre class="reader-text-block__code"><font size="4">$ kubectl get services -n ingress-nginx
NAME&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;TYPE&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;CLUSTER-IP&nbsp; &nbsp; &nbsp;EXTERNAL-IP&nbsp; &nbsp; PORT(S)&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;AGE
ingress-nginx-controller&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;LoadBalancer&nbsp; &nbsp;10.0.13.93&nbsp; &nbsp; &nbsp;10.224.2.146&nbsp; &nbsp;443:32490/TCP&nbsp; &nbsp;19mx</font></pre>
<p class="reader-text-block__paragraph"><font size="4">Then we need to start our test pod in the cluster:</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<pre class="reader-text-block__code"><font size="4">kubectl run -it --rm aks-ssh --image=debian:stable:</font></pre>
<p class="reader-text-block__paragraph"><font size="4">Once the pod is running we will see a shell and can enter the following commands to install curl:</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<pre class="reader-text-block__code"><font size="4">apt-get update -y &amp;&amp; apt-get install dnsutils -y &amp;&amp; apt-get install curl -y.</font></pre>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">We can then test our service.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<pre class="reader-text-block__code"><font size="4"># Curl your service /api/platforms
curl https://10.224.2.146/api/platforms

# Curl your service without validating certificate
curl https://10.224.2.146/api/platforms -k

# Curl to check http fails after closing port 80
curl http://10.224.2.146/api/platforms</font></pre>
<p class="reader-text-block__paragraph"><font size="4">&nbsp;<li-image width="999" height="172" alt="curl ssl.png" align="center" id="470903i6B61F67AE116F341" size="large" sourceType="new"></li-image></font></p>
<div class="reader-image-block reader-image-block--full-width lia-align-center">
<figure class="reader-image-block__figure">
<div class="ivm-image-view-model   ">
<div class="ivm-view-attr__img-wrapper ivm-view-attr__img-wrapper--use-img-tag display-flex
        
        ">
<p>&nbsp;</p>
</div>
</div>
<figcaption class="display-block mt2 full-width text-body-small-open t-sans text-align-center t-black--light"><font size="4">Secure curl fails, insecure curl works.</font></figcaption>
</figure>
<p>&nbsp;</p>
</div>
<p class="reader-text-block__paragraph"><font size="4">In the screen shot we can see that we were unable to create a secure connection from our pod as we didn't have access to a local user certificate. This is fine and expected as we have specified in our ingress rule that the host we are expecting requests from is "owain.online". If we add the -k to accept an insecure connection we can see our API response. If we curl using http we can see that it hangs which is expected as we have closed port 80.</font></p>
<h3 class="reader-text-block__heading2"><font size="5">Azure Front Door</font></h3>
<p>&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">With that now configured we can move on to creating and configuring Azure Front Door.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">As we are using Private Link Service and Private Endpoints we will need to use the Azure Front Door Premium SKU.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">We will then use either the Alias or selection from directory for the private link service that we created earlier under a "Custom" origin type and select enable private link service.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4"><li-image width="721" height="999" alt="AKS-First-Screen-Config.png" align="center" id="470904iEE22E32F57E4EC12" size="large" sourceType="new"></li-image></font></p>
<div class="reader-image-block reader-image-block--full-width lia-align-center">
<figure class="reader-image-block__figure">
<div class="ivm-image-view-model   ">
<div class="ivm-view-attr__img-wrapper ivm-view-attr__img-wrapper--use-img-tag display-flex
        
        ">
<p>&nbsp;</p>
</div>
</div>
<figcaption class="display-block mt2 full-width text-body-small-open t-sans text-align-center t-black--light"><font size="4">Front Door configuration</font></figcaption>
</figure>
<p>&nbsp;</p>
</div>
<p class="reader-text-block__paragraph"><font size="4">Once the front door instance is created we can then go to our PLS service and see we now have a pending connection to approve.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4"><li-image width="999" height="297" alt="aks-pls-private-endpoint-connection.png" align="center" id="470905i4D2A255E507595F1" size="large" sourceType="new"></li-image></font></p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<div class="reader-image-block reader-image-block--full-width lia-align-center">
<figure class="reader-image-block__figure">
<div class="ivm-image-view-model   ">
<div class="ivm-view-attr__img-wrapper ivm-view-attr__img-wrapper--use-img-tag display-flex
        
        ">
<p>&nbsp;</p>
</div>
</div>
<figcaption class="display-block mt2 full-width text-body-small-open t-sans text-align-center t-black--light"><font size="4">Front Door managed private endpoint request.</font></figcaption>
</figure>
</div>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">Configuring a custom domain in Azure Front Door and using your own certificate is outside of the scope for this post but the process is outlined<span>&nbsp;</span><a href="https://learn.microsoft.com/en-us/azure/frontdoor/standard-premium/how-to-add-custom-domain" target="_blank" rel="noopener">here</a>.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">Once our private endpoint is approved and the link is created we can then look at our route configuration in Front Door and ensure that we are only accepting HTTPS requests.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4"><li-image width="875" height="927" alt="route-front-door.png" align="center" id="470906i8E7C5E5763D4061D" size="large" sourceType="new"></li-image></font></p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<div class="reader-image-block reader-image-block--full-width lia-align-center">
<figure class="reader-image-block__figure">
<div class="ivm-image-view-model   ">
<div class="ivm-view-attr__img-wrapper ivm-view-attr__img-wrapper--use-img-tag display-flex
        
        ">
<p>&nbsp;</p>
</div>
</div>
<figcaption class="display-block mt2 full-width text-body-small-open t-sans text-align-center t-black--light"><font size="4">Azure Front Door https only route.</font></figcaption>
</figure>
</div>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">Although we could allow http &amp; https connections with redirects by selecting "HTTPS Only" we give users of our system more insight into what is happening with their HTTP request as instead of a curl returning a redirect the curl provides a 400 Bad Request error if we use HTTP.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4"><li-image width="708" height="308" alt="400 bad request.png" align="center" id="470907i07DE99367DA2AC02" size="large" sourceType="new"></li-image></font></p>
<div class="reader-image-block reader-image-block--full-width lia-align-center">
<figure class="reader-image-block__figure">
<div class="ivm-image-view-model   ">
<div class="ivm-view-attr__img-wrapper ivm-view-attr__img-wrapper--use-img-tag display-flex
        
        ">
<p>&nbsp;</p>
</div>
</div>
<figcaption class="display-block mt2 full-width text-body-small-open t-sans text-align-center t-black--light"><font size="4">Verbose http curl with bad request.</font></figcaption>
</figure>
</div>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">If we use do a verbose curl using https we can see the certificate being used and most importantly we get the expected result with the TLS termination taking place on the ingress because as we mentioned at the start our application is not configured to use HTTPS.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4"><li-image width="999" height="470" alt="https-curl.png" align="center" id="470908iB896F31B2D4166F6" size="large" sourceType="new"></li-image></font></p>
<div class="reader-image-block reader-image-block--full-width lia-align-center">
<figure class="reader-image-block__figure">
<div class="ivm-image-view-model   ">
<div class="ivm-view-attr__img-wrapper ivm-view-attr__img-wrapper--use-img-tag display-flex
        
        ">
<p>&nbsp;</p>
</div>
</div>
<figcaption class="display-block mt2 full-width text-body-small-open t-sans text-align-center t-black--light"><font size="4">Verbose curl with https</font></figcaption>
</figure>
<p>&nbsp;</p>
</div>
<p class="reader-text-block__paragraph"><font size="4">We can also verify that the requests are being forwarded to our backed as HTTP requests if we take a look at the logs of our NGINX ingress controller by using the following command:</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<pre class="reader-text-block__code"><font size="4">kubectl logs ingress-nginx-controller-&lt;YOUR VARCHAR&gt;</font></pre>
<div class="reader-image-block reader-image-block--full-width lia-align-center">
<p><font size="4"><li-image width="999" height="124" alt="Http Get requests forwarding.png" align="center" id="470909i0A647E4AFB83BCDE" size="large" sourceType="new"></li-image></font></p>
<figure class="reader-image-block__figure">
<div class="ivm-image-view-model   ">
<div class="ivm-view-attr__img-wrapper ivm-view-attr__img-wrapper--use-img-tag display-flex
        
        ">
<p>&nbsp;</p>
</div>
</div>
<figcaption class="display-block mt2 full-width text-body-small-open t-sans text-align-center t-black--light"><font size="4">Http request forwarding</font></figcaption>
</figure>
</div>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4">We can see that the above requests are being forwarded using HTTP on Port 80 of the Platforms-clusterip-srv.</font></p>
<p class="reader-text-block__paragraph"><font size="4">If we navigate to <a href="https://www.owain.online/api/platforms" target="_blank" rel="noopener">https://www.owain.online/api/platforms</a> we will also be able to see our API and by clicking on the HTTPS padlock in the URL we can view the certificate securing this connection.</font></p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<p class="reader-text-block__paragraph"><font size="4"><li-image width="999" height="445" alt="web result https.png" align="center" id="470910i251E0BFD3EE5C70A" size="large" sourceType="new"></li-image></font></p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p class="reader-text-block__paragraph">&nbsp;</p>
<div class="reader-image-block reader-image-block--full-width lia-align-center">
<figure class="reader-image-block__figure">
<div class="ivm-image-view-model   ">
<div class="ivm-view-attr__img-wrapper ivm-view-attr__img-wrapper--use-img-tag display-flex
        
        ">
<p>&nbsp;</p>
</div>
</div>
<figcaption class="display-block mt2 full-width text-body-small-open t-sans text-align-center t-black--light"><font size="4">Certificate in web browser</font></figcaption>
</figure>
<p>&nbsp;</p>
<h2 class="reader-text-block__heading1 lia-align-left"><font size="6">Conclusion</font></h2>
<p>&nbsp;</p>
<p class="reader-text-block__paragraph lia-align-left"><font size="4">Making the most of time saving features such as using azure front door managed PE's and PLS annotations on your ingress means that getting a secure private TLS connection from Front Door to your internal Kuberenetes cluster is much simpler. In a production environment it would certainly be advisable to use IaaC approaches throughout the deployment including for your secret creation and Azure Resource creation. Tools like Bicep and Terraform have great modules to get you up and running quickly.</font></p>
<p class="reader-text-block__paragraph lia-align-left">&nbsp;</p>
<p class="reader-text-block__paragraph lia-align-left"><font size="4">If you are looking at creating your Kubernetes cluster as code the<span>&nbsp;</span><a href="https://azure.github.io/AKS-Construction/" target="_blank" rel="noopener">AKS Construction Helper</a><span>&nbsp;</span>is a great way to visually configure your cluster and receive an automated script for IaaC deployment.</font></p>
<p class="reader-text-block__paragraph lia-align-left">&nbsp;</p>
<p class="reader-text-block__paragraph lia-align-left"><font size="4">Of course using HTTPS with SSL termination is only one small part of best practices for creating secure AKS deployments. You can find the full security base line<span>&nbsp;</span><a href="https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/aks-security-baseline" target="_blank" rel="noopener">here</a>.</font></p>
<p class="reader-text-block__paragraph lia-align-left">&nbsp;</p>
<p class="reader-text-block__paragraph lia-align-left"><font size="4">In my next blog I will be building on this architecture and looking at using the<span>&nbsp;</span><a href="https://github.com/oauth2-proxy/oauth2-proxy" target="_blank" rel="noopener">OAuth2 Reverse Proxy</a><span>&nbsp;</span>alongside Azure AD to secure your AKS hosted microservices.</font></p>
<p class="reader-text-block__paragraph lia-align-left">&nbsp;</p>
<p class="reader-text-block__paragraph lia-align-left"><font size="4">As mentioned all of the complete configuration files are available on Github here:<span>&nbsp;</span><a href="https://github.com/owainow/ssl-termination-private-aks" target="_blank" rel="noopener">https://github.com/owainow/ssl-termination-private-aks</a></font></p>
</div>