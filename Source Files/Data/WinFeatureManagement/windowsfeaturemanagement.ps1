<#
.SYNOPSIS
    Role-aware Windows feature management menus for multiple windows server roles.
.DESCRIPTION
    `windowsfeaturemanagement.ps1` provides interactive, role-specific management menus that
    light up only when corresponding Windows features are installed:

      - Active Directory Domain Services (with DNS & GPMC):
          - DNS server setup
          - First domain controller promotion
          - Post-setup tasks
          - Add additional domain controller
          - Import EF standard GPO set
          - Create Central Policy Store
          - Create standard OU template
          - Create standard AD groups and users
          - Bulk add users to groups
          - Export/Import AD users (CSV)

      - Hyper-V (with Hyper-V PowerShell):
          - Global default paths (VHD & VM)
          - Spanning NUMA
          - Live/Storage migration settings
          - Extended Session Mode
          - Virtual switch configuration
          - Hyper-V service control and status dashboard
          - VM management
          - iWARP configuration
          - S2D cluster creation (basic bootstrap)
          - HCI storage workflows (placeholder)

    The script performs feature detection via `Get-WindowsFeature` and then opens the
    appropriate menu. Each menu item launches a dedicated helper script in a new, maximized
    PowerShell window using `Start-Process -ExecutionPolicy Bypass`, while writing
    timestamped entries to `C:\_psc\psc_sconfig\Logfiles\psc_sconfig.log`.

    Intended usage:
      - Run locally on servers that already have AD DS/DNS/GPMC and/or Hyper-V installed.
      - Execute with administrative privileges.
      - Use as a companion to PSC_Sconfig to perform deeper role configuration tasks.
	  
.LINK
	https://learn.microsoft.com/windows-server/identity/ad-ds/
    https://learn.microsoft.com/windows-server/networking/dns/
    https://learn.microsoft.com/windows-server/administration/windows-commands/gpupdate
    https://learn.microsoft.com/windows-server/administration/windows-commands/dism
    https://learn.microsoft.com/virtualization/hyper-v-on-windows/
    https://learn.microsoft.com/windows-server/storage/storage-spaces/storage-spaces-direct-overview
	https://github.com/PScherling

.NOTES
          FileName: windowsfeaturemanagement.ps1
          Solution: PSC_Sconfig - Role Management
          Author: Patrick Scherling
          Contact: @Patrick Scherling
          Primary: @Patrick Scherling
          Created: 2024-12-01
          Modified: 2026-03-19

          Version - 0.0.1 - () - Initial first attempt. 
		  Version - 0.0.2 - () - ADC Management
		  Version - 0.0.3 - () - Hyper-V Management
		  Version - 0.0.4 - () - Extending ADC Management with AD User Export and Import
		  Version - 0.0.5 - (2026-03-19) - Check if tool is running with elevated privivledges


          TODO:
			Coming Features
				- HCI Management
				- PKI Management

.REQUIREMENTS
    - Run as Administrator.
    - Windows Server with relevant roles:
        - AD DS + DNS + GPMC for ADC menu
        - Hyper-V + Hyper-V PowerShell for Hyper-V menu
    - PowerShell 5.1+ (or PowerShell 7.x on Windows).
    - Helper scripts available at the expected paths under:
        C:\_psc\ADC_Setup\* and C:\_psc\HyperV_Setup\*

.OUTPUTS
    Console output and log entries written to:
        C:\_psc\psc_sconfig\Logfiles\psc_sconfig.log

.Example
    PS C:\> .\windowsfeaturemanagement.ps1
    Detects installed roles and opens the matching management menu (ADC or Hyper-V).

	PS C:\> powershell.exe -ExecutionPolicy Bypass -File "C:\_psc\psc_sconfig\WinFeatureManagement\windowsfeaturemanagement.ps1"
    Runs the role management menus in a new PowerShell process with execution policy bypass.
#>

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
Write-Log " Starting psc_sconfig - windowsfeature management..."

# Require admin
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
  Write-Log " ERROR: Run PowerShell as Administrator."
  throw "Run PowerShell as Administrator."
}

