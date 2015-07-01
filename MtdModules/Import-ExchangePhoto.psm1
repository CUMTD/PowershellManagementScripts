<# 
 .Synopsis
  Import a user photo into Exchange Address Book

 .Description
  Import a user photo into Exchange Address Book. Photo must be < 10MB.

  .Parameter computerName
  The name of the exchange server to import the picture on.

  .Parameter userName
  The username of the user who's photo should be imported.'

  .Parameter picturePath
  The path to the photo to import.

 .Example
   # Import a picture on a mailserver name "mail"
   Import-ExchangePhoto -computerName mail -userName jdoe -picturePath "C:\jdoe.jpg"
#>
function Import-ExchangePhoto {
	[CmdletBinding()]
	Param(
		[string]$computerName,
		[string]$userName,
		[string]$picturePath
	)
	
	# show a file picker if we don't specify a path
	if (!$picturePath) {
		[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
		$dialog = New-Object System.Windows.Forms.OpenFileDialog
		$dialog = New-Object System.Windows.Forms.OpenFileDialog
		$dialog.DefaultExt = '.jpeg'
		$dialog.Filter = 'jpg files|*.jpg|jpeg files|*.jpeg|all files|*.*';
		$dialog.FilterIndex = 0
		$dialog.InitialDirectory = $home
		$dialog.Multiselect = $false
		$dialog.RestoreDirectory = $true
		$dialog.Title = "Select a JEPG file (< 10MB)"
		$dialog.ValidateNames = $true
		$dialog.ShowHelp = $true
		$dialog.ShowDialog()
		$picturePath = $dialog.FileName
	}
	
	$fileData = ([Byte[]](Get-Content -Path $picturePath -Encoding Byte -ReadCount 0))
	$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri ("http://{0}/PowerShell/" -f $computerName) -Authentication Kerberos
  
	Invoke-Command -Session $session -ScriptBlock {
		Param(
			[string]$user,
			[Byte[]]$image
		)

		Import-RecipientDataProperty -Identity $user -Picture -FileData $image
		Exit-PSSession

	} -ArgumentList $userName, $fileData
    
	Remove-PSSession -Session $session  

}

Export-ModuleMember Import-ExchangePhoto