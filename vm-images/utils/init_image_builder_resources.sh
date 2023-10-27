#!/bin/bash

# Enable feature for image builder
az provider register -n Microsoft.VirtualMachineImages

# Setup environment variables
location=uksouth
sigName=OUHImageGallery
sigResourceGroup=OUHImageGalleryRG
subscriptionID=$(az account show --query id --output tsv)

# Create resource group for the image template process
az group create -n $sigResourceGroup -l $location


# Create compute gallery to hold the vm images
az sig create -g $sigResourceGroup --gallery-name $sigName


# Create a user-assigned identity for image builder to inject vm images into compute gallery
identityName=aibBuiUserId1663671995
imgBuilderCliId=$(az identity show -g $sigResourceGroup -n $identityName --query clientId -o tsv)
imageRoleDefName="OUH Azure Image Builder Image Def"
az identity create -g $sigResourceGroup -n $identityName

cp aibRoleImageCreation_base.json aibRoleImageCreation.json

sed -i -e "s/<subscriptionID>/$subscriptionID/g" aibRoleImageCreation.json
sed -i -e "s/<rgName>/$sigResourceGroup/g" aibRoleImageCreation.json
sed -i -e "s/Azure Image Builder Service Image Creation Role/$imageRoleDefName/g" aibRoleImageCreation.json


# Create custom role. This will take a few minutes.
az role definition create --role-definition ./aibRoleImageCreation.json
az role assignment create --assignee "$imgBuilderCliId" --role "$imageRoleDefName" --scope "/subscriptions/$subscriptionID/resourceGroups/$sigResourceGroup"


# Create the storage account and blob in the resource group
scriptStorageAcc=ouhvmimagefiles
scriptStorageAccContainer=ouhvmimagefilescontainer
az storage account create -n $scriptStorageAcc -g $sigResourceGroup -l uksouth --sku Standard_LRS
az storage container create -n $scriptStorageAccContainer --fail-on-exist --account-name $scriptStorageAcc
az role assignment create --assignee "$imgBuilderCliId" --role "Storage Blob Data Reader" --scope "/subscriptions/$subscriptionID/resourceGroups/$sigResourceGroup/providers/Microsoft.Storage/storageAccounts/$scriptStorageAcc/blobServices/default/containers/$scriptStorageAccContainer"


# Create vm definition version in gallery
az sig image-definition create -g $sigResourceGroup --gallery-name $sigName --gallery-image-definition OUHWindowsImageDef --publisher OUH --offer OUHWindowsVM --sku win-2019 --os-type Windows
az sig image-definition create -g $sigResourceGroup --gallery-name $sigName --gallery-image-definition OUHLinuxImageDef --publisher OUH --offer OUHLinuxVM --sku 18.04-LTS --os-type Linux



