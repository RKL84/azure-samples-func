#Requires -Version 7

param (
    [Parameter(Mandatory = $false)]
    [array] $moduleFolderPaths = ((Get-ChildItem $repoRootPath -Recurse -Directory -Force).FullName | Where-Object {
            (Get-ChildItem $_ -File -Depth 0 -Include @('main.json', 'main.bicep') -Force).Count -gt 0
        }),

    [Parameter(Mandatory = $false)]
    [string] $repoRootPath = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName,

    # Dedicated Tokens configuration hashtable containing the tokens and token prefix and suffix.
    [Parameter(Mandatory = $false)]
    [hashtable] $tokenConfiguration = @{},

    [Parameter(Mandatory = $false)]
    [bool] $AllowPreviewVersionsInAPITests = $true
)

Write-Verbose ("repoRootPath: $repoRootPath") -Verbose
Write-Verbose ("moduleFolderPaths: $($moduleFolderPaths.count)") -Verbose

$script:RGdeployment = 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
$script:Subscriptiondeployment = 'https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#'
$script:MGdeployment = 'https://schema.management.azure.com/schemas/2019-08-01/managementGroupDeploymentTemplate.json#'
$script:Tenantdeployment = 'https://schema.management.azure.com/schemas/2019-08-01/tenantDeploymentTemplate.json#'
$script:moduleFolderPaths = $moduleFolderPaths

# For runtime purposes, we cache the compiled template in a hashtable that uses a formatted relative module path as a key
$script:convertedTemplates = @{}

# Shared exception messages
$script:bicepTemplateCompilationFailedException = "Unable to compile the deploy.bicep template's content. This can happen if there is an error in the template. Please check if you can run the command ``bicep build {0} --stdout | ConvertFrom-Json -AsHashtable``." # -f $templateFilePath
$script:jsonTemplateLoadFailedException = "Unable to load the deploy.json template's content. This can happen if there is an error in the template. Please check if you can run the command `Get-Content {0} -Raw | ConvertFrom-Json -AsHashtable`." # -f $templateFilePath
$script:templateNotFoundException = 'No template file found in folder [{0}]' # -f $moduleFolderPath

# Import any helper function used in this test script
Import-Module (Join-Path $PSScriptRoot 'helper' 'helper.psm1') -Force