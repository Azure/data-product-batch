targetScope = 'resourceGroup'

// General parameters
@description('Specifies the location for all resources.')
param location string
@allowed([
  'dev'
  'tst'
  'prd'
])
@description('Specifies the environment of the deployment.')
param environment string
@minLength(2)
@maxLength(10)
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
param enableRoleAssignments bool = false

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
module keyvault001 'modules/services/keyvault.bicep' = {
  name: 'keyvault001'
  scope: resourceGroup()
  params: {
    location: location
    keyvaultName: '${name}-vault001'
    tags: tags
    subnetId: subnetId
    privateDnsZoneIdKeyVault: privateDnsZoneIdKeyVault
  }
}

module synapse001 'modules/services/synapse.bicep' = {
  name: 'synapse001'
  scope: resourceGroup()
  params: {
    location: location
    synapseName: '${name}-synapse001'
    tags: tags
    subnetId: subnetId
    administratorPassword: administratorPassword
    synapseSqlAdminGroupName: ''
    synapseSqlAdminGroupObjectID: ''
    privateDnsZoneIdSynapseDev: privateDnsZoneIdSynapseDev
    privateDnsZoneIdSynapseSql: privateDnsZoneIdSynapseSql
    purviewId: purviewId
    synapseComputeSubnetId: ''
    synapseDefaultStorageAccountFileSystemId: synapseDefaultStorageAccountFileSystemId
  }
}

module synapse001RoleAssignmentStorage 'modules/auxiliary/synapseRoleAssignmentStorage.bicep' = if (enableRoleAssignments) {
  name: 'synapse001RoleAssignmentStorage'
  scope: resourceGroup(synapseDefaultStorageAccountSubscriptionId, synapseDefaultStorageAccountResourceGroupName)
  params: {
    storageAccountFileSystemId: synapseDefaultStorageAccountFileSystemId
    synapseId: synapse001.outputs.synapseId
  }
}

module datafactory001 'modules/services/datafactory.bicep' = {
  name: 'datafactory001'
  scope: resourceGroup()
  params: {
    location: location
    datafactoryName: '${name}-datafactory001'
    tags: tags
    subnetId: subnetId
    keyvaultId: keyvault001.outputs.keyvaultId
    privateDnsZoneIdDataFactory: privateDnsZoneIdDataFactory
    privateDnsZoneIdDataFactoryPortal: privateDnsZoneIdDataFactoryPortal
    purviewId: purviewId
  }
}

module cosmosdb001 'modules/services/cosmosdb.bicep' = {
  name: 'cosmos001'
  scope: resourceGroup()
  params: {
    location: location
    cosmosdbName: '${name}-cosmos001'
    tags: tags
    subnetId: subnetId
    privateDnsZoneIdCosmosdbSql: privateDnsZoneIdCosmosdbSql
  }
}

module sql001 'modules/services/sql.bicep' = if (sqlFlavour == 'sql') {
  name: 'sql001'
  scope: resourceGroup()
  params: {
    location: location
    sqlserverName: '${name}-sqlserver001'
    tags: tags
    subnetId: subnetId
    administratorPassword: administratorPassword
    privateDnsZoneIdSqlServer: privateDnsZoneIdSqlServer
    sqlserverAdminGroupName: ''
    sqlserverAdminGroupObjectID: ''
  }
}

module mysql001 'modules/services/mysql.bicep' = if (sqlFlavour == 'mysql') {
  name: 'mysql001'
  scope: resourceGroup()
  params: {
    location: location
    mysqlserverName: '${name}-mysql001'
    tags: tags
    subnetId: subnetId
    administratorPassword: administratorPassword
    privateDnsZoneIdMySqlServer: privateDnsZoneIdMySqlServer
    mysqlserverAdminGroupName: ''
    mysqlserverAdminGroupObjectID: ''
  }
}

module mariadb001 'modules/services/mariadb.bicep' = if (sqlFlavour == 'maria') {
  name: 'mariadb001'
  scope: resourceGroup()
  params: {
    location: location
    mariadbName: '${name}-mariadb001'
    tags: tags
    subnetId: subnetId
    administratorPassword: administratorPassword
    privateDnsZoneIdMariaDb: privateDnsZoneIdMariaDb
  }
}

module potsgresql001 'modules/services/postgresql.bicep' = if (sqlFlavour == 'postgre') {
  name: 'postgresql001'
  scope: resourceGroup()
  params: {
    location: location
    postgresqlName: '${name}-postgresql001'
    tags: tags
    subnetId: subnetId
    administratorPassword: administratorPassword
    postgresqlAdminGroupName: ''
    postgresqlAdminGroupObjectID: ''
    privateDnsZoneIdPostgreSql: privateDnsZoneIdPostgreSql
  }
}
