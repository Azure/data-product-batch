// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// This template is used to create a SQL Server and Database.
targetScope = 'resourceGroup'

// Parameters
param location string
param tags object
param subnetId string
param sqlserverName string
param administratorUsername string = 'SqlMainUser'
@secure()
param administratorPassword string
param sqlserverAdminGroupName string = ''
param sqlserverAdminGroupObjectID string = ''
param privateDnsZoneIdSqlServer string = ''
param database001Name string

// Variables
var sqlserverPrivateEndpointName = '${sqlserver.name}-private-endpoint'

// Resources
resource sqlserver 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: sqlserverName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: administratorUsername
    administratorLoginPassword: administratorPassword
    administrators: {}
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    version: '12.0'
  }
}

resource sqlserverAdministrators 'Microsoft.Sql/servers/administrators@2020-11-01-preview' = if (!empty(sqlserverAdminGroupName) && !empty(sqlserverAdminGroupObjectID)) {
  parent: sqlserver
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: sqlserverAdminGroupName
    sid: sqlserverAdminGroupObjectID
    tenantId: subscription().tenantId
  }
}

// resource sqlserverElasticPool001 'Microsoft.Sql/servers/elasticPools@2020-11-01-preview' = {  // Uncomment, if you want to deploy an elastic pool
//   parent: sqlserver
//   name: 'elasticPool001'
//   location: location
//   tags: tags
//   sku: {
//     name: 'Basic'
//     tier: 'Basic'
//     capacity: 5
//   }
//   properties: {
//     licenseType: 'LicenseIncluded'
//     maxSizeBytes: 524288000
//     perDatabaseSettings: {
//       minCapacity: 524288000
//       maxCapacity: 524288000
//     }
//     zoneRedundant: true
//   }
// }

resource sqlserverDatabase001 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
  parent: sqlserver
  name: database001Name
  location: location
  tags: tags
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    autoPauseDelay: -1
    catalogCollation: 'DATABASE_DEFAULT'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    createMode: 'Default'
    readScale: 'Disabled'
    highAvailabilityReplicaCount: 0
    licenseType: 'LicenseIncluded'
    maxSizeBytes: 524288000
    minCapacity: 1
    requestedBackupStorageRedundancy: 'Geo'
    zoneRedundant: false
    // elasticPoolId: sqlserverElasticPool001.id  // Uncomment, if you want to deploy to an elastic pool. Do not forget to remove some properties from the database
  }
}

resource sqlserverPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: sqlserverPrivateEndpointName
  location: location
  tags: tags
  properties: {
    manualPrivateLinkServiceConnections: []
    privateLinkServiceConnections: [
      {
        name: sqlserverPrivateEndpointName
        properties: {
          groupIds: [
            'sqlServer'
          ]
          privateLinkServiceId: sqlserver.id
          requestMessage: ''
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource sqlserverPrivateEndpointARecord 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-11-01' = if (!empty(privateDnsZoneIdSqlServer)) {
  parent: sqlserverPrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${sqlserverPrivateEndpoint.name}-arecord'
        properties: {
          privateDnsZoneId: privateDnsZoneIdSqlServer
        }
      }
    ]
  }
}

// Outputs
output sqlserverName string = sqlserver.name
output sqlserverDatabase001Name string = sqlserverDatabase001.name
