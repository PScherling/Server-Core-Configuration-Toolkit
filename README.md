# README - PowerShell Advanced SConfig
Introduction
Since we are using Windows Server Core Editions more and more frequently, you may notice that the onboard 'sconfig' that is onboard from microsoft, is a big pain in the ass. To make our own lives easier, I have created the so called 'PSC SConfig Menu' aka. 'psc_sconfig'.

If you are deploying new Windows Servers 2025 in Core Edition, the 'psc_sconfig' will be installed automatically during the WDS deployment and will automatically startup with your login.
<img width="1024" height="773" alt="image" src="https://github.com/user-attachments/assets/4651a731-9a91-4179-880c-7ccc74a2fa4c" />
As you can see in the screenshot above, you get all relevant information of the server that you initially need.

Further down you get the possibility to configure the server. You can make all standard configurations that you initially need to do, to get your server running as you want.
<img width="1020" height="541" alt="image" src="https://github.com/user-attachments/assets/f3671cd7-24c1-462d-bc67-7e58547e9bd9" />

And whats even better, if you deploy e.g. a Domain-Controller or a Hyper-V via our Deployment System, you can do all initial configuration steps to get those Server Roles running too.
<img width="1024" height="768" alt="image" src="https://github.com/user-attachments/assets/500ffcdb-0243-4623-b111-245196e79c5d" />
<img width="1024" height="768" alt="image" src="https://github.com/user-attachments/assets/c069d5b9-52b3-4ab3-9467-fcb6e9094d2e" />

How to run 'psc_sconfig'
From the normal CLI or PowerShell you can use the following commands to start the "psc_sconfig' menu.

Command Line Interface:
1. psc_sconfig
2. start psc_sconfig

PowerShell:
1. psc_sconfig
2. start psc_sconfig

If you need to post-install 'psc_sconfig' by yourself
In case you have or want to install the 'psc_scofnig' on your system after your manual installation of a Windows Server Core Edition you can do that with the manual installation package.

To get the 'psc_sconfig' on your system, just do these simple steps:
1) Upload this zip file somewhere to your system, where you want to install it like to "D:\TEMP" and extract it.
2) Extract the zip file
3) Review the extracted contents. There should be a directory called 'Data' and a PowerShell Script for installation.
4) Logon to your server and enter the cli
5) In the new cli window:
   a) Review your systems execution policy by running the command 'Get-ExecutionPolicy'
     Get-ExecutionPolicy
     i) If the Policy is set to restricted, run this command 'Set-ExecutionPolicy Bypass'
       Set-ExecutionPolicy Bypass
       If you don't change the policy to bypass, you are not allowed to execute the install script.
   b) Verify that the ExecutionPolicy is set to 'Bypass'
     Get-ExecutionPolicy
   c) Navigate into the directory where you have extracted the files (e.g. 'D:\Temp')
     cd d:\temp
   d) Run the install script by executing this command: '.\manual_Install-psc_Sconfig.ps1'
     .\manual_Install-PSC_Sconfig.ps1
     Let the installer do it's thing
   e) After the installation has finished, you should see a message 'Configuration completed successfully.'
   f) Press any key to exit the script
   g) Run the command 'Set-ExecutionPolicy Default'
     Set-ExecutionPolicy Default
     Get-ExecutionPolicy
     Review that the policy is not set to bypass anymore
7) Now you can run the psc_sconfig menu  start psc_sconfig
   start psc_sconfig
