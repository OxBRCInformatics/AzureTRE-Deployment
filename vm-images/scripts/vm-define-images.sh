#!/bin/bash
set -e

# Define colours for output
GREEN="\033[0;32m"
NO_COLOUR="\033[0m"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$SCRIPT_DIR/load_metadata_from_json.sh" "$1"

# print metadata to console
echo -e "  Template Metadata:"
echo ""
echo -e "  ${GREEN}CVM_IMAGE_DEFINITION     ${CVM_IMAGE_DEFINITION}"
echo -e "  ${GREEN}CVM_TEMPLATE_NAME        ${CVM_TEMPLATE_NAME}"
echo -e "  ${GREEN}CVM_OFFER                ${CVM_OFFER}"
echo -e "  ${GREEN}CVM_PUBLISHER_NAME       ${CVM_PUBLISHER_NAME}"
echo -e "  ${GREEN}CVM_SKU                  ${CVM_SKU}"
echo -e "  ${GREEN}CVM_OSTYPE               ${CVM_OSTYPE}"
echo -e "  ${GREEN}CVM_IMAGE_TAGS           ${CVM_IMAGE_TAGS}"
echo -e "  ${GREEN}CVM_IMAGE_DESCRIPTION    ${CVM_IMAGE_DESCRIPTION}"
echo ""

# Create image definition
az sig image-definition create  --resource-group "${CVM_RESOURCE_GROUP}" \
                                --gallery-name "${CVM_GALLERY_NAME}" \
                                --gallery-image-definition "${CVM_IMAGE_DEFINITION}" \
                                --publisher "${CVM_PUBLISHER_NAME}" \
                                --offer "${CVM_OFFER}" \
                                --sku "${CVM_SKU}" \
                                --os-type "${CVM_OSTYPE}" \
                                --location "${CVM_LOCATION}" \
                                --tags $CVM_IMAGE_TAGS \
                                --description "${CVM_IMAGE_DESCRIPTION}" \
                                --hyper-v-generation "${CVM_IMAGE_HYPERV_VERSION}"
