# TODO

# output: aks_node_resource_group = 
TF_VAR_aks_node_resource_group = $(shell az aks show --name ${project_prefix}-k8s --resource-group ${AKS_RG} --subscription ${ARM_SUBSCRIPTION_ID} | jq '.nodeResourceGroup')
TF_VAR_aks_nsg_name = $(shell az network nsg list --resource-group ${TF_VAR_aks_node_resource_group} --subscription ${ARM_SUBSCRIPTION_ID} | jq '.[].name')
# --destination-address-prefixes = 'VirtualNetwork', 'AzureLoadBalancer', 'Internet' or '*'
add_rule_http:
	az network nsg rule create \
	--subscription ${ARM_SUBSCRIPTION_ID} \
	--resource-group ${TF_VAR_aks_node_resource_group} \
	--nsg-name ${TF_VAR_aks_nsg_name} \
	--name office-pip-http \
	--priority 100 \
	--access Allow \
	--destination-address-prefixes AzureLoadBalancer \
	--destination-port-ranges 80 \
	--direction Inbound \
	--protocol TCP \
	--source-port-ranges '*' \
	--source-address-prefixes ${OFFICE_PIP}

add_rule_https:
	az network nsg rule create \
	--subscription ${ARM_SUBSCRIPTION_ID} \
	--resource-group ${TF_VAR_aks_node_resource_group} \
	--nsg-name ${TF_VAR_aks_nsg_name} \
	--name office-pip-https \
	--priority 101 \
	--access Allow \
	--destination-address-prefixes AzureLoadBalancer \
	--destination-port-ranges 443 \
	--direction Inbound \
	--protocol TCP \
	--source-port-ranges '*' \
	--source-address-prefixes ${OFFICE_PIP}

add_rule_deny_any:
	az network nsg rule create \
	--subscription ${ARM_SUBSCRIPTION_ID} \
	--resource-group ${TF_VAR_aks_node_resource_group} \
	--nsg-name ${TF_VAR_aks_nsg_name} \
	--name office-pip-deny-any \
	--priority 110 \
	--access Deny \
	--destination-address-prefixes '*' \
	--destination-port-ranges '*' \
	--direction Inbound \
	--protocol '*' \
	--source-port-ranges '*' \
	--source-address-prefixes Internet

add_rules: add_rule_https add_rule_http add_rule_deny_any
