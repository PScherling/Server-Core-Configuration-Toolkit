<#
.SYNOPSIS
    Interactive Server Core configuration and management tool for Windows.
.DESCRIPTION
    `psc_sconfig.ps1` is an interactive, menu-driven PowerShell tool for configuring and
    administering Windows (especially Server Core) systems after deployment. It gathers key
    system facts (OS/build, uptime, RAM, storage, IPs, firewall, WAC/Arc/Update/Activation
    status) and provides guided actions to change common settings safely.

    Key capabilities:
      - System overview: OS/Product/Build (incl. UBR), display version, uptime/last boot,
        IP addresses, RAM and per-volume storage (auto GB/TB conversion).
      - Connectivity & access:
          - Remote Management (WinRM) enable/disable
          - Remote Desktop enable/disable
          - Windows Defender Firewall profile status display
      - Identity & time:
          - Hostname rename
          - Domain/Workgroup join/leave
          - Date/Time configuration
      - Updates & telemetry:
          - Read WSUS and AU policy (registry) and Windows Update service status
          - Windows Update workflows using the Windows Update Agent (WUA) APIs
          - Diagnostic data/telemetry (AllowTelemetry) view and configure
      - Licensing:
          - Windows activation status (WMI) and activation actions
      - Local users & groups:
          - Create user, add to Administrators, create local groups
      - Actions:
          - Refresh dashboard, logoff, restart, shutdown, open terminal
      - Role-aware add-ons (shown only when installed):
          - Active Directory Domain Services (with DNS & GPMC): AD management menu
          - Hyper-V (with Hyper-V PowerShell): Hyper-V management menu
      - Admin experience:
          - Clear, colorized console UI with progress messages
          - Robust error handling and warnings
          - Timestamped logging to: C:\_psc\psc_sconfig\Logfiles\psc_sconfig.log
          - Disables legacy SConfig autolaunch on start (best effort)

	Notes:
      - Run in an elevated PowerShell session for all features to work.
      - Designed for Server Core, but works on full GUI installations as well.
      - Windows Admin Center (WAC) detection:
          - Shows a caution when WAC is installed on a Domain Controller (per Microsoft guidance).
      - Version displayed in the banner is kept in $VersionNumber.
	  
.LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date?view=powershell-7.4
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date?view=powershell-7.4#notes
    https://www.thomasmaurer.ch/2021/03/get-system-uptime-with-powershell/
    https://devblogs.microsoft.com/scripting/powertip-use-powershell-to-find-system-uptime/#:~:text=How%20can%20I%20use%20Windows%20PowerShell%20to%20easily,the%20Win32_OperatingSystem%2C%20for%20example%3A%20%28get-date%29%20%E2%80%93%20%28gcim%20Win32_OperatingSystem%29.LastBootUpTime
    https://community.spiceworks.com/t/how-to-check-if-a-server-or-computer-is-domain-joined/1111349
    https://pureinfotech.com/enable-remote-desktop-powershell-windows-10/
    https://www.alltechnerd.com/how-to-activate-windows-via-powershell/
    https://www.action1.com/how-to-use-powershell-scripts-to-install-windows-updates-remotely/
    https://www.powershellgallery.com/packages/PSWindowsUpdate/2.2.1.5
    https://github.com/kliebenberg/PSWindowsUpdate
    https://powershellisfun.com/2024/01/19/using-the-powershell-pswindowsupdate-module/
    https://gist.github.com/cfebs/c9d83c2480a716f6d8571fb6cc80fd59
	https://learn.microsoft.com/en-us/powershell/module/netadapter/get-netadapterrdma?view=windowsserver2022-ps
	https://learn.microsoft.com/en-us/powershell/module/netadapter/enable-netadapterrdma?view=windowsserver2022-ps
	https://learn.microsoft.com/en-us/powershell/module/netadapter/disable-netadapterrdma?view=windowsserver2022-ps
	https://learn.microsoft.com/en-us/powershell/module/nettcpip/test-netconnection?view=windowsserver2025-ps
	https://learn.microsoft.com/en-us/powershell/module/netlbfo/remove-netlbfoteam?view=windowsserver2022-ps
	Windows Admin Center local scripts
	https://learn.microsoft.com/en-us/windows/win32/wua_sdk/windows-update-agent--wua--api-reference
	https://github.com/PScherling

.NOTES
          FileName: psc_sconfig.ps1
          Solution: PSC_Sconfig
          Author: Patrick Scherling
          Contact: @Patrick Scherling
          Primary: @Patrick Scherling
          Created: 2024-11-01
          Modified: 2025-11-5

          Version - 0.0.1 - () - Initial first attempt.
          Version - 0.0.2 - () - Finalized first functional Version
          Version - 0.0.3 - () - Fixed Minor Bugs
		  Version - 0.0.4 - () - Refactor the network configuration (2)
		  Version - 0.0.5 - () - Adding Teaming configuration for NICs
          Version - 0.0.6 - () - Expanding information for RAM and Storage
          Version - 0.0.7 - () - Adding information of current logged on user; Windows Defender Firewall status; Azure Arc status
          Version - 0.0.8 - () - First Try to implement specific Server Role Management Options (ADC)
          Version - 0.0.9 - () - Implementing Hyper-V Management
          Version - 0.0.10 - () - Adaption of function "Get-NetworkAdapters" with ErrorAction Silentlycontinue and checking if adapter is without ip address
		  Version - 0.0.11 - () - Adding 'Refresh' functionality to the menu
		  Version - 0.0.12 - () - Adding Logging Functionality and minor bug fixes
		  Version - 0.0.13 - () - Functionality for 'Renaming' Network Adapter
		  Version - 0.0.14 - () - Adding RDMA Information for Network Adapters
		  Version - 0.0.15 - () - Function to delete network team adapter
		  Version - 0.0.16 - () - Minor Bugfixing in Open-Network-Configuration (Menu is now working correctly with user input?!)
		  Version - 0.0.17 - () - Storage Size Convertion GB<->TB for better readability 
		  Version - 0.0.18 - () - Adding Prefix Network Information in Network Configuration function
		  Version - 0.0.19 - () - Minor Bug fixes. First attempt in reworking Windows Updates to work with the onboard Windows Update Agent API from Microsoft
		  Version - 0.0.20 - () - Adding version number to the menu
		  Version - 0.1.0 - () - Finalized first Stable Version.
		  Version - 0.1.1 - () - Minor Bug Fixes druing User/Group creation
		  Version - 0.1.2 - () - Minor Bug Fix in function WindowsUpdates; ErrorHandling implemented.
		  Version - 0.1.3 - () - Bug fix in function "Download-Updates" and "Install-Updates"; Refresh action removed
							   - Bug fix in function "Windows-Updates"; Status in List of available updates reworked; "Pending reboot" information added
		  Version - 0.1.4 - () - AD MGMT: Functions Added: Import and Export AD Users
							   - Changing Build Version to display the update revision number too; previous "10.0.26100"; now "10.0.26100.4061"
							   - Display Security Risk Info Message on Domain-Controller if WAC is installed.
                               - Changing "seletc"'s to "select-object"'s and fixing other PowerShell syntax issues #unapproved verb!
          Version - 0.1.5 - () - Changing "LastBoot" format from dd.mmm.yyyy to dd/mmm/yyyy 
          Version - 0.1.6 - () - Displaying Manucafurer and Model Information (Info is needed for HPE SPP Update functionality anyway)

          TODO:
			Coming Features
				Global:
				- User and Group Management (Edit and Delete)
				Role Related
				- PRINTSRV Management
				- FILESRV Management

.REQUIREMENTS
    - Run as Administrator.
    - PowerShell 5.1+ (Windows PowerShell) or PowerShell 7.x on Windows.
    - Network and policy permissions appropriate for domain join, WinRM/RDP enablement,
      Windows Update, and local user/group changes.

.OUTPUTS
    Console output (colorized) and log file at:
        C:\_psc\psc_sconfig\Logfiles\psc_sconfig.log

.Example
	PS C:\> psc_sconfig
    (When the module is installed) Starts PSC SConfig via the module launcher.
	
    PS C:\> powershell.exe -ExecutionPolicy Bypass -File "C:\_psc\psc_sconfig\psc_sconfig.ps1"
    Launches PSC SConfig with full interactive menu and logging.

	PS C:\> Start-Process powershell.exe -ArgumentList '-ExecutionPolicy Bypass -WindowStyle Maximized -File C:\_psc\psc_sconfig\psc_sconfig.ps1'
    Opens PSC SConfig in a new, maximized PowerShell window.
#>

# Version number
$VersionNumber = "0.1.6"

# Log file path
$logFile = "C:\_psc\psc_sconfig\Logfiles\psc_sconfig.log"

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
Write-Log " Starting psc_sconfig..."

####
#### Try to deactivate sconfig
####
Write-Log " Get sconfig autolaunch status."
$sconfig = (Get-Sconfig).AutoLaunch
if($sconfig -eq "True"){
	Write-Log " SConfig autolaunch is enabled."
	try {
		Set-SConfig -AutoLaunch $false
	} catch {
		Write-Warning " Autolaunch of sconfig could not be disabled"
		Write-Log " WARNING: Autolaunch of sconfig could not be disabled"
	}
}
else{
	Write-Warning " SConfig autolaunch is disabled."
	Write-Log " SConfig autolaunch is disabled."
}
	

####
#### Main Menu
####
function Show-Menu {
	
	Write-Log " Starting Main Menu."
	Write-Log " Gathering system information."
    
	# Function to convert sizes to GB or TB depending on the size
	function Convert-Size {
		param (
			[Parameter(Mandatory=$true)]
			[double]$sizeInBytes
		)

		$sizeInGB = [math]::round($sizeInBytes / 1GB, 2)
		if ($sizeInGB -ge 1000) {
			$sizeInTB = [math]::round($sizeInGB / 1024, 2)
			return "$sizeInTB TB"
		} else {
			return "$sizeInGB GB"
		}
	}
	
	
	### Variables ###
    
    # System Info
    $Hostname = $env:COMPUTERNAME
    $Domain = (Get-WmiObject Win32_ComputerSystem).Domain
    
    # Remote Management Info
    $RemoteMGMT = Get-Service -Name "WinRM" | select-object Status
    if($RemoteMGMT.Status -eq "Running") {
        $RemoteMGMT = "Enabled"
    }
    elseif($RemoteMGMT.Status -ne "Running"){
        $RemoteMGMT = "Disabled"
    }

    # RDP Info
    $RdpStatus = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections
    if ($RdpStatus.fDenyTSConnections -eq 0) {
        $RDP = "Enabled"
    } elseif($RdpStatus.fDenyTSConnections -eq 1) {
        $RDP = "Disabled"
    }

	# Windows Admin Center
    try {
	    $ErrorActionPreference = "SilentlyContinue"
	    $GetSoftware = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher | where-object { $_.DisplayName -ne $null -and $_.DisplayVersion -ne $null -and $_.Publisher -ne $null } | Sort-Object -Property DisplayName, DisplayVersion, Publisher #| Format-Table
    }
    catch {
	    Write-Warning "Something went wrong. Could not fetch all information for installed software."
    }
    $ErrorActionPreference = "Continue"

    if($GetSoftware.DisplayName -eq "Windows Admin Center"){
        $WACStatus = "Installed"
    }
    elseif($GetSoftware.DisplayName -ne "Windows Admin Center"){
        $WACStatus = "Not Installed"
    }

    # Windows Update
    $UpdateSvc = Get-Service -Name wuauserv | select-object Status
    $GetWSUSInfo = Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate | select-object WUServer,WUStatusServer,ElevateNonAdmins,DoNotConnectToWindowsUpdateInternetLocations,SetUpdateNotificationLevel,UpdateNotificationLevel
    $GetWSUSSettings = Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU | select-object AUOptions,UseWUServer,NoAutoRebootWithLoggedOnUsers,NoAutoUpdate,ScheduledInstallDay,ScheduledInstallTime

    if ($GetWSUSSettings.AUOptions -eq 2 -and $UpdateSvc.Status -eq "Running") {
        $AUOptions = "Notify before download"
    }
    elseif ($GetWSUSSettings.AUOptions -eq 3 -and $UpdateSvc.Status -eq "Running") {
        $AUOptions = "Automatically download and notify of installation"
    }
    elseif ($GetWSUSSettings.AUOptions -eq 4 -and $UpdateSvc.Status -eq "Running") {
        $AUOptions = "Automatic download and scheduled installation (Opnly valid if 'Scheduled Install Settings' are configured!)"
    }
    elseif ($GetWSUSSettings.AUOptions -eq 5 -and $UpdateSvc.Status -eq "Running") {
        $AUOptions = "Automatic Updates is required, but end users can configure it"
    }
    elseif ($GetWSUSSettings.AUOptions -ne 2 -and $GetWSUSSettings.AUOptions -ne 3 -and $GetWSUSSettings.AUOptions -ne 4 -and $GetWSUSSettings.AUOptions -ne 5 -and $UpdateSvc.Status -eq "Running") {
        $AUOptions = "Not Set"
    }
    elseif($UpdateSvc.Status -ne "Running") {
        $AUOptions = "Windows Update Service is not running"
    }

    # Query WMI for activation status
    <#
    0 = Unlicensed
    1 = Licensed
    2 = Notification (activation is needed)
    3 = OOBGrace (Out of Box Grace Period)
    4 = OOTGrace (Out of Tolerance Grace Period)
    5 = Non-Genuine
    6 = Notification (reached the grace period limit)
    7 = Evaluation (Evaluation mode)
    #>
    $Activation = (Get-WmiObject -Query "SELECT * FROM SoftwareLicensingProduct WHERE (PartialProductKey IS NOT NULL)").LicenseStatus

    if($Activation -eq 0) {
        $Activation = "Not Activated"
    }
    if($Activation -eq 1) {
        $Activation = "Activated"
    }
    if($Activation -eq 2) {
        $Activation = "Activation is needed"
    }
    if($Activation -eq 3) {
        $Activation = "Out of Box Grace Period"
    }
    if($Activation -eq 4) {
        $Activation = "Out of Tolerance Grace Period"
    }
    if($Activation -eq 5) {
        $Activation = "Not Activated"
    }
    if($Activation -eq 6) {
        $Activation = "Reached the grace period limit"
    }
    if($Activation -eq 7) {
        $Activation = "Evaluation"
    }

    <#
    Diagnostic data off (Security)	0
    Required (Basic)	1
    Enhanced	2
    Optional (Full)	3
    #>
    # Define the registry path and key
    $RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $RegistryName = "AllowTelemetry"

    # Initialize $Diag to a default value
    $Diag = 0

    # Check if the registry key exists
    if (Test-Path $RegistryPath) {
        try {
            # Attempt to retrieve the registry property
            $RegistryValue = Get-ItemProperty -Path $RegistryPath -Name $RegistryName -ErrorAction SilentlyContinue

            # If the registry value exists and is found
            if ($null -ne $RegistryValue) {
                # Extract the actual value of AllowTelemetry, ensuring it's treated as an integer
                $Diag = [int]$RegistryValue.AllowTelemetry
            }
            else {
                # If the registry value is null, set to default
                $Diag = 0
            }
        }
        catch {
            # In case of error, we catch and set $Diag to 0
            $Diag = 0
        }
    }
    else {
        # If the registry key does not exist, set the default value
        $Diag = 0
    }

    # Debugging: Output the raw value of $Diag to see what it's set to
    #Write-Host "Raw Diag Value: $Diag"

    # Assign the appropriate string based on the value of $Diag using a switch statement
    switch ($Diag) {
        0 { $DiagData = "Not Enabled" }
        1 { $DiagData = "Required (Basic)" }
        2 { $DiagData = "Enhanced" }
        3 { $DiagData = "Optional (Full)" }
        default { $DiagData = "Unknown" }
    }

    

    # OS Info
    $OSInfo = Get-ComputerInfo | select-object OSName,OSDisplayVersion,WindowsVersion,OSVersion #select WindowsProductName,WindowsVersion,OsVersion
    $WindowsProduct = $OSInfo.OSName #$global:OSInfo.WindowsProductName
    $WindowsVersion = $OSInfo.WindowsVersion
    $ubr = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "UBR").UBR
    $OSVersion = "$($OSInfo.OSVersion).$($ubr)"
    $OSDisplayVersion = $OSInfo.OSDisplayVersion
    if([string]::IsNullOrEmpty($OSDisplayVersion) -and $OSVersion -eq "10.0.19044" -and $WindowsVersion -eq "2009") { $OSDisplayVersion = "21H2" }

    

    # RAM Info
    #$RAMInfo = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | Foreach {"{0:N2}" -f ([math]::round(($_.Sum / 1GB),2))}
    $RAMInfo = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | ForEach-Object {
        # Round the sum and format it with a comma as a decimal separator
        $formatted = "{0:N2}" -f ([math]::round(($_.Sum / 1GB), 2))
        # Replace the first comma with a period
        $formatted -replace ',', '.'
    }
    $FreeRAM = (Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory
    $FreeRAM = [math]::round(([UInt64]$FreeRAM / 1MB),2)
    $UsedRAM = $RAMInfo - $FreeRAM
    
    # Time and Date Info
    $Date = Get-Date -UFormat "%A %d/%b/%Y %T"
    
    # Uptime Info
    $LastBootUpTime = Get-CimInstance -ClassName Win32_OperatingSystem | Select-object LastBootUpTime
    $LastBoot = $LastBootUpTime.LastBootUpTime.ToString("dddd dd/MMM/yyyy HH:mm:ss")
    $LastBoot = $LastBoot.Replace('.','/')
    $Uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $Uptime = $Uptime.Days.ToString() + " Days " + $Uptime.Hours.ToString() + " Hours " + $Uptime.Minutes.ToString() + " Minutes"

    # Network Info
    $IP = Get-NetIPAddress | Where-Object { $_.InterfaceAlias -notlike "Loopback*" -and $_.PrefixOrigin -notlike "WellKnown" } | Select-Object IPAddress
    $IP = $IP.IPAddress

    # Storage Info
    $StorageInfo = Get-PSDrive -PSProvider FileSystem

    $VolumeList = @()
    $VolumeUsedSizeList = @()
    $VolumeFreeSizeList = @()
    $StorageTotalSize = 0
    $VolumeTotalSizeList = @()

    foreach($Volume in $StorageInfo)
    {
        $VolumeList += $StorageInfo.Root
        $VolumeUsedSizeList += $StorageInfo.Used
        $VolumeFreeSizeList += $StorageInfo.Free

        $StorageTotalSize = $StorageInfo.Used + $StorageInfo.Free
        $VolumeTotalSizeList += $StorageTotalSize
    }

    # User Info
    $CurrUser = $env:USERNAME


    # Windows Defender Firewall
    # Get Firewall profiles from the active policy store
    $firewallInfo = Get-NetFirewallProfile -PolicyStore ActiveStore | Select-Object Name, Enabled

    # Output the retrieved firewall profiles to the console
    #$firewallInfo | Format-Table -Property Name, Enabled

    # Initialize empty arrays for storing firewall profile names and their statuses
    $fwProfileList = @()
    $fwProfileStatusList = @()

    # Populate the arrays with profile names and their corresponding status (Enabled or Disabled)
    foreach ($fwProfile in $firewallInfo) {
        $fwProfileList += $fwProfile.Name
        #$fwProfileStatusList += $fwProfile.Enabled
        if($fwProfile.Enabled -eq "False"){
            $fwProfileStatusList += "Disabled"
        }
        elseif($fwProfile.Enabled -eq "True"){
            $fwProfileStatusList += "Enabled"
        }
    }


    # Azure Arc Status
    $azurearcstatus = Get-Service -Name himds -ErrorAction SilentlyContinue
    if ($null -eq $azurearcstatus) {
        # which means no such service is found.
        <#@{ 
            Installed = "Not Installed"; #Running = "Not Running"
        }
        #>
        $azurearcstatus = "Not Installed"
    }
    elseif ($azurearcstatus.Status -eq "Running") {
        #@{ Installed = "Installed"; Running = "Running" }
        $azurearcstatus = "Installed but not running"
    }
    else {
        #@{ Installed = "Installed"; Running = "Not Running" }
        $azurearcstatus = "Installed and running"
    }

    # Manufacturer and Model Info
    $manufacturerInfo = Get-CimInstance -ClassName Win32_ComputerSystem | select-object Manufacturer,Model
    $manufacturer = $manufacturerInfo.Manufacturer
    $model = $manufacturerInfo.Model
    

    
    ###
    ### Showing the menu
    ###
    Clear-Host

	Write-Host -ForegroundColor Cyan "
    +----+ +----+     
    |####| |####|     
    |####| |####|       WW   WW II NN   NN DDDDD   OOOOO  WW   WW  SSSS
    +----+ +----+       WW   WW II NNN  NN DD  DD OO   OO WW   WW SS
    +----+ +----+       WW W WW II NN N NN DD  DD OO   OO WW W WW  SSS
    |####| |####|       WWWWWWW II NN  NNN DD  DD OO   OO WWWWWWW    SS
    |####| |####|       WW   WW II NN   NN DDDDD   OOOO0  WW   WW SSSS
    +----+ +----+       
