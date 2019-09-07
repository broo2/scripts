REM replicates NAS05 CIF contents to NAS02 for backup.
REM usage: nas04_to_nas04.bat <password> 

REM unmap & remap permissions to NAS02 and NAS05
net use \\nas02 /d
net use \\nas02\ipc$ /user:brooskie %1
net use \\nas05 /d
net use \\nas05\ipc$ /user:brooskie %1

robocopy /MIR /ts /xo /xn /r:2 /w:1 /MT:32 \\NAS05\Video \\NAS02\Video /xd ".\@Recycle","@Recently-Snapshot" /tee /log:c:\Scripts\nas_mirror.log 
robocopy /MIR /ts /xo /xn /r:2 /w:1 /MT:32 \\NAS05\Users \\nas02\Users /xd ".\@Recycle","@Recently-Snapshot" /tee /log+:c:\Scripts\nas_mirror.log
robocopy /MIR /ts /xo /xn /r:2 /w:1 /MT:32 \\NAS05\Storage \\nas02\Storage /xd ".\@Recycle","@Recently-Snapshot" /tee /log+:c:\Scripts\nas_mirror.log
robocopy /MIR /ts /xo /xn /r:2 /w:1 /MT:32 \\NAS05\Media \\nas02\Media /xd ".\@Recycle","@Recently-Snapshot" /tee /log+:c:\Scripts\nas_mirror.log