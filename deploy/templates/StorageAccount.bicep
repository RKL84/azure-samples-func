@description('Storage Account name')
@minLength(3)
@maxLength(24)
param name string

@description('Storage Account location')
param location string

@description('Storage Account SKU name')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param sku string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

var accountName = storageAccount.name
var endpointSuffix = environment().suffixes.storage
var key = listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value

output storageAccountConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${accountName};EndpointSuffix=${endpointSuffix};AccountKey=${key}'