"
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host "              System Information"
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host "
    + Version                  $VersionNumber
    + $Date

    + Logged on as             $CurrUser
    + Domain/Workgroup         $Domain
    + Hostname                 $Hostname
    + IP Address               $IP

    + Windows Defender Firewall"

    for ($x = 0; $x -lt $firewallInfo.Count; $x++) {
        $fwProfile = $fwProfileList[$x]
        $fwProfileStatus = $fwProfileStatusList[$x]
        Write-Host "        ${fwProfile}: $fwProfileStatus"
    }

	Write-Host "
    + Remote management        $RemoteMGMT
    + Remote desktop           $RDP
    + Windows Admin Center     $WACStatus
    + Azure Arc                $azurearcstatus
    + Windows Updates          $AUOptions
    + Diagnostic data          $DiagData
    + Activation status        $Activation

    + OS                       $WindowsProduct
    + Version                  $OSDisplayVersion
    + Build                    $OSVersion

    + Manufacturer             $manufacturer
    + Model                    $model

    + System Running Since     $LastBoot
    + Total Uptime             $Uptime

    + RAM
        Total: $RAMInfo GB, Used: $UsedRAM GB, Free: $FreeRAM GB
    
    + Storage"

    foreach ($x in 0..($StorageInfo.Count - 1)) {
        $Volume = $VolumeList[$x]
        $VolumeUsedSize = $VolumeUsedSizeList[$x] #[math]::round(($VolumeUsedSizeList[$x] / 1GB), 2)
        $VolumeFreeSize = $VolumeFreeSizeList[$x] #[math]::round(($VolumeFreeSizeList[$x] / 1GB), 2)
        $VolumeTotalSize = $VolumeUsedSize + $VolumeFreeSize
		
		# Convert from Bytes to GB or TB based on size
		$VolumeUsedSize = Convert-Size -sizeInBytes $VolumeUsedSize
		$VolumeFreeSize = Convert-Size -sizeInBytes $VolumeFreeSize
		$VolumeTotalSize = Convert-Size -sizeInBytes $VolumeTotalSize
		
        Write-Host "        ${Volume}: Total: $VolumeTotalSize, Used: $VolumeUsedSize, Free: $VolumeFreeSize"
    }
      
    Write-Host "`n-----------------------------------------------------------------------------------"
    Write-Host "               Windows Server Core Management"
    Write-Host "-----------------------------------------------------------------------------------"
    
    Write-Host "
    System Configuration
    1) Hostname configuration
    2) Network configuration
    3) Domain/Workgroup configuration
    4) Remote management configuration
    5) Remote desktop configuration
    6) Windows Update configuration
    7) Date and time configuration
    8) Diagnostic data configuration
    9) Windows activation

    Local User & Group Configuration
    10) Add local user
    11) Add local administrator
    12) Add local group

    Actions
    13) Refresh
    14) Windows-Updates
    15) Log-off user
    16) Restart server
    17) Shut down server
    18) Open Terminal Window (command line)"

    ###
    ### Server Role Specific Options
    ###

    # Get Only Installed Windows Features on server
    $InstalledWinFeatures = Get-WindowsFeature | Where-Object { $_.Installed -eq $true }

    if($InstalledWinFeatures.Name -contains "AD-Domain-Services" -and $InstalledWinFeatures.Name -contains "DNS" -and $InstalledWinFeatures.Name -contains "GPMC"){
        Write-Host -ForegroundColor Yellow "    19) Active-Directory Management"
        $WinFeatureUnlocked = "true"
		
		Write-Host "-----------------------------------------------------------------------------------"
		if($WACStatus -eq "Installed"){
			Write-Host -ForegroundColor Yellow "    Windows Admin Center on a Domain-Controller is not supported!
    https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/plan/installation-options"
			Write-Host -ForegroundColor Cyan "
    To start the PSC sconfig, use the command 'psc_sconfig'"
		}
		elseif($WACStatus -eq "Not Installed"){
			Write-Host -ForegroundColor Cyan "
    To start the PSC sconfig, use the command 'psc_sconfig'"
		}
		Write-Host "-----------------------------------------------------------------------------------"
    }
	elseif($InstalledWinFeatures.Name -contains "Hyper-V" -and $InstalledWinFeatures.Name -contains "Hyper-V-Powershell"){
        Write-Host -ForegroundColor Yellow "    19) Hyper-V Management"
        $WinFeatureUnlocked = "true"
    }
    elseif($InstalledWinFeatures.Name -contains "AD-Domain-Services" -and $InstalledWinFeatures.Name -contains "DNS" -and $InstalledWinFeatures.Name -contains "GPMC") {
        Write-Host -ForegroundColor Yellow "    19) Active-Directory Management"
        if($manufacturer -eq "HPE"){
            Write-Host -ForegroundColor Yellow "    20) Install HPE SPP via ISO"
        }
        $WinFeatureUnlocked = "true"
		
		Write-Host "-----------------------------------------------------------------------------------"
		if($WACStatus -eq "Installed"){
			Write-Host -ForegroundColor Yellow "    Windows Admin Center on a Domain-Controller is not supported!
    https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/plan/installation-options"
			Write-Host -ForegroundColor Cyan "
    To start the PSC sconfig, use the command 'psc_sconfig'"
		}
		elseif($WACStatus -eq "Not Installed"){
			Write-Host -ForegroundColor Cyan "
    To start the PSC sconfig, use the command 'psc_sconfig'"
		}
		Write-Host "-----------------------------------------------------------------------------------"
    }
    elseif($InstalledWinFeatures.Name -contains "Hyper-V" -and $InstalledWinFeatures.Name -contains "Hyper-V-Powershell"){
        Write-Host -ForegroundColor Yellow "    19) Hyper-V Management"
        if($manufacturer -eq "HPE"){
            Write-Host -ForegroundColor Yellow "    20) Install HPE SPP via ISO"
        }
        $WinFeatureUnlocked = "true"
    }
    else {
        if($manufacturer -eq "HPE"){
            Write-Host -ForegroundColor Yellow "    19) Install HPE SPP via ISO"
        }

        # Nothing to display
        $WinFeatureUnlocked = "false"
		
		Write-Host "-----------------------------------------------------------------------------------"
		if($WACStatus -eq "Installed"){
			Write-Host -ForegroundColor Yellow "    Do you need a GUI? 
    Use the Windows Admin Center via https://$IP or https://$Hostname"
			Write-Host -ForegroundColor Cyan "
    To start the PSC sconfig, use the command 'psc_sconfig'"
		}
		elseif($WACStatus -eq "Not Installed"){
			Write-Host -ForegroundColor Yellow "    Do you need a GUI? Install Windows Admin Center from
    https://www.microsoft.com/de-de/windows-server/windows-admin-center"
			Write-Host -ForegroundColor Cyan "
    To start the PSC sconfig, use the command 'psc_sconfig'"
		}
		Write-Host "-----------------------------------------------------------------------------------"
    }

    
	

    if($WinFeatureUnlocked -eq "true" -and $manufacturer -ne "HPE"){
        do {
            $choice = Read-Host " Choose an Option (1-19)"
			Write-Log " User Input: $choice"
            switch ($choice) {
                1 { Set-Hostname }
                2 { Open-Network-Configuration }
                3 { Open-Domain-Configuration }
                4 { Open-RemoteMGMT-Configuration }
                5 { Open-RDP-Configuration }
                6 { Open-WindowsUpdate-Configuration }
                7 { Open-DateTime-Configuration }
                8 { Open-DiagnosticData-Configuration }
                9 { Set-Windows-Activation }
                10 { Add-LocalUser }
                11 { Add-LocalAdministrator }
                12 { Add-LocalGroup }
				13 { Show-Menu }
                14 { WindowsUpdates }
                15 { Start-Log-Off }
                16 { Restart-System }
                17 { Start-Shutdown-System }
                18 { Start-Terminal }
                19 { Start-Process powershell.exe -ArgumentList @(
                        '-ExecutionPolicy', 'Bypass',
                        '-WindowStyle', 'Maximized',
                        '-File', 'C:\_psc\psc_sconfig\WinFeatureManagement\windowsfeaturemanagement.ps1'
                    ) 
                }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne {1..19})
    }
    elseif($WinFeatureUnlocked -eq "true" -and $manufacturer -eq "HPE") {
        do {
            $choice = Read-Host " Choose an Option (1-20)"
			Write-Log " User Input: $choice"
            switch ($choice) {
                1 { Set-Hostname }
                2 { Open-Network-Configuration }
                3 { Open-Domain-Configuration }
                4 { Open-RemoteMGMT-Configuration }
                5 { Open-RDP-Configuration }
                6 { Open-WindowsUpdate-Configuration }
                7 { Open-DateTime-Configuration }
                8 { Open-DiagnosticData-Configuration }
                9 { Set-Windows-Activation }
                10 { Add-LocalUser }
                11 { Add-LocalAdministrator }
                12 { Add-LocalGroup }
				13 { Show-Menu }
                14 { WindowsUpdates }
                15 { Start-Log-Off }
                16 { Restart-System }
                17 { Start-Shutdown-System }
                18 { Start-Terminal }
                #19 { Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\psc_sconfig\WinFeatureManagement\windowsfeaturemanagement.ps1" }
                19 { Start-Process powershell.exe -ArgumentList @(
                        '-ExecutionPolicy', 'Bypass',
                        '-WindowStyle', 'Maximized',
                        '-File', 'C:\_psc\psc_sconfig\WinFeatureManagement\windowsfeaturemanagement.ps1'
                    ) 
                }
                20 { Start-Process powershell.exe -ArgumentList @(
                        '-ExecutionPolicy', 'Bypass',
                        '-WindowStyle', 'Maximized',
                        '-File', 'C:\_psc\HPE\custom_Install_HPE-SPP.ps1',
                        '-Update',
                        '-UseISO',
                        '-Mode', 'Manual'
                    )
                }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne {1..20})
    }
    elseif($WinFeatureUnlocked -ne "true" -and $manufacturer -eq "HPE") {
        do {
            $choice = Read-Host " Choose an Option (1-19)"
			Write-Log " User Input: $choice"
            switch ($choice) {
                1 { Set-Hostname }
                2 { Open-Network-Configuration }
                3 { Open-Domain-Configuration }
                4 { Open-RemoteMGMT-Configuration }
                5 { Open-RDP-Configuration }
                6 { Open-WindowsUpdate-Configuration }
                7 { Open-DateTime-Configuration }
                8 { Open-DiagnosticData-Configuration }
                9 { Set-Windows-Activation }
                10 { Add-LocalUser }
                11 { Add-LocalAdministrator }
                12 { Add-LocalGroup }
				13 { Show-Menu }
                14 { WindowsUpdates }
                15 { Start-Log-Off }
                16 { Restart-System }
                17 { Start-Shutdown-System }
                18 { Start-Terminal }
                19 { Start-Process powershell.exe -ArgumentList @(
                        '-ExecutionPolicy', 'Bypass',
                        '-WindowStyle', 'Maximized',
                        '-File', 'C:\_psc\HPE\custom_Install_HPE-SPP.ps1',
                        '-Update',
                        '-UseISO',
                        '-Mode', 'Manual'
                    )
                }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne {1..19})
    }
    else{
        do {
            $choice = Read-Host " Choose an Option (1-18)"
			Write-Log " User Input: $choice"
            switch ($choice) {
                1 { Set-Hostname }
                2 { Open-Network-Configuration }
                3 { Open-Domain-Configuration }
                4 { Open-RemoteMGMT-Configuration }
                5 { Open-RDP-Configuration }
                6 { Open-WindowsUpdate-Configuration }
                7 { Open-DateTime-Configuration }
                8 { Open-DiagnosticData-Configuration }
                9 { Set-Windows-Activation }
                10 { Add-LocalUser }
                11 { Add-LocalAdministrator }
                12 { Add-LocalGroup }
				13 { Show-Menu }
                14 { WindowsUpdates }
                15 { Start-Log-Off }
                16 { Restart-System }
                17 { Start-Shutdown-System }
                18 { Start-Terminal }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne {1..18})
    }
}

<#

function Show-SystemInfo {
    Write-Host "Showing Systeminformations..."
    Get-ComputerInfo
    Read-Host "Press Enter to return to menu"
}
#>


####
#### Network-Configuration
####

# Function to display network adapter information
<#function Get-NetworkAdapters {
    $teams = Get-NetLbfoTeam | where-object {$_.Status -eq 'Up' -or $_.Status -eq 'Degraded'}
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $teams.Members -notcontains $_.Name }
    $adapters | ForEach-Object {
        $adapterName = $_.Name
        $ipAddresses = (Get-NetIPAddress -InterfaceAlias $adapterName | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.Store -eq 'ActiveStore'}).IPAddress
        $dnsServers = (Get-DnsClientServerAddress -InterfaceAlias $adapterName).ServerAddresses
		$defaultGateway = (Get-NetRoute -InterfaceAlias $adapterName | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' }).NextHop
        $isDHCP = (Get-NetIPAddress -InterfaceAlias $adapterName | Where-Object { $_.PrefixOrigin -eq 'Dhcp' }).PrefixOrigin
        if($isDHCP -eq "Dhcp"){
            $isDHCP = "DHCP"
        }
        elseif($isDHCP -ne "Dhcp") {
            $isDHCP = "Static"
        }
        [PSCustomObject]@{
            AdapterName  = $adapterName
            IfIndex      = $_.ifIndex
            IPAddresses  = $ipAddresses -join ', '
			DefaultGateway = $defaultGateway -join ', '
            DNSServers   = $dnsServers -join ', '
            Type         = $isDHCP
        }
    }
}#>
function Get-NetworkAdapters {
	Write-Log " Get Network Adapter Information."
	$teams = Get-NetLbfoTeam | where-object {$_.Status -eq 'Up' -or $_.Status -eq 'Degraded'}
	$adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $teams.Members -notcontains $_.Name }
	
	if($teams){
		$IsTeam = "Yes"
	}
	else{
		$IsTeam = "No"
	}

	$adapters | ForEach-Object {
		$adapterName = $_.Name
		$ipAddresses = (Get-NetIPAddress -ErrorAction SilentlyContinue -InterfaceAlias $adapterName | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.Store -eq 'ActiveStore'}).IPAddress
		$prefix = (Get-NetIPAddress -ErrorAction SilentlyContinue -InterfaceAlias $adapterName | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.Store -eq 'ActiveStore'}).PrefixLength
		$prefix = "/$($prefix)"
		$dnsServers = (Get-DnsClientServerAddress -ErrorAction SilentlyContinue -InterfaceAlias $adapterName).ServerAddresses
		$defaultGateway = (Get-NetRoute -ErrorAction SilentlyContinue -InterfaceAlias $adapterName | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' }).NextHop
		$isDHCP = (Get-NetIPAddress -ErrorAction SilentlyContinue -InterfaceAlias $adapterName | Where-Object { $_.PrefixOrigin -eq 'Dhcp' }).PrefixOrigin
		if($isDHCP -eq "Dhcp"){
			$isDHCP = "DHCP"
		}
		elseif($isDHCP -ne "Dhcp") {
			$isDHCP = "Static"
		}
		
		
		$rdma = Get-NetAdapterRdma | where-object { $_.Name -like $adapterName}
		
		$rdmaStatus = $rdma.Enabled
		if($rdmaStatus -eq $True){
			$rdmaStatus = "Enabled"
		}
		elseif($rdmaStatus -eq $False){
			$rdmaStatus = "Disabled"
		}
		elseif($rdmaStatus -eq $null){
			$rdmaStatus = "Not Supported"
		}
		
		$rdmaOperational = $rdma.OperationalState
		if($rdmaOperational -eq $True){
			$rdmaOperational = "Yes"
		}
		elseif($rdmaOperational -eq $False){
			$rdmaOperational = "No"
		}
		elseif($rdmaOperational -eq $null){
			$rdmaOperational = "No"
		}
		
		# Only add to $adaptersInfo if the adapter has an IP address
		if ($ipAddresses) {
			[PSCustomObject]@{
				AdapterName  = $adapterName
				IfIndex      = $_.ifIndex
				IsTeam       = $IsTeam
				IPAddresses  = $ipAddresses -join ', '
				Prefix = $prefix
				DefaultGateway = $defaultGateway -join ', '
				DNSServers   = $dnsServers -join ', '
				Type         = $isDHCP
				RDMA         = $rdmaStatus
				RDMAOperational = $rdmaOperational
			}
		}

		<#[PSCustomObject]@{
			AdapterName  = $adapterName
			IfIndex      = $_.ifIndex
			IPAddresses  = $ipAddresses -join ', '
			DefaultGateway = $defaultGateway -join ', '
			DNSServers   = $dnsServers -join ', '
			Type         = $isDHCP
		}#>
	}
}

