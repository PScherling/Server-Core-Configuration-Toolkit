# PSC SConfig – Server Core Configuration Toolkit
<img width="1579" height="875" alt="image" src="https://github.com/user-attachments/assets/0ce18da9-a479-44c9-9d8a-66eea30702e8" />
<img width="1579" height="564" alt="image" src="https://github.com/user-attachments/assets/5008246f-c581-4573-8c79-429b9239cc88" />

**PSC SConfig** is a menu‑driven PowerShell toolkit for configuring and administering Windows (especially **Server Core**) systems after deployment. It ships with a friendly console UI, robust logging, and role‑aware menus that light up for **Active Directory Domain Services** and **Hyper‑V** when those roles are installed and more are about to be included.

This repo includes:
- The interactive tool (`psc_sconfig.ps1`)
- A lightweight module launcher (`psc_sconfig.psm1`) so you can just type `psc_sconfig`
- Manual and automated installers (works with MDT)
- Optional role management menus (ADC/Hyper‑V) via `windowsfeaturemanagement.ps1`

---

## 🧭 Coming Features / Ideas

- Richer Hyper-V workflows for S2D and Shared Storage configurations
- File Server, Print Server, WSUS etc. workflows
- Simplify theming for the console header + report outputs

---

## ✨ What PSC SConfig does

### System overview (read‑only dashboard)
- OS/product/build (incl. UBR) and display version
- Uptime & last boot
- IP addresses info
- RAM (total/used/free) and **per‑volume** storage with **GB/TB** auto‑conversion
- Windows Defender Firewall profile status
- Windows Admin Center (WAC) / Azure Arc presence
- Windows Update policies & service status (WSUS/AU options)
- Diagnostic data (AllowTelemetry)
- Activation status
- Manufacturer and Model Information

### One‑key configuration actions
- Hostname / Domain or Workgroup join/leave
- Network Interface configuration
- Remote Management (WinRM) enable/disable
- Remote Desktop enable/disable
- Windows Update configuration + WUA‑based update workflows
- Date/Time configuration
- Diagnostic data level
- Windows activation
- Local users & groups: add user, add admin, create group
- Actions: Refresh, Logoff, Restart, Shutdown, open terminal

### 🧩 Role‑aware add‑ons (auto‑detected)
- **Active Directory Domain Services (AD DS)** + DNS + GPMC → **ADC menu**  
  - DNS server setup  
  - First domain controller promotion  
  - Post‑setup tasks  
  - Add additional domain controller  
  - Import “standard” GPO set & create central policy store  
  - Create OU template, standard groups/users, bulk group assignment  
  - **Export/Import AD users (CSV)**  
- **Hyper‑V** (+ Hyper‑V PowerShell) → **Hyper‑V menu**  
  - Global paths (VHD/VM)  
  - NUMA spanning, Live/Storage migration, Extended Session Mode  
  - Virtual switch management, service control, status dashboard  
  - VM management  
  - iWARP config, S2D cluster creation (bootstrap)
 
### 🧩 HPE‑aware add‑ons (auto‑detected)
https://github.com/PScherling/HPE-SPP-Installation-Toolkit is required.

Folder Structure:
`C:\_it\HPE\script.ps1`

- **HPE DL Server** (HPE SPP) Update option
  - Run interactively (iLO authentication required) for a manual install using a mounted ISO



### Admin experience
- Colorized menu UI with clear prompts
- Detailed **timestamped logging**
- Disables legacy **SConfig autolaunch** (best effort) on start

---

## 📦 Repository Contents

| Path / Script | Purpose |
|---|---|
| `Data\` | Copy payload for installers (module files, cmd/launchers, assets). |
| `Logfiles\` | Runtime log location (created under `C:\_it\psc_sconfig\Logfiles`). |
| `manual_Install-PSC_Sconfig.ps1` | **Manual/local** installer (uses local `.\Data` payload). |
| `custom_Install-PSC_Sconfig.ps1` | **Automated (MDT/WDS)** installer from a deployment share. |
| `Data\launch_psc_sconfig.bat` | For starting and auto-launching the module. |
| `Data\psc_sconfig.cmd` | For starting the main powershell script. |
| `Data\psc_sconfig.ps1` | The main interactive Server Core configuration tool. |
| `Data\psc_sconfig.psm1` | Module launcher: runs the tool in a new, maximized PowerShell window. |
| `Data\WinFeatureManagement\windowsfeaturemanagement.ps1` | Role‑aware management menus for **AD DS** and **Hyper‑V**. |

> The console header shows the current `$VersionNumber` defined in `psc_sconfig.ps1`.

---

## 🧱 Requirements

- Windows Server (Core recommended) or Windows with admin rights
- Run PowerShell as **Administrator**
- **PowerShell 5.1+** (or PowerShell 7.x on Windows)
- For role menus: install the corresponding roles first (AD DS + DNS + GPMC, or Hyper‑V + Hyper‑V PowerShell)
- Local write access for logs and reports

---

## 🔧 Installation

### A) Automated (MDT/WDS) – `custom_Install-PSC_Sconfig.ps1`
Pulls the payload from your deployment share and installs module + launchers.

- Copies **`\\<FileSrv>\DeploymentShare$\Scripts\custom\psc_sconfig\Data`** → `C:\_it\psc_sconfig`
- Creates module path: `C:\Program Files\WindowsPowerShell\Modules\psc_sconfig`
- Copies `psc_sconfig.psm1/.psd1` into the module path
- Copies `psc_sconfig.cmd` into `C:\Windows\System32`
- Imports the module
- Sets autostart (optional) and logs to a share
- Log upload to: `\\<FileSrv>\Logs$\Custom\Configuration`

Run (as Admin) in your task sequence:
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\custom_Install-PSC_Sconfig.ps1
```

