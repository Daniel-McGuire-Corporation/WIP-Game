param (
    [switch]$debug,
    [switch]$compile,
    [switch]$tools,
    [switch]$editor,
    [switch]$viewer,
    [switch]$game,
    [switch]$run,
    [switch]$all,
    [switch]$help,
    [switch]$h,
    [switch]$setupengine
)
Write-Host "Untiled-Game Make Script"
Write-Host "(c) 2024 Daniel McGuire"
Write-Host ""
$clPath = Get-Command cl.exe -ErrorAction SilentlyContinue

if ($null -eq $clPath) {
    Write-Host "cl.exe not found in PATH."
    Write-Host "Please start this script from the Visual Studio Developer PowerShell."
    exit
}

function Show-Help {
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  -run             Run the specified program(s)"
    Write-Host "  -compile         Compile specified targets"
    Write-Host ""
    Write-Host "Items to Compile or Run:"-ForegroundColor Cyan
    Write-Host "  -tools           Specify all tools"
    Write-Host "  -editor          Specify the level editor"
    Write-Host "  -viewer          Specify the level viewer"
    Write-Host "  -game            Specify the game"
    Write-Host "  -all             Specify everything"
    Write-Host ""
    Write-Host "Misc options:"-ForegroundColor Cyan
    Write-Host "  -debug           Specify debug"
    Write-Host "  -help, -h        Show this help message"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "$ ./main <OPTION(S)> <ITEM(S)> [misc]"
    Write-Host "Longest Command: (For an example)"
    Write-Host "$ ./main -compile -run -editor -viewer -game -debug"
    Write-Host "What you will probably want:"
    Write-Host "$ ./main -compile -run -game"
}

if ($setupengine) {
    # Define URLs and paths relative to the script location
    $aria2Url = "https://github.com/aria2/aria/releases/download/release-1.37.0/aria2-1.37.0-win-32bit-build1.zip"
    $aria2ZipPath = "./tmp/download/aria2.zip"
    $aria2ExtractPath = "./tmp/7zr/aria2"
    $aria2FinalPath = "./tools/aria2/bin"
    $aria2ExePath = "$aria2FinalPath/aria2c.exe"

    $sevenZipUrl = "https://7-zip.org/a/7zr.exe"
    $sevenZipPath = "./tmp/download/7zr.exe"
    $sevenZipFinalPath = "./tools/7z/bin/7zr.exe"

    $sfmlUrl = "https://www.sfml-dev.org/files/SFML-2.6.1-windows-vc17-32-bit.zip"
    $sfmlZipPath = "./tmp/download/sfml.zip"
    $sfmlExtractPath = "./tmp/7zr/sfml"
    $sfmlFinalPath = "./3rdpty/SFML-2.6.1"

    # Ensure necessary directories exist
    $downloadDir = "./tmp/download"
    if (-not (Test-Path $downloadDir)) {
        New-Item -ItemType Directory -Path $downloadDir -Force
    }

    $extractionDir = "./tmp/7zr"
    if (-not (Test-Path $extractionDir)) {
        New-Item -ItemType Directory -Path $extractionDir -Force
    }

    if (-not (Test-Path $aria2FinalPath)) {
        New-Item -ItemType Directory -Path $aria2FinalPath -Force
    }
    if (-not (Test-Path (Split-Path $sevenZipFinalPath))) {
        New-Item -ItemType Directory -Path (Split-Path $sevenZipFinalPath) -Force
    }
    if (-not (Test-Path (Split-Path $sfmlFinalPath))) {
        New-Item -ItemType Directory -Path (Split-Path $sfmlFinalPath) -Force
    }

    # Download aria2
    Invoke-WebRequest -Uri $aria2Url -OutFile $aria2ZipPath

    # Download 7zr
    Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipPath

    # Move 7zr to its final destination
    Move-Item $sevenZipPath $sevenZipFinalPath

    # Extract aria2 using 7zr
    Start-Process -FilePath $sevenZipFinalPath -ArgumentList "x", $aria2ZipPath, "-o$aria2ExtractPath" -Wait

    # Move extracted aria2 files to final destination
    Move-Item "$aria2ExtractPath/*" $aria2FinalPath -Force

    # Clean up temporary aria2 directory and zip
    Remove-Item $aria2ExtractPath -Recurse -Force
    Remove-Item $aria2ZipPath

    # Clone the repository if not already cloned
    if (-not (Test-Path "./WIP-Game")) {
        git clone "https://github.com/Daniel-McGuire-Corporation/WIP-Game" "./WIP-Game"
    }

    # Change the working directory to the cloned repository
    Set-Location "./WIP-Game"

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
    Write-Host "./make -compile -run -fullgame"
    exit
}


