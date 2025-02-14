CURRENT_DIR:=$(shell pwd)
GENERATED_DIR=$(CURRENT_DIR)/generated
INGRESS_CERTIFICATES_DIR=$(GENERATED_DIR)/certificates/ingress
PARAMETERS_FILE?=parameters.tfvars
EXTRA_PARAMETERS_FILE?=../../../extra.tfvars.json
VERSIONS_FILE?=../../../versions.tfvars.json
STATE_FILE=armonik-terraform.tfstate
OUTPUT_FILE=$(GENERATED_DIR)/armonik-output.json
MODULES_DIR=$(GENERATED_DIR)/infra-modules
MODULES_SOURCE=$(shell cat $(VERSIONS_FILE) | jq -r '.armonik_images.infra[0]')
MODULES_VERSION=$(shell cat $(VERSIONS_FILE) | jq -r '.armonik_versions.infra')

# Randomly generated string that is preserved across calls
RANDOM_PREFIX != [ -e $(GENERATED_DIR)/.prefix ] || { mkdir -p $(GENERATED_DIR) && tr -dc a-z0-9 </dev/urandom | head -c 5 > $(GENERATED_DIR)/.prefix ; } && cat $(GENERATED_DIR)/.prefix

export TF_DATA_DIR?=$(GENERATED_DIR)
export TF_PLUGIN_CACHE_DIR?=$(GENERATED_DIR)/terraform-plugins
export PROJECT_ID?=$(shell gcloud config get-value project)
export REGION?=europe-west1
export NAMESPACE?=armonik
export PREFIX?=armonik-$(RANDOM_PREFIX)
export TFSTATE_BUCKET_NAME?=$(PREFIX)-tfstate

export TF_VAR_region?=$(REGION)
export TF_VAR_namespace?=$(NAMESPACE)
export TF_VAR_prefix?=$(PREFIX)
export TF_VAR_project?=$(PROJECT_ID)
SHELL:=/bin/bash

.PHONY: apply destroy

all: get-modules init apply output kubeconfig
deploy: get-modules init apply output kubeconfig
destroy: init delete

env:
	@set

bootstrap-deploy:
	@if [[ $${TFSTATE_BUCKET_NAME} =~ ^[a-z0-9]([-a-z0-9_]*[a-z0-9])?$$ && $${#TFSTATE_BUCKET_NAME} -ge 3 && $${#TFSTATE_BUCKET_NAME} -le 63 && ! $${TFSTATE_BUCKET_NAME} =~ -- && ! $${TFSTATE_BUCKET_NAME} =~ ^- && ! $${TFSTATE_BUCKET_NAME} =~ -$$ ]]; then \
		echo "TFSTATE bucket Name : ${TFSTATE_BUCKET_NAME} is valid"; \
	else \
		echo -e "\e[91mError : Invalid TFSTATE bucket Name : '${TFSTATE_BUCKET_NAME}' ref: https://cloud.google.com/storage/docs/buckets#naming \e[0m"; \
		exit 1; \
	fi; \

	@if gsutil ls -b gs://${TFSTATE_BUCKET_NAME} > /dev/null 2>&1; then \
		echo "The bucket : ${TFSTATE_BUCKET_NAME} already exists."; \
	else \
		if gsutil mb -l ${TF_VAR_region} gs://${TFSTATE_BUCKET_NAME}; then \
			echo "The bucket ${TFSTATE_BUCKET_NAME} in Region : '${TF_VAR_region}' has been successfuly created."; \
		else \
			echo -e "\e[91mError : TFSTATE bucket Name : '${TFSTATE_BUCKET_NAME}' has NOT been created. \e[0m"; \
			gsutil ls -b gs://${TFSTATE_BUCKET_NAME}; \
			exit 1; \
		fi; \
	fi

bootstrap-destroy:
	@if gsutil ls -b gs://${TFSTATE_BUCKET_NAME} > /dev/null 2>&1; then \
		if gsutil rm -r gs://${TFSTATE_BUCKET_NAME}; then \
		echo "The bucket : ${TFSTATE_BUCKET_NAME} has been deleted."; \
		else \
			echo -e "\e[91mError : The bucket : ${TFSTATE_BUCKET_NAME} has NOT been deleted. \e[0m"; \
			gsutil ls -b gs://${TFSTATE_BUCKET_NAME}; \
			exit 1; \
		fi \
	else \
		echo "The bucket ${TFSTATE_BUCKET_NAME} is not in your bucket list."; \
	fi 


init:
	mkdir -p $(TF_PLUGIN_CACHE_DIR)
	mkdir -p $(GENERATED_DIR)
	terraform init -upgrade -reconfigure -backend-config 'bucket=$(TFSTATE_BUCKET_NAME)'

plan:
	terraform plan -var-file=$(VERSIONS_FILE) -var-file=$(PARAMETERS_FILE) -var-file=$(EXTRA_PARAMETERS_FILE) -out=/dev/null

apply:
	terraform apply -var-file=$(VERSIONS_FILE) -var-file=$(PARAMETERS_FILE) -var-file=$(EXTRA_PARAMETERS_FILE) -auto-approve

refresh:
	terraform refresh -var-file=$(VERSIONS_FILE) -var-file=$(PARAMETERS_FILE) -var-file=$(EXTRA_PARAMETERS_FILE)

delete:
	terraform destroy -var-file=$(VERSIONS_FILE) -var-file=$(PARAMETERS_FILE) -var-file=$(EXTRA_PARAMETERS_FILE) -auto-approve

hibernate:
	terraform destroy -var-file=$(VERSIONS_FILE) -var-file=$(PARAMETERS_FILE) -var-file=$(EXTRA_PARAMETERS_FILE) -auto-approve -target=module.vpc -target=module.gke -target=module.gcs_os -target=module.memorystore

console:
	terraform console -var-file=$(VERSIONS_FILE) -var-file=$(PARAMETERS_FILE) -var-file=$(EXTRA_PARAMETERS_FILE)

output:
	@terraform output -state=$(STATE_FILE) -json | jq 'map_values(.value)' > $(OUTPUT_FILE)
	@echo "\nOUTPUT FILE: $(OUTPUT_FILE)"

kubeconfig:
	@echo "Execute the following commands:"
	@echo "------------------------------"
	@echo "export KUBECONFIG=$(shell cat $(GENERATED_DIR)/armonik-output.json | jq -r '.gke.kubeconfig_file')"

get-modules:
	@if [ -d $(MODULES_DIR) ]; then\
		git -C $(MODULES_DIR) fetch --depth 1 origin $(MODULES_VERSION);\
		git -C $(MODULES_DIR) -c advice.detachedHead=false checkout $(MODULES_VERSION);\
    else \
      	git -c advice.detachedHead=false clone --branch $(MODULES_VERSION) --depth 1 $(MODULES_SOURCE) $(MODULES_DIR);\
    fi

clean:
	rm -rf $(TF_DATA_DIR) .terraform.lock.hcl .terraform

docs:
	terraform-docs markdown table --output-file parameters.md --output-mode inject $(CURRENT_DIR)