### B) Manual (Local) – `manual_Install-PSC_Sconfig.ps1`
Installs from local `.\Data` without any server dependency.
Upload the zip file from 'Manual Installation' somewhere to your system, where you want to install it like to "D:\TEMP" and extract it.

Run (as Admin):
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\manual_Install-PSC_Sconfig.ps1
```
<img width="1024" height="510" alt="image" src="https://github.com/user-attachments/assets/daf5d0d7-18df-472f-8cad-1f88c7b710e7" />
<img width="1024" height="510" alt="image" src="https://github.com/user-attachments/assets/3763c753-ec24-46b0-9ad9-a700d0ef6ab8" />
<img width="1024" height="510" alt="image" src="https://github.com/user-attachments/assets/5eb1fd3a-a397-49fd-a7e1-0ebc1139b4c4" />
<img width="977" height="510" alt="image" src="https://github.com/user-attachments/assets/b25fcece-4664-4866-b211-59b8d9b617e5" />
<img width="977" height="510" alt="image" src="https://github.com/user-attachments/assets/11f053b5-8feb-4876-b81c-51eff140802a" />
<img width="977" height="510" alt="image" src="https://github.com/user-attachments/assets/944e8ad9-8549-4f98-a67c-950cf4550386" />
<img width="977" height="510" alt="image" src="https://github.com/user-attachments/assets/9f99a1c2-38e0-4b36-970e-5df8610ed2c1" />



---

## ⚙️ Configuration & Paths

- **Module**: `C:\Program Files\WindowsPowerShell\Modules\psc_sconfig\`  
- **Launcher**: `C:\Windows\System32\psc_sconfig.cmd`  
- **Main tool**: `C:\_it\psc_sconfig\psc_sconfig.ps1`  
- **Logs**: `C:\_it\psc_sconfig\Logfiles\psc_sconfig.log`  
- **Installer logs** (pattern): `C:\_it\Configure_psc_sconfig_<COMPUTER>_<YYYY-MM-DD_HH-mm-ss>.log`  
- **Desktop/Autostart** (optional): `launch_psc_sconfig.bat`

> Update the installer variables (`$FileSrv`, log share paths, etc.) for your environment.

---

## 🚀 Usage

### Start via Module (recommended)
```powershell
Import-Module psc_sconfig
psc_sconfig
```

### Start via Command
```powershell
psc_sconfig.cmd
```
or run the script directly:
```powershell
powershell.exe -ExecutionPolicy Bypass -File "C:\_it\psc_sconfig\psc_sconfig.ps1"
```

You’ll see the PSC SConfig main menu. Use the numbered options to configure networking, join a domain, manage updates, users, and more. If AD DS / Hyper‑V roles are present, the corresponding **role menus** appear automatically.

---

## 📝 Logging

- The main tool appends to:  
  `C:\_it\psc_sconfig\Logfiles\psc_sconfig.log`
- Installers write **timestamped** logs (and the automated installer can upload them to your central log share).

---

## 🔐 Security Notes

- Run only on trusted admin servers.
- Limit access to deployment and log shares.
- If you extend the tool to push configs remotely, apply least‑privilege and auditing.

---

## 🛠️ Troubleshooting

- **Role menus don’t appear** → Confirm role prerequisites:  
  - AD DS menu requires **AD‑Domain‑Services**, **DNS**, and **GPMC**  
  - Hyper‑V menu requires **Hyper‑V** and **Hyper‑V‑PowerShell**
- **WUA / update info missing** → Ensure Windows Update service and WSUS policy keys are readable.
- **Firewall/WAC/Arc status missing** → Verify cmdlets/registry paths and permissions.
- **SConfig still auto‑launches** → The tool attempts to disable SConfig autolaunch; verify with `Get-SConfig` / `Set-SConfig` based on your environment.

---

## ❓ FAQ

**Q: Can I use PSC SConfig on a full GUI server?**  
A: Yes. It’s optimized for Server Core but works on full installations as well.

**Q: Does it require PSWindowsUpdate?**  
A: No. It uses built‑in APIs/registry + WUA for update flows.

**Q: Where do I change the version shown in the banner?**  
A: Update `$VersionNumber` inside `psc_sconfig.ps1`.

---

## 🔗 References

- Windows Admin Center: https://learn.microsoft.com/windows-server/manage/windows-admin-center/  
- Windows Update (WUA) API: https://learn.microsoft.com/windows/win32/wua_sdk/  
- Hyper‑V docs: https://learn.microsoft.com/virtualization/hyper-v-on-windows/  
- AD DS docs: https://learn.microsoft.com/windows-server/identity/ad-ds/  
- BitLocker & security hardening (general): https://learn.microsoft.com/windows/security/

---

## 👤 Author

**Author:** Patrick Scherling  
**Contact:** @Patrick Scherling  

---

> ⚡ *“Automate. Standardize. Simplify.”*  
> Part of Patrick Scherling’s IT automation suite for modern Windows Server infrastructure management.
