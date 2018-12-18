function Copy-UserDirectory {
	param ([String]$userName,
	[String]$originBaseDirectory,
	[String]$destinationBaseDirectory)
    
    $baseUserPath = "$($originBaseDirectory)\$($userName)"
    $documentsPath = "$($baseUserPath)\Documents"
    $copyFrom = $baseUserPath

    if (Test-Path $documentsPath) {
        Write-Host "$($documentsPath) already exists"
        $copyFrom = $documentsPath
    }
    else {
        Write-Host "$($documentsPath) does not yet exist"
    }

    $toBase = "$($destinationBaseDirectory)\$($userName)"
	$toPath = "$($toBase)\Documents"

    # copy the users directory
    Copy-Item -Path $copyFrom -Destination $toPath -Recurse

    return $toBase
}

function Set-Access {
    param ([String]$Path, [String]$userName, [Security.AccessControl.FileSystemAccessRule[]] $globalAccessRules)

    $domainIdentity = "CUMTD\$($userName)"
    $userAccessRule = New-Object Security.AccessControl.FileSystemAccessRule($domainIdentity, "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")

    # ACCESS
   
    # get the current ACL from the users folder
    $acl = Get-Acl -Path $Path

    # disable inheritance
    $acl.SetAccessRuleProtection($true, $false)

    # remove all old access rules
    $acl.Access | ForEach-Object {$acl.RemoveAccessRule($_)}
    
    #add access rules
    $globalAccessRules | ForEach-Object { $acl.AddAccessRule($_) }
    $acl.AddAccessRule($userAccessRule)

    #set owner to the current user
    $owner = New-Object System.Security.Principal.NTAccount($domainIdentity)
    $acl.SetOwner($owner)
    
    #apply the access rule to the users folder
    Set-Acl -Path $Path -AclObject $acl

}

function Remove-OldShare {
    param ([String]$userName)
    $shareName = "$($userName)$"
    Remove-SmbShare $shareName -Force
}

function Add-NewShare {
	param (
		[String]$userName,
		[String]$destinationBaseDirectory
	)
    $name = "$($userName)$"
    $path = "$($destinationBaseDirectory)\$($userName)"
    $description = "User share for $($userName)"
    New-SmbShare -Name $name -Path $path -Description $description -ChangeAccess "Everyone"
}

function Set-HomeDirectory {
    param ([String]$userName, [String]$DC, [String]$FS, [String]$authUserName, [SecureString]$authPassword)

    # create a new credential each time so we don't time out
    $cred = New-Object -TypeName System.Management.Automation.PSCredential($authUserName, $authPassword)

    # connect to the DC and import AD modules
	$session = New-PSSession -ComputerName $DC -Credential $cred
	Invoke-Command -Session $session {
		param(
			[String]$FS,
			[String]$userName
		)
		Import-Module ActiveDirectory
		$user = Get-ADUser -Identity $userName
		# Make sure home directory is set to documents
		Set-ADUser $user -HomeDirectory "\\$($FS)\$($userName)$\Documents" -HomeDrive U:
	} -ArgumentList $FS, $userName

    #close the session
    Remove-PSSession $session
}

<#
.Synopsis
Move a users home directory to a new location.
.Description
In addition to moving the directory. Permissions will be set on the directory, the share will be moved, and the users home directory in AD will be updated.
.Parameter originBaseDirectory
The base directory where user directories are currently kept  
.Parameter destinationBaseDirectory
The base directory that user directoires should be moved to
.Parameter dc
The FQDN of the domain controller
.Parameter fs
The FQDN of the file server
.Parameter authUserName
Username with which to authenticate to AD
.Parameter usersToMove
An array of usernames to move
.Example
# Move tech servers staff
Move-HomeDirectories -originBaseDirectory d:\users -destinationBaseDirectory e:\active -dc mtddc1.cumtd.com -fs mtdfs1.cumtd.com -authUserName cumtd.com\adminblackman -usersToMove rblackman, jfenelon, dorr, bcronk
#>
function Move-HomeDirectories {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$originBaseDirectory,
        [Parameter(Mandatory = $True)]
        [String]$destinationBaseDirectory,
        [Parameter(Mandatory = $True)]
        [String]$dc,
        [Parameter(Mandatory = $True)]
        [String]$fs,
        [Parameter(Mandatory = $True)]
        [String]$authUserName,
        [Parameter(Mandatory = $True, ValueFromRemainingArguments=$True)]
        [String[]]$usersToMove
    )
		
	$authPassword = Read-Host -Prompt "Password for '$($authUserName)'" -AsSecureString

    # give full control to SYSTEM, Administrators, and Domain Admins
    # we will reuse these for each directory
    $systemAccessRule = New-Object Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $administratorsAccessRule = New-Object Security.AccessControl.FileSystemAccessRule("Administrators", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $domainAdminAccessRule = New-Object Security.AccessControl.FileSystemAccessRule("CUMTD\Domain Admins", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
	
    $globalAccessRules = $systemAccessRule, $administratorsAccessRule, $domainAdminAccessRule
		
	$i = 0
	$count = $usersToMove.Count
    foreach($userName in $usersToMove) {
		$i = $i + 1

        # progress bar
        $status = "Moving Directory: $($i) / $($count)"
        $percent = (($i) / $count) * 100
        Write-Progress -Activity "Moving Directories" -Status $status -PercentComplete $percent -CurrentOperation $userName
		
        # remove the old share so nothing gets changed while we're copying
        Remove-OldShare -UserName $userName
		
        # copy the files
        $destPath = Copy-UserDirectory -UserName $userName -originBaseDirectory $originBaseDirectory -destinationBaseDirectory $destinationBaseDirectory
        $p = $p + 1
			
        # set permissions on directory
        Set-Access -Path $destPath -UserName $userName -globalAccessRules $globalAccessRules
	
        # share the new directory
        Add-NewShare -UserName $userName -destinationBaseDirectory $destinationBaseDirectory
		
        Set-HomeDirectory -userName $userName -DC $dc -FS $fs -authUserName $authUserName $authPassword $authPassword
    }
}

Export-ModuleMember Move-HomeDirectories
