$dn = Get-ADDomain | select -ExpandProperty DistinguishedName
$icOU = "InactiveComputers"

#Create an OU=Inactive Computers if it does not exist:  
Write-Output "Creating 'Inactive Computers' OU in Azure AD.  Note: an 'Unable to create' message is normal if already present:" > c:\logs\Disable_and_Remove_Inactive_AD_Azure_Computers.log
try {    
    New-ADOrganizationalUnit -name $icOU -EA stop
    Write-Output "Created OU: $icOU" >> c:\logs\Disable_and_Remove_Inactive_AD_Azure_Computers.log  
    }
catch {
      Write-Output "Unable to create OU: $icOU. The specified OU already exists." >> c:\logs\Disable_and_Remove_Inactive_AD_Azure_Computers.log
      }

$Inactive_Computers_OU = "OU=InactiveComputers,$dn"
$Computers_OU = "CN=Computers,$dn"
#lastSetdate - 60 days +  14 days defautlt update for the LastLogonTimeStamp attribute
$lastSetdate = [DateTime]::Now - [TimeSpan]::Parse("74")
# PingComputers that are 90+ days inactive 
$PingComputers = Get-ADComputer -SearchBase $Computers_OU -Filter {LastLogonTimeStamp -le $lastSetdate} -Properties Name,LastLogonTimeStamp -ResultSetSize $null
Write-Output " " >> c:\logs\Disable_and_Remove_Inactive_AD_Azure_Computers.log
Write-Output "Disabling non-pingable Azure computers with no login in > 60 days:" >> c:\logs\Disable_and_Remove_Inactive_AD_Azure_Computers.log
ForEach($Computer In $PingComputers){
    $ComputerName = $Computer.name
	$PingStatus = Gwmi Win32_PingStatus -Filter "Address = '$ComputerName'" | Select-Object StatusCode
    # Write-Output $ComputerName >> c:\logs\Disable_and_Remove_Inactive_AD_Azure_Computers.log #uncomment to list all AD computers scanned to log
    # Sort only Windows computers names that start with *USER* and ignore any others    
	If ($ComputerName -Like "*USER*" ) {
        If ($PingStatus.StatusCode -ne 0){
		    Write-Output "$ComputerName is Offline." >> c:\logs\Disable_and_Remove_Inactive_AD_Azure_Computers.log
		    $comp = Get-ADComputer $ComputerName |select DistinguishedName,Description
          # Disable computers that are 60+ days inactive   
		    dsmod computer $comp.DistinguishedName -disabled yes
		    Write-Output "Moved the computer account $ComputerName to the OU $Inactive_Computers_OU" >> c:\logs\Disable_and_Remove_Inactive_AD_Azure_Computers.log
		    Move-ADObject -identity $comp.DistinguishedName -TargetPath $Inactive_Computers_OU
		  # Updated the Computer account Description with the Disabled date"
		    $new_description = "Disabled on: " + [DateTime]::Now
 		    Set-ADComputer $ComputerName -Description $new_description
	    }
    }
}
Write-Output " " >> c:\logs\Disable_and_Remove_Inactive_AD_Azure_Computers.log
Write-Output "Removing inactive Azure computers with no login in > 90 days:" >> c:\logs\Disable_and_Remove_Inactive_AD_Azure_Computers.log
# Remove computers that are 90+ days inactive
#  $RemoveDate = [DateTime]::Now - [TimeSpan]::Parse("104")
#  Get-ADComputer -SearchBase "$Inactive_Computers_OU" -Filter {lastLogonTimeStamp -le $RemoveDate -and Enabled -eq $False -and Name -Like "*USER*"}-Property Name,lastLogonTimeStamp,Enabled | Remove-ADComputer -Confirm:$False