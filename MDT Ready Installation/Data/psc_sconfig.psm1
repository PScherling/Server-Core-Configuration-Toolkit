<#
.DESCRIPTION
    
.LINK
    
.NOTES
          FileName: psc_sconfig.psm1
          Solution: 
          Author: Patrick Scherling
          Contact: @Patrick Scherling
          Primary: @Patrick Scherling
          Created: 2025-10-10
          Modified: 2025-10-10

          Version - 0.0.1 - () - Finalized functional version 1.
          

          TODO:
		  
		
.Example
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