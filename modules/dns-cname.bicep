param dnsZoneName string
param targetFqdn string
param recordName string

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: dnsZoneName
}

resource dnsCname 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  parent: dnsZone
  name: recordName
  properties: {
    TTL: 3600
    CNAMERecord: {
      cname: targetFqdn
    }
  }
}
