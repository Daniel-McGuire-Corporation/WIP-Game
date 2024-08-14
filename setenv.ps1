# Change the directory to the location of the script
cd $PSScriptRoot

# Confirm the target directory exists
if (Test-Path ".\tools\bin") {
    # Set the PATH environment variable
    $env:PATH = "$($PSScriptRoot)\tools\bin;$env:PATH"
    Write-Output "Path updated: $env:PATH"
} else {
    Write-Output "Directory '.\tools\bin' does not exist."
}

