Install-Module ps2exe
clear-host
ps2exe .\tools\src\make\make.ps1 .\make.exe | grep Reading
Clear-Host
Write-Host Compiled MAKE.EXE
