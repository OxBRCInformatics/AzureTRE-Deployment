#!/bin/bash
set -e

# Define colours for output
GREEN="\033[0;32m"
NO_COLOUR="\033[0m"

# enable image builder
echo -e "➡ ${GREEN}Enabling Image Builder${NO_COLOUR}"
az provider register --namespace Microsoft.VirtualMachineImages

# create core resource group
echo -e "➡ ${GREEN}Creating Resource Group for Core Custom VM Resources${NO_COLOUR}"
az group create --resource-group "${CVM_RESOURCE_GROUP}" \
                --location "${CVM_LOCATION}" \
                --tags $CVM_TAGS

# create managed identity
echo -e "➡ ${GREEN}Creating Managed Identity${NO_COLOUR}"
az identity create --resource-group "${CVM_RESOURCE_GROUP}" \
                   --name "${CVM_IMAGE_BUILDER_ID_NAME}" \
                   --tags $CVM_TAGS

# create Azure Compute Gallery
echo -e "➡ ${GREEN}Creating Azure Compute Gallery${NO_COLOUR}"
az sig create --resource-group "${CVM_RESOURCE_GROUP}" \
              --gallery-name "${CVM_GALLERY_NAME}" \
              --tags $CVM_TAGS

# create storage account for image templates
echo -e "➡ ${GREEN}Creating Storage Account for Custom VM Templates and Scripts${NO_COLOUR}"
az storage account create --name "${CVM_STORAGE_ACCOUNT}" \
                          --resource-group "${CVM_RESOURCE_GROUP}" \
                          --location "${CVM_LOCATION}" \
                          --sku Standard_LRS \
                          --tags $CVM_TAGS

# create container within storage account
echo -e "➡ ${GREEN}Creating Container within Storage Account${NO_COLOUR}"
az storage container create --name "${CVM_CONTAINER_NAME}" \
                            --account-name "${CVM_STORAGE_ACCOUNT}"


echo -e "➡ ${GREEN}Granting Permissions to Managed Identity${NO_COLOUR}"
IMAGE_BUILDER_ID=$(az identity show --resource-group "${CVM_RESOURCE_GROUP}" \
                                    --name "${CVM_IMAGE_BUILDER_ID_NAME}" \
                                    --query clientId \
                                    -o tsv)

# Assign roles to image builder identity
echo -e "➡ ${GREEN}Assign Role '${CVM_IMAGE_BUILDER_ROLE_NAME}'${NO_COLOUR}"
az role assignment create --assignee "${IMAGE_BUILDER_ID}" \
                          --role "${CVM_IMAGE_BUILDER_ROLE_NAME}" \
                          --scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${CVM_RESOURCE_GROUP}"

echo -e "➡ ${GREEN}Assign Role 'Storage Blob Data Reader Role'${NO_COLOUR}"
az role assignment create --assignee "${IMAGE_BUILDER_ID}" \
                          --role "Storage Blob Data Reader" \
                          --scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${CVM_RESOURCE_GROUP}/providers/Microsoft.Storage/storageAccounts/${CVM_STORAGE_ACCOUNT}/blobServices/default/containers/${CVM_CONTAINER_NAME}"
