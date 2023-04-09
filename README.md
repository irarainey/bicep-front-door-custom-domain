## Deploy Azure Front Door and App Service with a custom domain using Bicep

This example demostrates how to deploy an Azure App Service that is protected by Azure Front Door and uses a custom domain, deployed using Bicep.

To do this it will deploy the following resources:

- DNS Zone
- Azure App Service
- Azure Front Door

Once deployed the App Service will be accessible via the specified subdomain of the domain, with all traffic routed through, and restricted to, the Azure Front Door.

## Deployment

To deploy the example first take a copy of the `.env.sample` file, rename it to `.env` and set the following values:

- `DOMAIN_NAME` - The domain to be deployed and configured for the App Service
- `SUBDOMAIN` - The subdomain to use for the App Service
- `PREFIX` - The prefix to use for the resources
- `SUFFIX` - The suffix to use for the resources

 Then run the following command:

```bash
make deploy
```

## Prerequisites

- Azure CLI
- Bicep
- A domain name with the nameservers configured for Azure DNS