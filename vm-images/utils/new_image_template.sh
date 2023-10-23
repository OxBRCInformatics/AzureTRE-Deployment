#!/bin/bash

# usage: init_image_template.sh <ARM image template file name>

# Setup some environment variables
sigName=OUHImageGallery
sigResourceGroup=OUHImageGalleryRG
imageDefName=OUHLinuxImageDef
runOutputName=OUHLinuxImageSIG
subscriptionID=$(az account show --query id --output tsv)
identityName=aibBuiUserId1663671995
imgBuilderId=/subscriptions/$subscriptionID/resourcegroups/$sigResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$identityName
scriptStorageAcc=ouhvmimagefiles
scriptStorageAccContainer=ouhvmimagefilescontainer

cp linux_vm_arm_template_base.json "$1"

# Add config details into linux image template
sed -i -e "s/<subscriptionID>/$subscriptionID/g" "$1"
sed -i -e "s/<rgName>/$sigResourceGroup/g" "$1"
sed -i -e "s/<imageDefName>/$imageDefName/g" "$1"
sed -i -e "s/<sharedImageGalName>/$sigName/g" "$1"
sed -i -e "s/<runOutputName>/$runOutputName/g" "$1"
sed -i -e "s%<imgBuilderId>%$imgBuilderId%g" "$1"
sed -i -e "s%<scriptStorageAcc>%$scriptStorageAcc%g" "$1"
sed -i -e "s%<scriptStorageAccContainer>%$scriptStorageAccContainer%g" "$1"


