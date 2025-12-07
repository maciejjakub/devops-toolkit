#!/bin/bash
# Create Azure AD Application & Service Principal pair with required API permissions

appId=$(az ad app create \
  --display-name "app-clone" \
  --required-resource-accesses @manifest.json \
  | jq -r '.appId' )

az ad app update --id $appId --set 'spa={"redirectUris": ["https://app-clone.sectoralarm.cloud/"]}'
az ad sp create --id $appId

az ad app permission admin-consent --id $appId
