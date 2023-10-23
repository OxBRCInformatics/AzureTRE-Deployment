#!/bin/bash
set -e
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NO_COLOUR="\033[0m"

echo -e "\nCustom VM Environment Settings:\n"
echo -e ""


# Subscription
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

echo -e "${BLUE}Subscription${NO_COLOUR}\n"
echo -e "  ${GREEN}SUBSCRIPTION_ID${NO_COLOUR}:             ${SUBSCRIPTION_ID}"
echo -e ""

# Environment
echo -e "${BLUE}Environment${NO_COLOUR}\n"
echo -e "  ${GREEN}CVM_ENVIRONMENT_SUFFIX${NO_COLOUR}:      ${CVM_ENVIRONMENT_SUFFIX}"
echo -e ""

# Resource group and location of Azure Compute Gallery
echo -e "${BLUE}Resource group and location of Azure Compute Gallery${NO_COLOUR}\n"
echo -e "  ${GREEN}CVM_RESOURCE_GROUP${NO_COLOUR}:          ${CVM_RESOURCE_GROUP}"
echo -e "  ${GREEN}CVM_LOCATION${NO_COLOUR}:                ${CVM_LOCATION}"
echo -e "  ${GREEN}CVM_GALLERY_NAME${NO_COLOUR}:            ${CVM_GALLERY_NAME}"
echo -e ""

# Storage Account for VM Image Templates
echo -e "${BLUE}Storage Account for VM Image Templates${NO_COLOUR}\n"
echo -e "  ${GREEN}CVM_STORAGE_ACCOUNT${NO_COLOUR}:         ${CVM_STORAGE_ACCOUNT}"
echo -e "  ${GREEN}CVM_CONTAINER_NAME${NO_COLOUR}:          ${CVM_CONTAINER_NAME}"
echo -e ""

# Managed Identity
echo -e "${BLUE}Managed Identity${NO_COLOUR}\n"
echo -e "  ${GREEN}CVM_IMAGE_BUILDER_ID_NAME${NO_COLOUR}:   ${CVM_IMAGE_BUILDER_ID_NAME}"
echo -e ""

# Custom Role Definition
echo -e "${BLUE}Custom Role Definition${NO_COLOUR}\n"
echo -e "  ${GREEN}CVM_IMAGE_BUILDER_ROLE_NAME${NO_COLOUR}: ${CVM_IMAGE_BUILDER_ROLE_NAME}"
echo -e ""
