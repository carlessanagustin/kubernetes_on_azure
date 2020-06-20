-include ./mk/secrets.mk
-include ./mk/nginx-ingress.mk
-include ./mk/secure-ingress.mk
-include ./mk/terraform.mk


export project_prefix=test-carlesaks
export project_sufix=ne-001

export TF_VAR_office_pip=${OFFICE_PIP}

OFFICE_PIP := $(shell curl -s https://checkip.amazonaws.com)
whatismyip:
	@echo ${OFFICE_PIP}