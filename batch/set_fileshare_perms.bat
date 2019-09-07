
REM Setup cashet_file01_priv permissions
time /t  > .\perms_set.log
REM set full access for 'domain admins'
icacls "\\fileshare\cashnet_file01_priv" /grant:r "prd1\Domain Admins":(OI)(CI)F /T /inheritance:e  >> .\perms_set.log
REM set change access for 'cashnet_file01_pub_access' group
icacls "\\fileshare\cashnet_file01_priv" /grant:r prd1\cashnet_file01_priv_acesss:(OI)(CI)M /T /inheritance:e >> .\perms_set.log
REM remove 'everyone' access
icacls "\\fileshare\cashnet_file01_priv" /remove:g Everyone /T /inheritance:e  >> .\perms_set.log

REM Setup cashet_file01_prub permissions
REM set full access for 'domain admins'
icacls "\\fileshare\cashnet_file01_pub" /grant:r "prd1\Domain Admins":(OI)(CI)F /T /inheritance:e  >> .\perms_set.log
REM set change access for 'cashnet_file01_pub_access' group
icacls "\\fileshare\cashnet_file01_pub" /grant:r prd1\cashnet_file01_pub_access:(OI)(CI)M /T /inheritance:e  >> .\perms_set.log
REM remove 'everyone' access
icacls "\\fileshare\cashnet_file01_pub" /remove:g Everyone /T /inheritance:e  >> .\perms_set.log

REM Setup cashnet_file01_pub\banking_ach permissions
icacls "\\fileshare\cashnet_file01_pub\banking_ach" /grant:r prd1\banking_ach_file_access:(OI)(CI)M /T /inheritance:e  >> .\perms_set.log
icacls "\\fileshare\cashnet_file01_pub\banking_ach" /grant:r prd1\irs_file_access:(OI)(CI)M /T /inheritance:e  >> .\perms_set.log
icacls "\\fileshare\cashnet_file01_pub" /remove:g prd1\cashnet_file01_pub_access:(OI)(CI)M /T /inheritance:e  >> .\perms_set.log

time /t  >> .\perms_set.log

