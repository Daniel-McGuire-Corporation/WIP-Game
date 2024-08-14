# Set the include directory
$includeDir = "..\..\3rdpty\include"

# Set the source files and output executable names
$sourceFiles = @("leveledit.cpp", "nfd_win.cpp")
$outputFile = "LevelEditor.exe"

# Compile the source files using MSVC
cl /I $includeDir $sourceFiles /Fe:$outputFile /link /LIBPATH:"..\..\3rdpty\lib" sfml-graphics.lib sfml-window.lib sfml-system.lib

# Check if the compilation was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "Compilation successful. Executable created: $outputFile"
} else {
    Write-Host "Compilation failed."
}
