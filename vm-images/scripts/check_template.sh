#!/bin/bash
set -e

TEMPLATE_PATH="$1"

if [[ -z $TEMPLATE_PATH ]]; then
    echo "Error: TEMPLATE_PATH parameter missing"
    exit 1
else
    if [[ ! -d ${TEMPLATE_PATH} ]]; then
        echo "Error: '${TEMPLATE_PATH}' directory NOT Found"
        exit 2
    fi
fi

echo "Working on ${TEMPLATE_PATH}"
