# Define script arguments
param (
    [Parameter(Mandatory = $true)]
    [String]
    $FilePath,

    [Parameter(Position=1, ValueFromRemainingArguments)]
    $Remaining
)

# Load json file
Write-Host "Loading JSON file"
$JsonContent = Get-Content -Path $FilePath -Raw | Out-String | ConvertFrom-Json

for ($i = 0; $i -lt $Remaining.Count; $i=$i+2)
{
    Write-Host "${ParameterName}: ${ParameterValue}"
    $ParameterName = $Remaining[$i].Substring(1)
    $ParameterValue = $Remaining[$i+1]
    $JsonContent.parameters.$ParameterName.value = $ParameterValue
}

# Write json file
Write-Host "Writing JSON file"
$JsonContent | ConvertTo-Json -Depth 64 | Set-Content $FilePath
