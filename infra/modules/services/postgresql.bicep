// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// This template is used to create a PostgreSql Server and Database.
targetScope = 'resourceGroup'

// Parameters
param location string
param tags object
param subnetId string
param postgresqlName string
param administratorUsername string = 'SqlMainUser'
@secure()
param administratorPassword string
param postgresqlAdminGroupName string = ''
param postgresqlAdminGroupObjectID string = ''
param privateDnsZoneIdPostgreSql string = ''

// Variables
var postgresqlPrivateEndpointName = '${postgresql.name}-private-endpoint'

// Resources
resource postgresql 'Microsoft.DBForPostgreSQL/servers@2017-12-01' = {
  name: postgresqlName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
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
    version: '11'
  }
}

resource postgresqlAdministrators 'Microsoft.DBForPostgreSQL/servers/administrators@2017-12-01' = if (!empty(postgresqlAdminGroupName) && !empty(postgresqlAdminGroupObjectID)) {
  parent: postgresql
  name: 'activeDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: postgresqlAdminGroupName
    sid: postgresqlAdminGroupObjectID
    tenantId: subscription().tenantId
  }
}

resource postgresqlDatabase001 'Microsoft.DBForPostgreSQL/servers/databases@2017-12-01' = {
  parent: postgresql
  name: 'Database001'
  properties: {
    charset: 'utf8'
    collation: 'English_United States.1252'
  }
}

resource postgresqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: postgresqlPrivateEndpointName
  location: location
  tags: tags
  properties: {
    manualPrivateLinkServiceConnections: []
    privateLinkServiceConnections: [
      {
        name: postgresqlPrivateEndpointName
        properties: {
          groupIds: [
            'postgresqlServer'
          ]
          privateLinkServiceId: postgresql.id
          requestMessage: ''
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource postgresqlPrivateEndpointARecord 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-11-01' = if (!empty(privateDnsZoneIdPostgreSql)) {
  parent: postgresqlPrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${postgresqlPrivateEndpoint.name}-arecord'
        properties: {
          privateDnsZoneId: privateDnsZoneIdPostgreSql
        }
      }
    ]
  }
}

// Outputs
output postgresqlName string = postgresql.name
