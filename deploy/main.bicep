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

@description('A unique suffix to add to resource names that need to be globally unique.')
@maxLength(13)
param resourceNameSuffix string = uniqueString(resourceGroup().id)


var appServicePlanName = '${appName}-plan'
var storageAccountName = 'st${appName}${env}'
var keyVaultName = take('kv-shared-${env}-${resourceNameSuffix}',24)
var functionAppName = 'func-${appName}-${env}'
var functionWorkerRuntime = runtime
var applicationInsightsName = appName

var buildNumber = uniqueString(resourceGroup().id)

module storageAccount 'br:acr10072023.azurecr.io/storage-account:1.2.20230709.1' = {
  name: 'stvmdeploy-${buildNumber}'
  params: {
    name: storageAccountName
    sku: storageAccountType
    location: location
  }
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

module keyVaultModule 'br:acr10072023.azurecr.io/key-vault:1.2.20230709.1' = {
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
    applicationInsightsKey: applicationInsights.outputs.applicationInsightsKey
    // databaseConnectionString: keyVaultModule.outputs.databaseConnectionStringSecretUri
    functionAppName: functionAppModule.outputs.functionAppName
    functionAppRuntime: functionWorkerRuntime
    storageAccountConnectionString: storageAccount.outputs.storageAccountConnectionString
  }
}
