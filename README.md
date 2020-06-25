# AKS deployment

## Requirements

* Docker
* make
* kubectl
* Terraform
* jq
* az CLI

## Architecture

![./aks_architecture.png](./aks_architecture.png)

## Deployment instructions

* **IMPORTANT**: Remember to change Terraform State remote location from `./terraform/backend.tf`

* AKS can be deployed with 1 or 2 ingress controllers:
  * `ingress-class=internal` (**recommended**): Manual provision of an internal NGINX ingress controller plus an Azure Application Gateway resource for L7 traffic forwarding and WAF security.
  * `ingress-class=addon-http-application-routing`: Azure provided enabling variable `tf.azurerm_kubernetes_cluster.addon_profile.http_application_routing.enabled=true`

### 1. Deploy AKS cluster

* Deploy AKS cluster

```shell
./ $ make tf_start
# (optional) ./ $ make tf_plan
./ $ make tf_apply
```

### 2. Setup custom internal NGINX ingress controller

* Create custom NGINX ingress controller by running:

```shell
./ $ make ingress_nginx
```

* *(optional)* Change `./vars-${TF_WS}.tfvars` by running:

```shell
# (optional) ./ $ make change_nginx_ingress_ip
```

* Apply changes by running:

```shell
# (optional) ./ $ make tf_plan
./ $ make tf_apply
```

## Test

Go to [test folder](./test/)

## Other commands

* Get appgw public ip

```shell
./ $ make show_ip_appgw
```

* Gain new AKS credentials for CLI

```shell
./ $ make aks_credentials
```