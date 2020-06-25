-include ./mk/secrets.mk
-include ./mk/nginx-ingress.mk
-include ./mk/secure-ingress.mk
-include ./mk/terraform.mk
-include ./mk/azure.mk

export project_prefix=test-carles-koa
export project_sufix=ne-001

export TF_VAR_project_prefix=${project_prefix}
export TF_VAR_project_sufix=${project_sufix}


AKS_RG=${project_prefix}-rg
AKS_NAME=${project_prefix}-k8s


OFFICE_PIP := $(shell curl -s https://checkip.amazonaws.com)
whatismyip:
	@echo ${OFFICE_PIP}