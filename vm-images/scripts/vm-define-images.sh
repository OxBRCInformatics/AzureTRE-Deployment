#!/bin/bash
# shellcheck disable=SC1091

set -e

# Define colours for output
GREEN="\033[0;32m"
NO_COLOUR="\033[0m"

ENV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$ENV_DIR/load_metadata.sh" "$1"

# print metadata to console
echo -e "  Template Metadata:"
echo ""
echo -e "  ${GREEN}CVM_IMAGE_DEFINITION${NO_COLOUR}: ${CVM_IMAGE_DEFINITION}"
echo -e "  ${GREEN}CVM_TEMPLATE_NAME${NO_COLOUR}:    ${CVM_TEMPLATE_NAME}"
echo -e "  ${GREEN}CVM_OFFER${NO_COLOUR}:            ${CVM_OFFER}"
echo -e "  ${GREEN}CVM_PUBLISHER_NAME${NO_COLOUR}:   ${CVM_PUBLISHER_NAME}"
echo -e "  ${GREEN}CVM_SKU${NO_COLOUR}:              ${CVM_SKU}"
echo -e "  ${GREEN}CVM_OSTYPE${NO_COLOUR}:           ${CVM_OSTYPE}"
echo ""

# Create image definition
az sig image-definition create  --resource-group "${CVM_RESOURCE_GROUP}" \
                                --gallery-name "${CVM_GALLERY_NAME}" \
                                --gallery-image-definition "${CVM_IMAGE_DEFINITION}" \
                                --publisher "${CVM_PUBLISHER_NAME}" \
                                --offer "${CVM_OFFER}" \
                                --sku "${CVM_SKU}" \
                                --os-type "${CVM_OSTYPE}"
