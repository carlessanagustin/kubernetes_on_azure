project_prefix ?= test-carlesaks
AKS_RG ?= ${project_prefix}-rg
AKS_NAME ?= ${project_prefix}-k8s

aks_credentials:
	az aks get-credentials --overwrite-existing \
	--subscription ${ARM_SUBSCRIPTION_ID} \
	--resource-group ${AKS_RG} \
	--name ${AKS_NAME}
	@watch kubectl get nodes