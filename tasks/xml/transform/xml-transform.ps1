[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation
try
{
    [string]$xmlFile = Get-VstsInput -Name 'xmlFile' -Require
	[string]$transformFile = Get-VstsInput -Name 'transformFile' -Require
	[string]$destinationPath = Get-VstsInput -Name 'destinationPath' -Require

	# Checks if the xml configuration file exists
	if (!$xmlFile -or !(Test-Path -path $xmlFile -PathType Leaf)) {
        throw "Could not find the xml configuration file [$xmlFile].";
	}
	
	# Checks if the transformation file exists
    if (!$transformFile -or !(Test-Path -path $transformFile -PathType Leaf)) {
        throw "Could not find transformation file [$transformFile].";
	}

	Write-Host " * XML Configuration File: $xmlFile"
	Write-Host " * Transformation File: $transformFile"
	Write-Host " * Destination Path: $destinationPath"

	# Creation of the destination directory if it does not exist
	If(!(Test-Path $destinationPath))
	{
		New-Item -ItemType Directory -Force -Path $destinationPath | Out-Null
	}
	
	# Copy the xml file to the destination directory for further processing
	Copy-Item $xmlFile -Destination $destinationPath
	
	# Retrieves the xml file information (to get file name)
	$xmlFileInfo = Get-Item $xmlFile
	
	# Concatenates the new xml file path, to be transformed
	$newXmlFile = Join-Path $destinationPath -ChildPath $xmlFileInfo.Name
	
	# Registers assembly for xml transformation
    Add-Type -LiteralPath "refs\Microsoft.Web.XmlTransform.dll"
 
	# Load the xml configuration file
    $xmlDocument = New-Object Microsoft.Web.XmlTransform.XmlTransformableDocument
    $xmlDocument.PreserveWhitespace = $true
    $xmlDocument.Load($newXmlFile)
 
	# Initializes the xml transformation object
    $transformation = New-Object Microsoft.Web.XmlTransform.XmlTransformation($transformFile)
	
	# Apply the transformation
	if ($transformation.Apply($xmlDocument) -eq $false)
    {
        throw "Transformation failure using [$xmlFile] and [$transformFile]"
	}
	
	# Saves the transformed file
	$xmlDocument.Save($newXmlFile)
	
	Write-Host "File transformation $newXmlFile successfully."
}
catch
{
	Write-Error $_
}
finally
{
    Trace-VstsLeavingInvocation $MyInvocation
}