# Function to configure static IP
function Set-StaticIP {
    param (
        [Parameter(Mandatory=$true)]
        [int]$IfIndex
    )
	
	Write-Log " Starting Static-IP Configuration."
    
    $selectedAdapter = Get-NetAdapter -IfIndex $IfIndex
    if ($selectedAdapter) {
		Write-Log " You selected adapter: $($selectedAdapter.Name) (IfIndex: $($selectedAdapter.IfIndex))"
        Write-Host "
    You selected adapter: $($selectedAdapter.Name) (IfIndex: $($selectedAdapter.IfIndex))"
        
        # Disable DHCP
        try {
            Set-NetIPInterface -InterfaceIndex $IfIndex -Dhcp Disabled
            Write-Host "
    DHCP has been disabled."
        }
        catch {
			Write-Log " ERROR: DHCP could not be disabled.
	Reason: $_"
            Write-Warning "ERROR: DHCP could not be disabled.
	Reason: $_"
            return
        }

        # Enter Static IP address
        <#
        do {
            $ipAddress = Read-Host "Enter the static IP address"
            if ($ipAddress -match "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$") {
                $validIP = $true
            }
            else {
                Write-Warning "Invalid IP address format. Please enter a valid IP address."
                $validIP = $false
            }
        } while (-not $validIP)
        #>
		Write-Log " Enter Static IP address."
        do{
            $ipAddress = Read-Host "
    Enter the static IP address"
            Write-Log " User Input: $ipAddress"
            if($ipAddress -eq $selectedAdapter.DefaultGateway) #-or $ipAddress -eq $selectedAdapter.IPAddresses
            {
				Write-Log " IP Address is already in use."
                Write-Warning " IP Address is already in use."
            }
        } while([string]::IsNullOrEmpty($ipAddress) -or $ipAddress -eq $selectedAdapter.DefaultGateway -or $ipAddress -notmatch "^[0-9\.]+$") #-or $ipAddress -eq $selectedAdapter.IPAddresses


        # Enter Subnet Mask
        <#do {
            $subnetMask = Read-Host "
    Enter the subnet mask (e.g., 24 for 255.255.255.0)"
        } while ($subnetMask -notmatch "^\d{1,2}$")#>
        Write-Log " Enter Subnet Mask."
        do{
            $subnetMask = Read-Host "
    Enter the subnet mask (for '255.255.255.0', enter '24')"#
			Write-Log " User Input: $subnetMask"
        } while([string]::IsNullOrEmpty($subnetMask) -or $subnetMask -notmatch "^[0-9]")

        # Enter Gateway
        <#do {
            $gateway = Read-Host "
    Enter the default gateway"
            if ($gateway -match "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$") {
                $validGW = $true
            }
            else {
                Write-Warning "
    Invalid Gateway address format."
                $validGW = $false
            }
        } while (-not $validGW)#>
		Write-Log " Enter Default Gateway."
        do{
            $gateway = Read-Host "
    Enter the default gateway"
			Write-Log " User Input: $gateway"
            if($gateway -eq $selectedAdapter.IPAddresses) #-or $gateway -eq $selectedAdapter.DefaultGateway
            {
				Write-Log " IP Address is already in use."
                Write-Warning " IP Address is already in use."
            }
        } while([string]::IsNullOrEmpty($gateway) -or $gateway -eq $selectedAdapter.IPAddresses -or $gateway -notmatch "^[0-9\.]+$") #-or $gateway -eq $selectedAdapter.DefaultGateway

        # Remove current IP address
		Write-Log " Remove current IP address."
        Write-Host -ForegroundColor Yellow "    Removing current IP Configuration of Interface [$($selectedAdapter.IfIndex)]"
        try{
                    
            Remove-NetIPAddress -InterfaceIndex $selectedAdapter.IfIndex -Confirm:$False #-WhatIf
        }
        catch{
			Write-Log " ERROR: IP Address could not be removed.
    Reason: $_"
            Write-Warning "
    IP Address could not be removed.
    Reason: $_"
            return
        }
        # Remove the default gateway
        #$currentRoute = Get-NetRoute -InterfaceAlias $selectedAdapter.AdapterName | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' }
		Write-Log " Remove the default gateway."
        Write-Host -ForegroundColor Yellow "    Removing current Gateway Configuration of Interface [$($selectedAdapter.IfIndex)]"
        $currentGW = (Get-NetRoute -InterfaceIndex $selectedAdapter.IfIndex | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' }).NextHop
        if ($currentGW) {
            try{
                        
                Remove-NetRoute -InterfaceIndex $selectedAdapter.IfIndex -DestinationPrefix '0.0.0.0/0' -NextHop $currentGW -Confirm:$False #-WhatIf
            }
            catch{
				Write-Log " ERROR: IP Address and/or default gateway could not be removed.
    Reason: $_"
                Write-Warning "
    IP Address and/or default gateway could not be removed.
    Reason: $_"
                return
            }
        }

        # Set Static IP
		Write-Log " Set Static IP."
        try {
            $err = ""
            New-NetIPAddress -InterfaceIndex $IfIndex -IPAddress $ipAddress -PrefixLength $subnetMask -DefaultGateway $gateway -ErrorVariable err -ErrorAction inquire
            

            if([string]::IsNullOrEmpty($err)){
                # Let the system configure the Network 
                for ($i = 1; $i -le 100; $i++ ) {
                    Write-Progress -Activity "Configuration in Progress" -Status "$i% Complete:" -PercentComplete $i
                    Start-Sleep -Milliseconds 125
                }

                Write-Host "    Static IP configuration applied."
                $ipAssigned = "true"
            }
            else{
				Write-Log " ERROR: Static-IP could not be applied.
	Reason: $err"
                Write-Host "
    ERROR: Static-IP could not be applied.
	Reason: $err"
                $ipAssigned = "false"
            }
        }
        catch {
            Write-Log " ERROR: Static-IP could not be applied.
	Reason: $err"
            Write-Warning "
    ERROR: Static-IP could not be applied.
	Reason: $err"
            return
        }
		
		Write-Log " Prompt to change DNS settings."
		do{
			# Prompt to change DNS settings
			$changeDns = Read-Host "
	Do you want to change DNS settings? (Y/N)"
			Write-Log " User Input: $changeDns"
			if($changeDns -notmatch "^[YyNn]$"){
				Write-Log " Wrong Input."
				Write-Warning " Wrong Input."
			}
		}while([string]::IsNullOrEmpty($changeDns) -or $changeDns -notmatch "^[YyNn]$")
		
		if ($changeDns -match "^[Yy]$") {
			Set-DNS -IfIndex $IfIndex
		}
		elseif($changeDns -match "^[Nn]$"){
			Write-Log " DNS settings will not be changed."
			Write-Host -ForegroundColor Yellow "    DNS settings will not be changed."
		}
		
    }
    else {
		Write-Log " Selected adapter not found."
        Write-Warning "
    Selected adapter not found."
    }
	Open-Network-Configuration
}

# Function to configure DHCP IP
function Set-DHCP {
    param (
        [Parameter(Mandatory=$true)]
        [int]$IfIndex
    )
    
	Write-Log " Starting DHCP Configuration."
	
    $selectedAdapter = Get-NetAdapter -IfIndex $IfIndex
    if ($selectedAdapter) {
		Write-Log " You selected adapter: $($selectedAdapter.Name) (IfIndex: $($selectedAdapter.IfIndex))"
        Write-Host "
    You selected adapter: $($selectedAdapter.Name) (IfIndex: $($selectedAdapter.IfIndex))"
        
        # Enable DHCP
        try {
            Set-NetIPInterface -InterfaceIndex $selectedAdapter.IfIndex -Dhcp Enabled
            Write-Host "
    DHCP enabled."
        }
        catch {
			Write-Log "ERROR: DHCP could not be enabled.
	Reason: $_"
            Write-Warning "
    ERROR: DHCP could not be enabled.
	Reason: $_"
            return
        }
    }
    else {
		Write-Log " Selected adapter not found."
        Write-Warning "
    Selected adapter not found."
    }
	Open-Network-Configuration
}

# Function to configure DNS Server
function Set-DNS {
	param (
        [Parameter(Mandatory=$true)]
        [int]$IfIndex
    )
	
	Write-Log " Starting DNS Configuration."
	
	$selectedAdapter = Get-NetAdapter -IfIndex $IfIndex
	if ($selectedAdapter) {
		Write-Log " You selected adapter: $($selectedAdapter.Name) (IfIndex: $($selectedAdapter.IfIndex))"
        Write-Host "
    You selected adapter: $($selectedAdapter.Name) (IfIndex: $($selectedAdapter.IfIndex))"
	
		$newDns = Read-Host "
	Enter DNS server addresses (comma-separated like 'x.x.x.x,y.y.y.y')"
		Write-Log " Entered DNS Server: $newDns"
		$dnsArray = $newDns.Split(",") | ForEach-Object { $_.Trim() }

		# Set new DNS servers
		try{
			Set-DnsClientServerAddress -InterfaceIndex $selectedAdapter.IfIndex -ServerAddresses $dnsArray #-WhatIf
			Write-Host -ForegroundColor Green "
	DNS servers have been updated."
		}
		catch{
			Write-Log " ERROR: DNS servers have not been updated.
	Reason: $_"
			Write-Warning "
	DNS servers have not been updated.
	$_"
			Read-Host -Prompt " Press any key"
		}
	}
	else {
		Write-Log " Selected adapter not found."
        Write-Warning "
    Selected adapter not found."
		
    }
	Open-Network-Configuration
	
	<#$selectedAdapter = Get-NetAdapter -IfIndex $IfIndex
	if ($selectedAdapter) {
        Write-Host "
    You selected adapter: $($selectedAdapter.Name) (IfIndex: $($selectedAdapter.IfIndex))"
	
		do{
			# Prompt to change DNS settings
			$changeDns = Read-Host "
	Do you want to change DNS settings? (Y/N)"
			if($changeDns -notmatch "^[YyNn]$"){
				Write-Warning " Wrong Input."
			}
		}while([string]::IsNullOrEmpty($changeDns) -or $changeDns -notmatch "^[YyNn]$")

		if ($changeDns -match "^[Yy]$") {
			$newDns = Read-Host "
	Enter DNS server addresses (comma-separated)"
			$dnsArray = $newDns.Split(",") | ForEach-Object { $_.Trim() }

			# Set new DNS servers
			try{
				Set-DnsClientServerAddress -InterfaceAlias $selectedAdapter.AdapterName -ServerAddresses $dnsArray #-WhatIf
				Write-Host -ForegroundColor Green "
	DNS servers have been updated."
			}
			catch{
				Write-Warning "
	DNS servers have not been updated.
	$_"
			}
		}
	}
	else {
        Write-Warning "
    Selected adapter not found."
    }#>
	
}

# Function to configure NIC Teaming
function Set-Teaming-Configuration {
	Write-Log " Starting Teaming Configuration."
    $adaptersInfo = Get-NetAdapter

    # Prompt user to select network adapters by IfIndex
	Write-Log " Prompt user to select network adapters by IfIndex."
    do {
        #Write-Host "Available Network Adapters:"
        #$adaptersInfo | Format-Table -Property IfIndex, Name, Status
        $adapterChoice = Read-Host "
    Enter the IfIndexes of the network adapters you want to add to your team (comma-separated like '5,8')"
		Write-Log " User Input: $adapterChoice"
	
        $indexArray = $adapterChoice.Split(",") | ForEach-Object { $_.Trim() }
        
        # Check if all entered IfIndexes are valid (exist in adaptersInfo)
        $invalidIndexes = $indexArray | Where-Object { -not ($adaptersInfo.IfIndex -contains [int]$_) }
    } while ([string]::IsNullOrEmpty($adapterChoice) -or ($indexArray.Count -lt 2) -or $invalidIndexes)

    # Validate that the entered indexes match actual adapters
	Write-Log " Validate that the entered indexes match actual adapters."
    $validAdapters = $adaptersInfo | Where-Object { $indexArray -contains $_.IfIndex }
    $selectedAdapters = $validAdapters | Format-Table -Property IfIndex, Name
    Write-Log " Selected following adapters:"
	Write-Host "
    You selected the following adapters:"
    foreach($Adapter in $validAdapters){
		Write-Log " $($Adapter.Name) (IfIndex: $($Adapter.IfIndex))"
        Write-Host -ForegroundColor Yellow "
    $($Adapter.Name) (IfIndex: $($Adapter.IfIndex))"
        #$validAdapters | Format-Table -Property IfIndex, Name
    }
    

    # Prompt for team name
	Write-Log " Prompt for team name."
    $teamName = Read-Host "
    Enter a name for your new team (e.g., Team1)"
	Write-Log " User Input: $teamName"
    
    # Team configuration options
	Write-Log " Team configuration options."
    Write-Host "
    Select the Load Balancing and Failover Mode
    1) Static
    2) SwitchIndependent
    3) LACP"

    do{  
        $choice = Read-Host " Choose an option (1-3)"
		Write-Log " User Input: $choice"
        switch ($choice) {
            1 { $teamMode = "Static" }
            2 { $teamMode = "SwitchIndependent" }
            3 { $teamMode = "LACP" }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }
    }while ($choice -notmatch "^[1-3]")
    Write-Log " Select the Teaming Load Balancing Mode."
    Write-Host "
    Select the Teaming Load Balancing Mode
    1) Dynamic
    2) Transport Ports
    3) IP Addresses
    4) MAC Addresses
    5) Hyper-V Port"

    do{ 
        $choice = Read-Host " Choose an option (1-5)"
		Write-Log " User Input: $choice"
        switch ($choice) {
            1 { $teamTlbMode = "Dynamic" }
            2 { $teamTlbMode = "TransportPorts" }
            3 { $teamTlbMode = "IPAddresses" }
            4 { $teamTlbMode = "MacAddresses" }
            5 { $teamTlbMode = "HyperVPort" }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }
    }while ($choice -notmatch "^[1-5]")


    
    # Create the LBFO Team
	Write-Log " Creating the team '$teamName' with the selected adapters."
    Write-Host "
    Creating the team '$teamName' with the selected adapters..."
    try {
        $err = ""
        New-NetLbfoTeam -Name $teamName -TeamMembers $validAdapters.Name -TeamingMode $teamMode -LoadBalancingAlgorithm $teamTlbMode -ErrorVariable err -ErrorAction inquire

        if([string]::IsNullOrEmpty($err)){
            # Let the system configure the Network 
            for ($i = 1; $i -le 100; $i++ ) {
                Write-Progress -Activity "Configuration in Progress" -Status "$i% Complete:" -PercentComplete $i
                Start-Sleep -Milliseconds 125
            }

            Write-Host "    Team '$teamName' created."
            $teamCreated = "true"
        }
        else{
			Write-Log " ERROR: Team could not be created.
	Reason: $err"
            Write-Host -ForegroundColor Red "
    ERROR: Team could not be created. 
	Reason: $err"
            $teamCreated = "false"
        }
    } 
    catch {
		Write-Log " ERROR: Team could not be created.
	Reason: $err"
        Write-Host "
    ERROR: Team could not be created. 
	Reason: $err"
        $teamCreated = "false"
        return
    }
    

    # Get back to menu
    if($teamCreated -eq "false"){
        do {
            Write-Host "
        Configuration Options:
        1) Return to main menu
-----------------------------------------------------------------------------------"
            $choice = Read-Host " Choose an option (1)"
			Write-Log " User Input: $choice"
            switch ($choice) {
                1 { Show-Menu }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }
        } while ($choice -ne 1)
    }
    else {
        do {
            Write-Host "
        Configuration Options:
        1) Return to network configuration
        2) Return to main menu
-----------------------------------------------------------------------------------"
            $choice = Read-Host " Choose an option (1-2)"
			Write-Log " User Input: $choice"
            switch ($choice) {
                1 { Open-Network-Configuration } 
                2 { Show-Menu }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }
        } while ($choice -ne {1..2})
        <#do {
            Write-Host "
        Team Configuration Options:
        1) Configure Static IP
        2) Configure DHCP (Dynamic IP)
        3) Configure DNS
        4) Return to main menu
-----------------------------------------------------------------------------------"
            $choice = Read-Host " Choose an option (1-4)"
        
            switch ($choice) {
                1 { Set-StaticIP -IfIndex $validAdapters[0].IfIndex } 
                2 { Set-DHCP -IfIndex $validAdapters[0].IfIndex }
                3 { Set-DNS -IfIndex $validAdapters[0].IfIndex }
                4 { Show-Menu }
                default { Write-Host "Wrong Input. Please choose an option above." }
            }
        } while ($choice -ne {1..4})#>
    }
}

# Function to delete NIC Team
function Remove-Team {
	param (
        [Parameter(Mandatory=$true)]
        [int]$IfIndex
    )
	Write-Log " Starting Teaming deletion."
	
	$selectedAdapter = Get-NetAdapter -IfIndex $IfIndex
    if ($selectedAdapter) {
		Write-Log " You selected adapter: $($selectedAdapter.Name) (IfIndex: $($selectedAdapter.IfIndex))"
        Write-Host "
    You selected adapter: $($selectedAdapter.Name) (IfIndex: $($selectedAdapter.IfIndex))"
	
		# Delete Team
        try {
            Remove-NetLbfoTeam -Name "$($selectedAdapter.Name)"
            Write-Host "
    Team has been deleted."
        }
        catch {
			Write-Log " ERROR: Team could not be deleted.
	Reason: $_"
            Write-Warning "ERROR: Team could not be deleted.
	Reason: $_"
            
			Read-Host -Prompt "Press any key"
        }
	}
	else {
		Write-Log " Selected team not found."
        Write-Warning "
    Selected team not found."
    }
	Open-Network-Configuration
	
}

# Function to rename network adapter
function Update-Adapter-Name {
    param (
        [Parameter(Mandatory=$true)]
        [int]$IfIndex
    )
	
	Write-Log "User chose to rename Network Adapter."
	
	$selectedAdapter = Get-NetAdapter -IfIndex $IfIndex
	
	if ($selectedAdapter) {
		Write-Log " You selected adapter: $($selectedAdapter.Name) (IfIndex: $($selectedAdapter.IfIndex))"
        Write-Host "
    You selected adapter: $($selectedAdapter.Name) (IfIndex: $($selectedAdapter.IfIndex))"
	
		do{
			$NewNICName = Read-Host "
	Enter a name for the network adapter"
		} while ([string]::IsNullOrEmpty($NewNICName))
				
		Write-Log " Entered NIC Name: $NewNICName"
			
		try{
			Rename-NetAdapter -Name "$($selectedAdapter.Name)" -newName "$NewNICName"
		}
		catch{
			Write-Log " ERROR: Network Adapter could not be renamed.
	$_"
			Write-Warning "
	Network Adapter could not be renamed.
	$_"
			Read-Host -Prompt " Press any key"
		}
	}
	else {
		Write-Log " Selected adapter not found."
        Write-Warning "
    Selected adapter not found."
		Read-Host -Prompt " Press any key"
    }
	Open-Network-Configuration
	
}

# Function to configure RDMA
function Set-RDMA {
	param (
        [Parameter(Mandatory=$true)]
        [int]$IfIndex,
		[string]$RDMA
    )
	
	Write-Log "User chose to configure RDMA."
	
	$selectedAdapter = Get-NetAdapter -IfIndex $IfIndex
	
	if ($selectedAdapter -and $RDMA -eq "Disabled") {
		Write-Log " You selected adapter: $($selectedAdapter.Name) (IfIndex: $($selectedAdapter.IfIndex))"
        Write-Host "
    You selected adapter: $($selectedAdapter.Name) (IfIndex: $($selectedAdapter.IfIndex))"
		Write-Log " Enabling RDMA on network adapter."
		try{
			Enable-NetAdapterRdma -Name "$($selectedAdapter.Name)"
		}
		catch{
			Write-Log " ERROR: RDMA could not be enabled.
	$_"
			Write-Warning "
	RDMA could not be enabled.
	$_"
			Read-Host -Prompt " Press any key"
		}
	}
	elseif ($selectedAdapter -and $RDMA -eq "Enabled") {
		Write-Log " You selected adapter: $($selectedAdapter.Name) (IfIndex: $($selectedAdapter.IfIndex))"
        Write-Host "
    You selected adapter: $($selectedAdapter.Name) (IfIndex: $($selectedAdapter.IfIndex))"
		Write-Log " Disabling RDMA on network adapter."
		try{
			Disable-NetAdapterRdma -Name "$($selectedAdapter.Name)"
		}
		catch{
			Write-Log " ERROR: RDMA could not be disabled.
	$_"
			Write-Warning "
	RDMA could not be disabled.
	$_"
			Read-Host -Prompt " Press any key"
		}
	}
	Open-Network-Configuration
}

# Function for Test Connection
function ConnectionTest {
	Write-Log "User chose to test connection."
	
	do{
		$ipAddress = Read-Host "
    Enter an IP address"
		Write-Log " User Input: $ipAddress"
    } while([string]::IsNullOrEmpty($ipAddress) -or $ipAddress -notmatch "^[0-9\.]+$") #-or $ipAddress -eq $selectedAdapter.IPAddresses
	
	if($ipAddress) {
		try{
			$conTest = Test-NetConnection $ipAddress
		}
		catch{
			Write-Log " ERROR: Connection Test failed.
	Reason: $_"
            Write-Warning "
    ERROR: ERROR: Connection Test failed.
	Reason: $_"
			
			Read-Host -Prompt " Press any key"
		}
	}
	$RemoteAddress = $conTest.RemoteAddress
	$SourceAddress = $conTest.SourceAddress.IPAddress
	$Interface = $conTest.InterfaceAlias
	$PingStatus = $conTest.PingReplyDetails.Status
	$ReplyDetails = $conTest.PingReplyDetails.RoundTripTime
	Write-Log " Test Result: Remote Address $RemoteAddress - Source Address $SourceAddress - Used Interface $Interface - Ping Succeeded $PingSucceeded"
	Write-Host "
    Test Result:
    Remote Address:        $RemoteAddress
    Source Address:        $SourceAddress
    Used Interface:        $Interface
    Pind Status:           $PingStatus
    Ping Reply (RRT):      $ReplyDetails ms
"
	#Open-Network-Configuration
}

