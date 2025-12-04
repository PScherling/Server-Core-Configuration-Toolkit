<#
.SYNOPSIS
	Manually installs and configures the PSC_Sconfig PowerShell module on a local Windows system.
	
.DESCRIPTION
    The `manual_Install-PSC_Sconfig.ps1` script performs a local, manual installation of the
    `psc_sconfig` PowerShell module without requiring access to a deployment or file server.

    It automatically copies all required module files from the script’s local directory structure
    (`.\Data`) into their appropriate system locations, creates necessary folders, imports the
    module, and configures autostart behavior at user logon.

    The script includes:
      - Dynamic path handling based on the script’s execution location
      - Step-by-step execution with progress feedback and colored console output
      - Detailed timestamped logging stored locally in `C:\_psc`
      - Error handling and warnings for failed operations

    This script is intended for **manual local deployment** on systems where the automated or
    remote installation (e.g., via WDS or MDT) is not available or desired. It should be executed
    with administrative privileges to ensure full functionality.
	
.LINK
    https://github.com/PScherling
	
.NOTES
          FileName: manual_Install-PSC_Sconfig.ps1
          Solution: PSC_Sconfig Local Deployment
          Author: Patrick Scherling
          Contact: @Patrick Scherling
          Primary: @Patrick Scherling
          Created: 2025-04-02
          Modified: 2025-04-02

          Version - 0.0.1 - () - Finalized functional version 1.
          

          TODO:
		  
		
.Example
	PS C:\> .\manual_Install-PSC_Sconfig.ps1
    Runs the manual installation and configuration of the PSC_Sconfig PowerShell module locally.

	PS C:\> powershell.exe -ExecutionPolicy Bypass -File "C:\Installers\manual_Install-PSC_Sconfig.ps1"
    Executes the script from a local path with elevated permissions, bypassing execution policy restrictions.
