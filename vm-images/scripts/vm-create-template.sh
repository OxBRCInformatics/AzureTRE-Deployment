#!/bin/bash
# shellcheck disable=SC1091

set -e
set -o errexit
set -o pipefail
# set -o xtrace

# Define colours for output
GREEN="\033[0;32m"
NO_COLOUR="\033[0m"

function usage() {
    cat <<USAGE

    Usage: $0 --template-url URL --metadata-url URL

    Options:
        --template-url         Path or URL to template location
        --metadata-url         Path or URL to template metadata
USAGE
    exit 1
}

# if no arguments are provided, return usage function
if [ $# -eq 0 ]; then
    usage # run usage function
fi

while [ "$1" != "" ]; do
    case $1 in
    --template-url)
        shift
        TEMPLATE_URL=$1
        ;;
    --metadata-url)
        shift
        METADATA_URL=$1
        ;;
    *)
        echo "Unexpected argument: '$1'"
        usage
        ;;
    esac

    if [[ -z "$2" ]]; then
      # if no more args then stop processing
      break
    fi

    shift # remove the current value for `$1` and use the next
done

if [[ -z "$TEMPLATE_URL" ]]; then
    echo "Please specify the template url" 1>&2
    usage
fi

if [[ -z "$METADATA_URL" ]]; then
    echo "Please specify the metadata url" 1>&2
    usage
fi

# Get Subscription ID
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/load_metadata.sh" "$METADATA_URL"

# copy template into build artifacts folder
IMAGE_JSON_PATH="${DIR}/../build_artifacts/${CVM_TEMPLATE_NAME}.json"
cp "${TEMPLATE_URL}" "${IMAGE_JSON_PATH}"

# populate image json

IMG_BUILDER_ID="/subscriptions/${SUBSCRIPTION_ID}/resourcegroups/${CVM_RESOURCE_GROUP}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${CVM_IMAGE_BUILDER_ID_NAME}"

sed -i -e "s/<subscriptionID>/$SUBSCRIPTION_ID/g" "${IMAGE_JSON_PATH}"
sed -i -e "s/<rgName>/$CVM_RESOURCE_GROUP/g" "${IMAGE_JSON_PATH}"
sed -i -e "s/<imageDefName>/$CVM_IMAGE_DEFINITION/g" "${IMAGE_JSON_PATH}"
sed -i -e "s/<sharedImageGalName>/$CVM_GALLERY_NAME/g" "${IMAGE_JSON_PATH}"
sed -i -e "s/<runOutputName>/$CVM_IMAGE_DEFINITION/g" "${IMAGE_JSON_PATH}"
sed -i -e "s%<imgBuilderId>%$IMG_BUILDER_ID%g" "${IMAGE_JSON_PATH}"
sed -i -e "s%<scriptStorageAcc>%$CVM_STORAGE_ACCOUNT%g" "${IMAGE_JSON_PATH}"
sed -i -e "s%<scriptStorageAccContainer>%$CVM_CONTAINER_NAME%g" "${IMAGE_JSON_PATH}"

# Create the vm image template as a resource
echo -e "  ${GREEN}Creating Image Template${NO_COLOUR}"
az image builder create --name "${CVM_TEMPLATE_NAME}" --resource-group "${CVM_RESOURCE_GROUP}" --image-template "${IMAGE_JSON_PATH}"
