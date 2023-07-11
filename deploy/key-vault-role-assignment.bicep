// key-vault-role-assignment.bicep
param keyVaultName string
param principalId string
param roleId string

// Get a reference to the storage account
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

// Grant permissions to the storage account
resource keyVaultAppRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' =  {
  name: guid(keyVault.id, roleId, principalId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId: principalId
  }
}
