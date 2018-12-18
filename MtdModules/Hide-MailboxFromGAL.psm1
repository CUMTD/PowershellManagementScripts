<# 
 .Synopsis
  Hides a mailbox from the Global Address List

 .Description
  Hide a mailbox from the Global Address List (GAL).

 .Parameter mailboxIdentity
  The identity of the mailbox to hide.
    
  .Parameter domainController
  The domain controller to connect to.

 .Example
   # Hide the jdoe mailbox from the GAL.
   Hide-MailboxFromGAL -mailboxIdentity jdoe -dc dc1.example.com
#>
function Hide-MailboxFromGAL {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [string]$mailboxIdentity,
        [Parameter(Mandatory = $True)]
        [String]$domainController
    )

	$cred = Get-Credential

	$session = New-PSSession -ComputerName $domainController -Credential $cred

    Invoke-Command -Session $session -ScriptBlock {
        Param(
			[String]$mailboxIdentity
			)
			Import-Module ActiveDirectory
			$user = Get-ADUser -Identity $mailboxIdentity
			Set-ADUser -Identity $mailboxIdentity -Replace @{ mailNickname = $user.Name }
			Set-ADUser -Identity $mailboxIdentity -Replace @{ msExchHideFromAddressLists =  $true }
			Import-Module ADSync
			Start-ADSyncSyncCycle -PolicyType Delta
	} -ArgumentList $mailboxIdentity
	
	Remove-PSSession $session
        
}

Export-ModuleMember Hide-MailboxFromGAL
