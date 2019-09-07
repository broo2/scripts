REM Backup Broo2 local directories to date stamped folder on NAS02 for long-term backup.
REM usage:robocopy_to_nas02.bat <password>

net use \\nas02 /d
net use \\nas02\ipc$ /user:brooskie %1

robocopy /MIR /ts /xn /xo /r:2 /w:1 /MT:32 c:\Users\Brooskie\Documents \\nas02\Backups\Broo\2019-07-01\Documents /tee /log:c:\Scripts\backup_nas02.log
robocopy /MIR /ts /xn /xo /r:2 /w:1 /MT:32 c:\Users\Brooskie\Pictures \\nas02\Backups\Broo\2019-07-01\Pictures /tee /log+:c:\Scripts\backup_nas02.log
robocopy /MIR /ts /xn /xo /r:2 /w:1 /MT:32 c:\Users\Brooskie\Videos \\nas02\Backups\Broo\2019-07-01\Videos /tee /log+:c:\Scripts\backup_nas02.log
robocopy /MIR /ts /xn /xo /r:2 /w:1 /MT:32 c:\Users\Brooskie\Music \\nas02\Backups\Broo\2019-07-01\Music /tee /log+:c:\Scripts\backup_nas02.log
robocopy /MIR /ts /xn /xo /xn /r:2 /w:1 /MT:32 c:\Users\Brooskie\Desktop \\nas02\Backups\Broo\2019-07-01\Desktop /tee /log+:c:\Scripts\backup_nas02.log


