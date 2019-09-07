if ($args.Count -ne 1) {
    Write-Host "Missing Parameter!" -ForegroundColor Red
    exit
}

$folderPath = $args[0]

Write-Host ("Directory Listing of "+ $folderPath)

# Process each item in the directory
foreach ($i in Get-ChildItem $folderPath) {
    if ($i.mode.substring(0,1) -eq "d") {
        Write-Host $i.name -ForegroundColor Yellow
    } else {
        Write-Host $i.name -ForegroundColor Green
    }
}