# Main Network Configuration Function
function Open-Network-Configuration {
	Write-Log " Starting Network Configuration."
    Clear-Host
    $setDynamicIp = ""
	$setStaticIp = ""
	$selectConfig = ""
    $adaptersInfo = Get-NetworkAdapters
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host "
    Available network interfaces: "
    $adaptersInfo | Format-Table -Property IfIndex, AdapterName, IsTeam, IPAddresses, Prefix, DefaultGateway, DNSServers, Type, RDMA, RDMAOperational
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host "
    Network configuration...
	"

    # Ask user if they want to continue with single NIC Config or Teaming Config
	Write-Log " Ask user if they want to continue with single NIC Config or Teaming Config."
    do {
		Write-Host "
    1) Configure Network Adapter
    2) Create new Team
    3) Refresh
	
    e) Leave
"
        $Continue = Read-Host " Choose an option (1-3/e)"
		Write-Log " User Input: $Continue"
		
		if ($Continue -eq "1") {
			Write-Log " Prompt user to select a network adapter by IfIndex."
			do {
				# Prompt user to select a network adapter by IfIndex
				$adapterChoice = Read-Host "
    Enter the Index of the network adapter you want to configure"
				Write-Log " User Input: $adapterChoice"
			} while ([string]::IsNullOrEmpty($adapterChoice) -or $adapterChoice -notmatch "^[0-9]" -or $adaptersInfo.IfIndex -notcontains $adapterChoice)

			# Validate if the user input is a valid IfIndex
			$selectedAdapter = $adaptersInfo | Where-Object { $_.IfIndex -eq [int]$adapterChoice }
			Write-Log " Selected Adapter: $selectedAdapter"
			if ($selectedAdapter) 
			{
				Write-Log " Selected adapter: $($selectedAdapter.AdapterName) (IfIndex: $($selectedAdapter.IfIndex))"
				Write-Host "
    Selected adapter: $($selectedAdapter.AdapterName) (IfIndex: $($selectedAdapter.IfIndex))"
				
				if($selectedAdapter.IsTeam -eq "No"){
					Write-Host "
    What do you want to do?
    1) Static IP configuration
    2) DHCP configuration
    3) DNS configuration
    4) Rename Network Adapter
			
    5) Test Connection"
					if($selectedAdapter.RDMA -ne "Not Supported" -and $selectedAdapter.RDMA -eq "Disabled"){
						Write-Host "    6) Enable RDMA"
					}
					elseif($selectedAdapter.RDMA -ne "Not Supported" -and $selectedAdapter.RDMA -eq "Enabled"){
						Write-Host "    6) Disable RDMA"
					}
					Write-Host "    7) Refresh
			
    8) Return to main menu
-----------------------------------------------------------------------------------"
					
					if($selectedAdapter.RDMA -ne "Not Supported"){
						do {
						
							$choice = Read-Host " Choose an Option (1-8)"
							Write-Log " User Input: $choice"
							switch ($choice) {
								1 { Set-StaticIP -IfIndex $selectedAdapter.IfIndex }
								2 { Set-DHCP -IfIndex $selectedAdapter.IfIndex }
								3 { Set-DNS -IfIndex $selectedAdapter.IfIndex }
								4 { Update-Adapter-Name -IfIndex $selectedAdapter.IfIndex }
								5 { ConnectionTest }
								6 { Set-RDMA -IfIndex $selectedAdapter.IfIndex -RDMA $selectedAdapter.RDMA }
								7 { Open-Network-Configuration }
								8 { Show-Menu }
								default { 
									Write-Log " Wrong Input."
									Write-Host "Wrong Input. Please choose an option above." 
								}
							}

						} while ($choice -ne {1..8})
					}
					else{
						do {
						
							$choice = Read-Host " Choose an Option (1-5/7-8)"
							Write-Log " User Input: $choice"
							switch ($choice) {
								1 { Set-StaticIP -IfIndex $selectedAdapter.IfIndex }
								2 { Set-DHCP -IfIndex $selectedAdapter.IfIndex }
								3 { Set-DNS -IfIndex $selectedAdapter.IfIndex }
								4 { Update-Adapter-Name -IfIndex $selectedAdapter.IfIndex }
								5 { ConnectionTest }
								7 { Open-Network-Configuration }
								8 { Show-Menu }
								default { 
									Write-Log " Wrong Input."
									Write-Host "Wrong Input. Please choose an option above." 
								}
							}

						} while ($choice -ne {1..5} -and $choice -ne {7..8})
					}
				}
				elseif($selectedAdapter.IsTeam -eq "Yes"){
					Write-Host "
    What do you want to do?
    1) Static IP configuration
    2) DHCP configuration
    3) DNS configuration
    4) Rename Network Adapter
    5) Delete Team
			
    6) Test Connection"
					if($selectedAdapter.RDMA -ne "Not Supported" -and $selectedAdapter.RDMA -eq "Disabled"){
						Write-Host "    7) Enable RDMA"
					}
					elseif($selectedAdapter.RDMA -ne "Not Supported" -and $selectedAdapter.RDMA -eq "Enabled"){
						Write-Host "    7) Disable RDMA"
					}
					Write-Host "    8) Refresh
			
    9) Return to main menu
-----------------------------------------------------------------------------------"
					
					if($selectedAdapter.RDMA -ne "Not Supported"){
						do {
						
							$choice = Read-Host " Choose an Option (1-8)"
							Write-Log " User Input: $choice"
							switch ($choice) {
								1 { Set-StaticIP -IfIndex $selectedAdapter.IfIndex }
								2 { Set-DHCP -IfIndex $selectedAdapter.IfIndex }
								3 { Set-DNS -IfIndex $selectedAdapter.IfIndex }
								4 { Update-Adapter-Name -IfIndex $selectedAdapter.IfIndex }
								5 { Remove-Team -IfIndex $selectedAdapter.IfIndex }
								6 { ConnectionTest }
								7 { Set-RDMA -IfIndex $selectedAdapter.IfIndex -RDMA $selectedAdapter.RDMA }
								8 { Open-Network-Configuration }
								9 { Show-Menu }
								default { 
									Write-Log " Wrong Input."
									Write-Host "Wrong Input. Please choose an option above." 
								}
							}

						} while ($choice -ne {1..8})
					}
					else{
						do {
						
							$choice = Read-Host " Choose an Option (1-6/8-9)"
							Write-Log " User Input: $choice"
							switch ($choice) {
								1 { Set-StaticIP -IfIndex $selectedAdapter.IfIndex }
								2 { Set-DHCP -IfIndex $selectedAdapter.IfIndex }
								3 { Set-DNS -IfIndex $selectedAdapter.IfIndex }
								4 { Update-Adapter-Name -IfIndex $selectedAdapter.IfIndex }
								5 { Remove-Team -IfIndex $selectedAdapter.IfIndex }
								6 { ConnectionTest }
								8 { Open-Network-Configuration }
								9 { Show-Menu }
								default { 
									Write-Log " Wrong Input."
									Write-Host "Wrong Input. Please choose an option above." 
								}
							}

						} while ($choice -ne {1..6} -and $choice -ne {8..9})
					}
				}
				
				
				<#
				do{
					$selectConfig = Read-Host "
		Do you want to change the full network configuration or dns settings only? (F/D)"
				}while($selectConfig -ne "F" -and $selectConfig -ne "D")
				
				if($selectConfig -eq "F"){
				
					# Ask whether to set static or dynamic IP
					if ($selectedAdapter.Type -eq "DHCP") {
						$setStaticIp = Read-Host "
		Do you want to set a static IP address? (Y/N)"
						if ($setStaticIp -match "^[Yy]$") {
							Set-StaticIP -IfIndex $selectedAdapter.IfIndex
						}
						elseif ($setStaticIp -match "^[Nn]$") {
							
							$setDynamicIp = Read-Host "
		Do you want to set a dynamic IP address (DHCP)? (Y/N)"
							if ($setDynamicIp -match "^[Yy]$") {
								Set-DHCP -IfIndex $selectedAdapter.IfIndex
							}
							elseif ($setDynamicIp -match "^[Nn]$") {
								Write-Host -ForegroundColor Yellow "    Aborting configuration..."
							}
						}
					}
					elseif ($selectedAdapter.Type -eq "Static") {
						$setDynamicIp = Read-Host "
		Do you want to set a dynamic IP address (DHCP)? (Y/N)"
						if ($setDynamicIp -match "^[Yy]$") {
							Set-DHCP -IfIndex $selectedAdapter.IfIndex
						}
						elseif ($setDynamicIp -match "^[Nn]$") {
							
							$setStaticIp = Read-Host "
		Do you want to set a static IP address? (Y/N)"
							if ($setStaticIp -match "^[Yy]$") {
								Set-StaticIP -IfIndex $selectedAdapter.IfIndex
							}
							elseif ($setStaticIp -match "^[Nn]$") {
								Write-Host -ForegroundColor Yellow "    Aborting configuration..."
							}
						}
					}
				}
				elseif($selectConfig -eq "D"){
					Set-DNS -IfIndex $selectedAdapter.IfIndex
				}
				#>

			} 
			else {
				Write-Log " Invalid Interface selected."
				Write-Host " Invalid Interface selected. Please ensure you enter a valid number."
			}
			Write-Host "
    1) Return to main menu
-----------------------------------------------------------------------------------"

			do {
				$choice = Read-Host " Choose an Option (1)"
				Write-Log " User Input: $choice"
				switch ($choice) {
					1 { Show-Menu }
					default { 
						Write-Log " Wrong Input."
						Write-Host "Wrong Input. Please choose an option above." 
					}
				}

			} while ($choice -ne 1)
		}
		elseif($Continue -eq "2") {
			Set-Teaming-Configuration
		}
		elseif($Continue -eq "3"){
			Write-Log " Refreshing network configuration."
			Open-Network-Configuration
		}
		elseif ($Continue -eq "E") {
			Write-Log " Returning to main menu."
			Write-Host "Returning to main menu..."
			Show-menu
		}
		
    } while ($Continue -ne {1..3} -and $Continue -ne "E")

    
}


####
#### RemoteMGMT-Configuration
####
function Disable-RemoteMGMT {
	Write-Log " Disable WinRM."
	$Startup = Get-Service "WinRM" | Select-Object -Property StartType
	$Status = Get-Service "WinRM" | Select-Object -Property Status
	
	if($Status.Status -eq "Running") {
		Write-Log " Stopping Service 'WinRM'."
		try{
			Get-Service -Name "WinRM" | Stop-Service -Force
		}
		catch{
			Write-Log " ERROR: Remote Management can not be stopped.
	Reason: $_"
			Write-Warning "
	Remote Management can not be stopped.
	$_"
		}
	}
	
	if($Startup.StartType -ne "Manual") {
		Write-Log " Set Service 'WinRM' Startup Type to 'Manual'."
		try{
			Set-Service -Name "WinRM" -StartupType Manual
		}
		catch{
			Write-Log " ERROR: Remote Management can not be disabled.
	Reason: $_"
			Write-Warning "
	Remote Management can not be disabled.
	$_"
		}
	}
	
    Open-RemoteMGMT-Configuration
}

function Enable-RemoteMGMT {
	Write-Log " Enable WinRM."
	$Startup = Get-Service "WinRM" | Select-Object -Property StartType
	$Status = Get-Service "WinRM" | Select-Object -Property Status
	
	if($Startup.StartType -eq "Manual") {
		Write-Log " Set Service 'WinRM' Startup Type to 'Automatic'."
		try{
			Set-Service -Name "WinRM" -StartupType Automatic
		}
		catch{
			Write-Log " ERROR: Remote Management can not be enabled.
	Reason: $_"
			Write-Warning "
	Remote Management can not be enabled.
	$_"
		}
	}
	
	if($Status.Status -eq "Stopped") {
		Write-Log " Starting Service 'WinRM'."
		try{
			Get-Service -Name "WinRM" | Start-Service
		}
		catch{
			Write-Log " ERROR: Remote Management can not be started.
	Reason: $_"
			Write-Warning "
	Remote Management can not be started.
	$_"
		}
	}

    Open-RemoteMGMT-Configuration
}

function Open-RemoteMGMT-Configuration {
	Write-Log " Remote Management Configuration."
    Clear-Host
    $RemoteMGMT = Get-Service -Name "WinRM" | select-object Status
    if($RemoteMGMT.Status -eq "Running") {
        $RemoteMGMT = "Enabled"
    }
    elseif($RemoteMGMT.Status -ne "Running"){
        $RemoteMGMT = "Disabled"
    }
	Write-Log " Current Remote Management Status: $RemoteMGMT"
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host "    Current Remote Management Status: $RemoteMGMT"
    Write-Host "-----------------------------------------------------------------------------------"
    if($RemoteMGMT -eq "Enabled"){
        Write-Host " 
    Remote Management configuration"
        Write-Host "
        1) Disable Remote Management
        2) Return to main menu
-----------------------------------------------------------------------------------"

        do {
            $choice = Read-Host " Choose an Option (1-2)"
			Write-Log " User input: $choice"
            switch ($choice) {
                1 { Disable-RemoteMGMT }
                2 { Show-Menu }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne {1..2})
    }
    elseif($RemoteMGMT -eq "Disabled"){
        Write-Host " 
    Remote Management configuration"
        Write-Host "
        1) Enable Remote Management
        2) Return to main menu
-----------------------------------------------------------------------------------"

        do {
            $choice = Read-Host " Choose an Option (1-2)"
			Write-Log " User input: $choice"
            switch ($choice) {
                1 { Enable-RemoteMGMT }
                2 { Show-Menu }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne {1..2})
    }
}

####
#### RDP-Configuration
####
function Disable-RDP {
	Write-Log " Disable Remote Desktop."
	Write-Log " Setting regestry value 'HKLM:\System\CurrentControlSet\Control\Terminal Server\fDenyTSConnections' to '1'."
    try{
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 1
    }
    catch{
		Write-Log " ERROR: Remote Desktop can not be disabled.
    Reason: $_"
        Write-Warning "
    Remote Desktop can not be disabled.
    $_"
    }
    <#try{
        Disable-NetFirewallRule -DisplayGroup "Remote Desktop"
    }
    catch{
        Write-Warning "
    Remote Desktop can not be disabled trough firewall.
    $_"
    }#>
    
    Open-RDP-Configuration
}

function Enable-RDP {
	Write-Log " Enable Remote Desktop."
	Write-Log " Setting regestry value 'HKLM:\System\CurrentControlSet\Control\Terminal Server\fDenyTSConnections' to '0'."
    try{
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
    }
    catch{
		Write-Log " ERROR: Remote Desktop can not be enabled.
    Reason: $_"
        Write-Warning "
    Remote Desktop can not be enabled.
    $_"
    }
    <#try{
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
    }
    catch{
        Write-Warning "
    Remote Desktop can not be enabled trough firewall.
    $_"
    }#>
    
    Open-RDP-Configuration
}

function Open-RDP-Configuration {
	Write-Log " Remote Desktop Configuration."
    Clear-Host
    $RdpStatus = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections
    if ($RdpStatus.fDenyTSConnections -eq 0) {
        $RDP = "Enabled"
    } elseif($RdpStatus.fDenyTSConnections -eq 1) {
        $RDP = "Disabled"
    }
    <#try {
		$RDPFWRules = Get-NetFirewallRule -Group "@FirewallAPI.dll,-28752" | select-object DisplayName,DisplayGroup,Description,Enabled | fl
	}
	catch {
		Write-Warning "
    Something went wrong. Could not fetch firewall settings for RDP.
	$_"
	}#>
	Write-Log " Current Remote Desktop Status: $RDP"
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host "    Current Remote Desktop Status: $RDP"
    Write-Host "-----------------------------------------------------------------------------------"
    if($RDP -eq "Enabled"){
        Write-Host " 
    Remote Management configuration"
        Write-Host "
        1) Disable Remote Desktop
        2) Return to main menu
-----------------------------------------------------------------------------------"

        do {
            $choice = Read-Host " Choose an Option (1-2)"
			Write-Log " User input: $choice"
            switch ($choice) {
                1 { Disable-RDP }
                2 { Show-Menu }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne {1..2})
    }
    elseif($RDP -eq "Disabled"){
        Write-Host " 
    Remote Management configuration"
        Write-Host "
        1) Enable Remote Desktop
        2) Return to main menu
-----------------------------------------------------------------------------------"

        do {
            $choice = Read-Host " Choose an Option (1-2)"
			Write-Log " User input: $choice"
            switch ($choice) {
                1 { Enable-RDP }
                2 { Show-Menu }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne {1..2})
    }
}

####
#### WindowsUpdate-Configuration
####
function Set-WUSvc {
	Write-Log " Set Windows Update Service."
    $UpdateSvc = Get-Service -Name wuauserv | select-object Status

    if($UpdateSvc.Status -eq "Running"){
		Write-Log " Disabling Windows Update Service."
        try{
            Get-Service -Name wuauserv | Stop-Service
        }
        catch{
			Write-Log " ERROR: Windows Update Service can not be stopped.
    Reason: $_"
            Write-Warning "
    Windows Update Service can not be stopped.
    $_"
        }
    }
    elseif($UpdateSvc.Status -eq "Stopped"){
		Write-Log " Enabling Windows Update Service."
        try{
            Get-Service -Name wuauserv | Start-Service
        }
        catch{
			Write-Log " ERROR: Windows Update Service can not be started.
    Reason: $_"
            Write-Warning "
    Windows Update Service can not be started.
    $_"
        }
    }

    Open-WindowsUpdate-Configuration
}

function Set-AUOpt2 {
	Write-Log " Set Windows Update Automatic Update Option 2."
	try{
		Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name AUOptions -Value 2
	}
	catch{
		Write-Log " Automatic Windows Update option can not be changed.
	$_"
		Write-Warning "
	Automatic Windows Update oprion can not be changed.
	$_"
	}
	
	Open-WindowsUpdate-Configuration
}

function Set-AUOpt3 {
	Write-Log " Set Windows Update Automatic Update Option 3."
	try{
		Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name AUOptions -Value 3
	}
	catch{
		Write-Log " Automatic Windows Update option can not be changed.
	$_"
		Write-Warning "
	Automatic Windows Update option can not be changed.
	$_"
	}
	
	Open-WindowsUpdate-Configuration
}

function Set-WUAUOpt {
	Write-Log " Set Windows Update Automatic Update Options."
    Write-Host " 
    Windows Update automatic options configuration
        1) Notify before download
        2) Automatically download and notify of installation
        3) Return to Windows Update configuration menu"
    Write-Host "-----------------------------------------------------------------------------------"

    do {
        $choice = Read-Host " Choose an Option (1-3)"
		Write-Log " User input: $choice"
        switch ($choice) {
            1 { Set-AUOpt2 }
            2 { Set-AUOpt3 }
            3 { Open-WindowsUpdate-Configuration }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne {1..3})
}

function Set-WUAU {
	Write-Log " Set Windows Update Automatic Update."
	
    $GetWSUSSettings = Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU | select-object NoAutoUpdate

    if($GetWSUSSettings.NoAutoUpdate -eq 1){
		Write-Log " Enable Automatic Update."
		Write-Log " Set 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\NoAutoUpdate' to '0'."
        try{
            Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 0
        }
        catch{
			Write-Log " Automatic Windows Update can not be enabled.
    $_"
            Write-Warning "
    Automatic Windows Update can not be enabled.
    $_"
            
        }
    }
    elseif($GetWSUSSettings.NoAutoUpdate -eq 0){
		Write-Log " Disable Automatic Update."
		Write-Log " Set 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\NoAutoUpdate' to '1'."
        try{
            Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 1
        }
        catch{
			Write-Log " Automatic Windows Update can not be disabled.
    $_"
            Write-Warning "
    Automatic Windows Update can not be disabled.
    $_"
            
        }
    }
    elseif(!($GetWSUSSettings.NoAutoUpdate)){
        <#try{
			New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 1
		}#>
		Write-Log " Enable Automatic Update."
		Write-Log " Set 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\NoAutoUpdate' to '0'."
		try{
            Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 1
        }
        catch{
			Write-Log " Automatic Windows Update can not be enabled.
    $_"
            Write-Warning "
    Automatic Windows Update can not be enabled.
    $_"
        }
    }

    Open-WindowsUpdate-Configuration
}

