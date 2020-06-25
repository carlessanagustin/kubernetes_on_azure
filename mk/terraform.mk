TF_DIR ?= ./
TF_WS ?= dev
TFVARS ?= -var-file=./vars-${TF_WS}.tfvars
#TFYES ?= -auto-approve

tf_start: tf_init tf_create  

tf_init:
	cd ${TF_DIR} && terraform init

tf_create:
	cd ${TF_DIR} && terraform workspace new ${TF_WS}

tf_cleanup:
	cd ${TF_DIR} && terraform workspace select default && terraform workspace delete -force ${TF_WS} && rm -Rf .terraform

tf_plan:
	cd ${TF_DIR} && terraform plan ${TFVARS}

tf_apply:
	cd ${TF_DIR} && terraform apply ${TFVARS} ${TFYES}

tf_destroy:
	cd ${TF_DIR} && terraform destroy ${TFVARS}

tf_console:
	cd ${TF_DIR} && terraform console
