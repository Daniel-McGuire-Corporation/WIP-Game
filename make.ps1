param (
    [switch]$debug
)

# Clean up previous build artifacts
Write-Host "Cleaning bin Directories" -ForegroundColor Yellow
Remove-Item -Path bin\* -Recurse -Force
Remove-Item -Path bin -Recurse -Force
Remove-Item -Path tools\bin\* -Recurse -Force
Remove-Item -Path tools\bin -Recurse -Force
Write-Host "Cleaned bin Directories." -ForegroundColor Green

Write-Host "Making Directories" -ForegroundColor Yellow
mkdir bin\ -Force
mkdir tools\bin\ -Force
mkdir bin\data\txd\ -Force
mkdir tools\bin\data\txd\ -Force
mkdir bin\data\levels -Force
mkdir tools\bin\data\levels -Force
Clear
Write-Host "Made Directories." -ForegroundColor Green

# Copy assets
Write-Host "Copying assets" -ForegroundColor Yellow
Copy-Item -Path levels\demo.level -Destination bin\data\levels\level1.ini
Copy-Item -Path assets\data\txd\* -Destination bin\data\txd -Recurse
Copy-Item -Path levels\demo.level -Destination tools\bin\data\levels\level1.ini
Copy-Item -Path assets\data\txd\* -Destination tools\bin\data\txd -Recurse
Clear
Write-Host "Copied assets" -ForegroundColor Green

# Copy DLLs
Write-Host "Copying DLLs" -ForegroundColor Yellow
Copy-Item -Path 3rdpty\bin\* -Destination bin\ -Recurse
Copy-Item -Path 3rdpty\bin\* -Destination tools\bin\ -Recurse
Clear
Write-Host "Copied DLLs" -ForegroundColor Green
Clear
Write-Host "Starting Compilation" -ForegroundColor Yellow

# Compile resources
Write-Host "Compiling Game Resources" -ForegroundColor Yellow
rc /fo game_resources.res .\game\ico.rc
Write-Host "Compiled Game Resources" -ForegroundColor Green

Write-Host "Compiling Level Viewer Resources" -ForegroundColor Yellow
rc /fo levelview_resources.res .\tools\src\levelview\ico.rc
Write-Host "Compiled Level Viewer Resources" -ForegroundColor Green

# Compile game files
Write-Host "Compiling GAME" -ForegroundColor Yellow
if ($debug) {
    cl /EHsc /std:c++17 /MP /I".\3rdpty\include" /DDEBUG_BUILD .\game\game\main.cpp .\game\vari.cpp .\game\debug\debug.cpp game_resources.res /link /LIBPATH:".\3rdpty\lib" User32.lib sfml-graphics.lib sfml-window.lib sfml-system.lib /MACHINE:X86 /OUT:".\bin\game-debug.exe"
} else {
    cl /EHsc /std:c++17 /MP /I".\3rdpty\include" .\game\game\main.cpp .\game\vari.cpp game_resources.res /link /LIBPATH:".\3rdpty\lib" User32.lib sfml-graphics.lib sfml-window.lib sfml-system.lib /MACHINE:X86 /OUT:".\bin\game.exe"
}
Write-Host "Compiled GAME" -ForegroundColor Green

# Compile tools
Write-Host "Compiling Tools" -ForegroundColor Yellow
cl /EHsc /std:c++17 /MP /I"./3rdpty/include" .\tools\src\levelview\levelviewer.cpp .\tools\src\levelview\nfd_common.c .\tools\src\levelview\nfd_win.cpp levelview_resources.res /link /LIBPATH:"./3rdpty/lib" Ole32.lib Shell32.lib User32.lib sfml-graphics.lib Comdlg32.lib sfml-window.lib sfml-system.lib /MACHINE:X86 /SUBSYSTEM:WINDOWS /OUT:"./tools/bin/levelviewer.exe"
Write-Host "Compiled Level Viewer" -ForegroundColor Green

Write-Host "Compiling Tools" -ForegroundColor Yellow

Write-Host "Compiled Level Viewer" -ForegroundColor Green
pip install pyinstaller
pyinstaller --onefile --windowed --distpath .\tools\bin\ --workpath .\tmp .\tools\src\leveledit\leveleditor.py --icon .\tools\src\leveledit\edit.ico
Copy-Item -Path tools\src\leveledit\edit.ico -Destination tools\bin\edit.ico
Write-Host "Compilation Completed!" -ForegroundColor Green
