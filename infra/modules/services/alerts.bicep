// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// This template is used to create an alert.
targetScope = 'resourceGroup'

// Parameters
param adfPipelineFailedAlertName string
param datafactoryScope string
param location string
param tags object
param processingService string
param synapsePipelineFailedAlertName string
param synapseScope string
param dataFactoryEmailActionGroup string
param dataProductTeamEmail string
param cosmosRequestLimitedAlertName string
param cosmosDBScope string
param enableCosmos bool

// Variables

// Resources
resource actiongroup 'Microsoft.Insights/actionGroups@2021-09-01' = {
  name: dataFactoryEmailActionGroup
  location: 'global'
  tags: tags
  properties: {
    groupShortName: 'emailgroup'
    emailReceivers: [
      {
        emailAddress: dataProductTeamEmail
        name: 'emailaction'
        useCommonAlertSchema: true
      }
    ]
    enabled: true
  }
}

// Alert if the Azure Data Factory pipeline failed.
resource adfPipelineFailedAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = if (processingService == 'dataFactory') {
  name: adfPipelineFailedAlertName
  location: 'global'
  tags: tags
  properties: {
    actions: [
      {
        actionGroupId: actiongroup.id
      }
    ]
    autoMitigate: false
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          threshold: 1
          name: 'Metric1'
          metricNamespace: 'Microsoft.DataFactory/factories'
          metricName: 'PipelineFailedRuns'
          operator: 'GreaterThanOrEqual'
          timeAggregation: 'Total'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    description: 'ADF pipeline failed'
    enabled: true
    evaluationFrequency: 'PT1M'
    scopes: [
      datafactoryScope
    ]
    severity: 1
    targetResourceRegion: location
    targetResourceType: 'Microsoft.DataFactory/factories'
    windowSize: 'PT5M'
  }
}

// Alert if the Azure Synapse pipeline failed.
resource synapsePipelineFailedAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = if (processingService == 'synapse') {
  name: synapsePipelineFailedAlertName
  location: 'global'
  tags: tags
  properties: {
    actions: [
      {
        actionGroupId: actiongroup.id
      }
    ]
    autoMitigate: false
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          threshold: 1
          name: 'Metric1'
          metricNamespace: 'Microsoft.Synapse/workspaces'
          metricName: 'IntegrationPipelineRunsEnded'
          operator: 'GreaterThanOrEqual'
          timeAggregation: 'Total'
          criterionType: 'StaticThresholdCriterion'
          dimensions: [
            {
              name: 'Result'
              operator: 'Include'
              values: [
                'Failed'
              ]
            }
          ]
        }
      ]
    }
    description: 'Synapse pipeline failed'
    enabled: true
    evaluationFrequency: 'PT1M'
    scopes: [
      synapseScope
    ]
    severity: 1
    targetResourceRegion: location
    targetResourceType: 'Microsoft.Synapse/workspaces'
    windowSize: 'PT5M'
  }
}

// Alert requests are rate limited and receving HTTP status code 429.
resource cosmosRequestLimitedAlert 'microsoft.insights/metricAlerts@2018-03-01' = if (enableCosmos) {
  name: cosmosRequestLimitedAlertName
  location: 'global'
  tags: tags
  properties: {
    severity: 1
    enabled: true
    scopes: [
      cosmosDBScope
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          threshold: 100
          name: 'Metric1'
          metricNamespace: 'Microsoft.DocumentDB/databaseAccounts'
          metricName: 'TotalRequestUnits'
          dimensions: [
            {
              name: 'StatusCode'
              operator: 'Include'
              values: [
                '429'
              ]
            }
          ]
          operator: 'GreaterThan'
          timeAggregation: 'Total'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    autoMitigate: false
    targetResourceType: 'Microsoft.DocumentDB/databaseAccounts'
    actions: [
      {
        actionGroupId: actiongroup.id
      }
    ]
  }
}

// Outputs
