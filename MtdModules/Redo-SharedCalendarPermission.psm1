<# 
 .Synopsis
  Redo user permissions on a shared calendar in Office 365

 .Description
  Pulls a list of all users on a shared calendar, removes them, then re-addes them.
  This is a fix that Microsoft Support recomends when calendar appointments cannot be seen between users.

 .Parameter mailbox
  The mailbox address of the calendar to redo.

 .Parameter credential
  Credentials to pass to Office 365

 .Example
   # Redo permissions on the "Large Conference Room"" calendar.
   Fix-SharedCalendarPermission -mailbox largeconference@cumtd.com
#>
function Redo-SharedCalendarPermission {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]$mailbox
        [Parameter(Mandatory=$True)]
        [System.Management.Automation.CredentialAttribute()]
        $credential
    )
    
    #Setup Session
    $Session = Get-Office365Session -credential $credential
    Import-PSSession $Session

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
        $permission = Add-MailboxPermission -Identity $mailbox -User $Username -AccessRights FullAccess -InheritanceType All -Automapping $True
    }

    #Close Session
    Remove-PSSession $Session
    
}

Export-ModuleMember Redo-SharedCalendarPermission
