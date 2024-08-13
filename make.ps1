param (
    [switch]$debug,
    [switch]$compile,
    [switch]$Tools,
    [switch]$Editor,
    [switch]$Viewer,
    [switch]$game,
    [switch]$run,
    [switch]$all,
    [switch]$help,
    [switch]$h
)

function Show-Help {
    Write-Host "Usage: script.ps1 [options]" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  -run             Run the specified program(s)" -ForegroundColor Green
    Write-Host "  -compile         Compile specified targets" -ForegroundColor Green
    Write-Host "  -Tools           Specify all tools" -ForegroundColor Green
    Write-Host "  -Editor          Specify the level editor" -ForegroundColor Green
    Write-Host "  -Viewer          Specify the level viewer" -ForegroundColor Green
    Write-Host "  -game            Specify the game" -ForegroundColor Green
    Write-Host "  -all             Specify everything" -ForegroundColor Green
    Write-Host "  -debug           Specify debug" -ForegroundColor Green
    Write-Host "  -help, -h        Show this help message" -ForegroundColor Green
}

if ($help -or $h) {
    Show-Help
    exit
}

if ($compile) {
    if ($Tools -or $all) {
        Write-Host "Compiling level viewer..." -ForegroundColor Yellow
        rc /fo levelview_resources.res .\tools\src\levelview\ico.rc
        cl /EHsc /std:c++17 /MP /I"./3rdpty/include" .\tools\src\levelview\levelviewer.cpp .\tools\src\levelview\nfd_common.c .\tools\src\levelview\nfd_win.cpp levelview_resources.res /link /LIBPATH:"./3rdpty/lib" Ole32.lib Shell32.lib User32.lib sfml-graphics.lib Comdlg32.lib sfml-window.lib sfml-system.lib /MACHINE:X86 /SUBSYSTEM:WINDOWS /OUT:"./tools/bin/levelviewer.exe"
        Write-Host "Compiled Level Viewer" -ForegroundColor Green

        Write-Host "Compiling Level Editor" -ForegroundColor Yellow
        pip install pyinstaller
        pyinstaller --onefile --windowed --distpath .\tools\bin\ --workpath .\tmp .\tools\src\leveledit\leveleditor.py --icon .\tools\src\leveledit\edit.ico
        Copy-Item -Path tools\src\leveledit\edit.ico -Destination tools\bin\edit.ico
        Write-Host "Compiled Level Editor" -ForegroundColor Green
    }
    if ($Editor -or $all) {
        Write-Host "Compiling level editor..." -ForegroundColor Yellow
        pip install pyinstaller
        pyinstaller --onefile --windowed --distpath .\tools\bin\ --workpath .\tmp .\tools\src\leveledit\leveleditor.py --icon .\tools\src\leveledit\edit.ico
        Copy-Item -Path tools\src\leveledit\edit.ico -Destination tools\bin\edit.ico
        Write-Host "Compiled Level Editor" -ForegroundColor Green
    }
    if ($Viewer -or $all) {
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
    if ($Tools -or $all) {
        Write-Host "Running Level Editor..." -ForegroundColor Green
        Start-Process -FilePath tools\bin\leveleditor.exe
        Write-Host "Running Level Viewer..." -ForegroundColor Green
        Start-Process -FilePath tools\bin\levelviewer.exe
    }
    if ($game -or $all) {
        Write-Host "Running Game..." -ForegroundColor Green
        if ($debug) {
            Start-Process -FilePath bin\game-debug.exe
        } else {
            Start-Process -FilePath bin\game.exe
        }
    }
}
