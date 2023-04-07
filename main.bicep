targetScope = 'subscription'
param location string = deployment().location
param prefix string
param suffix string
param dnsZoneName string
param subdomain string

// Create resource group for the resources
resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${prefix}-rg-${suffix}'
  location: location
}

// Create a dns zone
module dnsZone './modules/dns-zone.bicep' = {
  name: 'dnsZone'
  scope: resourceGroup
  params: {
    name: dnsZoneName
  }
}

// Create a web app
module webApp './modules/web-app.bicep' = {
  name: 'webApp'
  scope: resourceGroup
  params: {
    location: location
    suffix: suffix
    prefix: prefix
    webAppName: subdomain
  }
}

// Create a front door instance
module frontDoor './modules/front-door.bicep' = {
  name: 'frontDoor'
  scope: resourceGroup
  params: {
    suffix: suffix
    prefix: prefix
    dnsZoneName: dnsZoneName
    subdomain: subdomain
    originHostName: webApp.outputs.hostname
  }
}

// Create a dns cname record for the web app
module dnsCname './modules/dns-cname.bicep' = {
  name: 'dnsCname'
  scope: resourceGroup
  params: {
    dnsZoneName: dnsZoneName
    targetFqdn: frontDoor.outputs.endpointHostname
    recordName: subdomain
  }
}

module dnsTxt './modules/dns-txt.bicep' = {
  name: 'dnsTxt'
  scope: resourceGroup
  params: {
    dnsZoneName: dnsZoneName
    recordName: '_dnsauth.${subdomain}'
    txtValue: frontDoor.outputs.validationToken
  }
}
