@description('The name of the function app that you wish to create.')
param appName string = 'azsample0411'

@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
  'dotnet-isolated'
])
param runtime string = 'dotnet-isolated'
param env string
param keyVaultName string
param storageAccountName string
param logAnalyticsWorkspaceName string
param sharedResourceGroupName string

@description('Location for Application Insights')
param appInsightsLocation string = resourceGroup().location

@description('A unique suffix to add to resource names that need to be globally unique.')
@maxLength(13)
param resourceNameSuffix string = uniqueString(resourceGroup().id)

var appServicePlanName = 'asp-${appName}-${resourceNameSuffix}-${env}'
var applicationInsightsName = 'ain-${appName}-${resourceNameSuffix}-${env}'
var functionAppName = 'func-${appName}-${resourceNameSuffix}-${env}'
var functionWorkerRuntime = runtime
var buildNumber = uniqueString(resourceGroup().id)

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' existing =  {
  name: appServicePlanName
  scope: resourceGroup(sharedResourceGroupName)
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName
  scope: resourceGroup(sharedResourceGroupName)
}
var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing =  {
   name: keyVaultName
   scope: resourceGroup(sharedResourceGroupName)
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(sharedResourceGroupName)
}

module applicationInsights 'br:acrshr0411.azurecr.io/bicep/modules/microsoft.insights.components:latest' = {
  name: 'appinsightdeploy-${buildNumber}'
  params: {
    name: applicationInsightsName
    location: appInsightsLocation
    workspaceResourceId: logAnalytics.id
  }
}

module functionAppModule 'br:acrshr0411.azurecr.io/bicep/modules/microsoft.web.sites:latest' = {
  name: 'fapp-${buildNumber}'
  params: {
    // Required parameters
    kind: 'functionapp'
    systemAssignedIdentity: true
    name: functionAppName
    location: location
    serverFarmResourceId: appServicePlan.id
    storageAccountId: storageAccount.id
    appInsightId: applicationInsights.outputs.resourceId
    diagnosticWorkspaceId: logAnalytics.id
    appSettingsKeyValuePairs: {
      AzureFunctionsJobHost__logging__logLevel__default: 'Trace'
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: functionWorkerRuntime
      storageAccountConnectionString: storageAccountConnectionString
      keyVaultUri: keyVault.properties.vaultUri
    }
    // siteConfig: {
    //   alwaysOn: true
    // }
  }
}

module storageAccount_roleAssignments 'br:acrshr0411.azurecr.io/bicep/modules/microsoft.storage.storageaccounts.roleassignments:latest' = {
  name: 'storageAccount_roleAssignments-${buildNumber}'
  scope: resourceGroup(sharedResourceGroupName)
  params:{
    resourceId: storageAccount.id
    roleAssignments: [
        {
            roleDefinitionIdOrName: 'Storage Account Contributor'
            description: 'Storage Account Contributor'
            principalIds: [
              functionAppModule.outputs.systemAssignedPrincipalId
            ]
        }
    ]
  }
}

module keyVault_roleAssignments 'br:acrshr0411.azurecr.io/bicep/modules/microsoft.keyvault.vaults.roleassignments:latest' = {
  name: 'keyVault_roleAssignments-${buildNumber}'
  scope: resourceGroup(sharedResourceGroupName)
  params:{
    resourceId: keyVault.id
    roleAssignments: [
        {
            roleDefinitionIdOrName: 'Key Vault Secrets User'
            description: 'Key Vault Secrets User'
            principalIds: [
              functionAppModule.outputs.systemAssignedPrincipalId
            ]
        }
    ]
  }
}
