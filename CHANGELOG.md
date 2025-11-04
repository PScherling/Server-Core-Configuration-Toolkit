# Change Log
## Current Release
Version 0.1.5

## Release Notes

| Version| Release Date | Title | Description | Features | Bug Fixes | Known Issues |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------|
| **0.0.1** |  | Pre-Release | Initial first attempt | Showing System Information |  |  |
| **0.0.2** |  | Pre-Release | Finalized first functional version | Showing System Information |  |  |
| **0.0.3** |  | Pre-Release | Fixed Minor Bugs | First Configuration-Menu |  |  |
| **0.0.4** |  | Pre-Release | Refactor the network configuration |  |  | Windows Updates |
| **0.0.5** |  | Pre-Release | Adding Teaming configuration for NICs | NIC Teaming configuration |  | Windows Updates |
| **0.0.6** |  | Pre-Release | Expanding information for RAM and storage |  |  | Windows Updates |
| **0.0.7** |  | Pre-Release | Showing current logged on user, windows defender firewall status and azure arc status |  |  | Windows Updates |
| **0.0.8** |  | Pre-Release | First try to implement specific server role mgmt options (ADC) | ADC-Setup must be present! https://github.com/PScherling/ADC-Setup |  | Windows Updates |
| **0.0.9** |  | Pre-Release | First try to implement specific server role mgmt options (Hyper-V) | HyperV-Setup must be present! https://github.com/PScherling/Hyper-V-Setup |  | Windows Updates |
| **0.0.10** |  | Pre-Release | Adaption of function 'Get-NetworkAdapters' |  |  | Windows Updates |
| **0.0.11** |  | Pre-Release | Including 'Refresh' to menu | Refresh Function |  | Windows Updates |
| **0.0.12** |  | Pre-Release | Including logging and minor bug fixes |  |  | Windows Updates |
| **0.0.13** |  | Pre-Release | Including function for 'Renaming' Network Adapter | Renaming Network Adapter |  | Windows Updates |
| **0.0.14** |  | Pre-Release | Including 'RDMA' information fpr NICs | RDMA information for NICs |  | Windows Updates |
| **0.0.15** |  | Pre-Release | Including function for 'Deleting' Network Team Adapter | Delete network team adapter | Network-Configuration user input not working properly | Windows Updates |
| **0.0.16** |  | Pre-Release | Minor Bug Fixes in Network-Configuration |  |  | Windows Updates |
| **0.0.17** |  | Pre-Release | Storage size convertion GB<->TB for better readability |  |  | Windows Updates |
| **0.0.18** | 14/Mar/2025 | Pre-Release | Adding prefix NIC information |  |  | Windows Updates |
| **0.0.19** | 02/Apr/2025 | Pre-Release | Minor Bug Fixes. First attempt in reworking 'Windows Updates' to work with onboard windows update agent API from Microsoft |  |  |  |
| **0.0.20** | 02/Apr/2025 | Pre-Release | Showing Version Number in menu |  |  |  |
| **0.1.0** | 08/Apr/2025 | Initial Release | Finalized first stable version | System-Information; System-Configuration; Actions |  | UI bug during user and group creation; Windows-Update Error Handling |
| **0.1.1** | TBD | Hot Fix | Minor Bug Fixes in UI presentation during user and group creation |  | UI bug during user and group creation | Windows-Update Error Handling |
| **0.1.2** | 03/Jun/2025 | Hot Fix | Minor Bug Fix in function 'WindowsUpdates'; Error HAndling implemented |  | Function 'WindowsUpdates' Error Handling | Bug in function 'Install-WUpdates'; Refresh action should be removed; Bug in function 'WindowsUpdates' - Status in list of pending updates must be adapted; Pending reboot information should be displayed |
| **0.1.3** | 05/Jun/2025 | Hot Fix | Various Bug Fixes |  | Bug in function 'Install-WUpdates'; Bug in function 'WindowsUpdates' |  |
| **0.1.4** | 16/Sep/2025 | Minor Release |  | OS Build version including minor build number e.g.: '10.0.26100.**4061**'; Displaying information if 'WAC' is installed on domain-controller - https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/plan/installation-options |  |  |
| **0.1.5** | 27/Oct/2025 | Minor Release |  | Changing "LastBoot" format from dd.mmm.yyyy to dd/mmm/yyyy |  |  |
| **0.1.6** | TBD | Minor Release |  | Displaying Manucafurer and Model Information (Info is needed for HPE SPP Update functionality anyway) |  |  |


