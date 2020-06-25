## Update Kubernetes credentials
project_prefix ?= test-carles-koa
AKS_RG ?= ${project_prefix}-rg
AKS_NAME ?= ${project_prefix}-k8s
aks_credentials:
	az aks get-credentials --overwrite-existing \
	--subscription ${ARM_SUBSCRIPTION_ID} \
	--resource-group ${AKS_RG} \
	--name ${AKS_NAME}
	#@watch kubectl get nodes

## Get Azure Application Gateway public ip
show_ip_appgw:
	@echo ">> appgw_ip: "
	@az network public-ip show \
	--name ${project_prefix}-appgw-pip \
	--resource-group ${AKS_RG} \
	--subscription ${ARM_SUBSCRIPTION_ID} \
	| jq '.ipAddress' | tr -d '"'

## Create self-signed TLS/SSL certificates for Application Gateway
CERTDIR=./certs
CERTNAME=appgwcert
PASSWD ?= Shebai5oyav9eheghoowie4ah
DAYS=3650
Country_Name=ES
State_Name=Catalunya
Locality=Barcelona
Organization=OrgInc
Common_Name=org.inc
appgw_cert:
	-mkdir -p ${CERTDIR}
	openssl req -x509 -sha256 -nodes -days ${DAYS} -newkey rsa:2048 \
	  -keyout ${CERTDIR}/${CERTNAME}.key -out ${CERTDIR}/${CERTNAME}.crt \
	  -subj "/C=${Country_Name}/ST=${State_Name}/L=${Locality}/O=${Organization}/CN=${Common_Name}"
	openssl pkcs12 -export \
	  -password pass:${PASSWD} \
	  -out ${CERTDIR}/${CERTNAME}.pfx -inkey ${CERTDIR}/${CERTNAME}.key -in ${CERTDIR}/${CERTNAME}.crt
	echo "application gateway certificate: ${CERTDIR}/${CERTNAME}.pfx"
# docs: https://docs.microsoft.com/en-us/azure/application-gateway/redirect-http-to-https-cli#create-a-self-signed-certificate