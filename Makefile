HELM?=_output/linux-amd64/helm
KUBECTL?=kubectl

IMAGE=quay.io/skeeey/cluster-proxy-addon:latest
IMAGE_PULL_POLICY=Always
CLUSTER_BASE_DOMAIN=apps.wlawscluster1.dev04.red-chesterfield.com

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
	--set global.imageOverrides.clusterProxyAddOn="$(IMAGE)" \
	--set cluster_basedomain="$(CLUSTER_BASE_DOMAIN)" 
.PHONY: deploy

clean: ensure-helm
	$(HELM) delete -n open-cluster-management cluster-proxy-addon
.PHONY: clean
