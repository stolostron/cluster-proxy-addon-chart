HELM?=_output/linux-amd64/helm
KUBECTL?=kubectl

IMAGE=quay.io/stolostron/cluster-proxy-addon:latest
IMAGE_PULL_POLICY=Always

IMAGE_CLUSET_PROXY=quay.io/stolostron/cluster-proxy:latest

CLUSTER_BASE_DOMAIN=

ensure-helm:
	mkdir -p _output
	cd _output && curl -s -f -L https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz -o helm-v3.2.4-linux-amd64.tar.gz
	cd _output && tar -xvzf helm-v3.2.4-linux-amd64.tar.gz
.PHONY: setup

lint: ensure-helm
	$(HELM) lint stable/cluster-proxy-addon
.PHONY: lint

deploy: ensure-helm
	$(KUBECTL) get ns open-cluster-management ; if [ $$? -ne 0 ] ; then $(KUBECTL) create ns open-cluster-management ; fi
	$(HELM) install -n open-cluster-management cluster-proxy-addon stable/cluster-proxy-addon \
	--set global.pullPolicy="$(IMAGE_PULL_POLICY)" \
	--set global.imageOverrides.cluster_proxy_addon="$(IMAGE)" \
	--set cluster_basedomain="$(CLUSTER_BASE_DOMAIN)" 
.PHONY: deploy

deploy-cluster-proxy: ensure-helm
	$(HELM) install \
	-n open-cluster-management-addon --create-namespace \
	cluster-proxy stable/cluster-proxy \
	--set image="$(IMAGE_CLUSET_PROXY)" \
	--set proxyServerImage="$(IMAGE)" \
	--set proxyAgentImage="$(IMAGE)" \
.PHONY: deploy-cluster-proxy

clean: ensure-helm
	$(HELM) delete -n open-cluster-management cluster-proxy-addon
	$(KUBECTL) delete -n open-cluster-management configmaps cluster-proxy-ca-bundle
	$(KUBECTL) delete -n open-cluster-management secrets cluster-proxy-addon-serving-cert
	$(KUBECTL) delete -n open-cluster-management secrets cluster-proxy-signer
.PHONY: clean
