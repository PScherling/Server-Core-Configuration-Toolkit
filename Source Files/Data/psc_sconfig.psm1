<#
.SYNOPSIS
	Launches the PSC_Sconfig PowerShell interface.
	
.DESCRIPTION
    The `psc_sconfig.psm1` module provides the main entry point for launching the 
    `psc_sconfig.ps1` PowerShell configuration interface. It acts as a simple wrapper 
    function that ensures the configuration tool starts correctly in a new PowerShell 
    session with the proper execution policy and window state.

    When the `psc_sconfig` function is called, it:
      - Locates the `psc_sconfig.ps1` script in the local installation directory (`C:\_it\psc_sconfig\`)
      - Launches it in a new, maximized PowerShell window
      - Bypasses script execution policy restrictions to ensure successful execution
      - Logs errors to the console if the launch fails or the file cannot be found

    This module is designed to be imported automatically after installation,
    enabling users to start the PSC_Sconfig tool simply by typing `psc_sconfig` in PowerShell.
.LINK
    https://github.com/PScherling
.NOTES
          FileName: psc_sconfig.psm1
          Solution: PSC_Sconfig
          Author: Patrick Scherling
          Contact: @Patrick Scherling
          Primary: @Patrick Scherling
          Created: 2025-10-10
          Modified: 2025-10-10

          Version - 0.0.1 - () - Finalized functional version 1.
          

          TODO:
		  
		
.Example
	PS C:\> Import-Module psc_sconfig
    Imports the PSC_Sconfig module into the current PowerShell session.

	PS C:\> psc_sconfig
    Launches the PSC_Sconfig PowerShell configuration interface in a new maximized window.
#>

function psc_sconfig {
	$pscsconfig = "C:\_it\psc_sconfig\psc_sconfig.ps1"
	if($pscsconfig){
		try{
			Start-Process -FilePath "$PSHOME\powershell.exe" -ArgumentList "-windowstyle maximized -ExecutionPolicy Bypass -File $pscsconfig" #-PassThru
		}
		catch{
			Write-Error " Can't launch PowerShell script:
			$_"
		}
	}
	else{
		Write-Error "PowerShell Script file not found:
		$_"
	}

}

