<# 
 .Synopsis
  Redo user permissions on a shared calendar in Office 365

 .Description
  Pulls a list of all users on a shared calendar, removes them, then re-addes them.
  This is a fix that Microsoft Support recomends when calendar appointments cannot be seen between users.
  Must be run in Microsoft Exchange Online Powershell Module

 .Parameter mailbox
  The mailbox address of the calendar to redo.

 .Parameter username
  Username of the Office 365 user.

 .Example
   # Redo permissions on the "Large Conference Room"" calendar.
   Redo-SharedCalendarPermission -mailbox largeconference@cumtd.com -username foo@cumtd.com
#>
function Redo-SharedCalendarPermission {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [string]$mailbox,
        [Parameter(Mandatory = $True)]
        [String]
        $username
    )
    
    #Setup Session
    Connect-EXOPSSession -UserPrincipalName $username

    #Get all users with @ in name (email address)
    $Usernames = Get-MailboxPermission -Identity $mailbox | Where-Object {$_.User -like '*@*'} | Select -ExpandProperty User

    #Remove All Permissons
    $AccessRights = "FullAccess", "SendAs", "ExternalAccount", "DeleteItem", "ReadPermission", "ChangePermission", "ChangeOwner"
    ForEach ($Username in $Usernames) {
        Write-Output "Removing permissions for $Username on mailbox $mailbox"
        Remove-MailboxPermission -Identity $mailbox -User $Username -AccessRights $AccessRights -InheritanceType All -Confirm:$False
    }

    # Add FullAccess Permission
    ForEach ($Username in $Usernames) {
        Write-Output "Adding permissions for $Username on mailbox $mailbox"
        Add-MailboxPermission -Identity $mailbox -User $Username -AccessRights FullAccess -InheritanceType All -Automapping $True | Out-Null
    }	
	
    Get-PSSession | Remove-PSSession

}

Export-ModuleMember Redo-SharedCalendarPermission
