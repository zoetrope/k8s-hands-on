KUBERNETES_VERSION := 1.25.3

KIND_CLUSTER_NAME=hands-on

all: help

.PHONY: launch-k8s
launch-k8s: ## Launch Kubernetes cluster with kind
	if [ ! "$(shell kind get clusters | grep $(KIND_CLUSTER_NAME))" ]; then \
		kind create cluster --name=$(KIND_CLUSTER_NAME) --config kind-config.yaml --image kindest/node:v$(KUBERNETES_VERSION) --wait 180s; \
		kubectl wait pod --all -n kube-system --for condition=Ready --timeout 180s; \
	fi

.PHONY: shutdown-k8s
shutdown-k8s: ## Shutdown Kubernetes cluster
	if [ "$(shell kind get clusters | grep $(KIND_CLUSTER_NAME))" ]; then \
		kind delete cluster --name=$(KIND_CLUSTER_NAME) || true; \
	fi

.PHONY: deploy-application
deploy-application: ## Deploy applications on Kubernetes cluster
	helm repo add argo https://argoproj.github.io/argo-helm
	helm repo update
	helm install --create-namespace --namespace argocd argocd argo/argo-cd
	kubectl -n argocd wait --for=condition=available --timeout=300s --all deployments
	kubectl apply -f ./manifests/argocd-config/argocd-config.yaml

.PHONY: build-todo-image
build-todo-image: ## Build todo container image
	docker build -t todo:v1 ./todo

.PHONY: load-todo-image
load-todo-image: ## Load todo container image to kind
	kind load docker-image --name=$(KIND_CLUSTER_NAME) todo:v1

.PHONY: argocd-password
argocd-password: ## Show admin password for ArgoCD
	@kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

.PHONY: grafana-password
grafana-password: ## Show admin password for Grafana
	@kubectl get secrets -n grafana grafana-admin-credentials -o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 -d

.PHONY: grafana-api-token
grafana-api-token:
	$(eval GRAFANA_PASSWORD := $(shell $(MAKE) grafana-password))
	$(eval TOKEN_ID := $(shell curl -sS http://admin:$(GRAFANA_PASSWORD)@localhost:3000/api/auth/keys | jq '.[] | select(.name=="promlens_key") | .id'))
	@if [ -n "$(TOKEN_ID)" ]; then \
		curl -sS -X DELETE http://admin:$(GRAFANA_PASSWORD)@localhost:3000/api/auth/keys/$(TOKEN_ID); \
	fi
	curl -X POST -H "Content-Type: application/json" -d '{"name":"promlens_key", "role": "Admin"}' http://admin:$(GRAFANA_PASSWORD)@localhost:3000/api/auth/keys | jq -r .key > ./bin/GRAFANA_API_TOKEN

.PHONY: promlens
promlens: grafana-api-token
	$(eval GRAFANA_API_TOKEN := $(shell cat ./bin/GRAFANA_API_TOKEN))
	promlens --grafana.url=http://localhost:3000 --grafana.api-token=$(GRAFANA_API_TOKEN)

.PHONY: port-forward-argocd
port-forward-argocd:
	mkdir -p ./tmp/
	kubectl port-forward -n argocd service/argocd-server 8000:80 > /dev/null 2>&1 & jobs -p > ./tmp/port-forward-argocd.pid

.PHONY: stop-port-forward-argocd
stop-port-forward-argocd:
	echo "kill `cat ./tmp/port-forward-argocd.pid`" && kill `cat ./tmp/port-forward-argocd.pid`
	rm ./tmp/port-forward-argocd.pid

.PHONY: login-argocd
login-argocd:
	argocd login localhost:8000 --insecure --username admin --password $$(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

.PHONY: port-forward-grafana
port-forward-grafana:
	mkdir -p ./tmp/
	kubectl port-forward -n grafana service/grafana-service 3000:3000 > /dev/null 2>&1 & jobs -p > ./tmp/port-forward-grafana.pid

.PHONY: stop-port-forward-grafana
stop-port-forward-grafana:
	echo "kill `cat ./tmp/port-forward-grafana.pid`" && kill `cat ./tmp/port-forward-grafana.pid`
	rm ./tmp/port-forward-grafana.pid

.PHONY: port-forward-loki
port-forward-loki:
	mkdir -p ./tmp/
	kubectl port-forward -n loki service/loki 3100:3100 > /dev/null 2>&1 & jobs -p > ./tmp/port-forward-loki.pid

.PHONY: stop-port-forward-loki
stop-port-forward-loki:
	echo "kill `cat ./tmp/port-forward-loki.pid`" && kill `cat ./tmp/port-forward-loki.pid`
	rm ./tmp/port-forward-loki.pid

.PHONY: port-forward-todo
port-forward-todo:
	mkdir -p ./tmp/
	kubectl port-forward -n todo service/todo 9999:80 > /dev/null 2>&1 & jobs -p > ./tmp/port-forward-todo.pid

.PHONY: stop-port-forward-todo
stop-port-forward-todo:
	echo "kill `cat ./tmp/port-forward-todo.pid`" && kill `cat ./tmp/port-forward-todo.pid`
	rm ./tmp/port-forward-todo.pid

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
