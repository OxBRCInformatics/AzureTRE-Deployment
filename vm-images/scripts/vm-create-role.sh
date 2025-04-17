#!/bin/bash
set -e

# Define colours for output
GREEN="\033[0;32m"
NO_COLOUR="\033[0m"

# Get the directory that this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# load and populate template
IMAGE_BUILDER_ROLE_TEMPLATE=$(cat "$DIR"/../roles/image_builder_role_definition_template.json)
IMAGE_BUILDER_ROLE_TEMPLATE=${IMAGE_BUILDER_ROLE_TEMPLATE//<roleName>/${CVM_IMAGE_BUILDER_ROLE_NAME}}
IMAGE_BUILDER_ROLE_TEMPLATE=${IMAGE_BUILDER_ROLE_TEMPLATE//<subscriptionID>/${SUBSCRIPTION_ID}}

echo "${IMAGE_BUILDER_ROLE_TEMPLATE}"

# Create custom role definition and assign it to the Image Builder
echo -e "➡ ${GREEN}Create Role Definition.${NO_COLOUR}"
az role definition create --role-definition <(echo "$IMAGE_BUILDER_ROLE_TEMPLATE")
