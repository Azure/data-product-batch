// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// This template is used to setup diagnostic settings.
targetScope = 'resourceGroup'

// Parameters
param logAnalytics001Name string
param datafactoryName string
param processingService string
param synapseName string
param synapseSqlPools array
param synapseSparkPools array
param sqlServerDatabases array
param sqlServerName string
param mysql001Name string
param mariadb001Name string
param potsgresql001Name string
param cosmosdb001Name string
param sqlFlavour string
param enableCosmos bool

//variables
var synapseSqlPoolsCount = length(synapseSqlPools)
var synapseSparkPoolCount = length(synapseSparkPools)
var sqlServerDatabasesCount = length(sqlServerDatabases)

//Resources
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: logAnalytics001Name
}

resource datafactoryworkspace 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: datafactoryName
}

resource synapseworkspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: synapseName
}

resource synapsesqlpool 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01' existing = [for sqlPool in synapseSqlPools: {
  parent: synapseworkspace
  name: sqlPool
}]

resource synapsebigdatapool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' existing = [for sparkPool in synapseSparkPools: {
  parent: synapseworkspace
  name: sparkPool
}]

resource sqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = {
  name: sqlServerName
}

resource sqlDatabases 'Microsoft.Sql/servers/databases@2020-11-01-preview' existing = [for sqlDatabase in sqlServerDatabases: {
  parent: sqlServer
  name: sqlDatabase
}]

resource mySqlServer 'Microsoft.DBForMySQL/servers@2017-12-01' existing = {
  name: mysql001Name
}

resource mariaDBServer 'Microsoft.DBForMariaDB/servers@2018-06-01' existing = {
  name: mariadb001Name
}

resource postgreSQLServer 'Microsoft.DBForPostgreSQL/servers@2017-12-01' existing = {
  name: potsgresql001Name
}

resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts@2021-03-15' existing = {
  name: cosmosdb001Name
}

// Diagnostic settings for Azure Data Factory.
resource diagnosticSetting001 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (processingService == 'dataFactory') {
  scope: datafactoryworkspace
  name: 'diagnostic-${datafactoryworkspace.name}'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'PipelineRuns'
        enabled: true
      }
      {
        category: 'TriggerRuns'
        enabled: true
      }
      {
        category: 'ActivityRuns'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Diagnostic settings for Azure Synapse Workspace.
resource diagnosticSetting002 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (processingService == 'synapse') {
  scope: synapseworkspace
  name: 'diagnostic-${synapseworkspace.name}'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'SynapseRbacOperations'
        enabled: true
      }
      {
        category: 'GatewayApiRequests'
        enabled: true
      }
      {
        category: 'BuiltinSqlReqsEnded'
        enabled: true
      }
      {
        category: 'IntegrationPipelineRuns'
        enabled: true
      }
      {
        category: 'IntegrationActivityRuns'
        enabled: true
      }
      {
        category: 'IntegrationTriggerRuns'
        enabled: true
      }
    ]
  }
}

// Diagnostic settings for Azure Synapse SQL Pools.
resource diagnosticSetting003 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for i in range(0, synapseSqlPoolsCount): if (processingService == 'synapse') {
  scope: synapsesqlpool[i]
  name: 'diagnostic-${synapseworkspace.name}-${synapsesqlpool[i].name}'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'SqlRequests'
        enabled: true
      }
      {
        category: 'RequestSteps'
        enabled: true
      }
      {
        category: 'ExecRequests'
        enabled: true
      }
      {
        category: 'DmsWorkers'
        enabled: true
      }
      {
        category: 'Waits'
        enabled: true
      }
    ]
  }
}]

// Diagnostic settings for Azure Syanpse Apache Spark Pools. 
resource diagnosticSetting004 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for i in range(0, synapseSparkPoolCount): if (processingService == 'synapse') {
  scope: synapsebigdatapool[i]
  name: 'diagnostic-${synapseworkspace.name}-${synapsebigdatapool[i].name}'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'BigDataPoolAppsEnded'
        enabled: true
      }
    ]
  }
}]

// Diagnostic settings for Azure SQL Server.
resource diagnosticSetting005 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for i in range(0, sqlServerDatabasesCount): if (sqlFlavour == 'mysql') {
  scope: sqlDatabases[i]
  name: 'diagnostic-${sqlDatabases[i].name}'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'SQLInsights'
        enabled: true
      }
      {
        category: 'Errors'
        enabled: true
      }
      {
        category: 'Timeouts'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Basic'
        enabled: true
      }
    ]
  }
}]

// Diagnostic settings for Azure Database for MySQL Server.
resource diagnosticSetting006 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (sqlFlavour == 'mysql') {
  scope: mySqlServer
  name: 'diagnostic-${mySqlServer.name}'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'MySqlSlowLogs'
        enabled: true
      }
      {
        category: 'MySqlAuditLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Diagnostic settings for Azure Database for MariaDB Server.
resource diagnosticSetting007 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (sqlFlavour == 'maria') {
  scope: mariaDBServer
  name: 'diagnostic-${mariaDBServer.name}'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'MySqlSlowLogs'
        enabled: true
      }
      {
        category: 'MySqlAuditLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Diagnostic settings for Azure Database for PostgreSQL.
resource diagnosticSetting008 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (sqlFlavour == 'postgre') {
  scope: postgreSQLServer
  name: 'diagnostic-${postgreSQLServer.name}'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'PostgreSQLLogs'
        enabled: true
      }
      {
        category: 'QueryStoreRuntimeStatistics'
        enabled: true
      }
      {
        category: 'QueryStoreWaitStatistics'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Diagnostic settings for Azure Cosmos DB.
resource diagnosticSetting009 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableCosmos) {
  scope: cosmosDB
  name: 'diagnostic-${cosmosDB.name}'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
      }
      {
        category: 'ControlPlaneRequests'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Requests'
        enabled: true
      }
    ]
  }
}

//Outputs
