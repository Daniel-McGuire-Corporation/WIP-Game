if ($IsWindows) {
Install-Module ps2exe
clear-host
mkdir tools\bin\ -Force
ps2exe .\tools\src\make\make.ps1 .\tools\bin\make.exe | grep --------
} elseif ($IsMacOS) {
    # Function to check for and install Homebrew
    function Install-Homebrew {
        Write-Output "Homebrew is not installed. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    }

    # Function to install Python using Homebrew
    function Install-Python {
        if (-not (Get-Command "brew" -ErrorAction SilentlyContinue)) {
            Install-Homebrew
        }
        Write-Output "Installing Python..."
        & brew install python
    }

    # Function to determine if pip or pip3 is available
    function Get-PipCommand {
        if (Get-Command "pip3" -ErrorAction SilentlyContinue) {
            Write-Output "Using pip3"
            return "pip3"
        }
        elseif (Get-Command "pip" -ErrorAction SilentlyContinue) {
            Write-Output "Using pip"
            return "pip"
        }
        elseif (Get-Command "python3" -ErrorAction SilentlyContinue) {
            Write-Output "Using python3 -m pip"
            return "python3 -m pip"
        }
        elseif (Get-Command "python" -ErrorAction SilentlyContinue) {
            Write-Output "Using python -m pip"
            return "python -m pip"
        }
        else {
            Install-Python
            # Retry check after installing Python
            if (Get-Command "pip3" -ErrorAction SilentlyContinue) {
                Write-Output "Using pip3 after installation"
                return "pip3"
            }
            elseif (Get-Command "pip" -ErrorAction SilentlyContinue) {
                Write-Output "Using pip after installation"
                return "pip"
            }
            else {
                Write-Output "Python and pip could not be found or installed. Exiting."
                exit 1
            }
        }
    }

    # Function to determine if PyInstaller is installed
    function Test-PyInstaller {
        if (Get-Command "pyinstaller" -ErrorAction SilentlyContinue) {
            Write-Output "PyInstaller is already installed."
            return $true
        }
        return $false
    }

    # Function to install PyInstaller
    function Install-PyInstaller {
        $pipCommand = Get-PipCommand
        Write-Output "Installing pyinstaller..."
        & $pipCommand install pyinstaller
    }

    # Main script execution
    if (-not (Test-PyInstaller)) {
        Install-PyInstaller
    }
    # Compile the Python script to an executable
    Write-Output "Compiling ./tools/src/make.py to ./make"
    pyinstaller --onefile --name make ./tools/src/make/make.py
    mv dist/make ./make
    rm -rf build dist __pycache__ *.spec 
} elseif ($IsLinux) {
  Write-Error "Couldn't find valid config for linux"
    exit
}

#Clear-Host
Write-Host Make has been initialized.
Write-Host ""
Write-Host "If you haven't yet, run"
if ($IsWindows) {
    Write-Host ".\setenv"
    Write-Host "make -setupengine"
} elseif ($IsMacOS) {
Write-Host "./make -setupengine"
}