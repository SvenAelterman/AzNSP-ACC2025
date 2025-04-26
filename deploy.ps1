<#
.SYNOPSIS
    Deploy a sample Network Security Perimeter implementation.

.PARAMETER Demo
    The name of a bicepparam file in the .params directory. The file must exist and be a valid Bicep parameters file for this main.bicep.

.PARAMETER TargetSubscriptionId
    The subscription ID to deploy the resources to. The subscription must already exist.

.PARAMETER Location
    The Azure region to deploy the resources to.
#>

#Requires -Version 7.5
#Requires -Modules "Az.Resources"
#Requires -PSEdition Core

[CmdletBinding()]
param (
    [Parameter(Mandatory, Position = 0)]
    [string]$Demo,
    [Parameter(Mandatory, Position = 1)]
    [string]$TargetSubscriptionId,
    [Parameter(Position = 2)]
    [string]$Location = 'canadacentral',
    [Parameter(Position = 3)]
    [string]$Environment = 'AzureCloud'
)

[string]$TemplateParameterFile = "./.params/$Demo.bicepparam"

Write-Verbose "Using template parameter file '$TemplateParameterFile'"
[string]$TemplateParameterJsonFile = [System.IO.Path]::ChangeExtension($TemplateParameterFile, 'json')
bicep build-params $TemplateParameterFile --outfile $TemplateParameterJsonFile

# Retrieve current IP
[string]$CurrentIp = "$(Invoke-WebRequest -Uri 'https://api.ipify.org?format=json' -UseBasicParsing | ConvertFrom-Json | Select-Object -ExpandProperty ip)/32"
Write-Verbose "Current IP: $CurrentIp"

# Define common parameters for the New-AzDeployment cmdlet
[hashtable]$CmdLetParameters = @{
    TemplateFile            = './main.bicep'
    TemplateParameterFile   = $TemplateParameterJsonFile
    Location                = $Location
    allowInboundIpAddresses = @($CurrentIp)
}

# Read the values from the parameters file, to use when generating the $DeploymentName value
$ParameterFileContents = (Get-Content $TemplateParameterJsonFile | ConvertFrom-Json)
$WorkloadName = $ParameterFileContents.parameters.workloadName.value

Select-AzSubscription -SubscriptionId $TargetSubscriptionId | Out-Null

[string]$DeploymentName = "$WorkloadName-$(Get-Date -Format 'yyyyMMddThhmmssZ' -AsUTC)"
$CmdLetParameters.Add('Name', $DeploymentName)

Write-Verbose "Starting deployment '$DeploymentName' to subscription '$TargetSubscriptionId' in location '$Location'"
$DeploymentResults = New-AzDeployment @CmdLetParameters

if ($DeploymentResults.ProvisioningState -eq 'Succeeded') {
    Write-Host "🔥 Deployment successful!"

    $DeploymentResult.Outputs | Format-Table -Property Key, @{Name = 'Value'; Expression = { $_.Value.Value } }

    Remove-Item $TemplateParameterJsonFile -Force -ErrorAction SilentlyContinue
}
else {
    $DeploymentResults
}