function Open-WindowsUpdate-Configuration {
	Write-Log " Windows Update Basic Configuration."
    Clear-Host
    $UpdateSvc = Get-Service -Name wuauserv | select-object Status
    $GetWSUSInfo = Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate | select-object WUServer,WUStatusServer,ElevateNonAdmins,DoNotConnectToWindowsUpdateInternetLocations,SetUpdateNotificationLevel,UpdateNotificationLevel
    $GetWSUSSettings = Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU | select-object AUOptions,UseWUServer,NoAutoRebootWithLoggedOnUsers,NoAutoUpdate,ScheduledInstallDay,ScheduledInstallTime

    if ($GetWSUSSettings.AUOptions -eq 2) {
        $AUOptions = "Notify before download"
    }
    elseif ($GetWSUSSettings.AUOptions -eq 3) {
        $AUOptions = "Automatically download and notify of installation"
    }
    elseif ($GetWSUSSettings.AUOptions -eq 4) {
        $AUOptions = "Automatic download and scheduled installation (Opnly valid if 'Scheduled Install Settings' are configured!)"
    }
    elseif ($GetWSUSSettings.AUOptions -eq 5) {
        $AUOptions = "Automatic Updates is required, but end users can configure it"
    }    
    elseif ($GetWSUSSettings.AUOptions -ne 2 -and $GetWSUSSettings.AUOptions -ne 3 -and $GetWSUSSettings.AUOptions -ne 4 -and $GetWSUSSettings.AUOptions -ne 5) {
        $AUOptions = "Not Set"
    }
    
    if($GetWSUSSettings.NoAutoUpdate -eq 1)
    {
        $AutoUpdate = "Disabled"
    }
    elseif($GetWSUSSettings.NoAutoUpdate -eq 0)
    {
        $AutoUpdate = "Enabled"
    }
    elseif(!($GetWSUSSettings.NoAutoUpdate)){
        $AutoUpdate = "Manual"
    }
	Write-Log " Current Windows Update Service Status: $($UpdateSvc.Status)"
	Write-Log " Current Windows Update Configuration: $AUOptions"
	Write-Log " Current Windows Update automatic mechanism: $AutoUpdate"
	
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host "    Current Windows Update Service Status:         $($UpdateSvc.Status)"
    Write-Host "    Current Windows Update Configuration:          $AUOptions"
    Write-Host "    Current Windows Update automatic mechanism:    $AutoUpdate"
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host " 
    Windows Update configuration"
    if($UpdateSvc.Status -eq "Running"){
        Write-Host "    1. Stop Windows Update Service"      
    }
    elseif($UpdateSvc.Status -eq "Stopped"){
        Write-Host "    1. Start Windows Update Service"      
    }

    Write-Host "    2. Set automatic update configuration option"

    if($AutoUpdate -eq "Manual" -or $AutoUpdate -eq "Disabled"){
        Write-Host "    3. Enable automatic Windows Update mechanism"       
    }
    elseif($AutoUpdate -eq "Enabled"){
        Write-Host "    3. Disable automatic Windows Update mechanism"       
    }
    Write-Host "    4. Return to main menu"
    Write-Host "-----------------------------------------------------------------------------------"

    do {
        $choice = Read-Host " Choose an Option (1-4)"
		Write-Log " User input: $choice"
        switch ($choice) {
            1 { Set-WUSvc }
            2 { Set-WUAUOpt }
            3 { Set-WUAU }
            4 { Show-Menu }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne {1..4})
}


####
#### DateTime-Configuration
####
# Function to display current date, time, and timezone
function Get-DateTimeAndTimezone {
	Write-Log " Get Date and Time and TimeZone Information."
    $currentDateTime = Get-Date
    $currentTimeZone = Get-TimeZone
    [PSCustomObject]@{
        CurrentDateTime = $currentDateTime.ToString("dddd, MMMM dd, yyyy hh:mm tt")
        TimeZone     = $currentTimeZone.Id
        UTC  = $currentTimeZone.DisplayName
    }
}

function Set-DateAndTime {
	Write-Log " Setting Date and Time."
    # Loop until valid input is received
    do {
        # Get new date/time input
        $newDateTime = Read-Host "
    Enter the new date and time (dd/MM/yyyy HH:mm:ss)"
        Write-Log " User input: $newDateTime"
        # Validate the date/time format
        if ($newDateTime -match "^\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}$") {
            try {
                $formattedDateTime = [datetime]::ParseExact($newDateTime, "dd/MM/yyyy HH:mm:ss", $null)
                Set-Date -Date $formattedDateTime
				Write-Log " Date and time have been updated to $formattedDateTime"
                Write-Host "
    Date and time have been updated to $formattedDateTime"
                $validInput = $true
            } catch {
				Write-Log " Date and Time could not be set.
	Reason: $_"
                Write-Warning "
    Date and Time could not be set."
                $validInput = $false
            }
        } 
        else {
			Write-Log " Invalid date/time format."
            Write-Warning "
    Invalid date/time format. Please use dd/MM/yyyy HH:mm:ss."
            $validInput = $false
        }
    }while(-not $validInput)
    Open-DateTime-Configuration
}

function Set-SystemTimeZone {
    Write-Log " Setting time zone."
    # List available timezones with numeric index
    Write-Host "
    Listing available timezones...
    "
    $timeZones = Get-TimeZone -ListAvailable
    $index = 0
    $timeZones | ForEach-Object { 
        Write-Host "        ${index}: $($_.Id) - $($_.DisplayName)" 
        $index += 1
    }

    # Loop until valid input is received
    do {
        # Get user choice for timezone by numeric index
        $selectedIndex = Read-Host "
    Enter the numeric index of the timezone you want to set (e.g. '51')"
		Write-Log " User input: $selectedIndex"
        # Check if the entered index is a valid number
        if ($selectedIndex -match '^\d+$') {
            $selectedIndex = [int]$selectedIndex

            # Ensure the index is within valid range
            if ($selectedIndex -ge 0 -and $selectedIndex -lt $timeZones.Count) {
                # If the index is valid, select the timezone and set it
                $selectedTimeZone = $timeZones[$selectedIndex]
				try{
					Set-TimeZone -Id $selectedTimeZone.Id
				}
				catch{
					Write-Log " ERROR: Time Zone could not be set.
	Reason: $_"
					Write-Host -ForegroundColor Red " ERROR: Time Zone could not be set.
	Reason: $_"
				}
				Write-Log "Timezone has been changed to $($selectedTimeZone.DisplayName)"
                Write-Host "
    Timezone has been changed to $($selectedTimeZone.DisplayName)"
                $validInput = $true
            } else {
                # If the index is out of range, show a warning
				Write-Log " Invalid index selected."
                Write-Warning "
    Invalid index selected. Please choose a valid index from the list (0 to $($timeZones.Count - 1))."
                $validInput = $false
            }
        } else {
            # If the input is not a valid number, show a warning
			Write-Log " Invalid numeric input."
            Write-Warning "
    Invalid numeric input. Please enter a valid numeric index."
            $validInput = $false
        }
    } while (-not $validInput)
    Open-DateTime-Configuration
}

function Open-DateTime-Configuration {
	Write-Log " Date and Time configuration."
    Clear-Host
    $dateTimeInfo = Get-DateTimeAndTimezone | Format-List -Property CurrentDateTime, TimeZone, UTC
	Write-Log " Current system date and time configuration: $dateTimeInfo"
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host " 
    Current system date and time configuration: "
    $dateTimeInfo
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host " 
    Date/Time and Time Zone configuration"
    Write-Host "
        1) Set Date and Time
        2) Set Timezone
        3) Return to main menu
-----------------------------------------------------------------------------------"

    do {
        $choice = Read-Host " Choose an Option (1-3)"
		Write-Log " User input: $choice"
        switch ($choice) {
            1 { Set-DateAndTime }
            2 { Set-SystemTimeZone }
            3 { Show-Menu }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne {1..3})
}

####
#### DiagnosticData-Configuration
####
function Enable-DiagData {
	Write-Log " Enable Diagnostic Data."
    Write-Host "
    Choose an option for diagnostic data and feedback level:"
    Write-Host "
        1) Basic
        2) Enhanced
        3) Full"
    
    do {
        $choice = Read-Host " Choose an Option (1-3)"
		Write-Log " User input: $choice"
        switch ($choice) {
            1 { Set-Basic-DiagData }
            2 { Set-Enhanced-DiagData }
            3 { Set-Full-DiagData }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne {1..3})

}

function Set-Basic-DiagData {
	Write-Log " Set Diagnostic Data to 'Basic'."
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $regName = "AllowTelemetry"
    $regValue = 1

    if (-not (Test-Path -Path $regPath)) {
		Write-Log " Registry path must be created."
        # Create the registry key if it does not exist
        try{
            New-Item -Path $regPath -Force
        }
        catch{
			Write-Log " ERROR: Diagnostic data and feedback can not be set.
    Reason: $_"
            Write-Warning "
    Diagnostic data and feedback can not be enabled.
    $_"
        }
    }

    if (-not (Test-Path -Path "$regPath\$regName")) {
		Write-Log " Registry value must be set."
        # Create the registry value if it does not exist
        try{
            New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWord -Force
            #Write-Host "Diagnostic data and feedback is set to 'Basic'."
        }
        catch{
			Write-Log " Diagnostic data and feedback can not be set.
    Reason: $_"
            Write-Warning "
    Diagnostic data and feedback can not be enabled.
    $_"
        }
    } else {
		Write-Log " Diagnostic data and feeback setting already set to 'Basic'."
        Write-Host "Diagnostic data and feeback setting already set to 'Basic'."
    }

    Open-DiagnosticData-Configuration
}

function Set-Enhanced-DiagData {
	Write-Log " Set Diagnostic Data to 'Enhanced'."
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $regName = "AllowTelemetry"
    $regValue = 2

    if (-not (Test-Path -Path $regPath)) {
		Write-Log " Registry path must be created."
        # Create the registry key if it does not exist
        try{
            New-Item -Path $regPath -Force
        }
        catch{
			Write-Log " ERROR: Diagnostic data and feedback can not be set.
    Reason: $_"
            Write-Warning "
    Diagnostic data and feedback can not be set.
    $_"
        }
    }

    if (-not (Test-Path -Path "$regPath\$regName")) {
		Write-Log " Registry value must be set."
        # Create the registry value if it does not exist
        try{
            New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWord -Force
            #Write-Host "Diagnostic data and feedback is set to 'Enhanced'."
        }
        catch{
			Write-Log " Diagnostic data and feedback can not be set.
    Reason: $_"
            Write-Warning "
    Diagnostic data and feedback can not be set.
    $_"
        }
    } else {
		Write-Log " Diagnostic data and feeback setting already set to 'Enhanced'."
        Write-Host "Diagnostic data and feeback setting already set to 'Enhanced'."
    }

    Open-DiagnosticData-Configuration
}

function Set-Full-DiagData {
	Write-Log " Set Diagnostic Data to 'Full'."
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $regName = "AllowTelemetry"
    $regValue = 3

    if (-not (Test-Path -Path $regPath)) {
		Write-Log " Registry path must be created."
        # Create the registry key if it does not exist
        try{
            New-Item -Path $regPath -Force
        }
        catch{
			Write-Log " ERROR: Diagnostic data and feedback can not be set.
    Reason: $_"
            Write-Warning "
    Diagnostic data and feedback can not be set.
    $_"
        }
    }

    if (-not (Test-Path -Path "$regPath\$regName")) {
		Write-Log " Registry value must be set."
        # Create the registry value if it does not exist
        try{
            New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWord -Force
            #Write-Host "Diagnostic data and feedback is set to 'Full'."
        }
        catch{
			Write-Log " Diagnostic data and feedback can not be set.
    Reason: $_"
            Write-Warning "
    Diagnostic data and feedback can not be set.
    $_"
        }
    } else {
		Write-Log " Diagnostic data and feeback setting already set to 'Full'."
        Write-Host "Diagnostic data and feeback setting already set to 'Full'."
    }

    Open-DiagnosticData-Configuration
}

function Disable-DiagData {
	Write-Log " Disable Diagnostic Data."
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $regName = "AllowTelemetry"
    $regValue = 0

    if (-not (Test-Path -Path $regPath)) {
		Write-Log " Registry path must be created."
        # Create the registry key if it does not exist
        try{
            New-Item -Path $regPath -Force
        }
        catch{
			Write-Log " ERROR: Diagnostic data and feedback can not be disabled.
    Reason: $_"
            Write-Warning "
    Diagnostic data and feedback can not be disabled.
    $_"
        }
    }

    if (-not (Test-Path -Path "$regPath\$regName")) {
		Write-Log " Registry value must be set."
        # Create the registry value if it does not exist
        try{
            New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWord -Force
            #Write-Host "Diagnostic data and feedback is set to 'Disabled'."
        }
        catch{
			Write-Log " Diagnostic data and feedback can not be disabled.
    Reason: $_"
            Write-Warning "
    Diagnostic data and feedback can not be disabled.
    $_"
        }
    } else {
		Write-Log " Diagnostic data and feeback setting already disabled."
        Write-Host "Diagnostic data and feeback setting already disabled."
    }

    Open-DiagnosticData-Configuration
}


function Open-DiagnosticData-Configuration {
	Write-Log " Diagnostic Data Configuration."
    Clear-Host
    
    <#
    Diagnostic data off (Security)	0
    Required (Basic)	1
    Enhanced	2
    Optional (Full)	3
    #>
    # Define the registry path and key
    $RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $RegistryName = "AllowTelemetry"

    # Initialize $Diag to a default value
    $Diag = 0

    # Check if the registry key exists
	Write-Log " Checking registry path."
    if (Test-Path $RegistryPath) {
		Write-Log " Try to collect data."
        try {
            # Attempt to retrieve the registry property
            $RegistryValue = Get-ItemProperty -Path $RegistryPath -Name $RegistryName -ErrorAction SilentlyContinue

            # If the registry value exists and is found
            if ($null -ne $RegistryValue) {
                # Extract the actual value of AllowTelemetry, ensuring it's treated as an integer
                $Diag = [int]$RegistryValue.AllowTelemetry
            }
            else {
                # If the registry value is null, set to default
                $Diag = 0
            }
        }
        catch {
            # In case of error, we catch and set $Diag to 0
            $Diag = 0
        }
    }
    else {
        # If the registry key does not exist, set the default value
        $Diag = 0
    }

    # Debugging: Output the raw value of $Diag to see what it's set to
    #Write-Host "Raw Diag Value: $Diag"

    # Assign the appropriate string based on the value of $Diag using a switch statement
    switch ($Diag) {
        0 { $DiagData = "Disabled" }
        1 { $DiagData = "Required" }
        2 { $DiagData = "Enhanced" }
        3 { $DiagData = "Full" }
        default { $DiagData = "Unknown" }
    }
	Write-Log " Current diagnostic data and feedback configuration: $DiagData"
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host "    Current diagnostic data and feedback configuration: $DiagData"
    Write-Host "-----------------------------------------------------------------------------------"
    if($DiagData -eq "Disabled"){
        Write-Host " 
    Diagnostic data and feedback configuration"
        Write-Host "
        1) Enable diagnostic data and feedback
        2) Return to main menu
-----------------------------------------------------------------------------------"

        do {
            $choice = Read-Host " Choose an Option (1-2)"
			Write-Log " User input: $choice"
            switch ($choice) {
                1 { Enable-DiagData }
                2 { Show-Menu }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne {1..2})
    }
    elseif($DiagData -eq "Required"){
         Write-Host " 
    Diagnostic data and feedback configuration"
        Write-Host "
        1) Disable diagnostic data and feedback
        2) Set diagnostic data and feedback to enhanced
        3) Set diagnostic data and feedback to full
        4) Return to main menu
-----------------------------------------------------------------------------------"

        do {
            $choice = Read-Host " Choose an Option (1-4)"
			Write-Log " User input: $choice"
            switch ($choice) {
                1 { Disable-DiagData }
                2 { Set-Enhanced-DiagData }
                3 { Set-Full-DiagData }
                4 { Show-Menu }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne {1..4})
    }
    elseif($DiagData -eq "Enhanced"){
         Write-Host " 
    Diagnostic data and feedback configuration"
        Write-Host "
        1) Disable diagnostic data and feedback
        2) Set diagnostic data and feedback to basic
        3) Set diagnostic data and feedback to full
        4) Return to main menu
-----------------------------------------------------------------------------------"

        do {
            $choice = Read-Host " Choose an Option (1-4)"
			Write-Log " User input: $choice"
            switch ($choice) {
                1 { Disable-DiagData }
                2 { Set-Basic-DiagData }
                3 { Set-Full-DiagData }
                4 { Show-Menu }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne {1..4})
    }
    elseif($DiagData -eq "Full")
    {
         Write-Host " 
    Diagnostic data and feedback configuration"
        Write-Host "
        1) Disable diagnostic data and feedback
        2) Set diagnostic data and feedback to basic
        3) Set diagnostic data and feedback to enhanced
        4) Return to main menu
-----------------------------------------------------------------------------------"

        do {
            $choice = Read-Host " Choose an Option (1-4)"
			Write-Log " User input: $choice"
            switch ($choice) {
                1 { Disable-DiagData }
                2 { Set-Basic-DiagData }
                3 { Set-Enhanced-DiagData }
                4 { Show-Menu }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne {1..4})
    }
}


####
#### Windows-Activation
####
function Set-Windows-Activation{
	Write-Log " Windows Activation."
    Clear-Host
     # Query WMI for activation status
    <#
    0 = Unlicensed
    1 = Licensed
    2 = Notification (activation is needed)
    3 = OOBGrace (Out of Box Grace Period)
    4 = OOTGrace (Out of Tolerance Grace Period)
    5 = Non-Genuine
    6 = Notification (reached the grace period limit)
    7 = Evaluation (Evaluation mode)
    #>
	Write-Log " Get current activation status."
	try{
		$Activation = (Get-WmiObject -Query "SELECT * FROM SoftwareLicensingProduct WHERE (PartialProductKey IS NOT NULL)").LicenseStatus
	}
	catch{
		Write-Log " ERROR: Activation status could not be collected.
	Reason: $_"
		Write-Host -ForegroundColor Red " ERROR: Activation status could not be collected.
	Reason: $_"
	}

    if($Activation -eq 0) {
        $Activation = "Not Activated"
    }
    if($Activation -eq 1) {
        $Activation = "Activated"
    }
    if($Activation -eq 2) {
        $Activation = "Activation is needed"
    }
    if($Activation -eq 3) {
        $Activation = "Out of Box Grace Period"
    }
    if($Activation -eq 4) {
        $Activation = "Out of Tolerance Grace Period"
    }
    if($Activation -eq 5) {
        $Activation = "Not Activated"
    }
    if($Activation -eq 6) {
        $Activation = "Reached the grace period limit"
    }
    if($Activation -eq 7) {
        $Activation = "Evaluation"
    }
	Write-Log " Current Activation Status: $Activation"
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host "    Current Activation Status: $Activation"
    Write-Host "-----------------------------------------------------------------------------------"
    if($Activation -eq "Activated")
    {
        Write-Host "
    Nothing to do."
        Write-Host "
        1) Return to main menu
-----------------------------------------------------------------------------------"

        do {
            $choice = Read-Host " Choose an Option (1)"
			Write-Log " User input: $choice"
            switch ($choice) {
                1 { Show-Menu }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne 1)
    }
    else{
        Write-Host " 
    Activate Windows
    "
        do{
            $Continue = Read-Host "Do you want to continue (Y/N)"
			Write-Log " User input: $Continue"
        } while($Continue -ne "Y" -and $Continue -ne "N")

        if($Continue -eq "Y") 
        {
            do{
                $key = Read-Host "
    Enter the product key (e.g. XXXXX-XXXXX-XXXXX-XXXXX-XXXXX)"
            } while([string]::IsNullOrEmpty($key))
			Write-Log " User entered product key."
                        
            if($key)
            {
				Write-Log " Trying to activate windows."
				Write-Log " Starting Process 'slmgr /ipk'"
                Write-Host "
    Trying to activate windows...
                "
                try {
                    start-process slmgr -ArgumentList "/ipk $key"
                }
                catch {
					Write-Log " ERROR: An error occurred while trying to activate windows.
	Reason: $_"
                    Write-Error "
    An error occurred while trying to activate windows: 
    $_"   
                }
				
				Write-Log " Starting Process 'slmgr /ato'"
                try {
                    start-process slmgr -ArgumentList "/ato"
                }
                catch {
					Write-Log " ERROR: An error occurred during activation process.
	Reason: $_"
                    Write-Error "
    An error occurred during activation process: 
    $_"
                }
            }
            else{
				Write-Log " No product key found."
                Write-Warning "
    No product key found."
            }
        }
        elseif($Continue -eq "N"){
			Write-Log " Returning to main menu."
            Write-Host "Returning to main menu..."
            Show-menu
        }

        Write-Host "
        1) Return to main menu
-----------------------------------------------------------------------------------"

        do {
            $choice = Read-Host " Choose an Option (1)"
			Write-Log " User input: $choice"
            switch ($choice) {
                1 { Show-Menu }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne 1)
    }

}

