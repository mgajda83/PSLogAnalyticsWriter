Function Write-LogAnalytics_v2
{
	<#
	.SYNOPSIS
		Write object to LogAnalytics workspace using Logs Ingestion API.

	.PARAMETER AccessToken
		AccessToken for authorization header.

	.PARAMETER DCEUri
		Data collection endpoint logs ingestion Url.

	.PARAMETER DCRId
		Data collection rule id	(immutableId)

	.PARAMETER Table
		Custom table name in LogAnalytics workspace.

	.PARAMETER Object
		PowerShell object to write to LogAnalytics workspace.

	.EXAMPLE
		#Get token
		$Params = @{
			Scopes = 'https://monitor.azure.com/.default'
			Secret = $Secret
			TenantId = $TenantId
			ClientId = $ApplicationId
			AzureCloudInstance = "AzurePublic"
		}
		$Token = Get-PSMSALToken @Params

		#Create object to send
		$Object = [PSCustomObject]@{
			Requester    = $env:USERNAME
			ComputerName = $env:COMPUTERNAME
			Id           = (New-Guid).Guid
			Message      = "Custom Message"
		}

		#Write to Log Analytics
		$Log = @{
			AccessToken = $Token.AccessToken
			DCEUri = "https://test-data-collection-endpoint.westeurope-1.ingest.monitor.azure.com"
			DCRId = "dcr-abcdef1234567890"
			Table = "CustomLog"
			Object = $Object
		}
		Write-LogAnalytics @Log

	.NOTES
		Author: Michal Gajda
	#>
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$AccessToken,
		[Parameter(Mandatory=$true)][String]$DCEUri,
		[Parameter(Mandatory=$true)][String]$DCRId,
		[Parameter(Mandatory=$true)][String]$Table,
		[Parameter(Mandatory=$true)]$Object
	)

	#Create Authorization headers
	$Headers = @{
		Authorization = "Bearer $AccessToken"
		"Content-Type" = "application/json"
	}

	#Convert Object to JSON Array
	if($Host.Version -gt [Version]"7.2")
	{
		Write-Verbose "Converting object to JSON using -AsArray parameter."
		$Body = $Object | ConvertTo-Json -Depth 5 -Compress -AsArray
	} else {
		#Fix for PS5.1
		if($Object -is [System.Array])
		{
			Write-Verbose "The object is an array."
			$Body = $Object | ConvertTo-Json -Depth 5 -Compress
		} else {
			Write-Verbose "The object is not an array. Manual converting to JSON array."
			$Body = "[" + $($Object | ConvertTo-Json -Depth 5 -Compress) + "]"
		}
	}

	#Write to Log Analytics
	$Uri = "$($DCEUri)/dataCollectionRules/$($DCRId)/streams/Custom-$($Table)?api-version=2023-01-01"
	Write-Verbose "URI: $Uri"
	Write-Verbose "Body: $Body"

	Invoke-RestMethod -Uri $Uri -Method POST -Body $Body -Headers $Headers
}
