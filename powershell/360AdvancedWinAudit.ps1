$Computer = $env:computername
Get-GPOReport -All -ReportType HTML -Path "C:\AUDIT-$Computer\$Computer Group Policy Reports.html"

Import-Module Activedirectory
Get-ADUser -Filter * -Properties DisplayName,memberof | % {
  New-Object PSObject -Property @{
	UserName = $_.DisplayName
	Groups = ($_.memberof | Get-ADGroup | Select -ExpandProperty Name) -join ","
	}
} | Select UserName,Groups | Export-Csv "C:\AUDIT-$Computer\$Computer Users Listing and Group Membership.csv" -NTI

# Gets time stamps for all User in the domain that have NOT logged in since after specified date

$domain = '@' + (Get-ADDomain).dnsroot 
$DaysInactive = 90 
$time = (Get-Date).Adddays(-($DaysInactive))
 
# Get all AD User with lastLogonTimestamp less than our time and set to enable
Get-ADUser -Filter {LastLogonTimeStamp -lt $time -and enabled -eq $true} -Properties LastLogonTimeStamp |
 
# Output Name and lastLogonTimestamp into CSV
select-object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | Export-Csv "C:\AUDIT-$Computer\$Computer Users Inactive for More than 90 Days.csv" -NTI

Get-ADForest | Select-Object -ExpandProperty RootDomain | Get-ADDomain | Select-Object -ExpandProperty PDCEmulator > "C:\AUDIT-$Computer\$Computer NTP PDC Emulator.txt"