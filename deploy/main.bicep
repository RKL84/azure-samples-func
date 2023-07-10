@description('The name of the function app that you wish to create.')
param appName string = 'azsample0411'

@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param runtime string = 'dotnet'
param env string
param keyVaultName string
param storageAccountName string
param sharedResourceGroupName string

@description('Location for Application Insights')
param appInsightsLocation string = resourceGroup().location

@description('A unique suffix to add to resource names that need to be globally unique.')
@maxLength(13)
param resourceNameSuffix string = uniqueString(resourceGroup().id)


var appServicePlanName = '${appName}-plan'
var functionAppName = 'func-${appName}-${env}'
var functionWorkerRuntime = runtime
var applicationInsightsName = appName

var buildNumber = uniqueString(resourceGroup().id)

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName
  scope: resourceGroup(sharedResourceGroupName)
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing =  {
   name: keyVaultName
   scope: resourceGroup(sharedResourceGroupName)
}


module applicationInsights 'br:acr10072023.azurecr.io/application-insights:1.2.20230709.4' = {
  name: 'appinsightdeploy-${buildNumber}'
  params: {
    name: applicationInsightsName
    location: appInsightsLocation
  }
}

module appServicePlan 'br:acr10072023.azurecr.io/appservice-plan:1.2.20230709.1'= {
  name: 'plandeploy-${buildNumber}'
  params: {
    name: appServicePlanName
    location: location
  }
}

module functionAppModule 'br:acr10072023.azurecr.io/function-app:1.2.20230709.1' = {
  name: 'funcdeploy-${buildNumber}'
  params: {
    name: functionAppName
    location: location
    planId: appServicePlan.outputs.planId
  }
}

var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
module functionAppSettingsModule 'templates/FunctionAppSettings.bicep' = {
  name: 'siteconf-${buildNumber}'
  params: {
    applicationInsightsKey: applicationInsights.outputs.applicationInsightsKey
    // databaseConnectionString: keyVaultModule.outputs.databaseConnectionStringSecretUri
    functionAppName: functionAppModule.outputs.functionAppName
    functionAppRuntime: functionWorkerRuntime
    storageAccountConnectionString: storageAccountConnectionString
  }
}

module storageAccount_roleAssignments 'storage-account-role-assignment.bicep' = {
  name: 'data-facory-storage-account-role-assignment'
  scope: resourceGroup()
  params:{
    storageAccountName: storageAccountName
    roleId: 'Storage Account Contributor'
    principalId: functionAppModule.outputs.principalId
  }
}
