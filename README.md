# PowerShell Management Scripts
Repository of custom PowerShell scripts useful for managing MTD servers.

## Notes

### Prerequisites
Most of these scripts will use
[PowerShell Remoting](https://technet.microsoft.com/en-us/library/hh849694.aspx).
You should enable it on any remote servers you plan on interacting with
by running the following command at an administrative PowerShell Command Prompt.
```powershell
Enable-PSRemoting –force
```

These scripts will require you to enable unsigned script execution. You can do so by running the following command at an administrative PowerShell Command Prompt.
```powershell
Set-ExecutionPolicy Unrestricted -Force
```

### Installing Modules

Run `Install.ps1` or follow the instructions bellow to install manually.

1. Create a directory called `C:\Users\%username%\Documents\WindowsPowerShell\Modules`
2. Open PowerShell and make sure the directory is in your path (`$env:PSModulePath`).
3. Close Powershel and copy the `MtdModules` directory into ``.
4. Reopen PowerShell and verify that the modules are properly installed by typing running the command
`Get-Command -Module MtdModules`
5. To use the modules run the command `Import-Module MtdModules`.

## Commandlets

### Remove-MtdRemoteConnections
Kills all PSSessions for a remote computer
#### Requirements
The remote server must have [PowerShell Remoting](#prerequisites) enabled.
#### Usage
```powershell
Remove-MtdRemoteConnections -computerName <COMPUTER_NAME>
```
### Restart-MtdAppPool
Recycles the app pool on a remote IIS server
#### Requirements
The remote server must have the 
[Web Server Administration Cmdlets](https://technet.microsoft.com/en-us/library/ee790599.aspx)
 installed.
 
The remote server must have [PowerShell Remoting](#prerequisites) enabled.
#### Usage
```powershell
Restart-MtdAppPool -computerName <COMPUTER_NAME> -appPoolName <APP_POOL_NAME>
```

### Import-ExchangePhoto
Imports a user photo into the Exchange Offline Address Book.
#### Requirements
The remote server must be running Exchange 2010.

The remote server must have [PowerShell Remoting](#prerequisites) enabled.
#### Usage
```powershell
Import-ExchangePhoto -userName <USER_NAME> -computerName <COMPUTER_NAME> -picturePath <LOCAL_PATH_TO_PHOTO>
```