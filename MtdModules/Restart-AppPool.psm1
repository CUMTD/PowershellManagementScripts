<# 
 .Synopsis
  Recycles an app pool on a remote IIS server.

 .Description
  Recycles the specified app pool on a remote IIS server

 .Parameter computerName
  The name of the IIS sever where the  app pool is running

 .Parameter appPoolName
  The name of the app pool to recycle.

 .Example
   # Recylce the app pool "default" on the computer "webserver"
   Restart-AppPool -computerName webserverdefault -appPoolName default
#>
function Restart-AppPool {
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
    
}

Export-ModuleMember Restart-AppPool
