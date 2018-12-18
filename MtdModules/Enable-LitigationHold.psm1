<# 
 .Synopsis
  Enable litigation hold for a user or for all users.

 .Description
  Enable litigation hold for a user or for all users.

 .Parameter all
  If litigation hold should be enabled for all users
  
  .Parameter user
  If all is $False, a user must be specified. Use their email address.
  
  .Parameter username
  Username of the Office 365 user.

 .Example
   # Redo permissions on the "Large Conference Room"" calendar.
   Fix-SharedCalendarPermission -mailbox largeconference@cumtd.com -username foo@cumtd.com
   Must be run in Microsoft Exchange Online Powershell Module
#>
function Enable-LitigationHold {
    [CmdletBinding()]
    Param(
        [switch]$all,
        [string]$user,
        [Parameter(Mandatory=$True)]
        [String]
        $username
    )
    
    #Setup Session
    Connect-EXOPSSession -UserPrincipalName $username
    
    # Enable hold
    # Must use the -all flag or specify a user
    if ($all.IsPresent) {
        Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize unlimited | Set-Mailbox -LitigationHoldEnabled $True
    } elseif (!([string]::IsNullOrEmpty($user))) {
        Get-Mailbox -Identity $user | Set-Mailbox -LitigationHoldEnabled $True
    } else {
        throw "Must provide a valid -user or use the -all parameter."
	}
	
	Get-PSSession | Remove-PSSession
        
}

Export-ModuleMember Enable-LitigationHold
