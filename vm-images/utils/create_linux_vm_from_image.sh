#!/bin/bash

# usage: create_vm_from_image.sh <vm name> <admin user name>

sigResourceGroup=OUHImageGalleryRG
subscriptionID=$(az account show --query id --output tsv)
sigName=OUHImageGallery
imageDefName=OUHLinuxImageDef

# Create vm from the vm image
az vm create --resource-group $sigResourceGroup --name "$1" --admin-username "$2" --location uksouth --image "/subscriptions/$subscriptionID/resourceGroups/$sigResourceGroup/providers/Microsoft.Compute/galleries/$sigName/images/$imageDefName/versions/latest" --generate-ssh-keys
