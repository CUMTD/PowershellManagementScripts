<# 
 .Synopsis
  Get an Office 365 session.

 .Description
  Returns as session that can be stored in a variable and imported using Import-PSSession.

  .Parameter credential
  The credential to use to log in.

  .Example
   # Get a session and store it in a $Session variable
   $Session = Get-Office365Session
#>
function Get-Office365Session {
    [CmdletBinding()]
    Param(
            [Parameter(Mandatory=$True)]
            [System.Management.Automation.CredentialAttribute()]
            $credential
        )
            
    return New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRedirection
        
}

Export-ModuleMember Get-Office365Session