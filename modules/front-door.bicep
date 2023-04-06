param prefix string
param suffix string
param dnsZoneName string
param originHostName string
param subdomain string

// Select the SKU for the Front Door Instance
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param sku string = 'Standard_AzureFrontDoor'

// Create the Front Door Instance
resource frontDoor 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: '${prefix}-fd-${suffix}'
  location: 'Global'
  sku: {
    name: sku
  }
  properties: {
    originResponseTimeoutSeconds: 60
  }
}

// Create the Front Door Endpoint
resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdendpoints@2022-11-01-preview' = {
  parent: frontDoor
  name: '${prefix}-fd-endpoint-${suffix}'
  location: 'Global'
  properties: {
    enabledState: 'Enabled'
  }
}

// Create the Front Door Origin Group for a web app
resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/origingroups@2022-11-01-preview' = {
  parent: frontDoor
  name: 'web-app-origin-group'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Disabled'
  }
}

// Create the Front Door Origin for a web app within our origin group
resource frontDoorOrigins 'Microsoft.Cdn/profiles/origingroups/origins@2022-11-01-preview' = {
  parent: frontDoorOriginGroup
  name: 'web-app-primary'
  properties: {
    hostName: originHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: originHostName
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
}

// Create the Front Door Custom Domain for the web app
resource customDomain 'Microsoft.Cdn/profiles/customdomains@2021-06-01' = {
  parent: frontDoor
  name: '${subdomain}CustomDomain'
  properties: {
    hostName: '${subdomain}.${dnsZoneName}'
    tlsSettings: {
      certificateType: 'ManagedCertificate'
      minimumTlsVersion: 'TLS12'
    }
  }
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdendpoints/routes@2022-11-01-preview' = {
  parent: frontDoorEndpoint
  name: 'web-app-route'
  properties: {
    customDomains: [
      {
        id: customDomain.id
      }
    ]
    originGroup: {
      id: frontDoorOriginGroup.id
    }
    ruleSets: []
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Disabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
  dependsOn: [
    frontDoorOrigins
  ]
}

output id string = frontDoor.id
output endpointHostname string = frontDoorEndpoint.properties.hostName
output validationToken string = customDomain.properties.validationProperties.validationToken
