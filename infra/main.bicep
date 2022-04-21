// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

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
@description('Specifies the tags that you want to apply to all resources.')
param tags object = {}

// Resource parameters
@allowed([
  'none'
  'sql'
  'mysql'
  'maria'
  'postgre'
])
@description('Specifies the sql flavour that will be deployed (None, SQL Server, MySQL Server, MariaDB Server, PostgreSQL Server).')
param sqlFlavour string = 'sql'
@secure()
@description('Specifies the administrator password of the sql servers and synapse workspace.')
param administratorPassword string = ''
@allowed([
  'dataFactory'
  'synapse'
])
@description('Specifies the data engineering service that will be deployed (Data Factory, Synapse).')
param processingService string = 'dataFactory'
@description('Specifies the resource ID of the default storage account file system for Synapse. If you selected dataFactory as processingService, leave this value empty as is.')
param synapseDefaultStorageAccountFileSystemId string = ''
@description('Specifies whether an Azure SQL Pool should be deployed inside your Synapse workspace as part of the template. If you selected dataFactory as processingService, leave this value as is.')
param enableSqlPool bool = false
@description('Specifies whether Azure Cosmos DB should be deployed as part of the template.')
param enableCosmos bool = false
@description('Specifies the resource ID of the central Purview instance.')
param purviewId string = ''
@description('Specifies the resource ID of the managed storage account of the central Purview instance.')
param purviewManagedStorageId string = ''
@description('Specifies the resource ID of the managed Event Hub of the central Purview instance.')
param purviewManagedEventHubId string = ''
@description('Specifies whether role assignments should be enabled.')
param enableRoleAssignments bool = false

// Monitoring parameters
@description('Specifies whether monitoring capabilities should be enabled.')
param enableMonitoring bool = true
@description('Specifies the email ID of the alerts receiver.')
param dataProductTeamEmail string = ''

// Network parameters
@description('Specifies the resource ID of the subnet to which all services will connect.')
param subnetId string

// Private DNS Zone parameters
@description('Specifies the resource ID of the private DNS zone for KeyVault.')
param privateDnsZoneIdKeyVault string = ''
@description('Specifies the resource ID of the private DNS zone for Synapse Dev.')
param privateDnsZoneIdSynapseDev string = ''
@description('Specifies the resource ID of the private DNS zone for Synapse Sql.')
param privateDnsZoneIdSynapseSql string = ''
@description('Specifies the resource ID of the private DNS zone for Data Factory.')
param privateDnsZoneIdDataFactory string = ''
@description('Specifies the resource ID of the private DNS zone for Data Factory Portal.')
param privateDnsZoneIdDataFactoryPortal string = ''
@description('Specifies the resource ID of the private DNS zone for Cosmos Sql.')
param privateDnsZoneIdCosmosdbSql string = ''
@description('Specifies the resource ID of the private DNS zone for Sql Server.')
param privateDnsZoneIdSqlServer string = ''
@description('Specifies the resource ID of the private DNS zone for MySql Server.')
param privateDnsZoneIdMySqlServer string = ''
@description('Specifies the resource ID of the private DNS zone for MariaDB.')
param privateDnsZoneIdMariaDb string = ''
@description('Specifies the resource ID of the private DNS zone for PostgreSql.')
param privateDnsZoneIdPostgreSql string = ''

// Variables
var name = toLower('${prefix}-${environment}')
var tagsDefault = {
  Owner: 'Data Management and Analytics Scenario'
  Project: 'Data Management and Analytics Scenario'
  Environment: environment
  Toolkit: 'bicep'
  Name: name
}
var tagsJoined = union(tagsDefault, tags)
var administratorUsername = 'SqlMainUser'
var synapseDefaultStorageAccountSubscriptionId = length(split(synapseDefaultStorageAccountFileSystemId, '/')) >= 13 ? split(synapseDefaultStorageAccountFileSystemId, '/')[2] : subscription().subscriptionId
var synapseDefaultStorageAccountResourceGroupName = length(split(synapseDefaultStorageAccountFileSystemId, '/')) >= 13 ? split(synapseDefaultStorageAccountFileSystemId, '/')[4] : resourceGroup().name
var keyVault001Name = '${name}-vault001'
var synapse001Name = '${name}-synapse001'
var datafactory001Name = '${name}-datafactory001'
var cosmosdb001Name = '${name}-cosmos001'
var database001Name = 'Database001'
var sql001Name = '${name}-sqlserver001'
var mysql001Name = '${name}-mysql001'
var mariadb001Name = '${name}-mariadb001'
var potsgresql001Name = '${name}-postgresql001'
var logAnalytics001Name = '${name}-loganalytics001'
var dataFactoryEmailActionGroup = '${datafactory001Name}-emailactiongroup'
var adfPipelineFailedAlertName = '${datafactory001Name}-failedalert'
var synapsePipelineFailedAlertName = '${synapse001Name}-failedalert'
var cosmosRequestLimitedAlertName = '${cosmosdb001Name}-requestratealert'
var dashboardName = '${name}-dashboard'

