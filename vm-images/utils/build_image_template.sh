#!/bin/bash

# usage: build_image_template.sh <arm template file> <image template name>
# This script assumes that any script or file URLs specified in the image template customiser section is readily available at the location they referenced. These can be
#     - a storage account under the same resource group accessible by the image builder user identity, or
#     - publicly available URL. e.g. https://raw.githubusercontent.com/atpw25/VMBuildFiles/main/init_vm.sh

sigResourceGroup=OUHImageGalleryRG
imageTemplate=$1
imageTemplateName=$2

echo "Submitting image template to the image builder..."
# Submit vm image template to azure image builder.
az resource create --resource-group $sigResourceGroup --properties @"$imageTemplate" --is-full-object --resource-type Microsoft.VirtualMachineImages/imageTemplates -n "$imageTemplateName"

echo "Building image template... Please be patience. This usually takes at least 25-35 minutes."
# Build vm image
az resource invoke-action --resource-group $sigResourceGroup --resource-type  Microsoft.VirtualMachineImages/imageTemplates -n "$imageTemplateName" --action Run

echo "Completed"
