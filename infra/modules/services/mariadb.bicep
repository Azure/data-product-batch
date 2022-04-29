// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// This template is used to create a MariaDb Server and Database.
targetScope = 'resourceGroup'

// Parameters
param location string
param tags object
param subnetId string
param mariadbName string
param administratorUsername string = 'SqlMainUser'
@secure()
param administratorPassword string
param privateDnsZoneIdMariaDb string = ''

// Variables
var mariadbPrivateEndpointName = '${mariadb.name}-private-endpoint'

// Resources
resource mariadb 'Microsoft.DBForMariaDB/servers@2018-06-01' = {
  name: mariadbName
  location: location
  tags: tags
  sku: {
    name: 'GP_Gen5_2'
    family: 'Gen5'
    tier: 'GeneralPurpose'
    capacity: 2
    size: '5120'
  }
  properties: {
    createMode: 'Default'
    administratorLogin: administratorUsername
    administratorLoginPassword: administratorPassword
    #disable-next-line BCP037
    infrastructureEncryption: 'Disabled'
    minimalTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Disabled'
    sslEnforcement: 'Enabled'
    storageProfile: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Enabled'
      storageAutogrow: 'Enabled'
      storageMB: 5120
    }
    version: '10.3'
  }
}

resource mariadbDatabase001 'Microsoft.DBForMariaDB/servers/databases@2018-06-01' = {
  parent: mariadb
  name: 'Database001'
  properties: {
    charset: 'utf8'
    collation: 'utf8_general_ci'
  }
}

resource mariadbPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: mariadbPrivateEndpointName
  location: location
  tags: tags
  properties: {
    manualPrivateLinkServiceConnections: []
    privateLinkServiceConnections: [
      {
        name: mariadbPrivateEndpointName
        properties: {
          groupIds: [
            'mariadbServer'
          ]
          privateLinkServiceId: mariadb.id
          requestMessage: ''
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource mariadbPrivateEndpointARecord 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-11-01' = if (!empty(privateDnsZoneIdMariaDb)) {
  parent: mariadbPrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${mariadbPrivateEndpoint.name}-arecord'
        properties: {
          privateDnsZoneId: privateDnsZoneIdMariaDb
        }
      }
    ]
  }
}

// Outputs
output mariadbName string = mariadb.name
