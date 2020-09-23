# Define script arguments
param (
    [Parameter(Mandatory = $true)]
    [String[]]
    $FilePaths,

    [Parameter(Mandatory = $true)]
    [String]
    $ParameterName,

    [Parameter(Mandatory = $true)]
    [SecureString]
    $ParameterValue
)

foreach ($FilePath in $FilePaths) {
    $JsonContent = Get-Content -Path $FilePath -Raw | Out-String | ConvertFrom-Json
    $JsonContent.parameters.$ParameterName.value = $ParameterValue
    $JsonContent | ConvertTo-Json -Depth 32| Set-Content $FilePath
}