###
### ADC Menu
###
function Show-ADC-Menu {
	Write-Log " Showing ADC Menu."
    Clear-Host
    Write-Host "`n-----------------------------------------------------------------------------------"
    Write-Host "               Active-Directory Management"
    Write-Host "-----------------------------------------------------------------------------------"

    Write-Host "
    Initial Server Configuration
    1) DNS Server Setup
    2) Domain-Controller Setup
    3) Run Post-Setup Tasks
    4) Add Server as Domain-Controller

    Initial Active-Directory Setup
    5) Import Standard GPO Set
    6) Create Central Policy Store
    7) Create Standard OU Template
    8) Create Standard AD Groups
    9) Create Standard AD Users
    10) Add Standard AD Users to AD Groups
    11) Link Standard GPOs with OUs
	
    Actions
    12) Export AD Users into csv file
    13) Import AD Users from csv file

    14) Leave Management

-----------------------------------------------------------------------------------"

    do {
    
        $choice = Read-Host " Choose an Option (1-14)"
		Write-Log " User Input: $choice"
        switch ($choice) {
            1 { DNS-Server-Setup }
            2 { Domain-Controller-Setup }
            3 { Post-Setup-Tasks }
            4 { Add-DC }
            5 { Import-GPO-Set }
            6 { Create-Central-Policy-Store }
            7 { Create-OU-Template }
            8 { Create-AD-Groups }
            9 { Create-AD-Users }
            10 { Add-ADUsersToADGroups }
            11 { Link-GPOWithOU }
			12 { Export-AD-Users}
			13 { Import-AD-Users }
            14 { Exit }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne {1..14})  
    
}

### DNS Setup
function DNS-Server-Setup {
	Write-Log " Starting DNS Server Setup."
    Clear-Host

    try{
        $DNSZones = (Get-DNSServerZone -ErrorAction SilentlyContinue).ZoneName
    }
    catch{
        $DNSZones = $null
    }

    try{
        $DomainName = (Get-ADDomain -ErrorAction SilentlyContinue).DNSRoot
    }
    catch{
        $DomainName = $null
    }

    if([string]::IsNullOrEmpty($DNSZones)){
		Write-Log " Active-Directory Management can not be executed due to insufficient prerequisites!"
        Write-Host -ForegroundColor Red "    Active-Directory Management can not be executed due to insufficient prerequisites!"
        Read-Host " Press any key to abort"
    }
    <#$DNSzones -contains "0.in-addr.arpa" -and $DNSzones -contains "127.in-addr.arpa" -and $DNSzones -contains "255.in-addr.arpa"#>
    elseif($DNSZones -contains $DomainName){
		Write-Log " DNS Zone for your Domain already exists."
        Write-Host " DNS Zone for your Domain already exists..."
    }
    else{
        try{
            Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\ADC_Setup\0_DNS_AD_Initial-Setup\1_ad-dns-server-configuration_final.ps1"
        }
        catch{
			Write-Log " ERROR: Something went wrong!"
            Write-Warning " Something went wrong!"
        }
        
    }
    Show-ADC-Menu
}

### First Domain-Controller Setup
function Domain-Controller-Setup {
	Write-Log " Starting Domain Controller Setup."
    Clear-Host

    try{
        $DNSZones = (Get-DNSServerZone -ErrorAction SilentlyContinue).ZoneName
    }
    catch{
        $DNSZones = $null
    }

    try{
        $DomainName = (Get-ADDomain -ErrorAction SilentlyContinue).DNSRoot
    }
    catch{
        $DomainName = $null
    }

    if([string]::IsNullOrEmpty($DNSZones)){
		Write-Log " Active-Directory Management can not be executed due to insufficient prerequisites!"
        Write-Host -ForegroundColor Red "    Active-Directory Management can not be executed due to insufficient prerequisites!"
        Read-Host " Press any key to abort"
    }
    else{
        try{
            Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\ADC_Setup\0_DNS_AD_Initial-Setup\2_ad-setup_final.ps1"
        }
        catch{
			Write-Log " Something went wrong!"
            Write-Warning " Something went wrong!"
        }
        
    }
    Show-ADC-Menu
}

