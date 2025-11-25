-include .env
DOCKER_IMAGE ?= hashicorp/terraform:1.6
ROOT_DIR := /data
EXEC = docker run --rm -i \
					-e AWS_PROFILE=$(AWS_PROFILE) \
					-e KUBECONFIG=${ROOT_DIR}/kubeconfig.yaml \
					-v $(HOME)/.aws:/root/.aws \
					-v $(PWD):/data \
					-w /data \
					$(DOCKER_IMAGE)

.PHONY: init
init:
	@$(EXEC)  init -no-color

.PHONY: plan
plan:
	@$(EXEC)  plan -no-color

.PHONY: apply
apply:
	@$(EXEC)  apply -no-color
	@echo ""
	@echo "To access the Kubernetes cluster, run:"
	@echo "aws eks --region $$($(EXEC) output -raw region) update-kubeconfig --name $$($(EXEC) output -raw cluster_name)"
	@echo ""
	@echo "=== ArgoCD Access Information ==="
	@echo "ArgoCD Server URL: $$($(EXEC) output -raw argocd_server_url)"
	@echo "ArgoCD Username: $$($(EXEC) output -raw argocd_username)"
	@echo "ArgoCD Password: $$($(EXEC) output -raw argocd_password)"
	@echo ""
	@echo "Applying app-of-apps manifest..."
	@aws eks --region $$($(EXEC) output -raw region) update-kubeconfig --name $$($(EXEC) output -raw cluster_name) || true
	@sleep 10
	@kubectl apply -f https://raw.githubusercontent.com/Lforlinux/k8s-platform-toolkit/main/argocd/app-of-apps.yaml || echo "Note: Ensure kubectl is configured and ArgoCD is ready"

.PHONY: apply-auto-approve
apply-auto-approve:
	@$(EXEC)  apply -auto-approve
	@echo ""
	@echo "To access the Kubernetes cluster, run:"
	@echo "aws eks --region $$($(EXEC) output -raw region) update-kubeconfig --name $$($(EXEC) output -raw cluster_name)"
	@echo ""
	@echo "=== ArgoCD Access Information ==="
	@echo "ArgoCD Server URL: $$($(EXEC) output -raw argocd_server_url)"
	@echo "ArgoCD Username: $$($(EXEC) output -raw argocd_username)"
	@echo "ArgoCD Password: $$($(EXEC) output -raw argocd_password)"
	@echo ""
	@echo "Applying app-of-apps manifest..."
	@aws eks --region $$($(EXEC) output -raw region) update-kubeconfig --name $$($(EXEC) output -raw cluster_name) || true
	@sleep 10
	@kubectl apply -f https://raw.githubusercontent.com/Lforlinux/k8s-platform-toolkit/main/argocd/app-of-apps.yaml || echo "Note: Ensure kubectl is configured and ArgoCD is ready"

.PHONY: cleanup-argocd
cleanup-argocd:
	@echo "Cleaning up ArgoCD applications..."
	@kubectl delete application k8s-platform-toolkit -n argocd --ignore-not-found=true || true
	@kubectl delete -f https://raw.githubusercontent.com/Lforlinux/k8s-platform-toolkit/main/argocd/app-of-apps.yaml --ignore-not-found=true || true
	@echo "ArgoCD applications cleaned up"

.PHONY: destroy
destroy: cleanup-argocd
	@$(EXEC) destroy -no-color

.PHONY: deploy
deploy:
	@$(EXEC) init -no-color
	@$(EXEC) apply -no-color
	@echo ""
	@echo "To access the Kubernetes cluster, run:"
	@echo "aws eks --region $$($(EXEC) output -raw region) update-kubeconfig --name $$($(EXEC) output -raw cluster_name)"
	@echo ""
	@echo "=== ArgoCD Access Information ==="
	@echo "ArgoCD Server URL: $$($(EXEC) output -raw argocd_server_url)"
	@echo "ArgoCD Username: $$($(EXEC) output -raw argocd_username)"
	@echo "ArgoCD Password: $$($(EXEC) output -raw argocd_password)"
	@echo ""
	@echo "Applying app-of-apps manifest..."
	@aws eks --region $$($(EXEC) output -raw region) update-kubeconfig --name $$($(EXEC) output -raw cluster_name) || true
	@sleep 10
	@kubectl apply -f https://raw.githubusercontent.com/Lforlinux/k8s-platform-toolkit/main/argocd/app-of-apps.yaml || echo "Note: Ensure kubectl is configured and ArgoCD is ready"