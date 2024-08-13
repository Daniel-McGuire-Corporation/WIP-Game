# Define paths
$sourcePath = ".\Speed.asi.cc"
$outputPath = ".\bin"
$outputName = "Speed.dll"

# Ensure output directory exists
if (-not (Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath | Out-Null
}

# Compile the source file into a DLL
cl.exe /LD /EHsc /I"..\..\..\3rdpty\include" $sourcePath /link /OUT:$outputPath\$outputName User32.lib

# Check for errors
if ($LASTEXITCODE -ne 0) {
    Write-Host "Compilation failed with exit code $LASTEXITCODE" -ForegroundColor Red
} else {
    mv .\bin\speed.dll .\bin\speed.asi
    Write-Host "Compilation succeeded. Output ASI: $outputPath\speed.asi" -ForegroundColor Green
}
