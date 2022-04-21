// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// This template is used to create a Log Analytics workspace.
targetScope = 'resourceGroup'

// Parameters
param location string
param tags object
param processingService string
param logAnalyticsName string
param sqlFlavour string

// Variables
var dataFactoryAnalyticsName = 'AzureDataFactoryAnalytics(${logAnalyticsName})'
var sqlAnalyticsName = 'AzureSQLAnalytics(${logAnalyticsName})'

// Resources
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    features: {}
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: 120
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource dataFactoryAnalytics 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (processingService == 'dataFactory') {
  name: dataFactoryAnalyticsName
  location: location
  tags: tags
  plan: {
    name: dataFactoryAnalyticsName
    product: 'OMSGallery/AzureDataFactoryAnalytics'
    promotionCode: ''
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: logAnalytics.id
  }
}


resource sqlAnalytics 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (sqlFlavour == 'sql') {
  name: sqlAnalyticsName
  location: location
  tags: tags
  plan: {
    name: sqlAnalyticsName
    product: 'OMSGallery/AzureSQLAnalytics'
    promotionCode: ''
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: logAnalytics.id
  }
}

// Outputs
output logAnalyticsWorkspaceId string = logAnalytics.id
output logAnalyticsWorkspaceName string = logAnalytics.name
