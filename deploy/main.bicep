@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The type of environment. This must be nonprod or prod.')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

@description('Indicates whether to deploy the storage account')
param deployStorageAccount bool

@description('A unique suffix to add to resource names that need to be globally unique.')
@maxLength(13)
param resourceNameSuffix string = uniqueString(resourceGroup().id)

var appServiceAppName = 'azure-samples-${resourceNameSuffix}'
var appServicePlanName = 'azure-samples-plan'
var azureSamplesStorageAccountName = 'azuresamples${resourceNameSuffix}'

// Define the SKUs for each component based on the environment type.
var environmentConfigurationMap = {
  nonprod: {
    appServicePlan: {
      sku: {
        name: 'F1'
        capacity: 1
      }
    }
    azureSamplesStorageAccount: {
      sku: {
        name: 'Standard_LRS'
      }
    }
  }
  prod: {
    appServicePlan: {
      sku: {
        name: 'S1'
        capacity: 2
      }
    }
    azureSamplesStorageAccount: {
      sku: {
        name: 'Standard_ZRS'
      }
    }
  }
}

var azureSamplesStorageAccountConnectionString = deployStorageAccount ? 'DefaultEndpointsProtocol=https;AccountName=${azureSamplesStorageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${azureSamplesStorageAccount.listKeys().keys[0].value}' : ''

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: environmentConfigurationMap[environmentType].appServicePlan.sku
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureSamplesStorageAccountConnectionString'
          value: azureSamplesStorageAccountConnectionString
        }
      ]
    }
  }
}

resource azureSamplesStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = if (deployStorageAccount) {
  name: azureSamplesStorageAccountName
  location: location
  kind: 'StorageV2'
  sku: environmentConfigurationMap[environmentType].azureSamplesStorageAccount.sku
}
