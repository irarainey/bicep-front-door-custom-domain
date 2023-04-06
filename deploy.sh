#!/bin/bash
set -euo pipefail

# Run the bicep deployment
az deployment sub create \
    --template-file ./main.bicep \
    --location westeurope \
    --parameters \
        prefix=${PREFIX} \
        suffix=${SUFFIX} \
        dnsZoneName=${DOMAIN_NAME} \
        subdomain=${SUBDOMAIN}