### Post Domain-Controller Setup Tasks
function Post-Setup-Tasks {
	Write-Log " Starting Domain Controller Post Setup Tasks."
    Clear-Host

    try{
        $DNSZones = (Get-DNSServerZone -ErrorAction SilentlyContinue).ZoneName
    }
    catch{
        $DNSZones = $null
    }

    try{
        $DomainName = (Get-ADDomain -ErrorAction SilentlyContinue).DNSRoot
    }
    catch{
        $DomainName = $null
    }

    if([string]::IsNullOrEmpty($DNSZones)){
		Write-Log " Active-Directory Management can not be executed due to insufficient prerequisites!"
        Write-Host -ForegroundColor Red "    Active-Directory Management can not be executed due to insufficient prerequisites!"
        Read-Host " Press any key to abort"
    }
    else{
        try{
            Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\ADC_Setup\0_DNS_AD_Initial-Setup\3_ad-post-setup-tasks_final.ps1"
        }
        catch{
			Write-Log " Something went wrong!"
            Write-Warning " Something went wrong!"
        }
        
    }
    Show-ADC-Menu
}

### Add Server as DC
function Add-DC {
	Write-Log " Starting Adding Domain Controller."
    Clear-Host

    try{
        $LocalInfo = Get-ComputerInfo
        $DomainRole = $LocalInfo.CsDomainRole
    }
    catch{
        $LocalInfo = $null
        $DomainRole = $null
    }

    if($DomainRole -ne "MemberServer"){
		Write-Log " Active-Directory Management can not be executed due to insufficient prerequisites!"
        Write-Host -ForegroundColor Red "    Active-Directory Management can not be executed due to insufficient prerequisites!"
        Read-Host " Press any key to abort"
    }
    else{
        try{
            Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\ADC_Setup\0_DNS_AD_Initial-Setup\4_ad-setup_add-dc_final.ps1"
        }
        catch{
			Write-Log " Something went wrong!"
            Write-Warning " Something went wrong!"
        }
        
    }
    Show-ADC-Menu
}

### Import Standard Group Policies
function Import-GPO-Set {
	Write-Log " Starting Importing Group Policies."
    Clear-Host
    
    try{
        $LocalInfo = Get-ComputerInfo
        $DomainRole = $LocalInfo.CsDomainRole
    }
    catch{
        $LocalInfo = $null
        $DomainRole = $null
    }

    if($DomainRole -ne "PrimaryDomainController" -and $DomainRole -ne "BackupDomainController"){
		Write-Log " Active-Directory Management can not be executed due to insufficient prerequisites!"
        Write-Host -ForegroundColor Red "    Active-Directory Management can not be executed due to insufficient prerequisites!"
        Read-Host " Press any key to abort"
    }
    else{
        try{
            Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\ADC_Setup\1_GroupPolicies\1_AddAndImport_GPOSet.ps1"
        }
        catch{
			Write-Log " Something went wrong!"
            Write-Warning " Something went wrong!"
        }
        
    }
    Show-ADC-Menu
}

### Create Central Policy Store
function Create-Central-Policy-Store {
	Write-Log " Starting Creating Central Policy Store."
    Clear-Host

    try{
        $LocalInfo = Get-ComputerInfo
        $DomainRole = $LocalInfo.CsDomainRole
    }
    catch{
        $LocalInfo = $null
        $DomainRole = $null
    }

    if($DomainRole -ne "PrimaryDomainController" -and $DomainRole -ne "BackupDomainController"){
		Write-Log " Active-Directory Management can not be executed due to insufficient prerequisites!"
        Write-Host -ForegroundColor Red "    Active-Directory Management can not be executed due to insufficient prerequisites!"
        Read-Host " Press any key to abort"
    }
    else{
        try{
            Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\ADC_Setup\1_GroupPolicies\2_CreateCentralPolicyStore.ps1"
        }
        catch{
			Write-Log " Something went wrong!"
            Write-Warning " Something went wrong!"
        }
        
    }
    Show-ADC-Menu
}

### Create Standard OU Template
function Create-OU-Template {
	Write-Log " Starting Creating OU Template."
    Clear-Host

    try{
        $LocalInfo = Get-ComputerInfo
        $DomainRole = $LocalInfo.CsDomainRole
    }
    catch{
        $LocalInfo = $null
        $DomainRole = $null
    }

    if($DomainRole -ne "PrimaryDomainController" -and $DomainRole -ne "BackupDomainController"){
		Write-Log " Active-Directory Management can not be executed due to insufficient prerequisites!"
        Write-Host -ForegroundColor Red "    Active-Directory Management can not be executed due to insufficient prerequisites!"
        Read-Host " Press any key to abort"
    }
    else{
        try{
            Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\ADC_Setup\2_OU-Template_Import\1_ad-ou-std-creation_final.ps1"
        }
        catch{
			Write-Log " Something went wrong!"
            Write-Warning " Something went wrong!"
        }
        
    }
    Show-ADC-Menu
}