#>
function Start-Configuration {
    ### 
	### Variables
	###
	
	# Get the directory where the script is located
	$scriptDirectory = $PSScriptRoot
	
    $dest = "C:\_psc\psc_sconfig"
    $source = "$scriptDirectory\Data"
	# Get all files and subdirectories from the source folder, including hidden/system files
	$items = Get-ChildItem -Path $source -Recurse
	
    $step1 = "false"
    $step2 = "false"
    $step3 = "false"
    $step4 = "false"
    $step5 = "false"
    $step6 = "false"
	
	# Log file path and function to log messages
	$config = "psc_sconfig"
	$CompName = $env:COMPUTERNAME
	$DateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
	$logFileName = "Configure_$($config)_$($CompName)_$($DateTime).log"

	$localLogFilePath = "C:\_psc"
	$localLogFile = "$($localLogFilePath)\$($logFileName)"
	
	# Function to log messages with timestamps
    function Write-Log {
        param (
            [string]$Message
        )
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "[$timestamp] $Message"
        #Write-Output $logMessage
        $logMessage | Out-File -FilePath $localLogFile -Append
    }
    
    # Start logging
    Write-Log "Start Logging."
	Write-Host "-----------------------------------------------------------------------------------
    Starting PSC SConfig Installer...
-----------------------------------------------------------------------------------"
    
    try {
        Write-Log "Step 1 - Copy Files to target directory"
        Write-Host " Step 1 - Copy Files to target directory"
        ### Step 1 - Download Files to target directory
        if ($step1 -eq "false") {
            If (-Not (Test-Path $dest)) {
                # Create Directory
                try {
                    Write-Log "Creating target directory: $dest"
                    New-Item -Path "C:\_psc\" -Name "psc_sconfig" -ItemType "directory"
                } catch {
                    Write-Log "Error: Directory can not be created: $_"
                    break
                }
            }

            try {
                Write-Log " Copy files from $source to $dest"
				Write-Host " Copy files from $source to $dest"
                if (Test-Path $source) {
                    <#copy-item "$sourceFiles" -Destination "$dest\"
                    for ($i = 0; $i -le 100; $i = $i + 10) {
                        Write-Progress -Activity "File Copy in Progress" -Status "File Copy Progress $i% Complete:" -PercentComplete $i
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
							Write-Host "Copy file: $item.FullName to $targetItemPath"
							Write-Log " Copy file: $item.FullName to $targetItemPath"
							Copy-Item -Path $item.FullName -Destination $targetItemPath -Force
						}
						
						#Progress Bar
						$i = $i + 10
						Write-Progress -Activity "File copy in Progress" -Status "File copy Progress $i% Complete:" -PercentComplete $i
						Start-Sleep -Milliseconds 250
					}
					
                    Write-Log "File copy completed."
                } else {
                    Write-Log "Warning: Source path not found: $source"
                    break
                }
            } catch {
                Write-Log "Error: Files cannot be copied: $_"
                break
            }
            $step1 = "true"
        }

        Write-Log "Step 2 - Create Directories for our new module"
		Write-Host "
-----------------------------------------------------------------------------------"
        Write-Host " Step 2 - Create Directories for our new module"
        ### Step 2 - Create Directories for our new module
        if ($step1 -eq "true") {
            if (-Not (Test-Path "C:\Program Files\WindowsPowerShell\Modules\psc_sconfig")) {
                try {
                    Write-Log "Creating module directory at 'C:\Program Files\WindowsPowerShell\Modules\psc_sconfig'"
					Write-Host " Creating module directory at 'C:\Program Files\WindowsPowerShell\Modules\psc_sconfig'"
                    New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\" -Name "psc_sconfig" -ItemType "directory"
                } catch {
                    Write-Log "Error: Directory creation for module failed: $_"
					Write-Warning " Error: Directory creation for module failed: $_"
                    break
                }
            } else {
                Write-Log "Nothing to do. Directory already exists."
				Write-Host " Nothing to do. Directory already exists."
            }
            $step2 = "true"
        }

        Write-Log "Step 3 - Copy files to target directories"
		Write-Host "
-----------------------------------------------------------------------------------"
        Write-Host " Step 3 - Copy files to target directories"
        ### Step 3 - Copy files to target directories
        if ($step2 -eq "true") {
            if (-Not (Test-Path "C:\Windows\System32\psc_sconfig.cmd")) {
                try {
                    Write-Log "Copying psc_sconfig.cmd to System32"
					Write-Host " Copying psc_sconfig.cmd to System32"
                    copy-item "C:\_psc\psc_sconfig\psc_sconfig.cmd" -Destination "C:\Windows\System32\"
                    for ($i = 0; $i -le 100; $i = $i + 10) {
                        Write-Progress -Activity "File copy in Progress" -Status "File Copy Progress $i% Complete:" -PercentComplete $i
                        Start-Sleep -Milliseconds 250
                    }
                    Write-Log "File copy completed for psc_sconfig.cmd."
					Write-Host " File copy completed for psc_sconfig.cmd."
                } catch {
                    Write-Log "Error: File copy failed for psc_sconfig.cmd: $_"
					Write-Warning " Error: File copy failed for psc_sconfig.cmd: $_"
                    break
                }
            } else {
                Write-Log "Nothing to do. psc_sconfig.cmd already exists."
				Write-Host " Nothing to do. psc_sconfig.cmd already exists."
            }

            # Repeat for other files (psc_sconfig.psm1, psc_sconfig.psd1)
            if (-Not (Test-Path "C:\Program Files\WindowsPowerShell\Modules\psc_sconfig\psc_sconfig.psm1")) {
                try {
                    Write-Log "Copying psc_sconfig.psm1 to PowerShell Modules"
					Write-Host " Copying psc_sconfig.psm1 to PowerShell Modules"
                    copy-item "C:\_psc\psc_sconfig\psc_sconfig.psm1" -Destination "C:\Program Files\WindowsPowerShell\Modules\psc_sconfig\"
                } catch {
                    Write-Log "Error: File copy failed for psc_sconfig.psm1: $_"
					Write-Warning " Error: File copy failed for psc_sconfig.psm1: $_"
                    break
                }
            }

            if (-Not (Test-Path "C:\Program Files\WindowsPowerShell\Modules\psc_sconfig\psc_sconfig.psd1")) {
                try {
                    Write-Log "Copying psc_sconfig.psd1 to PowerShell Modules"
					Write-Host " Copying psc_sconfig.psd1 to PowerShell Modules"
                    copy-item "C:\_psc\psc_sconfig\psc_sconfig.psd1" -Destination "C:\Program Files\WindowsPowerShell\Modules\psc_sconfig\"
                } catch {
                    Write-Log "Error: File copy failed for psc_sconfig.psd1: $_"
					Write-Warning " Error: File copy failed for psc_sconfig.psd1: $_"
                    break
                }
            }

            $step3 = "true"
        }

        Write-Log "Step 4 - Import the new module"
		Write-Host "
-----------------------------------------------------------------------------------"
        Write-Host " Step 4 - Import the new module"
        ### Step 4 - Import our new module on the system
        if ($step3 -eq "true") {
            try {
                Write-Log "Importing psc_sconfig module"
				Write-Host " Importing psc_sconfig module"
                Import-Module psc_sconfig
            } catch {
                Write-Log "Error: Import of module failed: $_"
				Write-Warning " Error: Import of module failed: $_"
                break
            }
            $step4 = "true"
        }

        Write-Log "Step 5 - Autostart psc_sconfig at logon"
		Write-Host "
-----------------------------------------------------------------------------------"
        Write-Warning " Step 5 - Autostart psc_sconfig at logon"
        ### Step 5 - Autostart psc_sconfig at logon
        if ($step4 -eq "true") {
            try {
                Write-Log "Setting psc_sconfig to autostart at logon"
				Write-Host " Setting psc_sconfig to autostart at logon"
                new-itemproperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name psc_sconfig -Value 'C:\_psc\psc_sconfig\launch_psc_sconfig.bat'
            } catch {
                Write-Log "Error: Failed to set autolaunch for psc_sconfig: $_"
				Write-Warning " Error: Failed to set autolaunch for psc_sconfig: $_"
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
			Write-Host "
-----------------------------------------------------------------------------------"
			Write-Host -ForegroundColor Green " Configuration completed successfully."
        }

    } catch {
        Write-Log "Error: An unexpected error occurred: $_"
		Write-Warning " Error: An unexpected error occurred: $_"
    } finally {
        # End logging
        Write-Log "Finish Logging."
    }
	
	<#
	# Finalizing
	#>
	Read-Host -prompt " Press any key to finish..."
}


Start-Configuration




