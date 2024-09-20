#!/bin/bash

# Function to install requirements
install_requirements() {
    echo "Installing Python dependencies..."
    if command -v apt-get >/dev/null; then
        sudo apt-get install python3-pyinstaller
    elif command -v dnf >/dev/null; then
        sudo dnf install pyinstaller
    elif command -v yum >/dev/null; then
        sudo yum install pyinstaller
    elif command -v pacman >/dev/null; then
        sudo pacman -S python-pyinstaller
    elif command -v brew >/dev/null; then
        brew install python
    else
        pip install pyinstaller
    fi
    pip install -r requirements.txt
}

# Function to create macOS app bundle
create_mac_app_bundle() {
    local gui_source="$1"
    local app_name="$2"
    local bin_dir="$3"
    local gui_ext="$4"

    echo "Creating macOS app bundle for $app_name..."
    mkdir -p "$bin_dir"

    # Use PyInstaller to create the app bundle
    python3 -m PyInstaller --onefile --windowed --name "$app_name" --distpath "$bin_dir" "$gui_source"
    
    mv "$bin_dir/$app_name.app" "$bin_dir/chatugmp.app"
    xattr -cr "$bin_dir/$gui_ext.app"
    rm -f "$bin_dir/$app_name"
}

# Handle command-line arguments
case "$1" in
    install)
        install_requirements
        ;;
    create_app)
        create_mac_app_bundle "$2" "$3" "$4"
        ;;
    *)
        echo "Usage: $0 {install|create_app <gui_source> <app_name> <bin_dir>}"
        exit 1
        ;;
esac
