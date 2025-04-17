#!/bin/bash
set -e

# Define colours for output
GREEN="\033[0;32m"
NO_COLOUR="\033[0m"

# # delete core resource group
echo -e "➡ ${GREEN}Deleting Resource Group ${CVM_RESOURCE_GROUP} for Core Custom VM Resources${NO_COLOUR}"
az group delete --resource-group "${CVM_RESOURCE_GROUP}" --subscription "${SUBSCRIPTION_ID}"
