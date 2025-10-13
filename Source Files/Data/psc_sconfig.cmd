echo off
cls

set PowerShell=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe
REM set SConfigV2Command=Invoke-Sconfig
REM Change this to the actual path of your script
set PSCsconfig=C:\_it\psc_sconfig\psc_sconfig.ps1

pushd %~dp0
if exist %PowerShell% (
    REM %PowerShell% -Command "%SConfigV2Command%"
	%PowerShell% -ExecutionPolicy Bypass -windowstyle maximized -File "%PSCsconfig%"
) else (
    REM PowerShell was not found. The new SConfig requires PowerShell
    REM To run SConfig, please install Windows PowerShell feature
)
popd