####
#### Domain-Configuration
####
function Open-Domain-Configuration {
	Write-Log " Domain configuration."
    Clear-Host
    $Domain = (Get-WmiObject Win32_ComputerSystem).Domain
	Write-Log " Current domain: $Domain"
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host "    Current domain: $Domain"
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host " 
    Changing domain
    "
    do{
        $Continue = Read-Host "Do you want to continue (Y/N)"
		Write-Log " User input: $Continue"
    } while($Continue -ne "Y" -and $Continue -ne "N")

    if($Continue -eq "Y") {
		Write-Log " User choose to change (d)omain or (w)orkgroup."
        do{
            # Ask the user whether they want to change the workgroup or join a domain
            $choice = Read-Host "
    Do you want to change the Workgroup (W) or join a Domain (D)? (Enter W or D)"
			Write-Log " User input: $choice"
        }while($choice -ne "W" -and $choice -ne "D")

        if ($choice -eq 'W') {
			Write-Log " Changing workgroup."
            # Prompt user for Workgroup name
            do{
                $workgroupName = Read-Host "
    Enter the new Workgroup name"
            } while([string]::IsNullOrEmpty($workgroupName))
			Write-Log " Entered new workgroup name: $workgroupName"
            # Check if the new computer name is different from the current one
            if ($workgroupName -ne $Domain) {
                # Change the workgroup
                try{
                    Add-Computer -WorkGroupName $workgroupName #-WhatIf
                    Write-Host -ForegroundColor Yellow "
    Computer is being added to the workgroup '$workgroupName'. The system needs to be restarted."
                }
                catch{
					Write-Log " ERROR: Computer could not join the specified workgroup.
    Reason: $_"
                    Write-Warning "
    Computer could not join the specified workgroup.
    $_"
                }
            } 
            else {
				Write-Log " The computer is already in the workgroup '$workgroupName'. No changes were made."
                Write-Host "
    The computer is already in the workgroup '$workgroupName'. No changes were made."
                
            }
        } 
        elseif ($choice -eq 'D') {
			Write-Log " Changing domain."
            # Prompt user for Domain name and credentials
            do{
                $domainName = Read-Host "
    Enter the Domain name"
            } while([string]::IsNullOrEmpty($domainName))
			Write-Log " Entered new domain name: $domainName"
            do{
                $domainUser = Read-Host "
    Enter the username for the domain (only username)"
            } while([string]::IsNullOrEmpty($domainUser))
            $domainUser = $domainName+"\"+$domainUser
			Write-Log " Entered user to join domain: $domainUser"
            do{
                $domainPassword = Read-Host "
    Enter the password for the domain user" -AsSecureString
            } while([string]::IsNullOrEmpty($domainPassword))
			Write-Log " Password were entered 'AsSecureString'."
            try{
                # Join the computer to the domain
                Add-Computer -DomainName $domainName -Credential (New-Object System.Management.Automation.PSCredential($domainUser, $domainPassword)) #-WhatIf
                Write-Host -ForegroundColor Green "
    Computer is being joined to the domain: $domainName"
            }
            catch{
				Write-Log " ERROR: Computer could not join the specified domain.
    Reason: $_"
                Write-Warning "
    Computer could not join the specified domain.
    $_"
                
            }
        } 
        else {
			Write-Log " Invalid choice."
            Write-Host "Invalid choice. Please enter W or D."
        }

        Write-Host "
        1) Restart server
        2) Return to main menu
-----------------------------------------------------------------------------------"

        do {
            $choice = Read-Host " Choose an Option (1-2)"
			Write-Log " User input: $choice."
            switch ($choice) {
				1 { Restart-System }
                2 { Show-Menu }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne {1..2})
    }
    elseif($Continue -eq "N"){
		Write-Log " Returning to main menu."
        Write-Host "Returning to main menu..."
        Show-menu
    }

}


####
#### Change Hostname
####
function Set-Hostname{
	Write-Log " Setting new hostname."
    Clear-Host
    $Hostname = $env:COMPUTERNAME
	Write-Log " Current Hostname: $Hostname"
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host "    Current Hostname: $Hostname"
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host " 
    Changing hostname
    "

    do{
        $Continue = Read-Host "    Do you want to continue (Y/N)"
		Write-Log " User input: $Continue"
    } while($Continue -ne "Y" -and $Continue -ne "N")

    if($Continue -eq "Y") {
		Write-Log " User choose to set a new hostname."
        # Define the new computer name
        do{
            $newComputerName = Read-Host "
    Enter a new computer name"
        } while([string]::IsNullOrEmpty($newComputerName))
		Write-Log " Entered hostname: $newComputerName"

        # Check if the new computer name is different from the current one
        if ($newComputerName -ne $Hostname) {
            # Change the computer name
			try{
				Rename-Computer -NewName $newComputerName -Force #-WhatIf
			}
			catch{
				Write-Log " ERROR: Hostname could not be changed.
	Reason: $_"
				Write-Host -ForegroundColor Red " ERROR: Hostname could not be changed.
	Reason: $_"
			}
            <# This Code Snippet is redundant, because the system generates a warning message automatically with the command "Rename-Computer"
			Write-Host -ForegroundColor Yellow "
    The computer name has been changed to '$newComputerName'. The system needs to be restarted."#>
        } 
        else {
			Write-Log " The computer name is already '$newComputerName'. No changes were made."
            Write-Host "
    The computer name is already '$newComputerName'. No changes were made."

        }

        Write-Host "
        1) Restart server
        2) Return to main menu
-----------------------------------------------------------------------------------"

            do {
                $choice = Read-Host " Choose an Option (1-2)"
				Write-Log " User input: $choice"
                switch ($choice) {
					1 { Restart-System }
                    2 { Show-Menu }
                    default { 
						Write-Log " Wrong Input."
						Write-Host "Wrong Input. Please choose an option above." 
					}
                }

            } while ($choice -ne {1..2})
    }
    elseif($Continue -eq "N"){
		Write-Log " Returning to main menu."
        Write-Host "Returning to main menu..."
        Show-menu
    }
}

####
#### Create Local Administrator
####
function Add-LocalAdministrator{
	Write-Log " Create new local administrator."
    Clear-Host
    $UserList = Get-LocalUser
    Write-Host "-----------------------------------------------------------------------------------"
    if ($UserList) {
        Write-Host " 
    Existing Users:"
    $UserList | ForEach-Object { Write-Host "    - "$_.Name }
    } else {
        Write-Host "
    Existing Users:
        No user found."
    }
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host " 
    Create new local administrator
 "
    do{
        $Continue = Read-Host " Do you want to continue (Y/N)"
		Write-Log " User input: $Continue"
    } while($Continue -ne "Y" -and $Continue -ne "N")

    if($Continue -eq "Y") {
		Write-Log " User choose to create a new local administrator."
        do{
            $userName = Read-Host "
    Enter the name of the new local administrator"
        } while([string]::IsNullOrEmpty($userName))
		Write-Log " Entered administrator name: $userName"
        do{
            $userPassword = Read-Host -AsSecureString "
    Enter a password for the new administrator"
        } while([string]::IsNullOrEmpty($userPassword))
		Write-Log " User entered a password 'AsSecureString'."
        $userDisplayName = Read-Host "
    Enter the name of the administrator, that should be displayed (optional)"
        if ([string]::IsNullOrEmpty($userDisplayName)) {
            $userDisplayName = $userName
        }
		Write-Log " Entered administrator display name: $userDisplayName"
        $userDescription = Read-Host "
    Enter a description for the new administrator (optional)"
        if ([string]::IsNullOrEmpty($userDescription)) {
            $userDescription = "No description provided."
        }
		Write-Log " Entered administrator description: $userDescription"
		
		Write-Log " Checking if administrator already exists."
        $GetUsers = Get-LocalUser | Select-Object -ExpandProperty Name
        if ($GetUSers -contains $userName) {
			Write-Log " Administrator '$userName' already exists."
            Write-Warning "
    User $userName already exists
            "
        } 
        else {
            Write-Host "
        Creating new user account with following information:
            User Name:              $userName
            Display Name:           $userDisplayName
            Description:            $userDescription
            Account Expires:        Account never expires
            Password Expires:       Password never expires
            "
			Write-Log " Creating new administrator."
            try {
                New-LocalUser -Name $userName -Description $userDescription -FullName $userDisplayName -Password $userPassword -AccountNeverExpires -PasswordNeverExpires #-WhatIf
                Write-Host -ForegroundColor Green "Local administrator '$userName' created successfully." `n
            }
            catch {
				Write-Log " ERROR: An error occurred while creating the administrator.
    Reason: $_"
                Write-Error "
    An error occurred while creating the administrator: 
    $_"
            
            }
			Write-Log " Adding administrator user to local group 'Administrators'."
            try {
                Add-LocalGroupMember -Group "Administrators" -Member $userName #-WhatIf
                Write-Host "
    Administrator '$userName' added to group 'Administrators'"
            }
            catch {
				Write-Log " ERROR: An error occurred while adding the administrator '$userName' to the administrators group.
    Reason: $_"
                Write-Error "
    An error occurred while adding the administrator '$userName' to the administrators group: 
                $_"
            }
        }

        Write-Host "
        1) Return to main menu
-----------------------------------------------------------------------------------"

        do {
            $choice = Read-Host " Choose an Option (1)"
			Write-Log " User input: $choice"
            switch ($choice) {
                1 { Show-Menu }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne 1)
    }
    elseif($Continue -eq "N"){
		Write-Log " Returning to main menu."
        Write-Host "Returning to main menu..."
        Show-menu
    }
}


####
#### Create Local User
####
function Add-LocalUser{
	Write-Log " Create new local user."
    Clear-Host
    $UserList = Get-LocalUser
    Write-Host "-----------------------------------------------------------------------------------"
    if ($UserList) {
        Write-Host " 
    Existing Users:"
    $UserList | ForEach-Object { Write-Host "    - "$_.Name }
    } else {
        Write-Host "
    Existing Users:
        No user found."
    }
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host " 
    Create new local User
 "
    do{
        $Continue = Read-Host " Do you want to continue (Y/N)"
		Write-Log " User input: $Continue"
    } while($Continue -ne "Y" -and $Continue -ne "N")

    if($Continue -eq "Y") {
		
		Write-Log " User choose to create a new local user."
        do{
            $userName = Read-Host "
    Enter the name of the new local user"
        } while([string]::IsNullOrEmpty($userName))
		Write-Log " Entered user name: $userName"
        do{
            $userPassword = Read-Host -AsSecureString "
    Enter a password for the new user"
        } while([string]::IsNullOrEmpty($userPassword))
		Write-Log " User entered a password 'AsSecureString'."
        $userDisplayName = Read-Host "
    Enter the name of the user, that should be displayed (optional)"
        if ([string]::IsNullOrEmpty($userDisplayName)) {
            $userDisplayName = $userName
        }
		Write-Log " Entered user display name: $userDisplayName"
        $userDescription = Read-Host "
    Enter a description for the new user (optional)"
        if ([string]::IsNullOrEmpty($userDescription)) {
            $userDescription = "No description provided."
        }
		Write-Log " Entered user description: $userDescription"

		Write-Log " Checking if user already exists."
        $GetUsers = Get-LocalUser | Select-Object -ExpandProperty Name
        if ($GetUSers -contains $userName) {
			Write-Log " User '$userName' already exists."
            Write-Warning "
    User $userName already exists
            "
        } 
        else {
            Write-Host "
        Creating new user account with following information:
            User Name:              $userName
            Display Name:           $userDisplayName
            Description:            $userDescription
            Account Expires:        Account never expires
            Password Expires:       Password will expire
            "
			Write-Log " Creating new user."
            try {
                New-LocalUser -Name $userName -Description $userDescription -FullName $userDisplayName -Password $userPassword -AccountNeverExpires #-WhatIf
                Write-Host -ForegroundColor Green "
    Local user '$userName' created successfully." `n
            }
            catch {
				Write-Log " ERROR: An error occurred while creating the user. 
    Reason: $_"
                Write-Error "
    An error occurred while creating the user: 
    $_"   
            }
			Write-Log " Adding User to local group 'Users'."
            try {
                Add-LocalGroupMember -Group "Users" -Member $userName #-WhatIf
                Write-Host "
    User '$userName' added to group the default group 'Users'"
            }
            catch {
				Write-Log " ERROR: An error occurred while adding the user '$userName' to the default group. 
    Reason: $_"
                Write-Error "
    An error occurred while adding the user '$userName' to the default group: 
    $_"
            }
        }

        Write-Host "
        1) Return to main menu
-----------------------------------------------------------------------------------"

        do {
            $choice = Read-Host " Choose an Option (1)"
			Write-Log " User input: $choice"
            switch ($choice) {
                1 { Show-Menu }
                default {
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

        } while ($choice -ne 1)

    }
    elseif($Continue -eq "N"){
		
		Write-Log " Returning to main menu."
        Write-Host "Returning to main menu..."
        Show-menu
    }

}

####
#### Create Local Group
####
function Add-LocalGroup{
	Write-Log " Create new local group."
    Clear-Host
    $GroupList = Get-LocalGroup
    Write-Host "-----------------------------------------------------------------------------------"
    if ($GroupList) 
    {
        Write-Host " 
    Existing Groups:"
    $GroupList | ForEach-Object { Write-Host "    - "$_.Name }
    } 
    else {
        Write-Host "
    Existing Groups:
        No groups found."
    }
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host " 
    Create new local User Group
 "
    do{
        $Continue = Read-Host " Do you want to continue (Y/N)"
		Write-Log " User input: $Continue"
    } while($Continue -ne "Y" -and $Continue -ne "N")

    if($Continue -eq "Y") {
		Write-Log " User choose to create a new local group."
        # Prompt for the group name
        do{
            $groupName = Read-Host "
    Enter the name of the new local group"
        } while([string]::IsNullOrEmpty($groupName))
		Write-Log " Entered group name: $groupName"
        # Prompt for the group description
        $groupDescription = Read-Host "
    Enter a description for the new group (optional)"
		
        # If the user leaves the description blank, set it to a default value
        if ([string]::IsNullOrEmpty($groupDescription)) {
            $groupDescription = "No description provided."
        }
		Write-Log " Entered group description: $groupDescription"
        # Try to create the local group
        # Get all local groups and select only their Name property
        $GetGroups = Get-LocalGroup | Select-Object -ExpandProperty Name

        # Check if "Users" group exists in the list
		Write-Log " Checking if local group already exists."
        if ($GetGroups -contains $groupName) {
			Write-Log " Local Group $groupName already exists."
            Write-Warning "
    Group $groupName already exists
            "
        } else {
			Write-Log " Creating new local group $groupName"
			try {
				New-LocalGroup -Name $groupName -Description $groupDescription #-WhatIf
				Write-Host -ForegroundColor Green "
    Local group '$groupName' created successfully." `n
            }
            catch {
				Write-Log " ERROR: An error occurred while creating the group.
	Reason: $_"
                Write-Error "
    An error occurred while creating the group: $_"
                return
            }
        }

        # Ask if the user wants to add any members to the group
        $addMembers = Read-Host "
    Do you want to add members to this group? (Y/N)"

        if ($addMembers -eq 'Y' -or $addMembers -eq 'y') {
			Write-Log " User choose to add members to new local group."
            # Get the list of all local users
            $localUsers = Get-LocalUser | Select-Object Name

            # Check if there are any local users
            if ($localUsers.Count -eq 0) {
				Write-Log " No local users found."
                Write-Host "
    No local users found."
                return
            }

            # Display the list of local users with a prompt to select from
            Write-Host "
    Available local users:
    "
        
            $localUsers | ForEach-Object { 
            Write-Host "    $($_.Name)" 
            }

            # Loop to add multiple users to the group
            do {
                # Prompt user to select a user to add to the group
                $userName = Read-Host " Enter the username to add to the group (leave blank to stop)"

                # Exit the loop if the user leaves the input blank
                if ([string]::IsNullOrEmpty($userName)) {
                    break
                }

                # Check if the user entered a valid local username
                $validUser = $localUsers | Where-Object { $_.Name -eq $userName }

                if ($validUser) {
                    # Try to add the user to the group
					Write-Log " Try to add the user '$userName' to the group."
                    try {
                        Add-LocalGroupMember -Group $groupName -Member $userName #-WhatIf
                        Write-Host "
    User '$userName' added to group '$groupName'."
                    }
                    catch {
						Write-Log " ERROR: An error occurred while adding the user '$userName' to the group.
	Reason: $_"
                        Write-Error "
    An error occurred while adding the user '$userName' to the group: 
    $_"
                    }
                }
                else {
					Write-Log " ERROR: Invalid username '$userName'. Please select a valid local user."
                    Write-Host "
    Invalid username '$userName'. Please select a valid local user."
                }

            } while ($true)
        } 
        else {
			Write-Log " No users were added to the group."
            Write-Host "
    No users were added to the group."
        }

        Write-Host "
        1) Return to main menu
-----------------------------------------------------------------------------------"

        do {
            $choice = Read-Host " Choose an Option (1)"
			Write-Log " User input: $choice"
            switch ($choice) {
                1 { Show-Menu }
                default { 
					Write-Log " Wrong Input."
					Write-Host "Wrong Input. Please choose an option above." 
				}
            }

            # Flush Variables
            <#if($choice -eq 1){
                $GroupList = ""
                $groupName = ""
                $groupDescription = ""
                $validUser = ""
                $localUsers = ""
                $addMembers = ""
                $userName = ""
            }#>

        } while ($choice -ne 1)
    }
    elseif($Continue -eq "N"){
		Write-Log " Returning to main menu."
        Write-Host "Returning to main menu..."
        Show-menu
    }

}

####
#### WindowsUpdates
####
function Get-UpdateResultCodes($ResultCode){

    switch ($ResultCode)
    {
        0 { return "Not Started" }
        1 { return "In Progress" }
        2 { return "Succeeded" }
        3 { return "Succeeded with Errors" }
        4 { return "Failed" }
        5 { return "Stopped" }
    }
}

###
### Search and Download Updates
###
<#
function Download-Updates {
    Write-Log " Downloading available Windows Updates."
    Clear-Host
    try{
        #$DownloadUpdates = Get-WindowsUpdate -AcceptAll -Download | Select-Object Result,Size,Title | ft
        $DownloadUpdates = Download-WindowsUpdate -AcceptAll | Select-Object Result,Size,Title | ft
    }
    catch{
		Write-Log " ERROR: An error occurred while trying to search and download new updates.
	Reason: $_"
        Write-Error "An error occurred while trying to search and download new updates: $_"
    }
    if($DownloadUpdates) {
		Write-Log " Available updates downloaded."
        Write-Host -ForegroundColor Green "
    Available updates downloaded"
        
        $DownloadUpdates

    }
    else {
		Write-Log " No updates are available for download."
        Write-Warning "
    No updates are available for download"

    }
    Write-Host "
        1) Export to csv
        2) Install updates
        3) Return to Windows Updates Control menu
        4) Return to main menu
