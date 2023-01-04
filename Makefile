KUBERNETES_VERSION := 1.25.3

KIND_CLUSTER_NAME=hands-on

all: help

.PHONY: launch-k8s
launch-k8s: ## Launch Kubernetes cluster with kind
	if [ ! "$(shell kind get clusters | grep $(KIND_CLUSTER_NAME))" ]; then \
		kind create cluster --name=$(KIND_CLUSTER_NAME) --config kind-config.yaml --image kindest/node:v$(KUBERNETES_VERSION) --wait 180s; \
		kubectl wait pod --all -n kube-system --for condition=Ready --timeout 180s; \
	fi
	$(MAKE) portforward

.PHONY: shutdown-k8s
shutdown-k8s: ## Shutdown Kubernetes cluster
	if [ "$(shell kind get clusters | grep $(KIND_CLUSTER_NAME))" ]; then \
		kind delete cluster --name=$(KIND_CLUSTER_NAME) || true; \
	fi
	$(MAKE) stop-portforward

.PHONY: deploy-argocd
deploy-argocd: ## Deploy Argo CD on Kubernetes cluster
	helm repo add argo https://argoproj.github.io/argo-helm
	helm repo update
	helm install --create-namespace --namespace argocd argocd argo/argo-cd
	kubectl -n argocd wait --for=condition=available --timeout=300s --all deployments
	kustomize build ./manifests/applications | kubectl apply -f -
	$(MAKE) login-argocd

.PHONY: sync-applications
sync-applications: ## Sync Applications
	$(eval APPS := $(shell kustomize build ./manifests/applications/ | yq ea [.] -o json | jq -r '. | sort_by(.metadata.annotations."argocd.argoproj.io/sync-wave" // "0" | tonumber) | .[] | .metadata.name'))
	for app in $(APPS); do \
		argocd app sync $$app --retry-limit 3 --timeout 300; \
		argocd app wait $$app --timeout 300; \
	done

.PHONY: local-sync-applications
local-sync-applications: ## Sync Applications with local manifests
	$(eval APPS := $(shell kustomize build ./manifests/applications/ | yq ea [.] -o json | jq -r '. | sort_by(.metadata.annotations."argocd.argoproj.io/sync-wave" // "0" | tonumber) | .[] | .metadata.name'))
	for app in $(APPS); do \
		if [ $$app = "namespaces" ] || [ $$app = "monitoring" ] || [ $$app = "sandbox" ]; then \
			argocd app sync $$app --local=./manifests/$$app --retry-limit 3 --timeout 300; \
		else \
			argocd app sync $$app --retry-limit 3 --timeout 300; \
		fi; \
		argocd app wait $$app --timeout 300; \
	done

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
	@kubectl get secrets -n prometheus prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d

.PHONY: grafana-api-token
grafana-api-token:
	$(eval GRAFANA_PASSWORD := $(shell $(MAKE) grafana-password))
	$(eval TOKEN_ID := $(shell curl -sS http://admin:$(GRAFANA_PASSWORD)@localhost:33000/api/auth/keys | jq '.[] | select(.name=="promlens_key") | .id'))
	@if [ -n "$(TOKEN_ID)" ]; then \
		curl -sS -X DELETE http://admin:$(GRAFANA_PASSWORD)@localhost:33000/api/auth/keys/$(TOKEN_ID); \
	fi
	curl -X POST -H "Content-Type: application/json" -d '{"name":"promlens_key", "role": "Admin"}' http://admin:$(GRAFANA_PASSWORD)@localhost:33000/api/auth/keys | jq -r .key > ./bin/GRAFANA_API_TOKEN

.PHONY: promlens
promlens: grafana-api-token
	$(eval GRAFANA_API_TOKEN := $(shell cat ./bin/GRAFANA_API_TOKEN))
	promlens --grafana.url=http://localhost:33000 --grafana.api-token=$(GRAFANA_API_TOKEN)

.PHONY: login-argocd
login-argocd:
	argocd login localhost:30080 --insecure --username admin --password $$(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

.PHONY: portforward
portforward:
	mkdir -p /tmp/dpf
	declarative-port-forwarder start --config ./portforward.yaml

.PHONY: stop-portforward
stop-portforward:
	declarative-port-forwarder stop

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
