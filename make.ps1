# Clean up old files
del .\bin\*.obj -ErrorAction SilentlyContinue
del .\bin\*.exe -ErrorAction SilentlyContinue

Write-Host "Compiling"

# Compile game files
cl /EHsc /MP /I".\3rdpty\include" .\game\src\main.cpp .\game\src\debug.cpp /link /LIBPATH:".\3rdpty\lib" User32.lib sfml-graphics.lib sfml-window.lib sfml-system.lib /MACHINE:X86 /OUT:".\bin\game.exe"

# Compile level viewer
cl /EHsc /MP /I"./3rdpty/include" .\tools\src\levelviewer.cpp /link /LIBPATH:"./3rdpty/lib" User32.lib sfml-graphics.lib sfml-window.lib sfml-system.lib /MACHINE:X86 /SUBSYSTEM:WINDOWS /OUT:"./bin/levelviewer.exe"

Write-Host "Done"