// Resources
module keyVault001 'modules/services/keyvault.bicep' = {
  name: 'keyVault001'
  scope: resourceGroup()
  params: {
    location: location
    keyvaultName: keyVault001Name
    tags: tagsJoined
    subnetId: subnetId
    privateDnsZoneIdKeyVault: privateDnsZoneIdKeyVault
  }
}

module synapse001 'modules/services/synapse.bicep' = if (processingService == 'synapse') {
  name: 'synapse001'
  scope: resourceGroup()
  params: {
    location: location
    synapseName: synapse001Name
    tags: tagsJoined
    subnetId: subnetId
    administratorUsername: administratorUsername
    administratorPassword: administratorPassword
    synapseSqlAdminGroupName: ''
    synapseSqlAdminGroupObjectID: ''
    privateDnsZoneIdSynapseDev: privateDnsZoneIdSynapseDev
    privateDnsZoneIdSynapseSql: privateDnsZoneIdSynapseSql
    purviewId: purviewId
    enableSqlPool: enableSqlPool
    synapseComputeSubnetId: ''
    synapseDefaultStorageAccountFileSystemId: synapseDefaultStorageAccountFileSystemId
  }
}

module synapse001RoleAssignmentStorage 'modules/auxiliary/synapseRoleAssignmentStorage.bicep' = if (processingService == 'synapse' && enableRoleAssignments) {
  name: 'synapse001RoleAssignmentStorage'
  scope: resourceGroup(synapseDefaultStorageAccountSubscriptionId, synapseDefaultStorageAccountResourceGroupName)
  params: {
    storageAccountFileSystemId: synapseDefaultStorageAccountFileSystemId
    synapseId: processingService == 'synapse' ? synapse001.outputs.synapseId : ''
  }
}

module datafactory001 'modules/services/datafactory.bicep' = if (processingService == 'dataFactory') {
  name: 'datafactory001'
  scope: resourceGroup()
  params: {
    location: location
    datafactoryName: datafactory001Name
    tags: tagsJoined
    subnetId: subnetId
    keyVault001Id: keyVault001.outputs.keyvaultId
    privateDnsZoneIdDataFactory: privateDnsZoneIdDataFactory
    privateDnsZoneIdDataFactoryPortal: privateDnsZoneIdDataFactoryPortal
    purviewId: purviewId
    purviewManagedStorageId: purviewManagedStorageId
    purviewManagedEventHubId: purviewManagedEventHubId
  }
}

module cosmosdb001 'modules/services/cosmosdb.bicep' = if (enableCosmos) {
  name: 'cosmos001'
  scope: resourceGroup()
  params: {
    location: location
    cosmosdbName: cosmosdb001Name
    tags: tagsJoined
    subnetId: subnetId
    privateDnsZoneIdCosmosdbSql: privateDnsZoneIdCosmosdbSql
  }
}

module sql001 'modules/services/sql.bicep' = if (sqlFlavour == 'sql') {
  name: 'sql001'
  scope: resourceGroup()
  params: {
    location: location
    sqlserverName: sql001Name
    tags: tagsJoined
    subnetId: subnetId
    administratorUsername: administratorUsername
    administratorPassword: administratorPassword
    privateDnsZoneIdSqlServer: privateDnsZoneIdSqlServer
    database001Name: database001Name
    sqlserverAdminGroupName: ''
    sqlserverAdminGroupObjectID: ''
  }
}

module mysql001 'modules/services/mysql.bicep' = if (sqlFlavour == 'mysql') {
  name: 'mysql001'
  scope: resourceGroup()
  params: {
    location: location
    mysqlserverName: mysql001Name
    tags: tagsJoined
    subnetId: subnetId
    administratorUsername: administratorUsername
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
    mariadbName: mariadb001Name
    tags: tagsJoined
    subnetId: subnetId
    administratorUsername: administratorUsername
    administratorPassword: administratorPassword
    privateDnsZoneIdMariaDb: privateDnsZoneIdMariaDb
  }
}

