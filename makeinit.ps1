Install-Module ps2exe
clear-host
ps2exe .\tools\src\make\make.ps1 .\tools\bin\make.exe | grep --------
Clear-Host
Write-Host Make has been initialized.
Write-Host ""
Write-Host "If you haven't yet, run"
Write-Host "make -setupengine"
