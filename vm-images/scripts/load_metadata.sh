#!/bin/bash
# shellcheck disable=SC2034
set -e

TEMPLATE_METADATA_FILE="$1"

# extract values from metadata from file
CVM_IMAGE_DEFINITION_PREFIX=$(awk -F "=" '/IMAGE_DEFINITION_PREFIX/ {print $2}' "${TEMPLATE_METADATA_FILE}")
CVM_TEMPLATE_NAME_PREFIX=$(awk -F "=" '/TEMPLATE_NAME_PREFIX/ {print $2}' "${TEMPLATE_METADATA_FILE}")
CVM_OFFER_PREFIX=$(awk -F "=" '/OFFER_PREFIX/ {print $2}' "${TEMPLATE_METADATA_FILE}")
CVM_PUBLISHER_NAME=$(awk -F "=" '/PUBLISHER_NAME/ {print $2}' "${TEMPLATE_METADATA_FILE}")
CVM_SKU=$(awk -F "=" '/SKU/{print $2}' "${TEMPLATE_METADATA_FILE}")
CVM_OSTYPE=$(awk -F "=" '/OSTYPE/{print $2}' "${TEMPLATE_METADATA_FILE}")

if [[ -z $CVM_IMAGE_DEFINITION_PREFIX ]]; then
  echo "CVM_IMAGE_DEFINITION_PREFIX is missing from ${TEMPLATE_METADATA_FILE}:"
  exit 1
fi

if [[ -z $CVM_TEMPLATE_NAME_PREFIX ]]; then
  echo "CVM_TEMPLATE_NAME_PREFIX is missing from ${TEMPLATE_METADATA_FILE}:"
  exit 1
fi

if [[ -z $CVM_OFFER_PREFIX ]]; then
  echo "CVM_OFFER_PREFIX is missing from ${TEMPLATE_METADATA_FILE}:"
  exit 1
fi

if [[ -z $CVM_PUBLISHER_NAME ]]; then
  echo "CVM_PUBLISHER_NAME is missing from ${TEMPLATE_METADATA_FILE}:"
  exit 1
fi

if [[ -z $CVM_SKU ]]; then
  echo "CVM_SKU is missing from ${TEMPLATE_METADATA_FILE}:"
  exit 1
fi

if [[ -z $CVM_OSTYPE ]]; then
  echo "CVM_OSTYPE is missing from ${TEMPLATE_METADATA_FILE}:"
  exit 1
fi


# add environment suffix to prefix metadata
CVM_IMAGE_DEFINITION="${CVM_IMAGE_DEFINITION_PREFIX}${CVM_ENVIRONMENT_SUFFIX}"
CVM_TEMPLATE_NAME="${CVM_TEMPLATE_NAME_PREFIX}${CVM_ENVIRONMENT_SUFFIX}"
CVM_OFFER="${CVM_OFFER_PREFIX}${CVM_ENVIRONMENT_SUFFIX}"

