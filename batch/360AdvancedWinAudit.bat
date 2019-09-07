@echo off
echo Please wait while this script runs (can take several minutes)...
echo.
echo Output files will be saved in the C:\AUDIT-%computername% folder.
echo.
echo Please ZIP the folder contents after script completes and upload to ShareFile.

mkdir C:\AUDIT-%computername% 2>nul

>"C:\AUDIT-%computername%\%computername% Users Listing and Privileged Group Membership.txt" (

echo #### TIMESTAMP ####
echo.

date /T
time /T

echo.
echo #### PRIVILEGED AND REMOTE ACCESS USERS ####
echo.

net localgroup "Administrators" 2>nul
net localgroup "Remote Desktop Users" 2>nul
net group "Enterprise Admins" 2>nul
net group "Domain Admins" 2>nul
net group "Domain Users" 2>nul

for /f "tokens=2*" %%a in ('reg query hklm\SOFTWARE\Microsoft\MSDTC\Security /v DomainControllerState') do set "var=%%b"

if "%var%"=="0x0" (

echo.
echo #### ENTERPRISE ADMINS ####
echo.
dsquery group -name "Enterprise Admins" | dsget group -members -expand 2>nul

echo.
echo #### DOMAIN ADMINS ####
echo.
dsquery group -name "Domain Admins" | dsget group -members -expand 2>nul

)

wmic useraccount get Name, FullName, Description, Domain, Disabled, LocalAccount, PasswordExpires, PasswordRequired /format:htable > "C:\AUDIT-%computername%\%computername% Users Listing Properties and Disabled Status.html" 2>nul

)

>"C:\AUDIT-%computername%\%computername% Services Running and Listening Ports and DEP.txt" (

echo #### TIMESTAMP ####
echo.

date /T
time /T

echo.
echo #### SERVICES RUNNING ####
echo.

REM net start
sc queryex type= service | find "NAME"
echo.
netstat -ano | find "0.0.0.0"
tasklist

echo.
echo #### SERVICES DISABLED ####
echo.

sc query type= service state= inactive | find "NAME"

echo.
echo #### DATA EXECUTION PREVENTION ####
echo.
wmic OS Get DataExecutionPrevention_SupportPolicy 2>nul

wmic /output:'C:\AUDIT-%computername%\%computername% Product Installations and Versions.html' product get name,version /format:htable 2>nul

)

>"C:\AUDIT-%computername%\%computername% Patch Update Settings.txt" (

echo #### TIMESTAMP ####
echo.

date /T
time /T

echo.
echo #### WINDOWS UPDATE SETTINGS ####
echo.
echo NoAutoUpdate
echo 0 - Enable Automatic Updates Default
echo 1 - Disable Automatic Updates
echo.
echo AUOptions
echo 2 - Notify for download and notify for install
echo 3 - Auto download and notify for install
echo 4 - Auto download and schedule the install
echo.
echo ScheduledInstallDay
echo 0 Install every day
echo 1 to 7 - Install on specific day of the week from Sunday 1 to Saturday 7
echo.
echo ScheduledInstallTime
echo 0 to 23 - Install time of day in 24-hour format
echo.

reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" 2>nul
wmic qfe list full /format:htable > "C:\AUDIT-%computername%\%computername% Patches Installed.html"

)

>"C:\AUDIT-%computername%\%computername% Password and Account Lockout Policies.txt" (

echo #### TIMESTAMP ####
echo.

date /T
time /T

echo.
echo #### PASSWORD AND ACCOUNT LOCKOUT POLICY ####
echo.

net accounts
net accounts /domain 2>nul

)

>"C:\AUDIT-%computername%\%computername% Screen Saver and Remote Management Timeouts.txt" (

echo #### TIMESTAMP ####
echo.

date /T
time /T

echo.
echo #### SCREEN SAVER AND RDP INFO ####
echo.

echo HKCU\Control Panel\Desktop
reg query "HKCU\Control Panel\Desktop" | find /i "Screen" 2>nul
echo.
echo HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop 2>nul
reg query "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop" 2>nul
echo.
reg query "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "MinEncryptionLevel" 2>nul
echo.
reg query "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "SecurityLayer" 2>nul
echo.
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" 2>nul
echo.
powercfg /q 2>nul
echo.
)

