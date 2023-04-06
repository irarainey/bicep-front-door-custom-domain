param location string
param prefix string
param suffix string
param webAppName string

@allowed([
  'Y1'
  'EP1'
  'EP2'
  'EP3'
  'F1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1v2'
  'P2v2'
  'P3v2'
  'P1v3'
  'P2v3'
  'P3v3'
])
param sku string = 'P1v3'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${prefix}-asp-${suffix}'
  location: location
  kind: 'linux'
  sku: {
    name: sku
    capacity: 1
  }
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: '${prefix}-webapp-${webAppName}-${suffix}'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

output hostname string = appService.properties.defaultHostName
