# Variables for downloads and paths
$aria2Url = "https://github.com/aria2/aria/releases/download/release-1.37.0/aria2-1.37.0-win-32bit-build1.zip"
$aria2ZipPath = "./tmp/download/aria2.zip"
$aria2ExtractPath = "./tmp/7zr/aria2"
$aria2FinalPath = "./tools/aria2/bin"
$aria2ExePath = "$aria2FinalPath/aria2c.exe"

$sevenZipUrl = "https://7-zip.org/a/7zr.exe"
$sevenZipPath = "./tmp/download/7zr.exe"
$sevenZipFinalPath = "./tools/7z/bin/7zr.exe"

$gitRepoUrl = "https://github.com/Daniel-McGuire-Corporation/WIP-Game"
$cloneDir = "./WIP-Game"

$sfmlUrl = "https://www.sfml-dev.org/files/SFML-2.6.1-windows-vc17-32-bit.zip"
$sfmlZipPath = "./tmp/download/sfml.zip"
$sfmlExtractPath = "./tmp/7zr/sfml"
$sfmlFinalPath = "./3rdpty/SFML-2.6.1"

# Ensure download directory exists
$downloadDir = "./tmp/download"
if (-not (Test-Path $downloadDir)) {
    New-Item -ItemType Directory -Path $downloadDir -Force
}

# Download aria2
Invoke-WebRequest -Uri $aria2Url -OutFile $aria2ZipPath

# Download 7zr
Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipPath

# Ensure directories for final tools locations exist
if (-not (Test-Path $aria2FinalPath)) {
    New-Item -ItemType Directory -Path $aria2FinalPath -Force
}
if (-not (Test-Path (Split-Path $sevenZipFinalPath))) {
    New-Item -ItemType Directory -Path (Split-Path $sevenZipFinalPath) -Force
}

# Move 7zr to its final destination
Move-Item $sevenZipPath $sevenZipFinalPath

# Extract aria2 using 7zr
Start-Process -FilePath $sevenZipFinalPath -ArgumentList "x", $aria2ZipPath, "-o$aria2ExtractPath" -Wait

# Move extracted aria2 files to final destination
Move-Item "$aria2ExtractPath/*" $aria2FinalPath -Force

# Clean up temporary aria2 directory and zip
Remove-Item $aria2ExtractPath -Recurse -Force
Remove-Item $aria2ZipPath

# Clone the repository
git clone $gitRepoUrl $cloneDir

# Change the working directory to the cloned repository
Set-Location $cloneDir

# Move tools from ../tools/ to ./tools/ in the cloned repository
if (-not (Test-Path "./tools")) {
    New-Item -ItemType Directory -Path "./tools" -Force
}
Move-Item -Path "../tools/*" -Destination "./tools/" -Force

# Download SFML using aria2
Start-Process -FilePath $aria2ExePath -ArgumentList $sfmlUrl, "-d ./tmp/download -o sfml.zip" -Wait

# Extract SFML to a temporary directory using 7zr
Start-Process -FilePath $sevenZipFinalPath -ArgumentList "x", $sfmlZipPath, "-o$sfmlExtractPath" -Wait

# Clean up the SFML zip file
Remove-Item $sfmlZipPath

# Move extracted SFML directory to the final location
Move-Item "$sfmlExtractPath/SFML-2.6.1" $sfmlFinalPath -Force

# Clean up temporary SFML extraction directory
Remove-Item $sfmlExtractPath -Recurse -Force

# Prompt the user to compile and run the full game
Write-Host "Setup complete! Now you can compile and run the full game by executing the following command:"
Write-Host "./make -compile -run -game"
