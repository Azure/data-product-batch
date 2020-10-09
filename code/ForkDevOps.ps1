param (
    [Parameter(Mandatory = $true)]
    [String]
    $OrgName,

    [Parameter(Mandatory = $true)]
    [String]
    $SourceProjectName,

    [Parameter(Mandatory = $true)]
    [String]
    $SourceRepositoryName,

    [Parameter(Mandatory = $true)]
    [String]
    $DestinationProjectName,

    [Parameter(Mandatory = $true)]
    [String]
    $DestinationRepositoryName,

    [Parameter(Mandatory = $true)]
    [String]
    $PatToken,

    [Parameter(Position = 1, ValueFromRemainingArguments)]
    $Remaining
)

function Invoke-DevOpsApiRequest {
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $PatToken,

        [Parameter(Mandatory = $true)]
        [String]
        $RestMethod,

        [Parameter(Mandatory = $true)]
        [String]
        $UriExtension,

        [Parameter(Mandatory = $true)]
        [String]
        $Body
    )
    # Defining authentitaction header
    Write-Verbose "Defining authentication header"
    $authenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PatToken)")) }

    # Define base uri
    Write-Verbose "Defining base uri"
    $baseUri = "https://dev.azure.com/"
    $basePparameters = "api-version=6.0"

    # Create uri
    Write-Verbose "Creating uri"
    $parameters = "${basePparameters}"
    $uri = "${baseUri}${UriExtension}?${parameters}"
    Write-Host $uri

    # Call REST API
    Write-Verbose "Calling REST API"
    $result = Invoke-RestMethod -Uri $uri -Method $RestMethod -Headers $authenicationHeader -Body $Body -ContentType "application/json"
    return $result
}


function Get-ProjectId {
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $ProjectName,

        [Parameter(Mandatory = $true)]
        [String]
        $PatToken,

        [Parameter(Mandatory = $true)]
        [String]
        $OrgName
    )
    # Define uri extension
    Write-Verbose "Defining uri extension"
    $uriExtension = "${OrgName}/_apis/projects"

    # Define body
    Write-Verbose "Defining body"
    $body = @{} | ConvertTo-Json -Depth 5

    # Call rest api
    Write-Verbose "Calling REST API"
    $result = Invoke-DevOpsApiRequest -PatToken $PatToken -RestMethod Get -UriExtension $uriExtension -Body $body

    # Iterate through projects and return id
    Write-Verbose "Iterating through projects and returning id"
    foreach ($project in $result.value) {
        if ($project.name -eq $ProjectName) {
            return $project.id
        }
    }
}


function Get-RepositoryId {
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $RepositoryName,

        [Parameter(Mandatory = $true)]
        [String]
        $ProjectId,

        [Parameter(Mandatory = $true)]
        [String]
        $PatToken,

        [Parameter(Mandatory = $true)]
        [String]
        $OrgName
    )
    # Define uri extension
    Write-Verbose "Defining uri extension"
    $uriExtension = "${OrgName}/${ProjectId}/_apis/git/repositories"

    # Define body
    Write-Verbose "Defining body"
    $body = @{} | ConvertTo-Json -Depth 5

    # Call rest api
    Write-Verbose "Calling REST API"
    $result = Invoke-DevOpsApiRequest -PatToken $PatToken -RestMethod Get -UriExtension $uriExtension -Body $body

    # Iterate through repositories and return id
    Write-Verbose "Iterating through repositories and returning id"
    foreach ($repository in $result.value) {
        if ($repository.name -eq $RepositoryName) {
            return $repository.id
        }
    }
}

function Add-Fork {
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $SourceRepositoryId,

        [Parameter(Mandatory = $true)]
        [String]
        $SourceProjectId,

        [Parameter(Mandatory = $true)]
        [String]
        $DestinationRepositoryName,

        [Parameter(Mandatory = $true)]
        [String]
        $DestinationProjectId,

        [Parameter(Mandatory = $true)]
        [String]
        $PatToken,

        [Parameter(Mandatory = $true)]
        [String]
        $OrgName
    )
    # Define uri extension
    Write-Verbose "Defining uri extension"
    $uriExtension = "${OrgName}/_apis/git/repositories"

    # Define body
    Write-Verbose "Defining body"
    $body = @{
        "name" = $DestinationRepositoryName
        "project" = @{
            "id" = $DestinationProjectId
        }
        "parentRepository" = @{
            "id" = $SourceRepositoryId
            "project" = @{
                "id" = $SourceProjectId
            }
        }
    } | ConvertTo-Json -Depth 5

    # Call rest api
    Write-Verbose "Calling REST API"
    $result = Invoke-DevOpsApiRequest -PatToken $PatToken -RestMethod Post -UriExtension $uriExtension -Body $body
    return $result
}

# Get project and repository id's
Write-Verbose "Getting project and repository id's"
$sourceProjectId = Get-ProjectId -ProjectName $SourceProjectName -PatToken $PatToken -OrgName $OrgName
$destinationProjectId = Get-ProjectId -ProjectName $DestinationProjectName -PatToken $PatToken -OrgName $OrgName
$sourceRepositoryId = Get-RepositoryId -RepositoryName $SourceRepositoryName -ProjectId $sourceProjectId -PatToken $PatToken -OrgName $OrgName

# Fork repository
Write-Verbose "Forking repository"
$result = Add-Fork -SourceRepositoryId $repositoryId -SourceProjectId $projectId -DestinationProjectId $projectId -DestinationRepositoryName "fork-test001" -PatToken $PatToken -OrgName $OrgName
Write-Verbose $result
