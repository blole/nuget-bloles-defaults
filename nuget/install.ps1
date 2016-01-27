param($installPath, $toolsPath, $package, $project)
. $toolsPath\funcs.ps1

$projectName = $project.Name
$projectFullName = $project.FullName
$projectDir = $project.Properties.Item("ProjectDirectory").Value
$propertySheetRelPath = Relative-Path $projectDir "$toolsPath\bloles-defaults.props"


Select-Project $projectName
$dte.ExecuteCommand("Project.UnloadProject")
$projectMSBuild = [Microsoft.Build.Construction.ProjectRootElement]::Open($projectFullName)



# The goal is to add something like this to the projects' .vcxproj:
#
# <ImportGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'" Label="PropertySheets">
#+  <Import Project="..\packages\package.x.y.z\tools\sheet.props" Condition="exists('..\packages\package.x.y.z\tools\sheet.props')" />
#   ...
# </ImportGroup>

foreach ($propertySheetGroup in $projectMSBuild.ImportGroups | where {$_.Label -eq "PropertySheets"})
{
	$import = $projectMSBuild.CreateImportElement($propertySheetRelPath);
	$import.Condition = "exists('"+$propertySheetRelPath+"')"
	$propertySheetGroup.AppendChild($import)
}



$projectMSBuild.Save()
Select-Project $projectName
$dte.ExecuteCommand("Project.ReloadProject")
