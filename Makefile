GHUSER := yokawasa
GHPAT := patpatpat
GHREPO := apollo-graphql-supergraph

.PHONY: default
default: docker-build-subgraphs

##@ General

.PHONY: kind-create
kind-create: ## Create a KIND cluster
	@echo "Creating KIND Cluster"
	kind create cluster --image kindest/node:v1.21.1 --config=kubernetes/clusters/kind-cluster.yaml --wait 5m

.PHONY: kind-delete
kind-delete: ## Delete a KIND cluster
	@echo "Deleting KIND Cluster"
	kind delete cluster --name kind

.PHONY: docker-build-subgraphs
docker-build-subgraphs: ## Build subgraphs containers
	docker-compose -f subgraphs/docker-compose.yml build --no-cache

.PHONY: docker-push-subgraphs
docker-push-subgraphs: docker-build-subgraphs  ## Push subgraphs images to registries
	@echo "docker login..."
	@echo ${GHPAT} | docker login ghcr.io -u ${GHUSER} --password-stdin
	docker tag subgraphs-products ghcr.io/${GHUSER}/${GHREPO}/subgraph-products:latest
	docker push ghcr.io/${GHUSER}/${GHREPO}/subgraph-products:latest
	docker tag subgraphs-users ghcr.io/${GHUSER}/${GHREPO}/subgraph-users:latest
	docker push ghcr.io/${GHUSER}/${GHREPO}/subgraph-users:latest
	docker tag subgraphs-inventory ghcr.io/${GHUSER}/${GHREPO}/subgraph-inventory:latest
	docker push ghcr.io/${GHUSER}/${GHREPO}/subgraph-inventory:latest
	docker tag subgraphs-pandas ghcr.io/${GHUSER}/${GHREPO}/subgraph-pandas:latest
	docker push ghcr.io/${GHUSER}/${GHREPO}/subgraph-pandas:latest

.PHONY: k8s-deploy
k8s-deploy: ## Deploy Kubernetes resources
	kubectl apply -k kubernetes

.PHONY: k8s-undeploy
k8s-undeploy: ## Undeploy Kubernetes resources
	kubectl delete -k kubernetes

.PHONY: query-supergraph
query-supergraph: ## Send test query to the supergraph endpoint
	kubectl run -it --rm=true temp-curl --image=curlimages/curl --restart=Never -- /bin/sh -c \
		"curl -X POST -H 'Content-Type: application/json' --data '{ \"query\": \"{allProducts{id,sku,createdBy{email,totalProductsCreated}}}\" }' http://router-service:4000/" 

.PHONY: query-health
query-health: ## Send test query to the router health check endpoint
	kubectl run -it --rm=true temp-curl --image=curlimages/curl --restart=Never -- /bin/sh -c \
		"curl -X GET -H 'Content-Type: application/json' http://router-service:8088/health" 

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
