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
    [switch]$setupengine,
	[switch]$clean
)

cmd /c taskkill /im game.exe /F 
cmd /c taskkill /im game-debug.exe /f 
cmd /c taskkill /im leveleditor.exe /f 
cmd /c taskkill /im levelviewer.exe /f 
if ($clean) {
	Write-Host "Cleaning Directories" -ForegroundColor Yellow
	Remove-Item -Path bin\* -Recurse -Force
	Remove-Item -Path bin -Recurse -Force
	Remove-Item -Path tools\bin\* -Recurse -Force
	Remove-Item -Path tools\bin -Recurse -Force
	Remove-Item -Path tmp\* -Recurse -Force
	Remove-Item -Path tmp -Recurse -Force
	Remove-Item -Path *.obj -Recurse -Force
	Remove-Item -Path *.res -Recurse -Force
	Write-Host "Cleaned Directories." -ForegroundColor Green
	Clear-Host
	Write-Host "Untited-Game Make Script"
	Write-Host "(c) 2024 Daniel McGuire"
	Write-Host ""
}
clear-host
Write-Host "Untited-Game Make Script"
Write-Host "(c) 2024 Daniel McGuire"
Write-Host ""
$clPath = Get-Command cl.exe -ErrorAction SilentlyContinue

if ($null -eq $clPath) {
    Write-Host "cl.exe not found in PATH."
    Write-Host "Please start this script from the Visual Studio Developer PowerShell."
    exit
}

function Download-FileWithProgress {
    param (
        [string]$url,
        [string]$destinationPath
    )

    $request = [System.Net.HttpWebRequest]::Create($url)
    $request.Method = "HEAD"
    
    try {
        $response = $request.GetResponse()
        $contentLength = $response.Headers["Content-Length"]
        $response.Close()
    } catch {
        Write-Error "Failed to get file size from $url. $_"
        return
    }

    if ([string]::IsNullOrEmpty($contentLength)) {
		Invoke-WebRequest -Uri $url -OutFile $destinationPath
    }

    $request = [System.Net.HttpWebRequest]::Create($url)
    $request.Method = "GET"
    
    try {
        $response = $request.GetResponse()
        $responseStream = $response.GetResponseStream()
        $fileStream = [System.IO.File]::Create($destinationPath)

        $buffer = New-Object byte[] 8192
        $totalBytesRead = 0
        $bytesRead = 0

        $retryCount = 0
		$maxRetries = 3

while (($bytesRead = $responseStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
    $fileStream.Write($buffer, 0, $bytesRead)
    $totalBytesRead += $bytesRead

    if ($contentLength -ne $null -and $contentLength -gt 0) {
        $progress = [math]::Round(($totalBytesRead / [int64]$contentLength) * 100, 2)
        
        try {
            Write-Progress -Activity "Downloading Package" -PercentComplete $progress -Status "Downloading..." -CurrentOperation "Progress: $progress%"
            $retryCount = 0  # Reset retry count on success
        } catch {
            Write-Output "Write-Progress failed. Attempting retry $($retryCount + 1) of $maxRetries"
            $retryCount++
            if ($retryCount -ge $maxRetries) {
                Write-Error "Write-Progress failed after $maxRetries attempts. Exiting..."
                break
            }
        }
    }
}


        $fileStream.Close()
        $responseStream.Close()
        Write-Output "Download completed."
    } catch {
        Write-Error "Failed to download file from $url. $_"
    }
}
# Variable to handle cancellation
$global:cancelDownload = $false

# Register interrupt handling
Register-EngineEvent PowerShell.Exiting -Action {
    $global:cancelDownload = $true
} | Out-Null




if ($help -or $h) {
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  -run             Run the specified program(s)"
    Write-Host "  -compile         Compile specified targets"
    Write-Host "  -setupengine     Download and setup the SFML engine"
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
	Write-Host "  -clean           Clean all exes, objs, etc"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "$ .\main <OPTION(S)> <ITEM(S)> [misc]"
    Write-Host "Longest Command: (For an example)"
    Write-Host "$ .\main -compile -run -editor -viewer -game -debug"
    Write-Host "What you will probably want:"
    Write-Host "$ .\main -compile -run -game"
}

if ($setupengine) {
	clear-host
    # Define paths for SFML
    $sfmlZipUrl = "https://www.sfml-dev.org/files/SFML-2.6.1-windows-vc17-32-bit.zip"
    $sfmlTempZipPath = "$env:TEMP\SFML-2.6.1-windows-vc17-32-bit.zip"
    $sfmlExtractedPath = "$env:TEMP\SFML-2.6.1"
    $sfmlDestinationPath = ".\3rdpty"

    # Download SFML zip file
    Write-Output "Downloading SFML..."
    Download-FileWithProgress -url $sfmlZipUrl -destinationPath $sfmlTempZipPath

    # Extract the zip file
    Write-Output "Extracting SFML..."
    Expand-Archive -Path $sfmlTempZipPath -DestinationPath $sfmlExtractedPath -Force

    # Ensure the destination directory exists
    if (-not (Test-Path $sfmlDestinationPath)) {
        Write-Output "Creating SFML destination directory..."
        New-Item -ItemType Directory -Path $sfmlDestinationPath | Out-Null
    }

    # Copy the contents to the destination directory
    Write-Output "Copying SFML files to destination..."
    Copy-Item -Path "$sfmlExtractedPath\SFML-2.6.1\*" -Destination $sfmlDestinationPath -Recurse -Force

    # Cleanup SFML
    Write-Output "Cleaning up SFML..."
    Remove-Item -Path $sfmlTempZipPath -Force
    Remove-Item -Path $sfmlExtractedPath -Recurse -Force
	clear-host
    # Define paths for nativefiledialog
    $nativeFileDialogZipUrl = "https://github.com/mlabbe/nativefiledialog/archive/refs/heads/master.zip"
    $nativeFileDialogTempZipPath = "$env:TEMP\nativefiledialog-master.zip"
    $nativeFileDialogExtractedPath = "$env:TEMP\nativefiledialog-master"
    $nativeFileDialogDestinationPath = ".\3rdpty"

    # Download nativefiledialog zip file
    Write-Output "Downloading nativefiledialog..."
    Download-FileWithProgress -url $nativeFileDialogZipUrl -destinationPath $nativeFileDialogTempZipPath

    # Extract the zip file
    Write-Output "Extracting nativefiledialog..."
    Expand-Archive -Path $nativeFileDialogTempZipPath -DestinationPath $nativeFileDialogExtractedPath -Force

    # Copy the contents of the src directory to the destination directory
    Write-Output "Copying nativefiledialog src files to destination..."
    Copy-Item -Path "$nativeFileDialogExtractedPath\nativefiledialog-master\src\*" -Destination $nativeFileDialogDestinationPath -Recurse -Force

    # Cleanup nativefiledialog
    Write-Output "Cleaning up nativefiledialog..."
    Remove-Item -Path $nativeFileDialogTempZipPath -Force
    Remove-Item -Path $nativeFileDialogExtractedPath -Recurse -Force

    Write-Output "Engine setup completed."
    exit
}


if ($compile) {
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
	Copy-Item -Path tools\src\leveledit\edit.ico -Destination tools\bin\edit.ico
	Write-host copied edit.ico
	Copy-Item -Path tools\src\leveledit\edit.icns -Destination tools\bin\edit.icns
	Write-Host copied edit.icns
	Copy-Item -Path tools\src\leveledit\edit.png -Destination tools\bin\edit.png
	Write-Host copied edit.png
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
