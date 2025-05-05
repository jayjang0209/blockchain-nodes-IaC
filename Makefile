# Makefile for Terraform and Ansible on GCP

# Configuration variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Phony targets
.PHONY: help setup init fmt validate plan apply destroy ssh ansible verify all clean output build

# Default target
help:
	@echo "Available commands:"
	@echo "  make init      - Initialize Terraform"
	@echo "  make validate  - Validate Terraform configuration"
	@echo "  make fmt       - Format Terraform code"
	@echo "  make plan      - Create Terraform plan"
	@echo "  make apply     - Apply Terraform plan (deploy infrastructure)"
	@echo "  make destroy   - Destroy all resources"
	@echo "  make ssh       - SSH into the VM instance"
	@echo "  make ansible   - Run Ansible playbook manually"
	@echo "  make verify    - Verify Ansible ran correctly on VM"
	@echo "  make setup     - Initial setup (generate SSH keys, create tfvars from template)"
	@echo "  make all       - Full deployment (init, plan, apply)"

# Setup everything needed for deployment
setup:
	@echo "Setting up project dependencies..."
	@if [ ! -f ~/.ssh/id_rsa ]; then \
		echo "Generating new SSH key..."; \
		ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""; \
	fi
	@if [ ! -f terraform.tfvars ] && [ -f terraform.tfvars.template ]; then \
		echo "Creating terraform.tfvars from template..."; \
		cp terraform.tfvars.template terraform.tfvars; \
		echo "Please edit terraform.tfvars with your settings"; \
	fi
	@echo "Setup complete!"

# Initialize Terraform
init:
	cd terraform && terraform init

# Format Terraform code
fmt:
	cd terraform && terraform fmt

# Validate Terraform configuration
validate:
	cd terraform && terraform validate

# Create Terraform plan
plan:
	cd terraform && terraform plan -out=tfplan

# Apply Terraform plan
apply:
	@if [ ! -f terraform/tfplan ]; then \
		cd terraform && terraform apply; \
	else \
		cd terraform && terraform apply tfplan; \
		rm -f terraform/tfplan; \
	fi

# Destroy all resources
destroy:
	cd terraform && terraform destroy

# SSH into the instance
ssh:
	@SSH_CMD=$$(cd terraform && terraform output -raw ssh_command) && \
	echo "Connecting with: $$SSH_CMD" && \
	eval "$$SSH_CMD"

# Run Ansible playbook
ansible:
	@ANSIBLE_CMD=$$(cd terraform && terraform output -raw ansible_command) && \
	echo "Running: $$ANSIBLE_CMD" && \
	eval "$$ANSIBLE_CMD"

# Verify Ansible ran correctly
verify:
	@SSH_CMD=$$(cd terraform && terraform output -raw ssh_command) && \
	echo "Verifying Ansible configuration..." && \
	eval "$$SSH_CMD 'cat /tmp/ansible_test.txt && which git vim curl htop'"

# Full deployment workflow
all: init plan apply

# Clean up temporary files
clean:
	rm -f terraform/tfplan
	rm -f terraform/*.tfstate.backup
	rm -f terraform/*.tfplan
	rm -f terraform/crash.log
	rm -f terraform/*.retry

# Show output variables
output:
	cd terraform && terraform output

# Build infrastructure and run Ansible playbook
build:
	bin/build.sh
