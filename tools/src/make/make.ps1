param (
    [switch]$debug,
    [switch]$compile,
    [switch]$tools,
    [switch]$tweaker,
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
function Clear-Directories {
    Write-Host "Cleaning Directories" -ForegroundColor Yellow
    Remove-Item -Path bin\* -Recurse -Force
    Remove-Item -Path tools\bin\*.dll -Recurse -Force
    Remove-Item -Path tools\bin\data\* -Recurse -Force
    Remove-Item -Path tools\bin\data -Recurse -Force
    Remove-Item -Path tools\bin\level*.exe -Recurse -Force
    Remove-Item -Path tools\bin\edit.ico -Recurse -Force
    Remove-Item -Path bin -Recurse -Force
    Remove-Item -Path tmp\* -Recurse -Force
    Remove-Item -Path tmp -Recurse -Force
    Remove-Item -Path *.obj -Recurse -Force
    Remove-Item -Path *.res -Recurse -Force
    Write-Host "Cleaned Directories." -ForegroundColor Green
    Clear-Host
}

function Install-Engine {
    # Define paths for SFML
    $sfmlZipUrl = "https://www.sfml-dev.org/files/SFML-2.6.1-windows-vc17-32-bit.zip"
    $sfmlTempZipPath = "$env:TEMP\SFML-2.6.1-windows-vc17-32-bit.zip"
    $sfmlExtractedPath = "$env:TEMP\SFML-2.6.1"
    $sfmlDestinationPath = ".\3rdpty"

    # Download SFML zip file
    Write-Output "Downloading Engine..."
    Write-Output "(It's not stuck)"
    Invoke-WebRequest -Uri $sfmlZipUrl -OutFile $sfmlTempZipPath

    # Extract the zip file
    Write-Output "Extracting Engine..."
    Expand-Archive -Path $sfmlTempZipPath -DestinationPath $sfmlExtractedPath -Force

    # Ensure the destination directory exists
    if (-not (Test-Path $sfmlDestinationPath)) {
        Write-Output "Creating destination directory..."
        New-Item -ItemType Directory -Path $sfmlDestinationPath | Out-Null
    }

    # Copy the contents to the destination directory
    Write-Output "Copying files to destination..."
    Copy-Item -Path "$sfmlExtractedPath\SFML-2.6.1\*" -Destination $sfmlDestinationPath -Recurse -Force

    # Cleanup SFML
    Write-Output "Cleaning up..."
    Remove-Item -Path $sfmlTempZipPath -Force
    Remove-Item -Path $sfmlExtractedPath -Recurse -Force
    Clear-Host
}

function Invoke-BuildComponent {
    param (
        [string]$component,
        [switch]$debug
    )

    switch ($component) {
        "tweaker" {
            Write-Host "Compiling level tweaker..." -ForegroundColor Yellow
            pip install pyinstaller
            if ($debug) {
                pyinstaller --onefile --distpath .\tools\bin\ --workpath .\tmp .\tools\src\leveltweaker\leveltweaker.py --icon .\tools\src\leveltweaker\edit.ico 
            } else {
                pyinstaller --onefile --windowed --distpath .\tools\bin\ --workpath .\tmp .\tools\src\leveltweaker\leveltweaker.py --icon .\tools\src\leveltweaker\edit.ico
            }
            Write-Host "Compiled Level tweaker" -ForegroundColor Green
        }
        "editor" {
            Write-Host "Compiling level editor..." -ForegroundColor Yellow
            rc /nologo /fo leveledit_resources.res .\tools\src\leveledit\ico.rc
            if ($debug) {
                cl /EHsc /nologo /std:c++17 /MP /I"./3rdpty/include" /DDEBUG_BUILD .\tools\src\leveledit\leveledit.cpp .\tools\src\leveledit\nfd_common.c .\tools\src\leveledit\nfd_win.cpp leveledit_resources.res /link /LIBPATH:"./3rdpty/lib" sfml-graphics.lib sfml-window.lib sfml-system.lib ole32.lib shell32.lib uuid.lib /MACHINE:X86 /SUBSYSTEM:CONSOLE /OUT:"./tools/bin/leveleditor.exe"
            } else {
                cl /EHsc /nologo /std:c++17 /MP /I"./3rdpty/include" .\tools\src\leveledit\leveledit.cpp .\tools\src\leveledit\nfd_common.c .\tools\src\leveledit\nfd_win.cpp leveledit_resources.res /link /LIBPATH:"./3rdpty/lib" sfml-graphics.lib sfml-window.lib sfml-system.lib ole32.lib shell32.lib uuid.lib /MACHINE:X86 /SUBSYSTEM:WINDOWS /OUT:"./tools/bin/leveleditor.exe"
            }
            Write-Host "Compiled Level editor" -ForegroundColor Green 
        }
        "viewer" {
            Write-Host "Compiling level viewer..." -ForegroundColor Yellow
            rc /nologo /fo levelview_resources.res .\tools\src\levelview\ico.rc
            cl /EHsc /nologo /std:c++17 /MP /I"./3rdpty/include" .\tools\src\levelview\levelviewer.cpp .\tools\src\levelview\nfd_common.c .\tools\src\levelview\nfd_win.cpp levelview_resources.res /link /LIBPATH:"./3rdpty/lib" Ole32.lib Shell32.lib User32.lib sfml-graphics.lib Comdlg32.lib sfml-window.lib sfml-system.lib /MACHINE:X86 /SUBSYSTEM:WINDOWS /OUT:"./tools/bin/levelviewer.exe"
            Write-Host "Compiled Level Viewer" -ForegroundColor Green
        }
        "game" {
            Write-Host "Compiling game..." -ForegroundColor Yellow
            rc /nologo /fo game_resources.res .\game\ico.rc
            if ($debug) {
                cl /EHsc /nologo /std:c++17 /MP /I".\3rdpty\include" /DDEBUG_BUILD /DSFML_STATIC `
                    .\game\game\main.cpp `
                    .\game\vari.cpp `
                    .\game\debug\debug.cpp `
                    .\game\ai\enemy.cpp `
                    game_resources.res `
                    /link /LIBPATH:".\3rdpty\lib" `
                    User32.lib `
                    Advapi32.lib `
                    Shell32.lib `
                    Kernel32.lib `
                    Ws2_32.lib `
                    Dbghelp.lib `
                    sfml-graphics-s.lib `
                    sfml-window-s.lib `
                    sfml-system-s.lib `
                    sfml-audio-s.lib `
                    openal32.lib `
                    flac.lib `
                    vorbisenc.lib `
                    vorbisfile.lib `
                    vorbis.lib `
                    ogg.lib `
                    opengl32.lib `
                    freetype.lib `
                    winmm.lib `
                    gdi32.lib `
                    msvcrt.lib `
                    libucrt.lib `
                    /MACHINE:X86 /OUT:".\bin\game-debug.exe"
            } else {
                cl /EHsc /nologo /std:c++17 /MP /I".\3rdpty\include" /DSFML_STATIC `
                    .\game\game\main.cpp `
                    .\game\vari.cpp `
                    .\game\ai\enemy.cpp `
                    game_resources.res `
                    /link /LIBPATH:".\3rdpty\lib" `
                    User32.lib `
                    Advapi32.lib `
                    Shell32.lib `
                    Kernel32.lib `
                    Ws2_32.lib `
                    Dbghelp.lib `
                    sfml-graphics-s.lib `
                    sfml-window-s.lib `
                    sfml-system-s.lib `
                    sfml-audio-s.lib `
                    openal32.lib `
                    flac.lib `
                    vorbisenc.lib `
                    vorbisfile.lib `
                    vorbis.lib `
                    ogg.lib `
                    opengl32.lib `
                    freetype.lib `
                    winmm.lib `
                    gdi32.lib `
                    msvcrt.lib `
                    libucrt.lib `
                    /MACHINE:X86 /OUT:".\bin\game.exe"
            }
            Write-Host "Compiled game" -ForegroundColor Green            
        }            
        
    }
}

function Invoke-Component {
    param (
        [string]$component,
        [switch]$debug
    )

    Write-Host "Running $component..." -ForegroundColor Green
    switch ($component) {
        "tweaker" {
            Start-Process -FilePath tools\bin\leveltweaker.exe -WorkingDirectory tools\bin
        }
        "editor" {
            Start-Process -FilePath tools\bin\leveleditor.exe -WorkingDirectory tools\bin
        }
        "viewer" {
            Start-Process -FilePath tools\bin\levelviewer.exe -WorkingDirectory tools\bin
        }
        "game" {
            if ($debug) {
                Start-Process -FilePath bin\game-debug.exe -WorkingDirectory bin\
            } else {
                Start-Process -FilePath bin\game.exe -WorkingDirectory bin\
            }
        }
    }
}

Stop-Process -name game -Force
Stop-Process -name game-debug -Force 
Stop-Process -name leveleditor -Force
Stop-Process -Name levelviewer -Force 
Clear-Host
if ($clean) {
    Clear-Directories
}

Write-Host "Untitled-Game Make Script"
Write-Host "(c) 2024 Daniel McGuire"
Write-Host ""
$clPath = Get-Command cl.exe -ErrorAction SilentlyContinue

if ($null -eq $clPath) {
    Write-Host "cl.exe not found in PATH."
    Write-Host "Please start this script from the Visual Studio Developer PowerShell."
    exit
}

if ($help -or $h) {
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  -run             Run the specified program(s)"
    Write-Host "  -compile         Compile specified targets"
    Write-Host "  -setupengine     Download and setup the SFML engine"
    Write-Host ""
    Write-Host "Items to Compile or Run:"-ForegroundColor Cyan
    Write-Host "  -tools           Specify all tools"
    Write-Host "  -editor          Specify the level editor"
    Write-Host "  -tweaker         Specify the level tweaker"
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
    Install-Engine
}

if ($compile) {
    if ($game -or $all) {
        mkdir bin\ -Force
        Copy-Item -Path 3rdpty\bin\* -Destination bin\ -Recurse
        mkdir bin\data\txd\ -Force
        Copy-Item -Path assets\data\txd\* -Destination bin\data\txd -Recurse
        mkdir bin\data\levels -Force
        Copy-Item -Path levels\demo.level -Destination bin\data\levels\level1.ini
        mkdir bin\data\music -Force
        Get-ChildItem -Path "./assets/data/music/" -Filter *.mp3 | ForEach-Object {
            ffmpeg -i $_.FullName -acodec pcm_s16le -ar 44100 "./bin/data/music/$($_.BaseName).wav"
        }
        mkdir bin\scripts\ -Force  
    }
    if ($tools -or $editor -or $viewer -or $tweaker -or $all){
        mkdir tools\bin\ -Force
        Copy-Item -Path 3rdpty\bin\* -Destination tools\bin\ -Recurse
        mkdir tools\bin\data\txd\ -Force
        Copy-Item -Path assets\data\txd\* -Destination tools\bin\data\txd -Recurse
        mkdir tools\bin\data\levels -Force
        Copy-Item -Path levels\demo.level -Destination tools\bin\data\levels\level1.ini
        mkdir tools\bin\data\music -Force
        Get-ChildItem -Path "./assets/data/music/" -Filter *.mp3 | ForEach-Object {
            ffmpeg -i $_.FullName -acodec pcm_s16le -ar 44100 "./tools/bin/data/music/$($_.BaseName).wav"
        }
    }
    if ($tweaker -or $tools -or $all) {
        Invoke-BuildComponent i -component "tweaker" -debug:$debug
    }
    if ($editor -or $tools -or $all) {
        Invoke-BuildComponent -component "editor" -debug:$debug
    }
    if ($viewer -or $tools -or $all) {
        Invoke-BuildComponent -component "viewer" -debug:$debug
    }
    if ($game -or $all) {
        Invoke-BuildComponent -component "game" -debug:$debug
    }
}

if ($run) {
    Write-Host "Running the specified program(s)..." -ForegroundColor Yellow

    if ($tweaker -or $tools -or $all) {
        Invoke-Component -component "tweaker" -debug:$debug
    }
    if ($editor -or $tools -or $all) {
        Invoke-Component -component "editor" -debug:$debug
    }
    if ($viewer -or $tools -or $all) {
        Invoke-Component -component "viewer" -debug:$debug
    }
    if ($game -or $all) {
        Invoke-Component -component "game" -debug:$debug
    }
}
