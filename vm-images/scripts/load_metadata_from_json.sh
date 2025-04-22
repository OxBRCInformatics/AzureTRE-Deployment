#!/bin/bash
set -e

TEMPLATE_METADATA_FILE="$1"

if [[ -z $TEMPLATE_METADATA_FILE ]]; then
  echo "TEMPLATE_METADATA_FILE not provided"
  exit 1
fi

# extract values from metadata from file
while read -rd $'' line
do
    export "CVM_$line"
done < <(jq -r <<<$(cat $TEMPLATE_METADATA_FILE) \
         'to_entries|map("\(.key)=\(.value)\u0000")[]')

if [[ -z $CVM_IMAGE_DEFINITION_PREFIX ]]; then
  echo "CVM_IMAGE_DEFINITION_PREFIX is missing from ${TEMPLATE_METADATA_FILE}"
  exit 1
fi

if [[ -z $CVM_TEMPLATE_NAME_PREFIX ]]; then
  echo "CVM_TEMPLATE_NAME_PREFIX is missing from ${TEMPLATE_METADATA_FILE}"
  exit 1
fi

if [[ -z $CVM_OFFER_PREFIX ]]; then
  echo "CVM_OFFER_PREFIX is missing from ${TEMPLATE_METADATA_FILE}"
  exit 1
fi

if [[ -z $CVM_PUBLISHER_NAME ]]; then
  echo "CVM_PUBLISHER_NAME is missing from ${TEMPLATE_METADATA_FILE}"
  exit 1
fi

if [[ -z $CVM_SKU ]]; then
  echo "CVM_SKU is missing from ${TEMPLATE_METADATA_FILE}"
  exit 1
fi

if [[ -z $CVM_OSTYPE ]]; then
  echo "CVM_OSTYPE is missing from ${TEMPLATE_METADATA_FILE}"
  exit 1
fi

if [[ -z $CVM_IMAGE_TAGS ]]; then
  echo "CVM_IMAGE_TAGS is missing from ${TEMPLATE_METADATA_FILE}"
  exit 1
fi

if [[ -z $CVM_IMAGE_DESCRIPTION ]]; then
  echo "CVM_IMAGE_DESCRIPTION is missing from ${TEMPLATE_METADATA_FILE}"
  exit 1
fi

# add environment suffix to prefix metadata
CVM_IMAGE_DEFINITION="${CVM_IMAGE_DEFINITION_PREFIX}${CVM_ENVIRONMENT_SUFFIX}"
CVM_TEMPLATE_NAME="${CVM_TEMPLATE_NAME_PREFIX}${CVM_ENVIRONMENT_SUFFIX}"
CVM_OFFER="${CVM_OFFER_PREFIX}${CVM_ENVIRONMENT_SUFFIX}"
