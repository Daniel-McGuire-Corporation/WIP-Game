# Clean up previous build artifacts
Remove-Item -Path bin\* -Recurse -Force
Remove-Item -Path bin -Recurse -Force
mkdir bin\ 
Write-Host "Cleaned Bin Directory!"
$destinationPathTextures = "bin\data\txd\"
New-Item -Path $destinationPathTextures -ItemType Directory -Force


# Copy assets
Copy-Item -Path levels\demo.level -Destination bin\level.ini
Copy-Item -Path assets\data\txd\* -Destination $destinationPathTextures -Recurse
Write-Host "Copied assets"

# Copy DLLs
Copy-Item -Path 3rdpty\bin\* -Destination bin\ -Recurse
Write-Host "Copied DLLs"

# Compile game files
Write-Host Compiling GAME
cl /EHsc /MP /I".\3rdpty\include" .\game\src\main.cpp .\game\src\debug.cpp /link /LIBPATH:".\3rdpty\lib" User32.lib sfml-graphics.lib sfml-window.lib sfml-system.lib /MACHINE:X86 /OUT:".\bin\game.exe"

Write-Host Compiling Level Viewer
# Compile level viewer
cl /EHsc /MP /I"./3rdpty/include" .\tools\src\levelviewer.cpp /link /LIBPATH:"./3rdpty/lib" User32.lib sfml-graphics.lib sfml-window.lib sfml-system.lib /MACHINE:X86 /SUBSYSTEM:WINDOWS /OUT:"./bin/levelviewer.exe"

Write-Host "Done"