if ($help -or $h) {
    Show-Help
    exit
}

if ($compile) {
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
    mkdir bin\scripts\ -Force
	Write-Host "Made Directories." -ForegroundColor Green
	Write-Host "Copying assets" -ForegroundColor Yellow
	Copy-Item -Path levels\demo.level -Destination bin\data\levels\level1.ini
	Write-Host copied level1.ini
	Copy-Item -Path assets\data\txd\* -Destination bin\data\txd -Recurse
	Write-Host copied txd
	Copy-Item -Path levels\demo.level -Destination tools\bin\data\levels\level1.ini
	Write-Host copied level1.ini
	Copy-Item -Path assets\data\txd\* -Destination tools\bin\data\txd -Recurse
	Write-host copied txds
	Write-Host "Copied assets" -ForegroundColor Green
	Write-Host "Copying DLLs" -ForegroundColor Yellow
	Copy-Item -Path 3rdpty\bin\* -Destination bin\ -Recurse
	Copy-Item -Path 3rdpty\bin\* -Destination tools\bin\ -Recurse
	Write-Host "Copied DLLs" -ForegroundColor Green
    Clear-Host
    if ($editor -or $tools -or $all) {
        Write-Host "Compiling level editor..." -ForegroundColor Yellow
        pip install pyinstaller
        if ($debug) {
            pyinstaller --onefile --distpath .\tools\bin\ --workpath .\tmp .\tools\src\leveledit\leveleditor.py --icon .\tools\src\leveledit\edit.ico 
        } else {
            pyinstaller --onefile --windowed --distpath .\tools\bin\ --workpath .\tmp .\tools\src\leveledit\leveleditor.py --icon .\tools\src\leveledit\edit.ico
        }
    
        Copy-Item -Path tools\src\leveledit\edit.ico -Destination tools\bin\edit.ico
        Write-Host "Compiled Level Editor" -ForegroundColor Green
    }
    if ($viewer -or $tools -or $all) {
        Write-Host "Compiling level viewer..." -ForegroundColor Yellow
        rc /fo levelview_resources.res .\tools\src\levelview\ico.rc
        cl /EHsc /std:c++17 /MP /I"./3rdpty/include" .\tools\src\levelview\levelviewer.cpp .\tools\src\levelview\nfd_common.c .\tools\src\levelview\nfd_win.cpp levelview_resources.res /link /LIBPATH:"./3rdpty/lib" Ole32.lib Shell32.lib User32.lib sfml-graphics.lib Comdlg32.lib sfml-window.lib sfml-system.lib /MACHINE:X86 /SUBSYSTEM:WINDOWS /OUT:"./tools/bin/levelviewer.exe"
        Write-Host "Compiled Level Viewer" -ForegroundColor Green
    }
    if ($game -or $all) {
        Write-Host "Compiling game..." -ForegroundColor Yellow
        rc /fo game_resources.res .\game\ico.rc
        if ($debug) {
            cl /EHsc /std:c++17 /MP /I".\3rdpty\include" /DDEBUG_BUILD .\game\game\main.cpp .\game\vari.cpp .\game\debug\debug.cpp .\game\ai\enemie.cpp game_resources.res /link /LIBPATH:".\3rdpty\lib" User32.lib sfml-graphics.lib sfml-window.lib sfml-system.lib /MACHINE:X86 /OUT:".\bin\game-debug.exe"
        } else {
            cl /EHsc /std:c++17 /MP /I".\3rdpty\include" .\game\game\main.cpp .\game\vari.cpp .\game\ai\enemie.cpp game_resources.res /link /LIBPATH:".\3rdpty\lib" User32.lib sfml-graphics.lib sfml-window.lib sfml-system.lib /MACHINE:X86 /OUT:".\bin\game.exe"
        }
        Write-Host "Compiled game" -ForegroundColor Green
    }
}

if ($run) {
    Write-Host "Running the specified program(s)..." -ForegroundColor Yellow

    if ($editor -or $tools -or $all) {
        Write-Host "Running Level Editor..." -ForegroundColor Green
        Start-Process -FilePath tools\bin\leveleditor.exe -WorkingDirectory tools\bin
    }
    if ($viewer -or $tools -or $all) {
        Write-Host "Running Level Viewer..." -ForegroundColor Green
        Start-Process -FilePath tools\bin\levelviewer.exe -WorkingDirectory tools\bin
    }

    if ($game -or $all) {
        Write-Host "Running Game..." -ForegroundColor Green
        if ($debug) {
            Start-Process -FilePath bin\game-debug.exe -WorkingDirectory bin\
        } else {
            Start-Process -FilePath bin\game.exe -WorkingDirectory bin\
        }
    }
}
