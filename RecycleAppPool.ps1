[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$computerName,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$appPoolName
)

$session = New-PSSession $computerName

Invoke-Command -Session $session -ScriptBlock {
    param($name)
    Import-Module WebAdministration
    Restart-WebAppPool $name
    Exit-PSSession
} -ArgumentList $appPoolName

Remove-PSSession -Session $session