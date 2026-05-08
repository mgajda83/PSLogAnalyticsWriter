Param
(
	[ValidateSet('v1', 'v2')]
	$APIVersion = 'v1'
)

$APIVersions = @{
	v1 = "HTTP Data Collector API (deprecated)"
	v2 = "Logs Ingestion API"
}
Write-Host "Default API version selected: $($APIVersions[$APIVersion])" -ForegroundColor Yellow

Get-ChildItem -Path $PSScriptRoot | Unblock-File
Get-ChildItem -Path $PSScriptRoot\*.ps1 | Foreach-Object{ . $_.FullName }

if($APIVersion -eq 'v1')
{
	Set-Alias -Name Write-LogAnalytics -Value Write-LogAnalytics_v1
} else {
	Set-Alias -Name Write-LogAnalytics -Value Write-LogAnalytics_v2
}

Export-ModuleMember -Cmdlet * -Alias * -Function *
