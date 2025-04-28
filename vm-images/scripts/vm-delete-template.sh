#!/bin/bash
set -e
set -o errexit
set -o pipefail
# set -o xtrace

# Define colours for output
GREEN="\033[0;32m"
NO_COLOUR="\033[0m"

function usage() {
    cat <<USAGE

    Usage: $0 --metadata-url URL

    Options:
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

if [[ -z "$METADATA_URL" ]]; then
    echo "Please specify the metadata url" 1>&2
    usage
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/load_metadata_from_json.sh" "$METADATA_URL"

# Create the vm image template
az image builder delete --name "${CVM_TEMPLATE_NAME}" --resource-group "${CVM_RESOURCE_GROUP}"
