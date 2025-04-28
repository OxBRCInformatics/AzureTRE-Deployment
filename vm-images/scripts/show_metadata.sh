#!/bin/bash
set -e

GREEN="\033[0;32m"
BLUE="\033[0;34m"
NO_COLOUR="\033[0m"

echo -e "\nTemplate Metadata:\n"
echo -e ""

echo -e "  ${GREEN}CVM_IMAGE_DEFINITION     ${CVM_IMAGE_DEFINITION}"
echo -e "  ${GREEN}CVM_TEMPLATE_NAME        ${CVM_TEMPLATE_NAME}"
echo -e "  ${GREEN}CVM_OFFER                ${CVM_OFFER}"
echo -e "  ${GREEN}CVM_PUBLISHER_NAME       ${CVM_PUBLISHER_NAME}"
echo -e "  ${GREEN}CVM_SKU                  ${CVM_SKU}"
echo -e "  ${GREEN}CVM_OSTYPE               ${CVM_OSTYPE}"
echo -e "  ${GREEN}CVM_IMAGE_TAGS           ${CVM_IMAGE_TAGS}"
echo -e "  ${GREEN}CVM_IMAGE_DESCRIPTION    ${CVM_IMAGE_DESCRIPTION}"
