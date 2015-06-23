[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$computerName
)

$uri = ('http://{0}:5985/wsman' -f $computerName)

$connections = Get-WSManInstance -ConnectionURI $uri -ResourceURI shell -Enumerate

$connections | ForEach-Object {
    Write-Output ("Closing shell {0}." -f $_.ShellId)
    Remove-WSManInstance -ConnectionURI $uri shell @{ ShellID=$_.ShellId }
}