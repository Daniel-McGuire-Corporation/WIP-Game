# Clean up previous build artifacts
write-host "Cleaning bin Directories" -ForegroundColor Yellow
Remove-Item -Path bin\* -Recurse -Force
Remove-Item -Path bin -Recurse -Force
Remove-Item -Path tools\bin\* -Recurse -Force
Remove-Item -Path tools\bin -Recurse -Force
write-host "Cleaned bin Directories." -ForegroundColor Green

write-host "Making Directories" -ForegroundColor Yellow
mkdir bin\ -Force
mkdir tools\bin\ -Force
mkdir bin\data\txd\ -Force
mkdir tools\bin\data\txd\ -Force
mkdir bin\data\levels -Force
mkdir tools\bin\data\levels -Force
clear
write-host "Made Directories." -ForegroundColor Green

# Copy assets
write-host "Coping assets" -ForegroundColor Yellow
Copy-Item -Path levels\demo.level -Destination bin\data\levels\level1.ini
Copy-Item -Path assets\data\txd\* -Destination bin\data\txd -Recurse
Copy-Item -Path levels\demo.level -Destination tools\bin\data\levels\level1.ini
Copy-Item -Path assets\data\txd\* -Destination tools\bin\data\txd -Recurse
clear
Write-Host "Copied assets" -ForegroundColor Green

# Copy DLLs
write-host "Coping DLLs" -ForegroundColor Yellow
Copy-Item -Path 3rdpty\bin\* -Destination bin\ -Recurse
Copy-Item -Path 3rdpty\bin\* -Destination tools\bin\ -Recurse
clear
Write-Host "Copied DLLs" -ForegroundColor Green
clear
Write-Host "Starting Compilation" -ForegroundColor Yellow

# Compile game files
Write-Host "Compiling GAME" -ForegroundColor Yellow
cl /EHsc /std:c++17 /MP /I".\3rdpty\include" .\game\src\main.cpp .\game\src\debug\debug.cpp /link /LIBPATH:".\3rdpty\lib" User32.lib sfml-graphics.lib sfml-window.lib sfml-system.lib /MACHINE:X86 /OUT:".\bin\game.exe"
Write-Host "Compiled GAME" -ForegroundColor Green

Write-Host "Compiling Tools" -ForegroundColor Yellow
# Compile level viewer
cl /EHsc /std:c++17 /MP /I"./3rdpty/include" .\tools\src\levelview\levelviewer.cpp .\tools\src\levelview\nfd_common.c .\tools\src\levelview\nfd_win.cpp /link /LIBPATH:"./3rdpty/lib" Ole32.lib Shell32.lib User32.lib sfml-graphics.lib Comdlg32.lib sfml-window.lib sfml-system.lib /MACHINE:X86 /SUBSYSTEM:WINDOWS /OUT:"./tools/bin/levelviewer.exe"
Write-Host "Compiled Level Viewer" -ForegroundColor Green

#Write-Host "Compiling Level Editor" -ForegroundColor Yellow
# Compile level editor
#cl /EHsc /std:c++17 /MP /I"./3rdpty/include" .\tools\src\leveledit\editor.cpp /link /LIBPATH:"./3rdpty/lib" Ole32.lib Shell32.lib User32.lib sfml-graphics.lib Comdlg32.lib sfml-window.lib sfml-system.lib /MACHINE:X86 /SUBSYSTEM:WINDOWS /OUT:"./tools/bin/leveledit.exe"

Write-Host "Compiled Tools" -ForegroundColor Green

Write-Host "Compilation Completed!" -ForegroundColor Green
