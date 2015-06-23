<# 
 .Synopsis
  Kills all PSSessions for a remote computer

 .Description
  Kills all remote PSSessions for a computer regardless of the user.

 .Parameter computerName
  The name of the computer to kill connections for.

 .Example
   # Kill connections on the computer named "webserver"
   Remove-RemoteConnections -computerName webserver
#>
function Remove-RemoteConnections {
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
}

Export-ModuleMember Remove-RemoteConnections