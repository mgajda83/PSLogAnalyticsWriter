# PSLogAnalyticsWriter
A module that helps save data in Azure Log Analytics.

## Currently, the module can support both types of APIs:
- v1 - HTTP Data Collector API (deprecated). The Azure Monitor HTTP Data Collector API has been deprecated and will no longer be functional as of 9/14/2026
- v2 - Logs Ingestion API

## Logs Ingestion API Reguirments:
- Log Analytics workspace where to send events data
- Application Entra ID for authentication process
- Data collection endpoint (DCE) and data collection rules (DCR)
- Entra ID application permissions(Monitoring Metrics Publisher) for the DCR service

## Import module in specific API version
- v1
```PowerShell
Import-Module PSLogAnalyticsWriter
```
- v2
```PowerShell
Import-Module PSLogAnalyticsWriter -ArgumentList v2
```

## Example
```PowerShell
Import-Module PSMSAL
Import-Module PSLogAnalyticsWriter -ArgumentList v2

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

#Write to Log Analytics using Logs Ingestion API (v2)
$Log = @{
  AccessToken = $Token.AccessToken
  DCEUri = "https://test-data-collection-endpoint.westeurope-1.ingest.monitor.azure.com"
  DCRId = "dcr-abcdef1234567890"
  Table = "CustomLog"
  Object = $Object
}
Write-LogAnalytics @Log
```
