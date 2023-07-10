// storage-account-role-assignment.bicep
param storageAccountName string
param principalId string
param roleId string

// Get a reference to the storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: storageAccountName
}

// Grant permissions to the storage account
resource storageAccountAppRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' =  {
  name: guid(storageAccount.id, roleId, principalId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId: principalId
  }
}
