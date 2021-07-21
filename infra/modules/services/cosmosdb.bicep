// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// This template is used to create a Cosmos Database.
targetScope = 'resourceGroup'

// Parameters
param location string
param tags object
param subnetId string
param cosmosdbName string
param privateDnsZoneIdCosmosdbSql string

// Variables
var cosmosdbPrivateEndpointName = '${cosmosdb.name}-private-endpoint'

// Resources
resource cosmosdb 'Microsoft.DocumentDB/databaseAccounts@2021-03-15' = {
  name: cosmosdbName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'GlobalDocumentDB'
  properties: {
    // apiProperties: {  // For Mongo DB
    //   serverVersion: '4.0'
    // }
    backupPolicy: {
      type: 'Continuous'
    }
    capabilities: []
    // connectorOffer: 'Small'  // For Cassandra DB
    consistencyPolicy: {
      defaultConsistencyLevel: 'Eventual'
      maxStalenessPrefix: 1
      maxIntervalInSeconds: 5
    }
    cors: []
    databaseAccountOfferType: 'Standard'
    disableKeyBasedMetadataWriteAccess: true
    enableAnalyticalStorage: false
    enableAutomaticFailover: true
    enableCassandraConnector: false
    enableFreeTier: false
    enableMultipleWriteLocations: false
    ipRules: []
    networkAclBypass: 'None'
    networkAclBypassResourceIds: []
    publicNetworkAccess: 'Disabled'
    virtualNetworkRules: []
    isVirtualNetworkFilterEnabled: true
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: true
      }
    ]
  }
}

// resource cosmosdbSqlDatabase001 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-03-15' = {  // Uncomment to deploy SQL database to the cosmos account
//   parent: cosmosdb
//   name: 'Database001'
//   properties: {
//     options: {
//       autoscaleSettings: {
//         maxThroughput: 10
//       }
//     }
//     resource: {
//       id: 'Database001'
//     }
//   }
// }

resource cosmosdbPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: cosmosdbPrivateEndpointName
  location: location
  tags: tags
  properties: {
    manualPrivateLinkServiceConnections: []
    privateLinkServiceConnections: [
      {
        name: cosmosdbPrivateEndpointName
        properties: {
          groupIds: [
            'sql'
          ]
          privateLinkServiceId: cosmosdb.id
          requestMessage: ''
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource cosmosdbPrivateEndpointARecord 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-11-01' = if (!empty(privateDnsZoneIdCosmosdbSql)) {
  parent: cosmosdbPrivateEndpoint
  name: 'aRecord'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${cosmosdbPrivateEndpoint.name}-arecord'
        properties: {
          privateDnsZoneId: privateDnsZoneIdCosmosdbSql
        }
      }
    ]
  }
}

// Outputs
