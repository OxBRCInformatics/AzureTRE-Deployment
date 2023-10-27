#!/bin/bash
set -e

# Define colours for output
GREEN="\033[0;32m"
NO_COLOUR="\033[0m"

# Create custom role definition and assign it to the Image Builder
echo -e "➡ ${GREEN}View Role Definition.${NO_COLOUR}"
az role definition list --name "${CVM_IMAGE_BUILDER_ROLE_NAME}"
