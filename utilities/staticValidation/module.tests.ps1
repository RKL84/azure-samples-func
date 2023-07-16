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

Describe 'File/folder tests' -Tag 'Modules' {

    Context 'General module folder tests' {

        $moduleFolderTestCases = [System.Collections.ArrayList] @()
        foreach ($moduleFolderPath in $moduleFolderPaths) {
            $moduleFolderTestCases += @{
                moduleFolderName = $moduleFolderPath.Replace('\', '/').Split('/modules/')[1]
                moduleFolderPath = $moduleFolderPath
                isTopLevelModule = $moduleFolderPath.Replace('\', '/').Split('/modules/')[1].Split('/').Count -eq 2 # <provider>/<resourceType>
            }
        }

        It '[<moduleFolderName>] Module should contain a [` main.json ` / ` main.bicep `] file' -TestCases $moduleFolderTestCases {

            param( [string] $moduleFolderPath )

            $hasARM = Test-Path (Join-Path -Path $moduleFolderPath 'main.json')
            $hasBicep = Test-Path (Join-Path -Path $moduleFolderPath 'main.bicep')
                ($hasARM -or $hasBicep) | Should -Be $true
        }

        # It '[<moduleFolderName>] Module should contain a [` readme.md `] file' -TestCases $moduleFolderTestCases {

        #     param(
        #         [string] $moduleFolderPath
        #     )

        #     $pathExisting = Test-Path (Join-Path -Path $moduleFolderPath 'readme.md')
        #     $pathExisting | Should -Be $true
        # }

        # It '[<moduleFolderName>] Module should contain a [` .test `] folder' -TestCases ($moduleFolderTestCases | Where-Object { $_.isTopLevelModule }) {

        #     param(
        #         [string] $moduleFolderPath
        #     )

        #     $pathExisting = Test-Path (Join-Path -Path $moduleFolderPath '.test')
        #     $pathExisting | Should -Be $true
        # }

        # It '[<moduleFolderName>] Module should contain a [` version.json `] file' -TestCases $moduleFolderTestCases {

        #     param (
        #         [string] $moduleFolderPath
        #     )

        #     $pathExisting = Test-Path (Join-Path -Path $moduleFolderPath 'version.json')
        #     $pathExisting | Should -Be $true
        # }
    }
}