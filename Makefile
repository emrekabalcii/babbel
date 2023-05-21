.SHELL := /usr/bin/bash
.PHONY: apply destroy plan
ENV_REGION="$(ENV)-$(REGION)"
VARS="env/$(ENV)-$(REGION).tfvars"

ifeq (, $(shell which aws))
	$(error "No AWS in $(PATH), go to https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html, pick your OS, and follow the instructions")
endif
ifeq (, $(shell which terraform))
	$(error "No terraform in $(PATH), get it from https://www.terraform.io/downloads.html")
endif

default:
	@echo "Creates a Terraform system from a template."
	@echo "The following commands are available:"
	@echo " - plan               : runs terraform plan for an environment"
	@echo " - apply              : runs terraform apply for an environment"
	@echo " - destroy            : will delete the entire project's infrastructure"

plan:
	$(call check_defined, ENV, Please set the ENV to plan for. Values should be dev, test, uat or prod)
	@terraform fmt

	@echo "Pulling the required modules..."
	@terraform get

	@echo 'Switching to the [$(ENV)] environment ...'
	@terraform workspace select $(ENV) 

	@terraform plan -var-file="$(VARS)" -out $(ENV_REGION).plan

apply:
	$(call check_defined, ENV, Please set the ENV to apply. Values should be dev, test, uat or prod)

	@echo 'Switching to the [$(ENV)] environment ...'
	@terraform workspace select $(ENV)

	@echo "Will be applying the following to [$(ENV)] environment:"
	@terraform show -no-color $(ENV_REGION).plan

	@terraform apply $(ENV_REGION).plan
	@rm $(ENV_REGION).plan

destroy:
	@echo "Switching to the [$(ENV)] environment ..."
	@terraform workspace select $(ENV)

	@echo "## 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥 ##"
	@echo "Are you really sure you want to completely destroy [$(ENV)] environment ?"
	@echo "## 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥 ##"
	@read -p "Press enter to continue"
	@terraform destroy -var-file="$(VARS)"

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))