### Create Standard AD Groups
function Create-AD-Groups {
	Write-Log " Starting Creating AD Groups."
    Clear-Host

    try{
        $LocalInfo = Get-ComputerInfo
        $DomainRole = $LocalInfo.CsDomainRole
    }
    catch{
        $LocalInfo = $null
        $DomainRole = $null
    }

    if($DomainRole -ne "PrimaryDomainController" -and $DomainRole -ne "BackupDomainController"){
		Write-Log " Active-Directory Management can not be executed due to insufficient prerequisites!"
        Write-Host -ForegroundColor Red "    Active-Directory Management can not be executed due to insufficient prerequisites!"
        Read-Host " Press any key to abort"
    }
    else{
        try{
            Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\ADC_Setup\3_AD_Groups_Import\1_group-import_final.ps1"
        }
        catch{
			Write-Log " Something went wrong!"
            Write-Warning " Something went wrong!"
        }
        
    }
    Show-ADC-Menu
}

### Create Standard AD Users
function Create-AD-Users {
	Write-Log " Starting Creating AD Users."
    Clear-Host

    try{
        $LocalInfo = Get-ComputerInfo
        $DomainRole = $LocalInfo.CsDomainRole
    }
    catch{
        $LocalInfo = $null
        $DomainRole = $null
    }

    if($DomainRole -ne "PrimaryDomainController" -and $DomainRole -ne "BackupDomainController"){
		Write-Log " Active-Directory Management can not be executed due to insufficient prerequisites!"
        Write-Host -ForegroundColor Red "    Active-Directory Management can not be executed due to insufficient prerequisites!"
        Read-Host " Press any key to abort"
    }
    else{
        try{
            Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\ADC_Setup\4_AD_User_Import\1_user-import_final.ps1"
        }
        catch{
			Write-Log " Something went wrong!"
            Write-Warning " Something went wrong!"
        }
        
    }
    Show-ADC-Menu
}

### Add Standard AD Users to AD Groups
function Add-ADUsersToADGroups {
	Write-Log " Starting Adding AD Users to AD Groups."
    Clear-Host

    try{
        $LocalInfo = Get-ComputerInfo
        $DomainRole = $LocalInfo.CsDomainRole
    }
    catch{
        $LocalInfo = $null
        $DomainRole = $null
    }

    if($DomainRole -ne "PrimaryDomainController" -and $DomainRole -ne "BackupDomainController"){
		Write-Log " Active-Directory Management can not be executed due to insufficient prerequisites!"
        Write-Host -ForegroundColor Red "    Active-Directory Management can not be executed due to insufficient prerequisites!"
        Read-Host " Press any key to abort"
    }
    else{
        try{
            Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\ADC_Setup\5_AD_AddUserToGroup\1_ad-adduserstogroups_final.ps1"
        }
        catch{
			Write-Log " Something went wrong!"
            Write-Warning " Something went wrong!"
        }
        
    }
    Show-ADC-Menu
}

### Link Group Policies with OUs
function Link-GPOWithOU {
    Clear-Host

    try{
        $LocalInfo = Get-ComputerInfo
        $DomainRole = $LocalInfo.CsDomainRole
    }
    catch{
        $LocalInfo = $null
        $DomainRole = $null
    }

    if($DomainRole -ne "PrimaryDomainController" -and $DomainRole -ne "BackupDomainController"){
        Write-Host -ForegroundColor Red "    Active-Directory Management can not be executed due to insufficient prerequisites!"
        Read-Host " Press any key to abort"
    }
    else{
        try{
            Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\ADC_Setup\6_AD_OU-GPO-Link_Import\1_ou-gpo-link-import_final.ps1"
        }
        catch{
            Write-Warning " Something went wrong!"
        }
        
    }
    Show-ADC-Menu
}

### Export AD Users
function Export-AD-Users {
    Clear-Host

    try{
        $LocalInfo = Get-ComputerInfo
        $DomainRole = $LocalInfo.CsDomainRole
    }
    catch{
        $LocalInfo = $null
        $DomainRole = $null
    }

    if($DomainRole -ne "PrimaryDomainController" -and $DomainRole -ne "BackupDomainController"){
        Write-Host -ForegroundColor Red "    Active-Directory Management can not be executed due to insufficient prerequisites!"
        Read-Host " Press any key to abort"
    }
    else{
        try{
            Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\ADC_Setup\7_AD_User-Export-Import\AD-bulk-user-export.ps1"
        }
        catch{
            Write-Warning " Something went wrong!"
        }
        
    }
    Show-ADC-Menu
}

