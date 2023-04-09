param appServiceName string
param frontDoorId string

resource appService 'Microsoft.Web/sites@2022-03-01' existing = {
  name: appServiceName
} 

resource appServiceConfig 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: appService
  name: 'web'
  properties: {
    ipSecurityRestrictions: [
      {
        ipAddress: 'AzureFrontDoor.Frontend'
        action: 'Allow'
        tag: 'ServiceTag'
        priority: 100
        name: 'Front Door Only'
        headers: {
          'x-azure-fdid': [
            frontDoorId
          ]
        }
      }
      {
        ipAddress: 'Any'
        action: 'Deny'
        priority: 2147483647
        name: 'Deny all'
        description: 'Deny all access'
      }
    ]
    minTlsVersion: '1.2'
  }
}
