if (Test-Path Env:\USERPROFILE)
{

    Write-Output ("`n")
    
    $modulePath = ("{0}\Documents\WindowsPowerShell\Modules" -f $env:USERPROFILE)
    $installPath = ("{0}\MtdModules" -f $modulePath)

    #check for the install directory
    If (!(Test-Path -Path $installPath))
    {
        Write-Output ("Creating install directory: {0}" -f $installPath)
        New-Item -ItemType directory -Path $installPath
    }
    Else
    {
        Write-Output ("Install directory already exists: {0}" -f $installPath)
    }


    Write-Output ("Copying module to install directory: {0}" -f $installPath)
    Copy-Item -Path ".\MtdModules\*" -Destination $installPath

    Write-Output "`n`nSuccess! MtdModules have been installed successfully."
    Write-Output ("`t* Make sure that {0} is in your $env:PSModulePath." -f $modulePath)
    Write-Output ("`t* Your current $env:PSModulePath is {0}." -f $env:PSModulePath)

}
else
{
    Write-Error 'Unable to install. Cannot find "Env:\USERPROFILE".'
}

Write-Output "`n"