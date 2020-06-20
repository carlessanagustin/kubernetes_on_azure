# Testing environment for Kubernetes

This folder creates a single nginx deployment in Kubernetes with 2 services:

1. kind: Service > spec: > type: ClusterIP = uses the default ingress PIP
2. kind: Service > spec: > type: LoadBalancer = creates a new PIP in Azure

## Usage

* Launch a simple nginx deployment

```shell
make RESOURCES=./hello-world-layers.yaml apply
```

* L4 test: `curl -Iks http://${IP_SERVICE}` (service/nginx-svc-l4)
* L7 test: `curl -Iks http://${IP_APPGW}/nginx-test`
* Only if `tf.azurerm_kubernetes_cluster.addon_profile.http_application_routing.enabled=true`
  * L7 test: `curl -Iks https://${IP_INGRESS}/nginx-test` (ingress/nginx-ingress-l7-external)

> Run `kubectl -n nginx-test get svc,ingress` to get previous information

* Extra test with ArangoDB container

```shell
make RESOURCES=./arangodb-L4.yaml apply
```

## Delete test

```shell
make RESOURCES=./hello-world-layers.yaml delete
make RESOURCES=./arangodb-L4.yaml delete
```