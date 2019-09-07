REM Backup Broo2 local directories to date stamped folder on NAS05 for backup.
REM usage:robocopy_to_nas02.bat <password>

net use \\nas05 /d
net use \\nas05\ipc$ /user:brooskie %1

robocopy /MIR /ts /xn /xo  /r:2 /w:1 /MT:32 c:\Users\Brooskie\Documents \\nas05\users\Brooskie\Documents /tee /log:c:\Scripts\backup_nas04.log
robocopy /MIR /ts /xn /xo  /r:2 /w:1 /MT:32 c:\Users\Brooskie\Pictures \\nas05\users\Brooskie\Pictures /tee /log+:c:\Scripts\backup_nas04.log
robocopy /MIR /ts /xn /xo  /r:2 /w:1 /MT:32 c:\Users\Brooskie\Videos \\nas05\users\Brooskie\Videos /tee /log+:c:\Scripts\backup_nas04.log
robocopy /MIR /ts /xn /xo  /r:2 /w:1 /MT:32 c:\Users\Brooskie\Music \\nas05\users\Brooskie\Music /tee /log+:c:\Scripts\backup_nas04.log
robocopy /MIR /ts /xn /xo  /xn /r:2 /w:1 /MT:32 c:\Users\Brooskie\Desktop \\nas05\users\Brooskie\Desktop /tee /log+:c:\Scripts\backup_nas04.log


