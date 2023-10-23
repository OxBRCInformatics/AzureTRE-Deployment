SHELL := /bin/bash

.PHONY: help
help: ## Show this help
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%s\033[0m|%s\n", $$1, $$2}' \
        | column -t -s '|'
	@echo

vm-show-env: ## show the environment variables associated with custom VM images
	. ./scripts/load_env.sh && ./scripts/vm-show-env.sh

vm-create-role: ## creates the custom role defintion (run once per subscription)
	. ./scripts/load_env.sh && ./scripts/vm-create-role.sh

vm-view-role: ## views the custom role defintion
	. ./scripts/load_env.sh && ./scripts/vm-view-role.sh

vm-deploy-core: ## deploy core infra required for custom VMs (run once per environment)
	. ./scripts/load_env.sh && ./scripts/vm-deploy-core.sh

vm-define-linux-image: ## create linux image definitions within Azure Compute Gallery
	. ./scripts/load_env.sh && ./scripts/vm-define-images.sh ./templates/linux/image_metadata.txt

vm-define-basic-linux-image: ## create basic linux image definitions within Azure Compute Gallery
	. ./scripts/load_env.sh && ./scripts/vm-define-images.sh ./templates/basic-linux/image_metadata.txt

vm-define-windows-image: ## create windows image definitions within Azure Compute Gallery
	. ./scripts/load_env.sh && ./scripts/vm-define-images.sh ./templates/windows/image_metadata.txt

vm-deploy-template-artifacts: ## copy VM templates and supporting scripts to storage in Azure (run when templates are updated)
	. ./scripts/load_env.sh && ./scripts/vm-deploy-template-artifacts.sh ./templates

vm-create-linux-template: ## create the linux template in Azure (run once per template)
	. ./scripts/load_env.sh && ./scripts/vm-create-template.sh --template-url ./templates/linux/image_template.json --metadata-url ./templates/linux/image_metadata.txt

vm-create-basic-linux-template: ## create the basic linux template in Azure (run once per template)
	. ./scripts/load_env.sh && ./scripts/vm-create-template.sh --template-url ./templates/basic-linux/image_template.json --metadata-url ./templates/basic-linux/image_metadata.txt

vm-create-windows-template: ## createthe windows template (run once per template)
	. ./scripts/load_env.sh && ./scripts/vm-create-template.sh --template-url ./templates/windows/image_template.json --metadata-url ./templates/windows/image_metadata.txt

vm-build-linux-image: ## builds the custom Linux VM image
	. ./scripts/load_env.sh && ./scripts/vm-build-image.sh --metadata-url ./templates/linux/image_metadata.txt

vm-build-basic-linux-image: ## builds the basic Linux VM image
	. ./scripts/load_env.sh && ./scripts/vm-build-image.sh --metadata-url ./templates/basic-linux/image_metadata.txt

vm-build-windows-image: ## builds the custom Windows VM image
	. ./scripts/load_env.sh && ./scripts/vm-build-image.sh --metadata-url ./templates/windows/image_metadata.txt

vm-remove-linux-template: ## remove the linux template in Azure
	. ./scripts/load_env.sh && ./scripts/vm-remove-template.sh --metadata-url ./templates/linux/image_metadata.txt

vm-remove-basic-linux-template: ## remove the basic linux template in Azure
	. ./scripts/load_env.sh && ./scripts/vm-remove-template.sh --metadata-url ./templates/basic-linux/image_metadata.txt

vm-remove-windows-template: ## remove the windows template in Azure
	. ./scripts/load_env.sh && ./scripts/vm-remove-template.sh --metadata-url ./templates/windows/image_metadata.txt

vm-rebuild-windows-template: ## Rebuild windows vm template
	. ./scripts/load_env.sh && ./scripts/vm-deploy-template-artifacts.sh ./templates
	. ./scripts/load_env.sh && ./scripts/vm-remove-template.sh --metadata-url ./templates/windows/image_metadata.txt
	. ./scripts/load_env.sh && ./scripts/vm-create-template.sh --template-url ./templates/windows/image_template.json --metadata-url ./templates/windows/image_metadata.txt
	. ./scripts/load_env.sh && ./scripts/vm-build-image.sh --metadata-url ./templates/windows/image_metadata.txt

vm-rebuild-linux-template: ## Rebuild linux vm template
	. ./scripts/load_env.sh && ./scripts/vm-deploy-template-artifacts.sh ./templates
	. ./scripts/load_env.sh && ./scripts/vm-remove-template.sh --metadata-url ./templates/linux/image_metadata.txt
	. ./scripts/load_env.sh && ./scripts/vm-create-template.sh --template-url ./templates/linux/image_template.json --metadata-url ./templates/linux/image_metadata.txt
	. ./scripts/load_env.sh && ./scripts/vm-build-image.sh --metadata-url ./templates/linux/image_metadata.txt

vm-create-linux-test-vm: ## create test linux vm in Azure
	. ./scripts/load_env.sh && ./scripts/vm-create-test-vm.sh --metadata-url ./templates/linux/image_metadata.txt

vm-create-windows-test-vm: ## create test windows vm in Azure
	. ./scripts/load_env.sh && ./scripts/vm-create-test-vm.sh --metadata-url ./templates/windows/image_metadata.txt

vm-remove-linux-test-vm: ## remove test linux vm from Azure
	. ./scripts/load_env.sh && ./scripts/vm-remove-test-vm.sh --metadata-url ./templates/linux/image_metadata.txt

vm-remove-windows-test-vm: ## remove test windows vm from Azure
	. ./scripts/load_env.sh && ./scripts/vm-remove-test-vm.sh --metadata-url ./templates/windows/image_metadata.txt

vm-test-linux-vm-all: ## create linux vm test instance in Azure
	. ./scripts/load_env.sh && ./scripts/vm-remove-test-vm.sh --metadata-url ./templates/linux/image_metadata.txt
	. ./scripts/load_env.sh && ./scripts/vm-remove-template.sh --metadata-url ./templates/linux/image_metadata.txt
	. ./scripts/load_env.sh && ./scripts/vm-deploy-template-artifacts.sh ./templates
	. ./scripts/load_env.sh && ./scripts/vm-create-template.sh --template-url ./templates/linux/image_template.json --metadata-url ./templates/linux/image_metadata.txt
	. ./scripts/load_env.sh && ./scripts/vm-build-image.sh --metadata-url ./templates/linux/image_metadata.txt
	. ./scripts/load_env.sh && ./scripts/vm-create-test-vm.sh --metadata-url ./templates/linux/image_metadata.txt
	. ./scripts/load_env.sh && ./scripts/vm-open-port.sh --metadata-url ./templates/linux/image_metadata.txt --port 3389

vm-test-windows-vm-all: ## create windows vm test instance in Azure
	. ./scripts/load_env.sh && ./scripts/vm-remove-test-vm.sh --metadata-url ./templates/windows/image_metadata.txt
	. ./scripts/load_env.sh && ./scripts/vm-remove-template.sh --metadata-url ./templates/windows/image_metadata.txt
	. ./scripts/load_env.sh && ./scripts/vm-deploy-template-artifacts.sh ./templates
	. ./scripts/load_env.sh && ./scripts/vm-create-template.sh --template-url ./templates/windows/image_template.json --metadata-url ./templates/windows/image_metadata.txt
	. ./scripts/load_env.sh && ./scripts/vm-build-image.sh --metadata-url ./templates/windows/image_metadata.txt
	. ./scripts/load_env.sh && ./scripts/vm-create-test-vm.sh --metadata-url ./templates/windows/image_metadata.txt


