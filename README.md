# README - PSC SConfig

## Introduction
Since we are using Windows Server Core Editions more and more frequently, you may notice that the onboard 'sconfig' that is onboard from microsoft, is a big pain in the ass. To make our own lives easier, I have created the so called 'PSC SConfig Menu' aka. 'psc_sconfig'.

If you are deploying new Windows Servers 2025 in Core Edition, the 'psc_sconfig' will be installed automatically during the WDS deployment and will automatically startup with your login.

<img width="1024" height="773" alt="image" src="https://github.com/user-attachments/assets/d1f706a1-7633-43e8-a1e5-32bb98667056" />

 

As you can see in the screenshot above, you get all relevant information of the server that you initially need.

Further down you get the possibility to configure the server. You can make all standard configurations that you initially need to do, to get your server running as you want.

<img width="1020" height="541" alt="image" src="https://github.com/user-attachments/assets/ce1ac050-b842-4057-aa8a-ace9ffd2baf4" />

 

And whats even better, if you deploy e.g. a Domain-Controller or a Hyper-V via our Deployment System, you can do all initial configuration steps to get those Server Roles running too.

<img width="1024" height="768" alt="image" src="https://github.com/user-attachments/assets/4d4e8847-57f5-48c5-99d3-d58d1b9dcf78" />

<img width="1024" height="768" alt="image" src="https://github.com/user-attachments/assets/14f9b821-910e-4db6-a624-c64e76f067eb" />

 

 

How to run 'psc_sconfig'
From the normal CLI or PowerShell you can use the following commands to start the "psc_sconfig' menu.

Command Line Interface:



psc_sconfig


start psc_sconfig
 

PowerShell:



psc_sconfig


start psc_sconfig
 

## If you need to post-install 'psc_sconfig' by yourself
In case you have or want to install the 'psc_scofnig' on your system after your manual installation of a Windows Server Core Edition you can do that with the 'Manual Installation' package.

 

To get the 'psc_sconfig' on your system, just do these simple steps:

Upload this zip file somewhere to your system, where you want to install it like to "D:\TEMP" and extract it.

Extract the zip file

Review the extracted contents. There should be a directory called 'Data' and a PowerShell Script for installation.

Logon to your server and enter the cli

In the new cli window:

Review your systems execution policy by running the command 'Get-ExecutionPolicy'




Get-ExecutionPolicy
 

If the Policy is set to restricted, run this command 'Set-ExecutionPolicy Bypass'




Set-ExecutionPolicy Bypass
 

If you don't change the policy to bypass, you are not allowed to execute the install script.


Verify that the ExecutionPolicy is set to 'Bypass'




Get-ExecutionPolicy
Navigate into the directory where you have extracted the files (e.g. 'D:\Temp')




cd d:\temp
Run the install script by executing this command: '.\manual_Install-psc_Sconfig.ps1'




.\manual_Install-PSC_Sconfig.ps1
 

Let the installer do it's thing


After the installation has finished, you should see a message 'Configuration completed successfully.'

Press any key to exit the script

Run the command 'Set-ExecutionPolicy Default'




Set-ExecutionPolicy Default
Get-ExecutionPolicy
 

Review that the policy is not set to bypass anymore

Now you can run the psc_sconfig menu  start psc_sconfig winking face




start psc_sconfig
 

<img width="1024" height="510" alt="image" src="https://github.com/user-attachments/assets/47c7ae29-3b9d-4a39-a45f-87e6240f9c82" />

<img width="1024" height="510" alt="image" src="https://github.com/user-attachments/assets/424283a3-32dc-4d78-944d-5c381da7d066" />

<img width="1024" height="510" alt="image" src="https://github.com/user-attachments/assets/efc5a613-7bcf-44f4-8e10-e2fdf2de612d" />

<img width="977" height="510" alt="image" src="https://github.com/user-attachments/assets/e71d9698-493c-403b-9d34-69633d6559d5" />

<img width="977" height="510" alt="image" src="https://github.com/user-attachments/assets/cbd25e97-35aa-44e3-b8e2-828bd9208eed" />

<img width="977" height="510" alt="image" src="https://github.com/user-attachments/assets/7b0f8463-99fb-4933-86b2-7f674fca02b2" />

<img width="977" height="510" alt="image" src="https://github.com/user-attachments/assets/4aabd667-fee6-416c-bcf3-08ad0a80b816" />

<img width="1024" height="773" alt="image" src="https://github.com/user-attachments/assets/ccbf8099-8127-4e8a-bf70-f2a64343d2ee" />

 
