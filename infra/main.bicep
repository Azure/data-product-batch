targetScope = 'resourceGroup'

// General parameters
@description('Specifies the location for all resources.')
param location string
@allowed([
  'dev'
  'test'
  'prod'
])
@description('Specifies the environment of the deployment.')
param environment string
@minLength(2)
@maxLength(5)
@description('Specifies the prefix for all resources created in this deployment.')
param prefix string

// Resource parameters
@allowed([
  'sql'
  'mysql'
  'maria'
  'postgre'
])
@description('Specifies the sql flavour that will be deployed.')
param sqlFlavour string
@secure()
@description('Specifies the administrator password of the sql servers.')
param administratorPassword string
@description('Specifies the resource ID of the default storage account file system for synapse.')
param synapseDefaultStorageAccountFileSystemId string
@description('Specifies the resource ID of the central purview instance.')
param purviewId string
@description('Specifies whether role assignments should be enabled.')
param enableRoleAssignments bool

// Network parameters
@description('Specifies the resource ID of the subnet to which all services will connect.')
param subnetId string

// Private DNS Zone parameters
@description('Specifies the resource ID of the private DNS zone for KeyVault.')
param privateDnsZoneIdKeyVault string
@description('Specifies the resource ID of the private DNS zone for Synapse Dev.')
param privateDnsZoneIdSynapseDev string
@description('Specifies the resource ID of the private DNS zone for Synapse Sql.')
param privateDnsZoneIdSynapseSql string
@description('Specifies the resource ID of the private DNS zone for Data Factory.')
param privateDnsZoneIdDataFactory string
@description('Specifies the resource ID of the private DNS zone for Data Factory Portal.')
param privateDnsZoneIdDataFactoryPortal string
@description('Specifies the resource ID of the private DNS zone for Cosmos Sql.')
param privateDnsZoneIdCosmosdbSql string
@description('Specifies the resource ID of the private DNS zone for Sql Server.')
param privateDnsZoneIdSqlServer string
@description('Specifies the resource ID of the private DNS zone for MySql Server.')
param privateDnsZoneIdMySqlServer string
@description('Specifies the resource ID of the private DNS zone for MariaDB.')
param privateDnsZoneIdMariaDb string
@description('Specifies the resource ID of the private DNS zone for PostgreSql.')
param privateDnsZoneIdPostgreSql string

// Variables
var name = toLower('${prefix}-${environment}')
var tags = {
  Owner: 'Enterprise Scale Analytics'
  Project: 'Enterprise Scale Analytics'
  Environment: environment
  Toolkit: 'bicep'
  Name: name
}
var synapseDefaultStorageAccountSubscriptionId = split(synapseDefaultStorageAccountFileSystemId, '/')[2]
var synapseDefaultStorageAccountResourceGroupName = split(synapseDefaultStorageAccountFileSystemId, '/')[4]

// Resources
module keyvault001 'services/keyvault.bicep' = {
  name: 'keyvault001'
  scope: resourceGroup()
  params: {
    location: location
    keyvaultName: '${prefix}-vault001'
    tags: tags
    privateDnsZoneIdKeyVault: privateDnsZoneIdKeyVault
    subnetId: subnetId
  }
}

module synapse001 'services/synapse.bicep' = {
  name: 'synapse001'
  scope: resourceGroup()
  params: {
    location: location
    synapseName: '${prefix}-synapse001'
    tags: tags
    administratorPassword: administratorPassword
    synapseSqlAdminGroupName: ''
    synapseSqlAdminGroupObjectID: ''
    privateDnsZoneIdSynapseDev: privateDnsZoneIdSynapseDev
    privateDnsZoneIdSynapseSql: privateDnsZoneIdSynapseSql
    purviewId: purviewId
    subnetId: subnetId
    synapseComputeSubnetId: ''
    synapseDefaultStorageAccountFileSystemId: synapseDefaultStorageAccountFileSystemId
  }
}

module synapse001RoleAssignmentStorage 'auxiliary/synapseRoleAssignmentStorage.bicep' = if (enableRoleAssignments) {
  name: 'synapse001RoleAssignmentStorage'
  scope: resourceGroup(synapseDefaultStorageAccountSubscriptionId, synapseDefaultStorageAccountResourceGroupName)
  params: {
    storageAccountFileSystemId: synapseDefaultStorageAccountFileSystemId
    synapseId: synapse001.outputs.synapseId
  }
}

module datafactory001 'services/datafactory.bicep' = {
  name: 'datafactory001'
  scope: resourceGroup()
  params: {
    location: location
    datafactoryName: '${prefix}-datafactory001'
    tags: tags
    keyvaultId: keyvault001.outputs.keyvaultId
    privateDnsZoneIdDataFactory: privateDnsZoneIdDataFactory
    privateDnsZoneIdDataFactoryPortal: privateDnsZoneIdDataFactoryPortal
    purviewId: purviewId
    subnetId: subnetId
  }
}

module cosmosdb001 'services/cosmosdb.bicep' = {
  name: 'cosmos001'
  scope: resourceGroup()
  params: {
    location: location
    cosmosdbName: '${prefix}-cosmos001'
    tags: tags
    privateDnsZoneIdCosmosdbSql: privateDnsZoneIdCosmosdbSql
    subnetId: subnetId
  }
}

module sql001 'services/sql.bicep' = if (sqlFlavour == 'sql') {
  name: 'sql001'
  scope: resourceGroup()
  params: {
    location: location
    sqlserverName: '${prefix}-sqlserver001'
    tags: tags
    administratorPassword: administratorPassword
    privateDnsZoneIdSqlServer: privateDnsZoneIdSqlServer
    sqlserverAdminGroupName: ''
    sqlserverAdminGroupObjectID: ''
    subnetId: subnetId
  }
}

module mysql001 'services/mysql.bicep' = if (sqlFlavour == 'mysql') {
  name: 'mysql001'
  scope: resourceGroup()
  params: {
    location: location
    mysqlserverName: '${prefix}-mysql001'
    tags: tags
    administratorPassword: administratorPassword
    privateDnsZoneIdMySqlServer: privateDnsZoneIdMySqlServer
    mysqlserverAdminGroupName: ''
    mysqlserverAdminGroupObjectID: ''
    subnetId: subnetId
  }
}

module mariadb001 'services/mariadb.bicep' = if (sqlFlavour == 'maria') {
  name: 'mariadb001'
  scope: resourceGroup()
  params: {
    location: location
    mariadbName: '${prefix}-mariadb001'
    tags: tags
    administratorPassword: administratorPassword
    privateDnsZoneIdMariaDb: privateDnsZoneIdMariaDb
    subnetId: subnetId
  }
}

module potsgresql001 'services/postgresql.bicep' = if (sqlFlavour == 'postgre') {
  name: 'postgresql001'
  scope: resourceGroup()
  params: {
    location: location
    postgresqlName: '${prefix}-postgresql001'
    tags: tags
    administratorPassword: administratorPassword
    postgresqlAdminGroupName: ''
    postgresqlAdminGroupObjectID: ''
    privateDnsZoneIdPostgreSql: privateDnsZoneIdPostgreSql
    subnetId: subnetId
  }
}