>"C:\AUDIT-%computername%\%computername% Audit Policy and Log Samples.txt" (

echo #### TIMESTAMP ####
echo.

date /T
time /T

echo.
echo #### AUDITING POLICY ####
echo #### Security State Change includes System Time Change events ####
echo.

auditpol /get /category:*
echo.

echo.
echo #### NEWEST 10 SECURITY LOGS ####
echo.

wevtutil qe Security /c:10 /f:text

echo.
echo #### OLDEST 10 SECURITY LOGS ####
echo.

wevtutil qe Security /rd:false /c:10 /f:text

echo.
echo #### NEWEST 10 SYSTEM LOGS ####
echo.

wevtutil qe System /c:10 /f:text

echo.
echo #### OLDEST 10 SYSTEM LOGS ####
echo.

wevtutil qe System /rd:false /c:10 /f:text

)

>"C:\AUDIT-%computername%\%computername% NTP Configuration.txt" (

echo #### TIMESTAMP ####
echo.

date /T
time /T

echo.
echo #### NTP INFO ####
echo.

w32tm /query /status
echo.
reg query "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" 2>nul
echo.
echo HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NTP Client
reg query "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" | find /i "Enabled" 2>nul
echo.
echo HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NTP Server
reg query "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer" | find /i "Enabled" 2>nul

)

>"C:\AUDIT-%computername%\%computername% Host Information and Shares.txt" (

echo #### TIMESTAMP ####
echo.

date /T
time /T

echo.
echo #### IP INFO ####
echo.

set | find /i "COMPUTERNAME="
set | find /i "USERDNSDOMAIN="
set | find /i "USERDOMAIN="
echo.
ipconfig | findstr "IPv4 Mask Gateway"

echo.
echo #### WINDOWS OPERATING SYSTEM TYPE ####
echo.
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" | find "ProductName" 2>nul

echo.
echo #### LOCALLY SHARED FOLDERS ####
echo.

net share 2>nul

echo.
echo #### REMOTELY CONNECTED SHARES ####
echo.

net use 2>nul

)

>"C:\AUDIT-%computername%\%computername% Windows Firewall Settings.txt" (

echo #### TIMESTAMP ####
echo.

date /T
time /T

echo.
echo #### WINDOWS FIREWALL INFO ####
echo.

netsh advfirewall show allprofiles 2>nul

)

>"C:\AUDIT-%computername%\%computername% Legal Notice Banner Settings.txt" (

echo #### TIMESTAMP ####
echo.

date /T
time /T

echo.
echo #### LEGAL NOTICE BANNER ####
echo.

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | find /i "legalnotice" 2>nul

)

>"C:\AUDIT-%computername%\%computername% Hard Drive Encryption.txt" (

echo #### TIMESTAMP ####
echo.

date /T
time /T

echo.
echo #### Bit Locker Status ####
echo.

manage-bde -status 2>nul

)
>"C:\AUDIT-%computername%\%computername% Anti-Virus Configuration and Settings.txt" (

echo #### TIMESTAMP ####
echo.

date /T
time /T

echo.
echo #### ANTI-VIRUS INFORMATION ####
echo.

echo #### SYMANTEC ENDPOINT PROTECTION ####
echo.
echo HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Symantec\Symantec Endpoint Protection\AV\Storages\SymProtect\RealTimeScan
echo HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Symantec\Symantec Endpoint Protection\{E1A40A89-2B89-44FA-9E96-395B7D7F03AC}\public-opstate
echo.

reg query "HKLM\SOFTWARE\Symantec" /s 2>nul
reg query "HKLM\SOFTWARE\Wow6432Node\Symantec" /s 2>nul
echo.

echo #### MICROSOFT SECURITY ESSENTIALS ####
reg query "HKLM\SOFTWARE\Microsoft\Microsoft Antimalware" /s 2>nul
echo.

echo  #### SOPHOS ####
reg query "HKLM\SOFTWARE\Sophos" /s 2>nul
reg query "HKLM\SOFTWARE\Wow6432Node\Sophos" /s 2>nul
echo.

echo  #### TREND MICRO ####
reg query "HKLM\SOFTWARE\TrendMicro" /s 2>nul
reg query "HKLM\SOFTWARE\Wow6432Node\TrendMicro" /s 2>nul
echo.

REM #### GFI VIPRE ####
REM xcopy "%ProgramData%\GFI Software\AntiMalware\*.xml" "C:\AUDIT-%computername%\%computername% Anti-Virus Files - GFI VIPRE\" /i 2>nul

REM #### BITDEFENDER ####
REM xcopy "%ProgramFiles%\Bitdefender\Endpoint Security\settings\*" "C:\AUDIT-%computername%\%computername% Anti-Virus Files - BitDefender\" /s /i 2>nul
)

@ECHO OFF
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%~dpn0.ps1'"
## PowerShell.exe -NoProfile -Command "& {Start-Process Powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}"
## START GetGPOs.bat