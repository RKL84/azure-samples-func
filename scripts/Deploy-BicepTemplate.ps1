param(
 $ResourceGroupName,
 $Location,
 $TemplateFile,
 $TemplateParameterFile
)


$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if(-Not $resourceGroup){

# $updateDate = get-Date -Format "yyyy-MM-dd HH:mm:ss K"
# }