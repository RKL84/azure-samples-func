##############################
#   Load general functions   #
##############################
$repoRootPath = (Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName

. (Join-Path $repoRootPath 'utilities' 'scripts' 'Get-ScopeOfTemplateFile.ps1')