### Import AD Users
function Import-AD-Users {
    Clear-Host

    try{
        $LocalInfo = Get-ComputerInfo
        $DomainRole = $LocalInfo.CsDomainRole
    }
    catch{
        $LocalInfo = $null
        $DomainRole = $null
    }

    if($DomainRole -ne "PrimaryDomainController" -and $DomainRole -ne "BackupDomainController"){
        Write-Host -ForegroundColor Red "    Active-Directory Management can not be executed due to insufficient prerequisites!"
        Read-Host " Press any key to abort"
    }
    else{
        try{
            Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\ADC_Setup\7_AD_User-Export-Import\AD-bulk-user-import.ps1"
        }
        catch{
            Write-Warning " Something went wrong!"
        }
        
    }
    Show-ADC-Menu
}

###
### Hyper-V Menu
###
function Show-HyperV-Menu {
	Write-Log " Showing Hyper-V Menu."
    Clear-Host
    Write-Host "`n-----------------------------------------------------------------------------------"
    Write-Host "               Hyper-V Management"
    Write-Host "-----------------------------------------------------------------------------------"

    Write-Host "
    Server Configuration
    1) Global Virtual Hard Disks Storage Location
    2) Global Virtual Computer Storage Location
    3) Spanning NUMA
    4) Live Migration
    5) Storage Migration
    6) Extended Session Mode
    7) Replication Configuration (TBD)
    8) Virtual Switch Configuration
    9) Start/Stop Service
    
    Hyper-V and HCI Management
    10) Display Hyper-V Status Information
    11) Virtual Machine Management
	
    12) iWARP Configuration
    13) Create S2D Cluster
    14) S2D Cluster Storage Configuration (TBD)
    
    15) Leave Management

-----------------------------------------------------------------------------------"

    do {
    
        $choice = Read-Host " Choose an Option (1-15)"
		Write-Log " User Input: $choice"
        switch ($choice) {
            1 { Manage-Global-VHD-Location }
            2 { Manage-Global-VC-Location }
            3 { Manage-Spanning-NUMA }
            4 { Manage-Live-Migration }
            5 { Manage-Storage-Migration }
            6 { Manage-Extended-Session-Mode }
            7 { Manage-Replication-Configuration }
            8 { Manage-Virtual-Switch-Configuration }
            9 { Manage-HyperV-Service }
            10 { Display-HyperV-Status-Information }
			11 { VirtualMachine-Management }
			12 { Manage-iWARP }
			13 { Create-S2DCluster }
			14 { Manage-HCI-Storage }
            15 { Exit }
            default { 
				Write-Log " Wrong Input."
				Write-Host "Wrong Input. Please choose an option above." 
			}
        }

    } while ($choice -ne {1..15})  
    
}

function Create-S2DCluster {
	Write-Log " Starting S2D Cluster creation."
	Clear-Host
	
    try{
        Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\HyperV_Setup\create_s2d-cluster.ps1"
    }
    catch{
		Write-Log " Something went wrong!"
        Write-Warning " Something went wrong!"
    }
    Show-HyperV-Menu
}

function Manage-iWARP {
	Write-Log " Starting iWARP Network Configuration."
	Clear-Host
	
    try{
        Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\HyperV_Setup\manage_iwarp.ps1"
    }
    catch{
		Write-Log " Something went wrong!"
        Write-Warning " Something went wrong!"
    }
    Show-HyperV-Menu
}

function Manage-HCI-Storage {
	Write-Warning " Feature is not ready at the moment..."
	<#
	Write-Log " Starting Replication Configuration."
	Clear-Host
	
    try{
        Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\HyperV_Setup\manage_replication.ps1"
    }
    catch{
		Write-Log " Something went wrong!"
        Write-Warning " Something went wrong!"
    }
	#>
	Read-Host -Prompt " Press any key"
	Show-HyperV-Menu
}

function Manage-Global-VHD-Location {
	Write-Log " Starting Manage Global VHD Location."
	Clear-Host
	
    try{
        Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\HyperV_Setup\manage_vhd-location.ps1"
    }
    catch{
		Write-Log " Something went wrong!"
        Write-Warning " Something went wrong!"
    }
    Show-HyperV-Menu
}

