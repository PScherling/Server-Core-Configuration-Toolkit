<#
.SYNOPSIS
	Installs and configures the custom PSC_Sconfig PowerShell module on a Windows system.
.DESCRIPTION
    The `custom_Install-PSC_Sconfig.ps1` script automates the setup and configuration of the 
    custom `psc_sconfig` module on a Windows machine. It performs the following actions:

	1. Downloads all required files and directories from a specified network share.
    2. Creates the necessary local directories for module installation.
    3. Copies module and support files (such as `.psm1`, `.psd1`, and `.cmd` files) 
       to their appropriate target locations.
    4. Imports the module into PowerShell for immediate use.
    5. Configures an autostart entry in the Windows Registry to launch `psc_sconfig` at user logon.
    6. Logs all operations (success, warnings, and errors) both locally and remotely 
       to ensure full traceability.

    The script includes error handling, detailed timestamped logging, and progress indicators
    for each installation step. It can be executed remotely or locally, making it ideal 
    for deployment automation scenarios such as WDS or MDT post-install tasks.
.LINK
    https://github.com/PScherling
.NOTES
          FileName: custom_Install-PSC_Sconfig.ps1
          Solution: PSC_Sconfig Deployment
          Author: Patrick Scherling
          Contact: @Patrick Scherling
          Primary: @Patrick Scherling
          Created: 2025-02-03
          Modified: 2025-02-03

          Version - 0.0.1 - () - Finalized functional version 1.
		  Version - 0.0.2 - () - Extended with logging
		  Version - 0.0.3 - () - Updating Logging
          

          TODO:
		  
		
.Example
	PS C:\> .\custom_Install-PSC_Sconfig.ps1
	Runs the installation and configuration process for the PSC_Sconfig module on the local machine.

	PS C:\> powershell.exe -ExecutionPolicy Bypass -File "\\192.168.121.66\DeploymentShare$\Scripts\custom\psc_sconfig\custom_Install-PSC_Sconfig.ps1"
    Executes the script from a network share, bypassing local execution policy restrictions.
