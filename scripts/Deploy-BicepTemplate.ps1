param(
 $ResourceGroupName,
 $Location,
 $TemplateFile,
 $TemplateParametersFile
)

# $resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
# if(-Not $resourceGroup){
# }

$DeploymentName  =(([io.path]::GetFileNameWithoutExtension($TemplateFile)) + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm'))

New-AzResourceGroupDeployment `
  -Name $DeploymentName `
  -ResourceGroupName $ResourceGroupName `
  -TemplateFile $TemplateFile
  -TemplateParametersFile $TemplateParametersFile
 