-----------------------------------------------------------------------------------"
    do {
        $choice = Read-Host " Choose an Option (1-4)"
		Write-Log " User input: $choice"
        switch ($choice) {
            1 { ExportUpdateHistory }
            2 { Install-Updates }
            3 { WindowsUpdates }
            4 { Show-Menu }
            default {
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne 4)
}
#>
<#
function Enter-Download-WUpdates {
	Write-Log " Downloading Windows Updates."
    Clear-Host
    try{
        $WUDownload = Install-WindowsUpdate -Download -AcceptAll #Get-WUInstall -Download -AcceptAll
        $WUDownload | select-object Result,KB,Size,Title | ft
    }
    catch{
		Write-Log " ERROR: Windows Updates can not be downloaded.
	Reason: $_"
        Write-Warning "
    Windows Updates can not be downloaded.
    $_"
    }

    Write-Host "
        1) Return to Windows Update menu
-----------------------------------------------------------------------------------"

    do {
        $choice = Read-Host " Choose an Option (1)"
		Write-Log " User input: $choice"
        switch ($choice) {
            1 { WindowsUpdates }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne 1)
}
#>
function Enter-Download-WUpdates {
	Write-Log " Downloading Windows Updates."
	Clear-Host
	
	try{
		$UpdateSession = New-Object -ComObject Microsoft.Update.Session
	}
	catch{
		Write-Log " ERROR: An error occurred while trying to load Microsoft Update Session Object.
	Reason: $_"
        Write-Host -ForegroundColor Red " ERROR: An error occurred while trying to load Microsoft Update Session Object.
    Reason: $_"
	}

	# Create the searcher and search for available updates
	try{
		$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
		
	}
	catch{
		Write-Log " ERROR: An error occurred while trying to create update seacrher.
	Reason: $_"
        Write-Host -ForegroundColor Red " ERROR: An error occurred while to create update seacrher.
    Reason: $_"
	}
	
	try{
		$SearchResult = $UpdateSearcher.Search("IsInstalled=0")
	}
	catch{
		Write-Log " ERROR: An error occurred while trying to find available udpates.
	Reason: $_"
        Write-Host -ForegroundColor Red " ERROR: An error occurred while to find available udpates.
    Reason: $_"
	}
	
	$UpdatesToDownload = @()
	
	try{
		$UpdatesToDownload = New-Object -ComObject Microsoft.Update.UpdateColl
	}
	catch{
		Write-Log " ERROR: An error occurred while trying to get update collection.
	Reason: $_"
        Write-Host -ForegroundColor Red " ERROR: An error occurred while to get update collection.
    Reason: $_"
	}
	
    
    try{		
		# Create an array to hold the custom objects for each update
		$UpdateInfoList = @()
		
		if ($SearchResult.Updates.Count -gt 0) {
			foreach ($update in $SearchResult.Updates) {
				
				$Title = $update.Title
				#$KBNumbers = "KB$($update.KBArticleIDs)" -join ", "  # Join multiple KBs if applicable
				# Get KB numbers, join them if multiple, or use a placeholder if empty
				$KBNumbers = if ($update.KBArticleIDs -ne "") { "KB$($update.KBArticleIDs)" -join ", " } else { "-" }
				$SizeInMB = [math]::round($update.MaxDownloadSize / 1MB, 2)  # Convert bytes to MB and round to 2 decimal places
				
				# Convert size to GB if it's greater than 1000 MB, else keep it in MB
				if ($SizeInMB -gt 1000) {
					$SizeInGB = [math]::round($SizeInMB / 1024, 2)  # Convert MB to GB and round to 2 decimal places
					$SizeDisplay = "$($SizeInGB)GB"
				} else {
					$SizeDisplay = "$($SizeInMB)MB"
				}
				
				# Check if the update is already downloaded or not
				$updateState = if ($update.IsDownloaded -eq 1) { "Already Downloaded" } else { "Ready for Download" }
				#Write-Host "$($update.Title) - $updateState"
				
				# Create a custom object to store the update info
				$UpdateInfo = [PSCustomObject]@{
					Status 		= $updateState
					KBNumber   	= $KBNumbers
					Size   		= $SizeDisplay
					Title      	= $Title
				}

				# Add the custom object to the list
				$UpdateInfoList += $UpdateInfo
				
				# Add to the list of updates to download if not already downloaded
				if ($update.IsDownloaded -eq 0 -and $update.IsInstalled -eq 0) {
					#$UpdatesToDownload += $update
					$Null = $UpdatesToDownload.Add($update)
				}
			}
			
			
			# Display the updates in a table format
			Write-Host "-----------------------------------------------------------------------------------

    Available Updates for download:"
			$UpdateInfoList | Select-Object Status,KBNumber,Size,Title | Format-Table #Format-Table -AutoSize
			

			# Proceed to download if there are updates to download
			if ($UpdatesToDownload.Count -gt 0) {
				Write-Host "    Starting download..."
				Write-Log " Starting download..."
				
				# Create an installer object
				$UpdateDownloader = $UpdateSession.CreateUpdateDownloader()
				# Set the updates to install
				$UpdateDownloader.Updates = $UpdatesToDownload
				#$DownloadResult = $UpdateDownloader.Download()

				# Iterate through each update and download it
				foreach ($update in $UpdatesToDownload) {
					Write-Host "    Downloading update: KB$($update.KBArticleIDs) - $($update.Title)
    ..."
					# Install the update
					$DownloadResult = $UpdateDownloader.Download()
					
					$StatusMessage = Get-UpdateResultCodes($DownloadResult.ResultCode)
					
					# Check download result for the specific update
					if ($DownloadResult.ResultCode -eq 2) {
						Write-Host "    Update 'KB$($update.KBArticleIDs) - $($update.Title)'"
						Write-Host -ForegroundColor Green "    Downloaded successfully.
"
						Write-Log " Update 'KB$($update.KBArticleIDs) - $($update.Title)' downloaded successfully."
					}
					elseif ($DownloadResult.ResultCode -ne 2){
						Write-Host "    Download of update 'KB$($update.KBArticleIDs) - $($update.Title)' failed with exit code:"
						Write-Host -ForegroundColor Yellow "    $($DownloadResult.ResultCode) - $($StatusMessage)
"
						Write-Log " ERROR: Download of update 'KB$($update.KBArticleIDs) - $($update.Title)' failed with exit code:
    $($DownloadResult.ResultCode) - $($StatusMessage)"
					}
				}

				# Check download status
				<#if ($DownloadResult.ResultCode -eq 0) {
					Write-Host "    Updates downloaded successfully."
					Write-Log " Updates downloaded successfully."
				}
				else {
					Write-Host "Download failed with error code: $($DownloadResult.ResultCode)"
					Write-Log " ERROR: Download failed with error code: $($DownloadResult.ResultCode)"
				}#>
			}
			else {
				Write-Host "    No updates need to be downloaded.
-----------------------------------------------------------------------------------"
				Write-Log " No updates need to be downloaded."
			}
		}
		else {
			Write-Host "No updates available."
			Write-Log " No updates available."
		}

    }
    catch{
		Write-Log " ERROR: Windows Updates can not be downloaded.
	Reason: $_"
        Write-Warning "
    Windows Updates can not be downloaded.
    $_"
    }
	
	Write-Host "
        1) Return to Windows Update menu
-----------------------------------------------------------------------------------"

    do {
        $choice = Read-Host " Choose an Option"
		Write-Log " User input: $choice"
        switch ($choice) {
            1 { WindowsUpdates }
			#2 { Enter-Download-WUpdates }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne 1)
}

###
### Install Updates
###
<#
function Install-Updates{
	Write-Log " Installing available Windows Updates."
    Clear-Host
    try{
        #Install-WindowsUpdate -MicrosoftUpdate -AcceptAll
        #$InstallUpdates = Get-WindowsUpdate -AcceptAll -Install | Select-Object Result,Size,Title | ft
        $InstallUpdates = Install-WindowsUpdate -AcceptAll | Select-Object Result,Size,Title | ft
    }
    catch{
		Write-Log " ERROR: An error occurred while trying to intsall new updates.
	Reason: $_"
        Write-Error "An error occurred while trying to intsall new updates: $_"
    }
    if($InstallUpdates) {
		Write-Log "  Available updates installed."
        Write-Host -ForegroundColor Green "
    Available updates installed"
        
        $InstallUpdates

    }
    else {
		Write-Log " No updates installed."
        Write-Warning "
    No updates installed"

    }
    
    Write-Host "
        1) Export to csv
        2) Return to Windows Updates Control menu
        3) Return to main menu
-----------------------------------------------------------------------------------"
    do {
        $choice = Read-Host " Choose an Option (1-3)"
		Write-Log " User input: $choice"
        switch ($choice) {
            1 { ExportUpdateHistory }
            2 { WindowsUpdates }
            3 { Show-Menu }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne 3)
}
#>
<#
function Install-WUpdates {
	
	Write-Log " Installing Windows Updates."
	
    Clear-Host
    try{ 
        $WUInstall = Install-WindowsUpdate -AcceptAll -IgnoreReboot #Get-WUInstall -AcceptAll -IgnoreReboot
        $WUInstall | select-object Status,KB,Size,Title | ft
    }
    catch{
		Write-Log " ERROR: Windows Updates can not be installed.
	Reason: $_"
        Write-Warning "
    Windows Updates can not be installed.
    $_"
    }

    Write-Host "
        1) Return to Windows Update menu
-----------------------------------------------------------------------------------"

    do {
        $choice = Read-Host " Choose an Option (1)"
		Write-Log " User input: $choice"
        switch ($choice) {
            1 { WindowsUpdates }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne 1)
}
#>
function Install-WUpdates {
	Write-Log " Installing Windows Updates."
	Clear-Host
	try{
		$UpdateSession = New-Object -ComObject Microsoft.Update.Session
	}
	catch{
		Write-Log " ERROR: An error occurred while trying to load Microsoft Update Session Object.
	Reason: $_"
        Write-Host -ForegroundColor Red " ERROR: An error occurred while trying to load Microsoft Update Session Object.
    Reason: $_"
	}

	# Create the searcher and search for available updates
	try{
		$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
		
	}
	catch{
		Write-Log " ERROR: An error occurred while trying to create update seacrher.
	Reason: $_"
        Write-Host -ForegroundColor Red " ERROR: An error occurred while to create update seacrher.
    Reason: $_"
	}
	
	try{
		$SearchResult = $UpdateSearcher.Search("IsInstalled=0")
	}
	catch{
		Write-Log " ERROR: An error occurred while trying to find available udpates.
	Reason: $_"
        Write-Host -ForegroundColor Red " ERROR: An error occurred while to find available udpates.
    Reason: $_"
	}
	
	#$UpdatesToInstall = @()
	try{
		$UpdatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
	}
	catch{
		Write-Log " ERROR: An error occurred while trying to get update collection.
	Reason: $_"
        Write-Host -ForegroundColor Red " ERROR: An error occurred while to get update collection.
    Reason: $_"
	}
	
    
    try{
		# Create an array to hold the custom objects for each update
		$UpdateInfoList = @()
		
		if ($SearchResult.Updates.Count -gt 0) {
			foreach ($update in $SearchResult.Updates) {
				
				$Title = $update.Title
				#$KBNumbers = "KB$($update.KBArticleIDs)" -join ", "  # Join multiple KBs if applicable
				# Get KB numbers, join them if multiple, or use a placeholder if empty
				$KBNumbers = if ($update.KBArticleIDs -ne "") { "KB$($update.KBArticleIDs)" -join ", " } else { "-" }
				$SizeInMB = [math]::round($update.MaxDownloadSize / 1MB, 2)  # Convert bytes to MB and round to 2 decimal places
				
				# Convert size to GB if it's greater than 1000 MB, else keep it in MB
				if ($SizeInMB -gt 1000) {
					$SizeInGB = [math]::round($SizeInMB / 1024, 2)  # Convert MB to GB and round to 2 decimal places
					$SizeDisplay = "$($SizeInGB)GB"
				} else {
					$SizeDisplay = "$($SizeInMB)MB"
				}
				
				# Check if the update is already downloaded or installed or not
				$updateState = if ($update.IsInstalled -eq 1) { "Installed" } elseif ($update.IsDownloaded -eq 1 -and $update.IsInstalled -eq 0) { "Ready to Install" } elseif ($update.IsDownloaded -eq 0 -and $update.IsInstalled -eq 0) { "Ready for Download" }
				#Write-Host "$($update.Title) - $updateState"
				
				# Create a custom object to store the update info
				$UpdateInfo = [PSCustomObject]@{
					Status 		= $updateState
					KBNumber   	= $KBNumbers
					Size   		= $SizeDisplay
					Title      	= $Title
				}

				# Add the custom object to the list
				$UpdateInfoList += $UpdateInfo
				
				# Add to the list of updates to install if already downloaded
				if ($update.IsDownloaded -eq 1 -and $update.IsInstalled -eq 0) {
					#$UpdatesToInstall += $update
					$Null = $UpdatesToInstall.Add($update)
				}
			}
			
			
			# Display the updates in a table format
			Write-Host "-----------------------------------------------------------------------------------

    Available Updates for installation:"
			$UpdateInfoList | Select-Object Status,KBNumber,Size,Title | Format-Table #Format-Table -AutoSize
			

			# Proceed to install if there are updates to install
			if ($UpdatesToInstall.Count -gt 0) {
				Write-Host "    Starting installation..."
				Write-Log " Starting installation..."
				
				# Create an installer object
				$UpdateInstaller = $UpdateSession.CreateUpdateInstaller()
				# Set the updates to install
				$UpdateInstaller.Updates = $UpdatesToInstall
				#$InstallResult = $UpdateInstaller.Install()
				
				
				# Iterate through each update and install it
				foreach ($update in $UpdatesToInstall) {
					Write-Host "    Installing update: KB$($update.KBArticleIDs) - $($update.Title)
    ..."
					# Install the update
					$InstallResult = $UpdateInstaller.Install()
					
					$StatusMessage = Get-UpdateResultCodes($InstallResult.ResultCode)
					
					# Check install result for the specific update
					if ($InstallResult.ResultCode -eq 2 -or $InstallResult.ResultCode -eq 3) {
						Write-Host "    Update 'KB$($update.KBArticleIDs) - $($update.Title)'"
						Write-Host -ForegroundColor Green "    Installed successfully.
"
						Write-Log " Update 'KB$($update.KBArticleIDs) - $($update.Title)' installed successfully."
						
						if($InstallResult.RebootRequired){
							Write-Host -ForegroundColor Yellow "    A reboot is required.
"
							Write-Log "A reboot is required."
						}
					}
					else {
						Write-Host "    Installation of update 'KB$($update.KBArticleIDs) - $($update.Title)' failed with exit code:"
						Write-Host -ForegroundColor Yellow "    $($InstallResult.ResultCode) - $($StatusMessage)
"
						Write-Log " ERROR: Installation of update 'KB$($update.KBArticleIDs) - $($update.Title)' failed with exit code:
    $($InstallResult.ResultCode) - $($StatusMessage)"
					}
				}
				
				# Check install status
				<#if ($InstallResult.ResultCode -eq 0) {
					Write-Host "    Updates installed successfully."
					Write-Log " Updates installed successfully."
				}
				else {
					Write-Host "Installation failed with error code: $($InstallationResult.ResultCode)"
					Write-Log " ERROR: Installation failed with error code: $($InstallationResult.ResultCode)"
				}#>
			}
			else {
				Write-Host "    No updates need to be installed.
-----------------------------------------------------------------------------------"
				Write-Log " No updates need to be installed."
			}
		}
		else {
			Write-Host "No updates available."
			Write-Log " No updates available."
		}
    }
    catch{
		Write-Log " ERROR: Windows Updates can not be installed.
	Reason: $_"
        Write-Warning "
    Windows Updates can not be installed.
    $_"
    }

    Write-Host "
        1) Return to Windows Update menu
-----------------------------------------------------------------------------------"

    do {
        $choice = Read-Host " Choose an Option"
		Write-Log " User input: $choice"
        switch ($choice) {
            1 { WindowsUpdates }
			#2 { Install-WUpdates }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne 1)
}

###
### Get History of Updates
###
<#
function History-Updates{
	Write-Log " Accessing Windows Update History."
    Get-WUHistory | select-object Result,Date,Title | ft

    Write-Host "
        1) Export to csv
        2) Return to Windows Updates Control menu
        3) Return to main menu
-----------------------------------------------------------------------------------"
    do {
        $choice = Read-Host " Choose an Option (1-3)"
		Write-Log " User input: $choice"
        switch ($choice) {
            1 { ExportUpdateHistory }
            2 { WindowsUpdates }
            3 { Show-Menu }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne 3)
}
#>
<#
function Export-History {
	Write-Log " Exporting Windows Update History."
	
    # File Creation
    $TimeDate = Get-Date -Format "dd-MM-yyyy_HH-mm"
    $HRTimeDate = Get-Date -Format "dd.MM.yyyy HH:mm"
    $Hostname = $env:COMPUTERNAME
    $GetUpdateHistory = Get-WUHistory | Select-Object Result,Date,Title #| ft
    $FileName = $Hostname+"_WUHistory_"+$TimeDate+".csv"
    $FileDir = "C:\_psc\WindowsUpdate-History\"
    $FilePath = "$FileDir$FileName"

    # Ensure the directory exists
	Write-Log " Checking if destination directory '$FileDir' for export file '$FileName' exists."
    if (-not (Test-Path -Path $FileDir)) {
		Write-Log " Creating destination directory for export."
		try{
			New-Item -ItemType Directory -Path $FileDir -Force
		}
		catch{
			Write-Log " ERROR: Destination directory for export could not be created.
	Reason: $_"
			Write-Host -ForegroundColor Red " ERROR: Destination directory for export could not be created.
	Reason: $_"
		}
    }
	
	Write-Log " Exporting Information."
	try{
        # Export the update history to CSV
        #$GetUpdates
        $GetUpdateHistory | Export-Csv -Path $FilePath -Delimiter ';' -encoding utf8 -NoTypeInformation -Force
        for ($i = 0; $i -le 100; $i=$i+10 ) {
            Write-Progress -Activity "Export in progress" -Status "$i% Complete:" -PercentComplete $i
            Start-Sleep -Milliseconds 250
        }
        Write-Host -ForegroundColor Yellow "    Update history exported successfully to $FilePath"
        Write-Host "    Returning to menu..."
        Start-Sleep -Seconds 8
    }
	catch{
		Write-Log " ERROR: Failed to export update history.
	Reason: $_"
		Write-Host -ForegroundColor Red " ERROR: Failed to export update history: 
    $_"
	}
    Show-WUpdateHistory
}
#>
function Export-History($UpdateHistory) {
	Write-Log " Exporting Windows Update History."
	
    # File Creation
    $TimeDate = Get-Date -Format "dd-MM-yyyy_HH-mm"
    $HRTimeDate = Get-Date -Format "dd.MM.yyyy HH:mm"
    $Hostname = $env:COMPUTERNAME
    $FileName = $Hostname+"_WUHistory_"+$TimeDate+".csv"
    $FileDir = "C:\_psc\WindowsUpdate-History\"
    $FilePath = "$FileDir$FileName"

    # Ensure the directory exists
	Write-Log " Checking if destination directory '$FileDir' for export file '$FileName' exists."
    if (-not (Test-Path -Path $FileDir)) {
		Write-Log " Creating destination directory for export."
		try{
			New-Item -ItemType Directory -Path $FileDir -Force
		}
		catch{
			Write-Log " ERROR: Destination directory for export could not be created.
	Reason: $_"
			Write-Host -ForegroundColor Red " ERROR: Destination directory for export could not be created.
	Reason: $_"
		}
    }
	
	Write-Log " Exporting Information."
	try{
        # Export the update history to CSV
        $UpdateHistory | Export-Csv -Path $FilePath -Delimiter ';' -encoding utf8 -NoTypeInformation -Force
		for ($i = 0; $i -le 100; $i=$i+10 ) {
            Write-Progress -Activity "Export in progress" -Status "$i% Complete:" -PercentComplete $i
            Start-Sleep -Milliseconds 250
        }
        Write-Host -ForegroundColor Yellow "    Update history exported successfully to $FilePath"
        Write-Host "    Returning to menu..."
        Start-Sleep -Seconds 10
    }
	catch{
		Write-Log " ERROR: Failed to export update history.
	Reason: $_"
		Write-Host -ForegroundColor Red " ERROR: Failed to export update history:
    $_"
	}
    Show-WUpdateHistory
}