function Manage-Global-VC-Location {
	Write-Log " Starting Manage Global Virtual Computer Location."
    Clear-Host
	
    try{
        Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\HyperV_Setup\manage_vc-location.ps1"
    }
    catch{
		Write-Log " Something went wrong!"
        Write-Warning " Something went wrong!"
    }
    Show-HyperV-Menu
}

function Manage-Spanning-NUMA {
	Write-Log " Starting Manage Spanning-NUMA."
	Clear-Host
	
    try{
        Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\HyperV_Setup\manage_numa.ps1"
    }
    catch{
		Write-Log " Something went wrong!"
        Write-Warning " Something went wrong!"
    }
	Show-HyperV-Menu
}

function Manage-Live-Migration {
	Write-Log " Starting Manage Live-Migration."
	Clear-Host
	
    try{
        Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\HyperV_Setup\manage_live-migration.ps1"
    }
    catch{
		Write-Log " Something went wrong!"
        Write-Warning " Something went wrong!"
    }
	Show-HyperV-Menu
}

function Manage-Storage-Migration {
	Write-Log " Starting Manage Storage-Migration."
	Clear-Host
	
    try{
        Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\HyperV_Setup\manage_storage-migration.ps1"
    }
    catch{
		Write-Log " Something went wrong!"
        Write-Warning " Something went wrong!"
    }
	Show-HyperV-Menu
}

function Manage-Extended-Session-Mode {
	Write-Log " Starting Manage Extended-Session-Mode."
	Clear-Host
	
    try{
        Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\HyperV_Setup\manage_extended-session-mode.ps1"
    }
    catch{
		Write-Log " Something went wrong!"
        Write-Warning " Something went wrong!"
    }
	Show-HyperV-Menu
}

function Manage-Replication-Configuration {
	Write-Warning " Please, do not use this feature!"
	<#
	Write-Log " Starting Replication Configuration."
	Clear-Host
	
    try{
        Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\HyperV_Setup\manage_replication.ps1"
    }
    catch{
		Write-Log " Something went wrong!"
        Write-Warning " Something went wrong!"
    }
	#>
	Read-Host -Prompt " Press any key"
	Show-HyperV-Menu
}

function Manage-Virtual-Switch-Configuration {
	Write-Log " Starting Manage Virtual-Switch Configuration."
	Clear-Host
	
    try{
        Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\HyperV_Setup\manage_vmswitch.ps1"
    }
    catch{
		Write-Log " Something went wrong!"
        Write-Warning " Something went wrong!"
    }
	Show-HyperV-Menu
}

function Manage-HyperV-Service {
	Write-Log " Starting Manage Hyper-V Service."
	Clear-Host
	
    try{
        Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\HyperV_Setup\manage_hyperv-svc.ps1"
    }
    catch{
		Write-Log " Something went wrong!"
        Write-Warning " Something went wrong!"
    }
	Show-HyperV-Menu
}

function Display-HyperV-Status-Information {
	Write-Log " Starting showing Hyper-V Status Information."
	
	Clear-Host
	
    try{
        Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\HyperV_Setup\display_hyperv-info.ps1"
    }
    catch{
		Write-Log " Something went wrong!"
        Write-Warning " Something went wrong!"
    }
	Show-HyperV-Menu
}

function VirtualMachine-Management {
	Write-Log " Starting Virtual Machine Management."
	Clear-Host
	
    try{
        Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -windowstyle maximized -File", "C:\_psc\HyperV_Setup\manage_virtualmachines.ps1"
    }
    catch{
		Write-Log " Something went wrong!"
        Write-Warning " Something went wrong!"
    }
	Show-HyperV-Menu
}

























###
### Server Role Specific Options
###

# Get Only Installed Windows Features on server
$InstalledWinFeatures = Get-WindowsFeature | Where-Object { $_.Installed -eq $true }

if($InstalledWinFeatures.Name -contains "AD-Domain-Services" -and $InstalledWinFeatures.Name -contains "DNS" -and $InstalledWinFeatures.Name -contains "GPMC"){    
    Show-ADC-Menu
}
elseif($InstalledWinFeatures.Name -contains "Hyper-V" -and $InstalledWinFeatures.Name -contains "Hyper-V-Powershell"){
	Show-HyperV-Menu
}
else {
    # Nothing to display
}



