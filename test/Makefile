RESOURCES ?= ./hello-world-layers.yaml

apply:
	kubectl apply -f ${RESOURCES}

delete:
	-kubectl delete -f ${RESOURCES}

get:
	watch kubectl -n nginx-test get deployments,pod,svc,endpoints,ingress,replicasets


# TODO
# https://github.com/kubernetes/dashboard/tree/master/docs
proxy:
	kubectl proxy --port=8001 &
	curl -Iks http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy


# TODO
# change with correct secret id
SECRET ?= kubernetes-dashboard-token-pq5lp
token:
	kubectl -n kube-system describe secret ${SECRET}