<#
function Show-WUpdateHistory {
	Write-Log " Showing Windows Update History."
	Write-Log " Try to gather Windows Update History Information."
    Clear-Host

    try{ 
        $WUHistory = Get-WUHistory
        $WUHistory | Select-Object Result,Date,Title | ft
    }
    catch{
		Write-Log " ERROR: Windows Updates can not be displayed.
    Reason: $_"
        Write-Warning "
    Windows Updates can not be displayed.
    $_"
    }

    Write-Host "
        1) Export History
        2) Return to Windows Update menu
-----------------------------------------------------------------------------------"

    do {
        $choice = Read-Host " Choose an Option (1-2)"
		Write-Log " User input: $choice"
        switch ($choice) {
            1 { Export-History }
            2 { WindowsUpdates }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne {1..2})
    
}
#>
function Show-WUpdateHistory {
	Write-Log " Showing Windows Update History."
	Write-Log " Try to gather Windows Update History Information."
    Clear-Host
	
	try{
		$UpdateSession = New-Object -ComObject Microsoft.Update.Session
	}
	catch{
		Write-Log " ERROR: An error occurred while trying to load Microsoft Update Session Object.
	Reason: $_"
        Write-Host -ForegroundColor Red " ERROR: An error occurred while trying to load Microsoft Update Session Object.
    Reason: $_"
	}

	# Create the searcher and search for available updates
	try{
		$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
		
	}
	catch{
		Write-Log " ERROR: An error occurred while trying to create update seacrher.
	Reason: $_"
        Write-Host -ForegroundColor Red " ERROR: An error occurred while to create update seacrher.
    Reason: $_"
	}

    # Create an array to hold the custom objects for each update
	$UpdateInfoList = @()
	
	# Retrieve the updates installed
	try{
		$HistoryCount = $UpdateSearcher.GetTotalHistoryCount()
	}
	catch{
		Write-Log " ERROR: An error occurred while trying to count update history.
	Reason: $_"
        Write-Host -ForegroundColor Red " ERROR: An error occurred while to count update history.
    Reason: $_"
	}
	
    try{ 
		# Fetch history entries (most recent first)
		$HistoryItems = $UpdateSearcher.QueryHistory(0, $HistoryCount)  # Fetch all available updates
		
		# Loop through the update history
		foreach ($HistoryItem in $HistoryItems) {
			$Title = $HistoryItem.Title
			$Date = $HistoryItem.Date
			$ResultCode = $HistoryItem.ResultCode
			$UpdateID = $HistoryItem.UpdateIdentity.UpdateID
			$SupportURL = $HistoryItem.SupportUrl

			<#$KBNumbers = if ($HistoryItem.SupportUrl -ne "") { "KB$($HistoryItem.KBArticleIDs)" } else { "-" }
			if ($HistoryItem.SupportUrl -ne ""){
				$URL = $HistoryItem.SupportUrl
				$KBNumber = $URL.Split('?')[-1].Split('=')[-1]
				$KBNumber = "KB$($KBNumber)"
				#Write-Host "KB: $KBNumber"
			}
			else{
				$KBNumber = "-"
			}#>

			$StatusMessage = Get-UpdateResultCodes($HistoryItem.ResultCode)

			# Create a custom object to store the update info
			$UpdateInfo = [PSCustomObject]@{
				Date        = $Date
				StatusCode 	= $ResultCode
				Status      = $StatusMessage
				SupportURL 	= $SupportURL
				UpdateID    = $UpdateID
				Title      	= $Title
			}

			# Add the custom object to the list
			#$UpdateInfoList += $UpdateInfo
			
			# Add the custom object to the list if not already added (remove duplicates by UpdateID)
            if (-not ($UpdateInfoList.UpdateID -contains $UpdateID)) {
                $UpdateInfoList += $UpdateInfo
            }
		}
		
		# Display the updates in a table format
		Write-Host "-----------------------------------------------------------------------------------"
		Write-Host "    Total Updates in History: $($UpdateInfoList.Count)
"
		$UpdateInfoList | Select-Object Date,StatusCode,Status,SupportURL,UpdateID,Title | Format-Table #Format-Table -AutoSize
    }
    catch{
		Write-Log " ERROR: Windows Updates can not be displayed.
    Reason: $_"
        Write-Warning "
    Windows Updates can not be displayed.
    $_"
    }

    Write-Host "
        1) Export History
        2) Return to Windows Update menu
        3) Refresh
-----------------------------------------------------------------------------------"

    do {
        $choice = Read-Host " Choose an Option (1-3)"
		Write-Log " User input: $choice"
        switch ($choice) {
            1 { Export-History($UpdateInfoList) }
            2 { WindowsUpdates }
			3 { Show-WUpdateHistory }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne {1..3})
    
}

###
### Perform Windows Updates
###
<#
-Download Get list of updates and download approved updates, but do not install it.
-AcceptAll Do not ask confirmation for updates. Download or Install all available updates.
-AutoReboot Do not ask for reboot if it needed.
-IgnoreReboot Do not ask for reboot if it needed, but do not reboot automaticaly.
-Install Get list of updates and install approved updates.
-WindowsUpdate Use Microsoft Update Service Manager - '7971f918-a847-4430-9279-4a52d1efe18d'
-MicrosoftUpdate Use Windows Update Service Manager - '9482f4b4-e343-43b6-b170-9a65bc822c77'
#>
<#
function WindowsUpdates {
    #Write-Warning " Function TBD"
    #return


    Write-Log " Accessing Windows Updates."
	
    Clear-Host

    ### Load Modules
    # NuGet
	Write-Log " Checking for 'NuGet' Package Provider."
    if(-not (Get-PackageProvider | Where-Object { $_.Name -eq "NuGet" })) 
    {
		Write-Log " Installing additional tools, that are required."
		Write-Log " Installing NuGet Package-Provider with '-MinimumVersion 2.8.5.201', '-ForceBootstrap' and '-Force'."
        Write-Host "
    Installing additional tools, that are required..."
        try {
            $NuGet = Install-PackageProvider -Name "NuGet" -MinimumVersion "2.8.5.201" -ForceBootstrap -Force
            #Write-Host "NuGet PackageProvider installed successfully."
        }
        catch {
			Write-Log " ERROR: An error occurred while trying to install NuGet PackageProvider:
	Reason: $_"
            Write-Error "An error occurred while trying to install NuGet PackageProvider: $_"
        }
    }
    else {
		Write-Log " Additional tools installed."
        Write-Host " 
    Additional tools installed"
    }

    # Repository
	Write-Log " Checking for 'PSGallery' PowerShell Repository."
    if(-not (Get-PSRepository | Where-Object { $_.Name -ne "PSGallery"})) 
    {
		Write-Log "  Loading additional tools."
		Write-Log "  Setting new PowerShell Repository 'PS-Gallery' to 'Trusted'."
        Write-Host " 
    Loading additional tools..."
        try{
            Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
        }
        catch{
			Write-Log " ERROR: An error occurred while trying to to set PS Repository:
	Reason: $_"
            Write-Error "An error occurred while trying to set PS Repository: $_"
        }
    }
    else
    {
		Write-Log " Additional tools loaded."
        Write-Host " 
    Additional tools loaded"
    }

    # Module
	Write-Log " Checking if 'PSWindowsUpdate' PowerShell Module is installed."
    if(-not (Get-InstalledModule | Where-Object { $_.Name -eq "PSWindowsUpdate" })) 
    {
		Write-Log "  Installing more additional tools, that are required."
		Write-Log "  Installing PowerShell Module 'PSWindowsUpdate'."
        Write-Host " 
    Installing more additional tools, that are required..."
        try{
            Install-Module -Name "PSWindowsUpdate" #-Confirm:$True
        }
        catch{
            Write-Log " ERROR: An error occurred while trying to install PSWindowsUpdate Module:
	Reason: $_"
			Write-Error "An error occurred while trying to install PSWindowsUpdate Module: $_"
        }
    }
    else{
		Write-Log " More additional tools installed."
        Write-Host " 
    More additional tools installed"
    }

	Write-Log " Checking if 'PSWindowsUpdate' PowerShell Module is imported."
    if(-not (Get-Module | Where-Object { $_.Name -eq "PSWindowsUpdate" })) 
    {
		Write-Log "  Loading more additional tools."
		Write-Log "  Importing PowerShell Module 'PSWindowsUpdate'."
		Write-Host " 
    Loading more additional tools..."
        try{
            Import-Module "PSWindowsUpdate"
        }
        catch{
             Write-Log " ERROR: An error occurred while trying to import PSWindowsUpdate Module:
	Reason: $_"
			Write-Error "An error occurred while trying to import PSWindowsUpdate Module: $_"
        }
    }
    else{
		Write-Log " More additional tools loaded."
        Write-Host " 
    More additional tools loaded"
    }

    
    #$UpdateList = Get-WUList
    # Get all available updates (including those that are downloaded and pending installation)
    #$UpdateList = Get-WindowsUpdate -AcceptAll -Download
    Clear-Host
    $UpdateList = Get-WindowsUpdate -ComputerName $env:COMPUTERNAME

    Write-Host "-----------------------------------------------------------------------------------"
    # Check if there are any updates that are available to install
    if ($UpdateList) {
        Write-Host " 
    Pending Updates:"
    $UpdateList | Select-Object Status,KB,Size,Title | ft
    } else {
        Write-Host "
    Pending Updates:
        No pending updates found."
    }
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host " 
    Windows Updates menu"
    Write-Host "
        1) Search and download updates
        2) Install updates
        3) Show Update Hostory
        4) Return to main menu
-----------------------------------------------------------------------------------"

    do {
        $choice = Read-Host " Choose an Option (1-4)"
		Write-Log " User input: $choice"
        switch ($choice) {
            1 { Enter-Download-WUpdates }
            2 { Install-WUpdates }
            3 { Show-WUpdateHistory }
            4 { Show-Menu }
            default {
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne {1..4})
    
}
#>
function WindowsUpdates {
	#$UpdateList = Get-WUList
    # Get all available updates (including those that are downloaded and pending installation)
    #$UpdateList = Get-WindowsUpdate -AcceptAll -Download
    Clear-Host
    #$UpdateList = Get-WindowsUpdate -ComputerName $env:COMPUTERNAME
	
	try{
		$UpdateSession = New-Object -ComObject Microsoft.Update.Session
	}
	catch{
		Write-Log " ERROR: An error occurred while trying to load Microsoft Update Session Object.
	Reason: $_"
        Write-Host -ForegroundColor Red " ERROR: An error occurred while trying to load Microsoft Update Session Object.
    Reason: $_"
	}

	# Create the searcher and search for available updates
	try{
		$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
		
	}
	catch{
		Write-Log " ERROR: An error occurred while trying to create update seacrher.
	Reason: $_"
        Write-Host -ForegroundColor Red " ERROR: An error occurred while to create update seacrher.
    Reason: $_"
	}
	
	# Get only "not installed" updates
	try{
		$SearchResult = $UpdateSearcher.Search("IsInstalled=0")
	}
	catch{
		Write-Log " ERROR: An error occurred while trying to find available udpates.
	Reason: $_"
        Write-Host -ForegroundColor Red " ERROR: An error occurred while to find available udpates.
    Reason: $_"
	}
	
	
	# Create an array to hold the custom objects for each update
	$UpdateInfoList = @()

	<#
	Update objects:
Title                           : Security Intelligence Update for Microsoft Defender Antivirus - KB2267602 (Version 1.403.748.0) - Current Channel (Broad)
AutoSelectOnWebSites            : True
BundledUpdates                  : System.__ComObject
CanRequireSource                : False
Categories                      : System.__ComObject
Deadline                        : 
DeltaCompressedContentAvailable : False
DeltaCompressedContentPreferred : True
Description                     : Install this update to revise the files that are used to detect viruses, spyware, and other potentially unwanted software. Once you have installed 
                                  this item, it cannot be removed.
EulaAccepted                    : True
EulaText                        : 
HandlerID                       : 
Identity                        : System.__ComObject
Image                           : 
InstallationBehavior            : System.__ComObject
IsBeta                          : False
IsDownloaded                    : False
IsHidden                        : False
IsInstalled                     : False
IsMandatory                     : False
IsUninstallable                 : False
Languages                       : System.__ComObject
LastDeploymentChangeTime        : 23.09.2024 00:00:00
MaxDownloadSize                 : 1093925848
MinDownloadSize                 : 0
MoreInfoUrls                    : System.__ComObject
MsrcSeverity                    : 
RecommendedCpuSpeed             : 0
RecommendedHardDiskSpace        : 0
RecommendedMemory               : 0
ReleaseNotes                    : 
SecurityBulletinIDs             : System.__ComObject
SupersededUpdateIDs             : System.__ComObject
SupportUrl                      : https://go.microsoft.com/fwlink/?LinkId=52661
Type                            : 1
UninstallationNotes             : 
UninstallationBehavior          : 
UninstallationSteps             : System.__ComObject
KBArticleIDs                    : System.__ComObject
DeploymentAction                : 1
DownloadPriority                : 2
DownloadContents                : System.__ComObject
RebootRequired                  : False
IsPresent                       : True
CveIDs                          : System.__ComObject
BrowseOnly                      : False
PerUser                         : False
AutoSelection                   : 0
AutoDownload                    : 0
	#>
	foreach ($update in $SearchResult.Updates) {
		$Title = $update.Title
		#$KBNumbers = "KB$($update.KBArticleIDs)" -join ", "  # Join multiple KBs if applicable
		# Get KB numbers, join them if multiple, or use a placeholder if empty
		$KBNumbers = if ($update.KBArticleIDs -ne "") { "KB$($update.KBArticleIDs)" -join ", " } else { "-" }
		$SizeInMB = [math]::round($update.MaxDownloadSize / 1MB, 2)  # Convert bytes to MB and round to 2 decimal places
		
		# Convert size to GB if it's greater than 1000 MB, else keep it in MB
		if ($SizeInMB -gt 1000) {
			$SizeInGB = [math]::round($SizeInMB / 1024, 2)  # Convert MB to GB and round to 2 decimal places
			$SizeDisplay = "$($SizeInGB)GB"
		} else {
			$SizeDisplay = "$($SizeInMB)MB"
		}
		
		#$Status = if($update.IsDownloaded -eq 1 -and $update.IsInstalled -eq 0){ "Ready to Install" } elseif($update.IsDownloaded -eq 0 -and $update.IsInstalled -eq 0){ "Ready to Download" } elseif($update.IsInstalled -eq 1){ "Is Installed" } else { "No Status" }
		$Status = if($update.IsDownloaded -eq 1 -and $update.RebootRequired -eq 0){ "Ready to Install" } elseif($update.IsDownloaded -eq 0){ "Ready to Download" } elseif($update.IsDownloaded -eq 1 -and $update.RebootRequired -eq 1){ "Pending Reboot" } else{ "No Status" }
		
		$RebootReq = if($update.RebootRequired -eq 1){ "Reboot Required" } else{ "-" }
		
		# Create a custom object to store the update info
		$UpdateInfo = [PSCustomObject]@{
			Status 		= $Status
			Reboot      = $RebootReq
			KBNumber   	= $KBNumbers
			Size   		= $SizeDisplay
			Title      	= $Title
		}

		# Add the custom object to the list
		$UpdateInfoList += $UpdateInfo
	}

    Write-Host "-----------------------------------------------------------------------------------"
    # Check if there are any updates that are available to install
    if ($SearchResult.Updates) {
        Write-Host " 
    Available Updates:"
		#$UpdateList | Select-Object Status,KB,Size,Title | ft
		
		# Display the updates in a table format
		$UpdateInfoList | Select-Object Status,KBNumber,Size,Title | Format-Table #Format-Table -AutoSize
		
		if (($UpdateInfoList | Select-Object -ExpandProperty Reboot) -contains "Reboot Required") {
            Write-Host -ForegroundColor Yellow "
    System Reboot is required.
"
        }
		
    } else {
        Write-Host "
    Available Updates:
        No available updates found."
    }
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host " 
    Windows Updates menu"
    Write-Host "
        1) Search and download updates
        2) Install updates
        3) Show Update Hostory
        4) Refresh 
        5) Return to main menu
-----------------------------------------------------------------------------------"

    do {
        $choice = Read-Host " Choose an Option (1-5)"
		Write-Log " User input: $choice"
        switch ($choice) {
            1 { Enter-Download-WUpdates }
            2 { Install-WUpdates }
            3 { Show-WUpdateHistory }
			4 { WindowsUpdates }
            5 { Show-Menu }
            default {
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne {1..5})
}

####
#### Log-Off
####
function Start-Log-Off {
	Write-Log " Logging off current user session."
	for ($i = 3; $i -gt 0; $i=$i - 1 ) {
		clear-host
		Write-Host -ForegroundColor Yellow "
	Logging you out in $i seconds..."
		Start-Sleep -Seconds 1
	}
    
    try {
        shutdown.exe /l
    } catch {
		Write-Log " ERROR: An error occurred while trying to log out.
	Reason: $_"
        Write-Host -ForegroundColor Red " ERROR: An error occurred while trying to log out.
    Reason: $_"
    }
}

####
#### Restart-System
####
function Restart-System {
	Write-Log " Restarting system."
    do{
        $Continue = Read-Host " Do you want to continue (Y/N)"
		Write-Log " User input: $Continue"
    } while($Continue -ne "Y" -and $Continue -ne "N")
	
    if($Continue -eq "Y") {
		Write-Log " User choose to restart the system. Restart is executed in 10 seconds."
        for ($i = 10; $i -gt 0; $i=$i - 1 ) {
		    clear-host
		    Write-Host -ForegroundColor Yellow "
	System is going down for reboot in $i seconds..."
		    Start-Sleep -Seconds 1
	    }
        Restart-Computer #-WhatIf
    }
    elseif($Continue -eq "N"){
		Write-Log " User choose to not restart the system."
        Show-Menu
    }
}

####
#### Shutdown-System
####
function Start-Shutdown-System {
	Write-Log " Shutting down system."
    do{
        $Continue = Read-Host " Do you want to continue (Y/N)"
		Write-Log " User input: $Continue"
    } while($Continue -ne "Y" -and $Continue -ne "N")

    if($Continue -eq "Y") {
		Write-Log " User choose to shut down the system. Shutdown is executed in 10 seconds."
	    for ($i = 10; $i -gt 0; $i=$i - 1 ) {
		    clear-host
		    Write-Host -ForegroundColor Yellow "
    System is shutting down in $i seconds..."
		    Start-Sleep -Seconds 1
	    }
        Stop-Computer #-WhatIf
    }
    elseif($Continue -eq "N"){
		Write-Log " User choose to not shut down the system."
        Show-Menu
    }
}

####
#### Start-Terminal
####
function Start-Terminal {
	Write-Log " Starting new terminal window."
	try{
		Start-Process -FilePath "C:\Windows\System32\cmd.exe" -verb runas
	}
	catch{
		Write-Log " ERROR: New terminal window could not be started.
    Reason: $_"
		Write-Host -ForegroundColor Red " ERROR: New terminal window could not be started.
    Reason: $_"
	}
}


####
#### Main Menu Selection
####
Show-Menu

