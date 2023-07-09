@description('The name of the function app that you wish to create.')
param appName string = 'fnapp'

@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param runtime string = 'dotnet'
param env string

@description('Location for Application Insights')
param appInsightsLocation string = resourceGroup().location

// @description('A unique suffix to add to resource names that need to be globally unique.')
// @maxLength(13)
// param resourceNameSuffix string = uniqueString(resourceGroup().id)


var appServicePlanName = '${appName}-plan'
var storageAccountName = 'st${appName}${env}'
var keyVaultName = 'kv-shared-${env}'
var functionAppName = 'func-${appName}-${env}'
var functionWorkerRuntime = runtime
var applicationInsightsName = appName

var buildNumber = uniqueString(resourceGroup().id)

module storageAccount 'templates/StorageAccount.bicep' = {
  name: 'stvmdeploy-${buildNumber}'
  params: {
    name: storageAccountName
    sku: storageAccountType
    location: location
  }
}

module applicationInsightsModule 'templates/ApplicationInsights.bicep' = {
  name: 'appinsightdeploy-${buildNumber}'
  params: {
    name: applicationInsightsName
    location: appInsightsLocation
  }
}

module appServicePlan 'templates/AppServicePlan.bicep'= {
  name: 'plandeploy-${buildNumber}'
  params: {
    name: appServicePlanName
    location: location
  }
}

module functionAppModule 'templates/FunctionApp.bicep' = {
  name: 'funcdeploy-${buildNumber}'
  params: {
    name: functionAppName
    location: location
    planId: appServicePlan.outputs.planId
  }
}

module keyVaultModule 'templates/KeyVault.bicep' = {
  name: 'kvdeploy-${buildNumber}'
  params: {
    name: keyVaultName
    location: location
    sku: 'standard'
    funcTenantId: functionAppModule.outputs.tenantId
    funcPrincipalId: functionAppModule.outputs.principalId
  }
}

module functionAppSettingsModule 'templates/FunctionAppSettings.bicep' = {
  name: 'siteconf-${buildNumber}'
  params: {
    applicationInsightsKey: applicationInsightsModule.outputs.applicationInsightsKey
    // databaseConnectionString: keyVaultModule.outputs.databaseConnectionStringSecretUri
    functionAppName: functionAppModule.outputs.functionAppName
    functionAppRuntime: functionWorkerRuntime
    storageAccountConnectionString: storageAccount.outputs.storageAccountConnectionString
  }
}
