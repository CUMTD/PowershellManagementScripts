<# 
 .Synopsis
  Enable litigation hold for a user or for all users.

 .Description
  Enable litigation hold for a user or for all users.

 .Parameter all
  If litigation hold should be enabled for all users
  
  .Parameter user
  If all is $False, a user must be specified. Use their email address.
  
  .Parameter credential
  Credentials to pass to Office 365

 .Example
   # Redo permissions on the "Large Conference Room"" calendar.
   Fix-SharedCalendarPermission -mailbox largeconference@cumtd.com
#>
function Enable-LitigationHold {
    [CmdletBinding()]
    Param(
        [switch]$all,
        [string]$user,
        [Parameter(Mandatory=$True)]
        [System.Management.Automation.CredentialAttribute()]
        $credential
    )
    
    #Setup Session
    $Session = Get-Office365Session -credential $credential
    Import-PSSession $Session
    
    # Enable hold
    # Must use the -all flag or specify a user
    if ($all.IsPresent) {
        Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize unlimited | Set-Mailbox -LitigationHoldEnabled $True
    } elseif (!([string]::IsNullOrEmpty($user))) {
        Get-Mailbox -Identity $user | Set-Mailbox -LitigationHoldEnabled $True
    } else {
        throw "Must provide a valid -user or use the -all parameter."
    }
    
    #Close Session
    Remove-PSSession $Session
    
}

Export-ModuleMember Enable-LitigationHold