#>
function Start-Configuration {
    # Variables
	# Set your WDS Credentials and Server Information here
    $user = "wdsuser"
    $pass = "Password"
	$FileSrv = "0.0.0.0" # MDT Server IP-Address
	
    $dest = "C:\_it\psc_sconfig"
    $source = "\\$($FileSrv)\DeploymentShare$\Scripts\custom\psc_sconfig\Data"
	# Get all files and subdirectories from the source folder, including hidden/system files
	$items = Get-ChildItem -Path $source -Recurse
	
    $step1 = "false"
    $step2 = "false"
    $step3 = "false"
    $step4 = "false"
    $step5 = "false"
    $step6 = "false"
    
    # Log file path
    #$logFile = "C:\_it\psc_sconfig_install.log"
	
	# Log file path and function to log messages
	$config = "psc_sconfig"
	$CompName = $env:COMPUTERNAME
	$DateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
	$logFileName = "Configure_$($config)_$($CompName)_$($DateTime).log"

	$logFilePath = "\\$($FileSrv)\Logs$\Custom\Configuration"
	$logFile = "$($logFilePath)\$($logFileName)"

	$localLogFilePath = "C:\_it"
	$localLogFile = "$($localLogFilePath)\$($logFileName)"
	
	# Function to log messages with timestamps
    function Write-Log {
        param (
            [string]$Message
        )
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "[$timestamp] $Message"
        #Write-Output $logMessage
        $logMessage | Out-File -FilePath $logFile -Append
    }
    
    # Start logging
    Write-Log "Start Logging."
    
    try {
        Write-Log "Step 1 - Download Files to target system"
        
        ### Step 1 - Download Files to target system
        if ($step1 -eq "false") {
            If (-Not (Test-Path $dest)) {
                # Create Directory
                try {
                    Write-Log "Creating target directory: $dest"
                    New-Item -Path "C:\_it\" -Name "psc_sconfig" -ItemType "directory"
                } catch {
                    Write-Log "Error: Directory can not be created: $_"
                    break
                }
            }

            try {
                Write-Log " Downloading files from $source to $dest"
                if (Test-Path $source) {
                    <#copy-item "$sourceFiles" -Destination "$dest\"
                    for ($i = 0; $i -le 100; $i = $i + 10) {
                        Write-Progress -Activity "File download in Progress" -Status "File Download Progress $i% Complete:" -PercentComplete $i
                        Start-Sleep -Milliseconds 250
                    }#>
					
					# Copy each item individually
					$i = 0
					foreach ($item in $items) {
						# Ensure the target folder structure is created
						$targetItemPath = Join-Path -Path $dest -ChildPath $item.FullName.Substring($source.Length)
						
						# If it's a directory, create it
						if ($item.PSIsContainer) {
							if (-not (Test-Path -Path $targetItemPath)) {
								Write-Host "Creating directory: $targetItemPath"
								Write-Log " Creating directory: $targetItemPath"
								New-Item -Path $targetItemPath -ItemType Directory
							}
						}
						else {
							# If it's a file, copy it
							Write-Host "Download file: $item.FullName to $targetItemPath"
							Write-Log " Download file: $item.FullName to $targetItemPath"
							Copy-Item -Path $item.FullName -Destination $targetItemPath -Force
						}
						
						#Progress Bar
						$i = $i + 10
						Write-Progress -Activity "File download in Progress" -Status "File Download Progress $i% Complete:" -PercentComplete $i
						Start-Sleep -Milliseconds 250
					}
					
                    Write-Log "File download completed."
                } else {
                    Write-Log "Warning: Source path not found: $source"
                    break
                }
            } catch {
                Write-Log "Error: Files cannot be downloaded: $_"
                break
            }
            $step1 = "true"
        }

        Write-Log "Step 2 - Create Directories for our new module"
        
        ### Step 2 - Create Directories for our new module
        if ($step1 -eq "true") {
            if (-Not (Test-Path "C:\Program Files\WindowsPowerShell\Modules\psc_sconfig")) {
                try {
                    Write-Log "Creating module directory at 'C:\Program Files\WindowsPowerShell\Modules\psc_sconfig'"
                    New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\" -Name "psc_sconfig" -ItemType "directory"
                } catch {
                    Write-Log "Error: Directory creation for module failed: $_"
                    break
                }
            } else {
                Write-Log "Nothing to do. Directory already exists."
            }
            $step2 = "true"
        }

        Write-Log "Step 3 - Copy downloaded files to target directories"
        
        ### Step 3 - Copy downloaded files to target directories
        if ($step2 -eq "true") {
            if (-Not (Test-Path "C:\Windows\System32\psc_sconfig.cmd")) {
                try {
                    Write-Log "Copying psc_sconfig.cmd to System32"
                    copy-item "C:\_it\psc_sconfig\psc_sconfig.cmd" -Destination "C:\Windows\System32\"
                    for ($i = 0; $i -le 100; $i = $i + 10) {
                        Write-Progress -Activity "File copy in Progress" -Status "File Copy Progress $i% Complete:" -PercentComplete $i
                        Start-Sleep -Milliseconds 250
                    }
                    Write-Log "File copy completed for psc_sconfig.cmd."
                } catch {
                    Write-Log "Error: File copy failed for psc_sconfig.cmd: $_"
                    break
                }
            } else {
                Write-Log "Nothing to do. psc_sconfig.cmd already exists."
            }

            # Repeat for other files (psc_sconfig.psm1, psc_sconfig.psd1)
            if (-Not (Test-Path "C:\Program Files\WindowsPowerShell\Modules\psc_sconfig\psc_sconfig.psm1")) {
                try {
                    Write-Log "Copying psc_sconfig.psm1 to PowerShell Modules"
                    copy-item "C:\_it\psc_sconfig\psc_sconfig.psm1" -Destination "C:\Program Files\WindowsPowerShell\Modules\psc_sconfig\"
                } catch {
                    Write-Log "Error: File copy failed for psc_sconfig.psm1: $_"
                    break
                }
            }

            if (-Not (Test-Path "C:\Program Files\WindowsPowerShell\Modules\psc_sconfig\psc_sconfig.psd1")) {
                try {
                    Write-Log "Copying psc_sconfig.psd1 to PowerShell Modules"
                    copy-item "C:\_it\psc_sconfig\psc_sconfig.psd1" -Destination "C:\Program Files\WindowsPowerShell\Modules\psc_sconfig\"
                } catch {
                    Write-Log "Error: File copy failed for psc_sconfig.psd1: $_"
                    break
                }
            }

            $step3 = "true"
        }

        Write-Log "Step 4 - Import the new module"
        
        ### Step 4 - Import our new module on the system
        if ($step3 -eq "true") {
            try {
                Write-Log "Importing psc_sconfig module"
                Import-Module psc_sconfig
            } catch {
                Write-Log "Error: Import of module failed: $_"
                break
            }
            $step4 = "true"
        }

        Write-Log "Step 5 - Autostart psc_sconfig at logon"
        
        ### Step 5 - Autostart psc_sconfig at logon
        if ($step4 -eq "true") {
            try {
                Write-Log "Setting psc_sconfig to autostart at logon"
                new-itemproperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name psc_sconfig -Value 'C:\_it\psc_sconfig\launch_psc_sconfig.bat'
            } catch {
                Write-Log "Error: Failed to set autolaunch for psc_sconfig: $_"
                break
            }
            $step5 = "true"
        }

        <#Write-Log "Step 6 - Disable sconfig autolaunch"
        
        ### Step 6 - Disable sconfig autolaunch
        if ($step5 -eq "true") {
            try {
                Write-Log "Disabling sconfig autolaunch"
                # Assuming Set-SConfig works for disabling autolaunch
                # This part needs to be adapted for your environment
                Set-SConfig -AutoLaunch $false
            } catch {
                Write-Log "Warning: Failed to disable autolaunch for sconfig: $_"
            }
            $step6 = "true"
        }#>

        if ($step5 -eq "true") {
            Write-Log "Configuration completed successfully."
        }

    } catch {
        Write-Log "Error: An unexpected error occurred: $_"
    } finally {
        # End logging
        Write-Log "Finish Logging."
    }
	
	<#
	# Finalizing
	#>
	
	# Upload logFile
	try{
		Copy-Item "$logFile" -Destination "$logFilePath"
	}
	catch{
		Write-Warning "ERROR: Logfile '$logFile' could not be uploaded to Deployment-Server.
		Reason: $_"
	}

	# Delete local logFile
	<#try{
		Remove-Item "$logFile" -Force
	}
	catch{
		Write-Warning "ERROR: Logfile '$logFile' could not be deleted.
		Reason: $_"
	}#>
}


Start-Configuration



