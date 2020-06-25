# ingress-class=nginx
helm_nginx_ns:
	kubectl create namespace ingress-internal

helm_nginx_repo:
	helm repo add stable https://kubernetes-charts.storage.googleapis.com/
	helm repo update

# ingress-nginx documentation: \
https://docs.microsoft.com/en-us/azure/aks/ingress-internal-ip \
https://github.com/helm/charts/tree/master/stable/nginx-ingress \
https://kubernetes.github.io/ingress-nginx/
helm_nginx_install:
	helm install nginx-ingress stable/nginx-ingress \
	--namespace ingress-internal \
	--set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
	--set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
	--set controller.addHeaders.Strict-Transport-Security="max-age=31536000; includeSubDomains" \
	--set controller.addHeaders.X-Frame-Options="DENY" \
	--set controller.addHeaders.X-XSS-Protection="1; mode=block" \
	--set controller.addHeaders.X-Content-Type-Options="nosniff" \
	--set controller.addHeaders.Server="clientServer" \
	--set controller.service.omitClusterIP=true \
	--set defaultBackend.service.omitClusterIP=true \
	--set controller.replicaCount=3 \
	--set controller.ingressClass="internal" \
	--set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-internal"="true"

helm_nginx_uninstall:
	-helm uninstall nginx-ingress

helm_nginx_ingress_test:
	watch kubectl get service -l app=nginx-ingress --namespace ingress-internal

ingress_nginx: aks_credentials helm_nginx_ns helm_nginx_repo helm_nginx_install helm_nginx_ingress_test


# Get nginx ingress controller public ip
TF_VAR_k8s_ingress_ip = $(shell kubectl -n ingress-internal get service nginx-ingress-controller -o json | jq '.status.loadBalancer.ingress[0].ip' | sed 's|^|[|' | sed 's|$$|]|' )
show_ip_nginx_ingress:
	@echo ">> nginx_ingress_ip = tf.var.k8s_ingress_ip: "
	@echo ${TF_VAR_k8s_ingress_ip}

# Change var.k8s_ingress_ip@./terraform/vars.tf
change_nginx_ingress_ip:
	@sed -i '' 's/k8s_ingress_ip.*/k8s_ingress_ip = ${TF_VAR_k8s_ingress_ip}/' ${TF_DIR}/vars-${TF_WS}.tfvars