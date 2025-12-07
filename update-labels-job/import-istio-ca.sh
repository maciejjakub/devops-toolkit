#!/bin/bash

if [[ -z "${AZURE_KEYVAULT_NAME:-}" ]]; then
  echo "Error: AZURE_KEYVAULT_NAME environment variable is not set."
  exit 1
fi

if [[ -z "${ISTIO_CA_SECRET_NAME:-}" ]]; then
  echo "Error: ISTIO_CA_SECRET_NAME environment variable is not set."
  exit 1
fi

# Convert ca-cert.pem and ca-key.pem into .pfx format
openssl pkcs12 -export -in /etc/istio-ca/ca-cert.pem -inkey /etc/istio-ca/ca-key.pem -out istio-ca-secret.pfx -passout pass:
az login --federated-token "$(cat $AZURE_FEDERATED_TOKEN_FILE)" --service-principal -u $AZURE_CLIENT_ID -t $AZURE_TENANT_ID
az keyvault certificate import --vault-name $AZURE_KEYVAULT_NAME -n $ISTIO_CA_SECRET_NAME -f istio-ca-secret.pfx
