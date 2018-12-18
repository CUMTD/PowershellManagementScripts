# PowerShell Management Scripts

Repository of custom PowerShell scripts useful for managing MTD servers.

## Notes

### Prerequisites

Most of these scripts will use
[PowerShell Remoting](https://technet.microsoft.com/en-us/library/hh849694.aspx).
You should enable it on any remote servers you plan on interacting with
by running the following command at an administrative PowerShell Command Prompt.

Scripts that interact with Office 365 must be run in [Microsoft Exchange Online PowerShell Module](https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/mfa-connect-to-exchange-online-powershell?view=exchange-ps).

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
4. Reopen PowerShell and verify that the modules are properly installed by typing running the command `Get-Command -Module MtdModules`
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

### Enable-LitigationHold

Enable litigation hold for a single user or for all users.

#### Requirements

[Microsoft Exchange Online PowerShell Module](#prerequisites)

#### Usage

For a single user

```powershell
Enable-LitigationHold -user foo@cumtd.com -username foo@cumtd.com
```

For all users

```powershell
Enable-LitigationHold -credential -username foo@cumtd.com
```

### Redo-SharedCalendarPermission

Pulls a list of all users on a shared calendar, removes them, then re-addes them.

This is a fix that Microsoft Support recomends when calendar appointments cannot be seen between users.

#### Requirements

[Microsoft Exchange Online PowerShell Module](#prerequisites)
#### Usage

```powershell
Redo-SharedCalendarPermission -mailbox largeconference@cumtd.com -username foo@cumtd.com
```

### Hide-MailboxFromGAL

Hides a mailbox from the Exchange GAL.

### Requirements

The remote server must have [PowerShell Remoting](#prerequisites) enabled.

### Usage

```powershell
Hide-MailboxFromGAL -mailboxIdentity jdoe -dc dc1.example.com
```

### Move-HomeDirectories
Move a users home directory to a new location.
In addition to moving the directory. Permissions will be set on the directory,
the share will be moved, and the users home directory in AD will be updated.

### Requirements

The remote servers must have [PowerShell Remoting](#prerequisites) enabled.

### Usage

```powershell
Move-HomeDirectories -originBaseDirectory d:\users -destinationBaseDirectory e:\active -dc mtddc1.cumtd.com -fs mtdfs1.cumtd.com -authUserName cumtd.com\foo -usersToMove user1, user2, user3

```
