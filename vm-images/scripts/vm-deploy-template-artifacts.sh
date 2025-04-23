#!/bin/bash
set -e

# Define colours for output
RED="\033[0;31m"
GREEN="\033[0;32m"
NO_COLOUR="\033[0m"

echo -e "➡ ${GREEN}Creating SAS token${NO_COLOUR}"

EXPIRE=$(date -u -d "3 months" '+%Y-%m-%dT%H:%M:%SZ')
START=$(date -u -d "-1 day" '+%Y-%m-%dT%H:%M:%SZ')

STORAGE_ACCOUNT_KEY=$(az storage account keys list \
  --resource-group "${CVM_RESOURCE_GROUP}" \
  --account-name "${CVM_STORAGE_ACCOUNT}" \
  --query "[0].value" \
  --output tsv)

AZURE_STORAGE_SAS_TOKEN=$(az storage account generate-sas \
  --account-name "${CVM_STORAGE_ACCOUNT}" \
  --account-key "${STORAGE_ACCOUNT_KEY}" \
  --start "${START}" \
  --expiry "${EXPIRE}" \
  --https-only \
  --resource-types sco \
  --services b \
  --permissions dlrw -o tsv | sed 's/%3A/:/g;s/\"//g')

# use AzCopy to copy the folder (passed as parameter to script) to the storage account's container
INCLUDE_PATTERN="*.json;*.sh;*.ps1;*.pkla"
azcopy cp "${1}/*" "https://$CVM_STORAGE_ACCOUNT.blob.core.windows.net/${CVM_CONTAINER_NAME}/?$AZURE_STORAGE_SAS_TOKEN" --recursive --include-pattern "${INCLUDE_PATTERN}"
