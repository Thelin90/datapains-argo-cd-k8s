export APP := datapains
export NAMESPACE := argocd
export VERSION := 7.1.0
export TOOLS_PATH := tools/k8s
export ENVIRONMENT := local
export SCRIPT_PATH := tools/scripts

.PHONY: deploy-local-argocd
deploy-local-argocd:
	kubectl create namespace $(NAMESPACE) || true
	helm install -f $(TOOLS_PATH)/$(ENVIRONMENT)/core/values.yaml datapains-argocd oci://ghcr.io/argoproj/argo-helm/argo-cd --version $(VERSION) --namespace $(NAMESPACE)

.PHONY: delete-local-argocd
delete-local-argocd:
	helm uninstall datapains-argocd --namespace $(NAMESPACE)

.PHONY: create-k8s-secret
create-k8s-secret:
	chmod +x tools/scripts/*.sh
	./{SCRIPT_PATH}/create_k8s_secret.sh $(SECRET_NAME) {NAMESPACE} 

.PHONY: create-secret
create-secret:
	chmod +x $(SCRIPT_PATH)/*.sh
	$(SCRIPT_PATH)/create_repo_secret.sh $(REPO_URL) $(SECRET_NAME) $(NAMESPACE) $(SSH_KEY_PATH)

.PHONY: apply-argocd-app
apply-argocd-app:
	kubectl apply -f $(TOOLS_PATH)/$(ENVIRONMENT)/applications/$(REPO_NAME)/$(APP_NAME)/app.yaml
