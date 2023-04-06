param dnsZoneName string
param recordName string
param txtValue string

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: dnsZoneName
}

resource dnsAuth 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
  parent: dnsZone
  name: recordName
  properties: {
    TTL: 3600
    TXTRecords: [
      {
        value: [
          txtValue
        ]
      }
    ]
  }
}