module postgresql001 'modules/services/postgresql.bicep' = if (sqlFlavour == 'postgre') {
  name: 'postgresql001'
  scope: resourceGroup()
  params: {
    location: location
    postgresqlName: potsgresql001Name
    tags: tagsJoined
    subnetId: subnetId
    administratorUsername: administratorUsername
    administratorPassword: administratorPassword
    postgresqlAdminGroupName: ''
    postgresqlAdminGroupObjectID: ''
    privateDnsZoneIdPostgreSql: privateDnsZoneIdPostgreSql
  }
}

module logAnalytics001 'modules/services/loganalytics.bicep' = if (enableMonitoring) {
  name: 'logAnalytics001'
  scope: resourceGroup()
  params: {
    location: location
    tags: tagsJoined
    logAnalyticsName: logAnalytics001Name
    processingService: processingService
    sqlFlavour: sqlFlavour
  }
}

module diagnosticSettings './modules/services/diagnosticsettings.bicep' = if (enableMonitoring) {
  name: 'diagnosticSettings'
  scope: resourceGroup()
  params: {
    datafactoryName: processingService == 'dataFactory' ? datafactory001.outputs.dataFactoryName : ''
    logAnalytics001Name: enableMonitoring ? logAnalytics001.outputs.logAnalyticsWorkspaceName: ''
    processingService: processingService    
    sqlFlavour: sqlFlavour
    mysql001Name: sqlFlavour == 'mysql' ? mysql001.outputs.mysqlName : ''
    sqlServerName: sqlFlavour == 'sql' ? sql001.outputs.sqlserverName : ''
    mariadb001Name: sqlFlavour == 'maria' ? mariadb001.outputs.mariadbName : ''    
    potsgresql001Name: sqlFlavour == 'postgre' ? postgresql001.outputs.postgresqlName : ''
    enableCosmos: enableCosmos
    cosmosdb001Name: enableCosmos ? cosmosdb001.outputs.cosmosName : ''
    synapseName: processingService == 'synapse' ? synapse001.outputs.synapseName : ''
    synapseSqlPools: [
      processingService == 'synapse' ? synapse001.outputs.synapseSqlPool001Name : null
    ]
    synapseSparkPools: [
      processingService == 'synapse' ? synapse001.outputs.synapseBigDataPool001Name : null
    ]
    sqlServerDatabases: [
      sqlFlavour == 'sql' ? sql001.outputs.sqlserverDatabase001Name : null
    ]
  }
}

module alerts './modules/services/alerts.bicep' = if (!empty(dataProductTeamEmail) && enableMonitoring) {
  name: 'alerts'
  scope: resourceGroup()
  params: {
    adfPipelineFailedAlertName: adfPipelineFailedAlertName
    datafactoryScope: processingService == 'dataFactory' ? datafactory001.outputs.dataFactoryId : ''
    dataFactoryEmailActionGroup: dataFactoryEmailActionGroup
    dataProductTeamEmail: dataProductTeamEmail
    location: location
    processingService: processingService
    synapsePipelineFailedAlertName: synapsePipelineFailedAlertName
    cosmosRequestLimitedAlertName: cosmosRequestLimitedAlertName
    synapseScope: processingService == 'synapse' ? synapse001.outputs.synapseId : ''
    enableCosmos: enableCosmos
    cosmosDBScope: enableCosmos ? cosmosdb001.outputs.cosmosId :''    
    tags: tagsJoined
  }
}

module dashboards './modules/services/dashboard.bicep' = if (enableMonitoring) {
  name: 'dashboard'
  scope: resourceGroup()
  params: {
    dashboardName: dashboardName
    datafactoryName: processingService == 'dataFactory' ? datafactory001.outputs.dataFactoryName : ''
    datafactoryScope: processingService == 'dataFactory' ? datafactory001.outputs.dataFactoryId : ''
    location: location
    processingService: processingService
    synapse001Name: processingService == 'synapse' ? synapse001.outputs.synapseName : ''
    synapseScope: processingService == 'synapse' ? synapse001.outputs.synapseId : ''
    tags: tagsJoined
  }
}

// Outputs
