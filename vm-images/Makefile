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

vm-destroy-core: ## destroy all custom VMs infrastructure
	. ./scripts/load_env.sh && ./scripts/vm-destroy-core.sh

vm-show-metadata: ## load template metadata and print to screen (requires first argument of TEMPLATE_PATH=<path_to_template>)
	. ./scripts/load_env.sh \
	&& . ./scripts/load_metadata_from_json.sh $(TEMPLATE_PATH)/image_metadata.json \
	&& . ./scripts/show_metadata.sh

vm-define-image: ## create the specified image definition (requires first argument of TEMPLATE_PATH=<path_to_template>)
	./scripts/check_template.sh $(TEMPLATE_PATH) \
	&& . ./scripts/load_env.sh \
	&& ./scripts/vm-define-images.sh $(TEMPLATE_PATH)/image_metadata.json

vm-deploy-template-artifacts: ## copy VM templates and supporting scripts to storage in Azure (run when templates are updated)
	. ./scripts/load_env.sh && ./scripts/vm-deploy-template-artifacts.sh ./templates

vm-create-image-template: ## create the specified image template in Azure (requires first argument of TEMPLATE_PATH=<path_to_template>)
	./scripts/check_template.sh $(TEMPLATE_PATH) \
	&& . ./scripts/load_env.sh \
	&& ./scripts/vm-create-template.sh --template-url $(TEMPLATE_PATH)/image_template.json --metadata-url $(TEMPLATE_PATH)/image_metadata.json

vm-build-image: ## builds specified VM image (requires first argument of TEMPLATE_PATH=<path_to_template>)
	./scripts/check_template.sh $(TEMPLATE_PATH) \
	&& . ./scripts/load_env.sh \
	&& ./scripts/vm-build-image.sh --metadata-url $(TEMPLATE_PATH)/image_metadata.json

vm-delete-image-template: ## delete the specified image template in Azure (requires first argument of TEMPLATE_PATH=<path_to_template>)
	./scripts/check_template.sh $(TEMPLATE_PATH) \
	&& . ./scripts/load_env.sh \
	&& ./scripts/vm-delete-template.sh --metadata-url $(TEMPLATE_PATH)/image_metadata.json

vm-update-image: ## update the specified image template in Azure (requires first argument of TEMPLATE_PATH=<path_to_template>)
	./scripts/check_template.sh $(TEMPLATE_PATH) \
	&& . ./scripts/load_env.sh \
	&& ./scripts/vm-delete-template.sh --metadata-url $(TEMPLATE_PATH)/image_metadata.json \
	&& ./scripts/vm-deploy-template-artifacts.sh ./templates \
	&& ./scripts/vm-create-template.sh --template-url $(TEMPLATE_PATH)/image_template.json --metadata-url $(TEMPLATE_PATH)/image_metadata.json \
	&& ./scripts/vm-build-image.sh --metadata-url $(TEMPLATE_PATH)/image_metadata.json

# vm-test-linux-vm-all: ## create linux vm test instance in Azure
# 	. ./scripts/load_env.sh && ./scripts/vm-remove-test-vm.sh --metadata-url ./templates/linux/image_metadata.txt
# 	. ./scripts/load_env.sh && ./scripts/vm-remove-template.sh --metadata-url ./templates/linux/image_metadata.txt
# 	. ./scripts/load_env.sh && ./scripts/vm-deploy-template-artifacts.sh ./templates
# 	. ./scripts/load_env.sh && ./scripts/vm-create-template.sh --template-url ./templates/linux/image_template.json --metadata-url ./templates/linux/image_metadata.txt
# 	. ./scripts/load_env.sh && ./scripts/vm-build-image.sh --metadata-url ./templates/linux/image_metadata.txt
# 	. ./scripts/load_env.sh && ./scripts/vm-create-test-vm.sh --metadata-url ./templates/linux/image_metadata.txt
# 	. ./scripts/load_env.sh && ./scripts/vm-open-port.sh --metadata-url ./templates/linux/image_metadata.txt --port 3389

# vm-test-windows-vm-all: ## create windows vm test instance in Azure
# 	. ./scripts/load_env.sh && ./scripts/vm-remove-test-vm.sh --metadata-url ./templates/windows/image_metadata.txt
# 	. ./scripts/load_env.sh && ./scripts/vm-remove-template.sh --metadata-url ./templates/windows/image_metadata.txt
# 	. ./scripts/load_env.sh && ./scripts/vm-deploy-template-artifacts.sh ./templates
# 	. ./scripts/load_env.sh && ./scripts/vm-create-template.sh --template-url ./templates/windows/image_template.json --metadata-url ./templates/windows/image_metadata.txt
# 	. ./scripts/load_env.sh && ./scripts/vm-build-image.sh --metadata-url ./templates/windows/image_metadata.txt
# 	. ./scripts/load_env.sh && ./scripts/vm-create-test-vm.sh --metadata-url ./templates/windows/image_metadata.txt


