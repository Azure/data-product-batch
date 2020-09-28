# Define script arguments
param (
    [Parameter(Mandatory = $true)]
    [String]
    $FilePath,

    [Parameter(Position=1, ValueFromRemainingArguments)]
    $Remaining
)

# Install YAML pwsh module
Install-Module -Name powershell-yaml -AcceptLicense
Import-Module powershell-yaml

# Load json file
Write-Host "Loading YAML file"
$YamlContent = Get-Content -Path $FilePath -Raw | Out-String | ConvertFrom-Yaml -Ordered

for ($i = 0; $i -lt $Remaining.Count; $i=$i+2)
{
    Write-Host "${ParameterName}: ${ParameterValue}"
    $ParameterName = $Remaining[$i].Substring(1)
    $ParameterValue = $Remaining[$i+1]
    $YamlContent.variables[$ParameterName] = $ParameterValue
}

# Write json file
Write-Host "Writing YAML file"
$YamlContent | ConvertTo-Yaml | Set-Content $FilePath
