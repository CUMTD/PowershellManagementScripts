# PowershellManagementScripts
Repository of custom Powershell scripts useful for managing MTD servers.

##Notes
Most of these scripts will use [Powershell Remoting](https://technet.microsoft.com/en-us/library/hh849694.aspx). You should be able to enable it on a server by running the following command at an administrative Powershell Command Prompt.
```powershell
Enable-PSRemoting –force
```

These scripts will require you to enable unsigned script execution. You can do so by running the following command at an administrative Powershell Command Prompt.
```powershell
Set-ExecutionPolicy Unrestricted -Force
```

##Scripts

### Kill-RemoteConnections
Kills all PSSessions for a remote computer
#### Usage
```powershell
Kill-RemoteConnections.ps1 -computerName <COMPUTER_NAME>
```

### Recycle-AppPool
Recycles the app pool on a remote IIS server
#### Requirements
The remote server must have the [Web Server Administration Cmdlets](https://technet.microsoft.com/en-us/library/ee790599.aspx) powershell cmdlets installed.
The remote server must have [Powershell Remoting](##Notes) enabled.
#### Usage
```powershell
Recycle-AppPool.ps1 -computerName <COMPUTER_NAME> -$appPoolName <APP_POOL_NAME>
```