##############################
#   Load general functions   #
##############################
$repoRootPath = (Get-Item $PSScriptRoot).Parent.Parent.Parent.Parent.FullName

. (Join-Path $repoRootPath 'utilities' 'scripts' 'Get-ScopeOfTemplateFile.ps1')
. (Join-Path $repoRootPath 'utilities' 'scripts' 'Get-ModuleTestFileList.ps1')