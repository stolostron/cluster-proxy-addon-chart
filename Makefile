HELM?=_output/linux-amd64/helm
KUBECTL?=kubectl

IMAGE_CLUSTER_PROXY_ADDON?=quay.io/stolostron/cluster-proxy-addon:latest
IMAGE_CLUSTER_PROXY?=quay.io/stolostron/cluster-proxy:latest
IMAGE_PULL_POLICY=Always

IMAGE_TAG?=latest

# Using the following command to get the base domain of a OCP cluster
# export CLUSTER_BASE_DOMAIN=$(kubectl get ingress.config.openshift.io cluster -o=jsonpath='{.spec.domain}')
CLUSTER_BASE_DOMAIN?=

ensure-helm:
	mkdir -p _output
	cd _output && curl -s -f -L https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz -o helm-v3.2.4-linux-amd64.tar.gz
	cd _output && tar -xvzf helm-v3.2.4-linux-amd64.tar.gz
.PHONY: setup

lint: ensure-helm
	$(HELM) lint stable/cluster-proxy-addon
.PHONY: lint

deploy: ensure-helm
	$(HELM) install \
	-n open-cluster-management-addon --create-namespace \
	cluster-proxy-addon stable/cluster-proxy-addon \
	--set global.pullPolicy="$(IMAGE_PULL_POLICY)" \
	--set global.imageOverrides.cluster_proxy_addon="$(IMAGE_CLUSTER_PROXY_ADDON)" \
	--set global.imageOverrides.cluster_proxy="$(IMAGE_CLUSTER_PROXY)" \
	--set cluster_basedomain="$(CLUSTER_BASE_DOMAIN)" 
.PHONY: deploy

clean: ensure-helm
	$(HELM) delete -n open-cluster-management cluster-proxy-addon
	$(KUBECTL) delete -n open-cluster-management configmaps cluster-proxy-ca-bundle
	$(KUBECTL) delete -n open-cluster-management secrets cluster-proxy-addon-serving-cert
	$(KUBECTL) delete -n open-cluster-management secrets cluster-proxy-signer
.PHONY: clean
