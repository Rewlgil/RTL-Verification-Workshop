#!/bin/bash

# 1. Force the script to run in its own directory
cd "$(dirname "$0")"

echo "Checking for Python 3..."

# 2. Check if python3 is already installed
# We check for the command 'python3' and ensure it's not just a stub
if command -v python3 >/dev/null 2>&1; then
    # Grab version string
    VER=$(python3 --version)
    echo "---------------------------------------------------"
    echo "Found $VER. Skipping installation."
    echo "---------------------------------------------------"
    # Wait for user input so the window doesn't disappear immediately
    read -p "Press [Enter] to close..."
    exit 0
fi

# 3. Download Python 3.13 (Universal2 for Intel & Apple Silicon)
# Note: Always check python.org for the specific patch version URL if you want to pin it.
PYTHON_URL="https://www.python.org/ftp/python/3.13.0/python-3.13.0-macos11.pkg"
PKG_FILE="python_installer.pkg"

echo "Python 3 not found."
echo "Downloading Python 3.13 from python.org..."
curl -L -o "$PKG_FILE" "$PYTHON_URL"

if [ $? -ne 0 ]; then
    echo "[ERROR] Download failed."
    read -p "Press [Enter] to close..."
    exit 1
fi

# 4. Install using macOS 'installer' tool
echo "---------------------------------------------------"
echo "Installing Python 3.13..."
echo "NOTE: You will be asked for your Mac password to proceed."
echo "---------------------------------------------------"

# sudo is required to install the pkg to system paths
sudo installer -pkg "$PKG_FILE" -target /

if [ $? -eq 0 ]; then
    echo "---------------------------------------------------"
    echo "Success! Python 3.13 is installed."
    echo "---------------------------------------------------"
else
    echo "---------------------------------------------------"
    echo "[ERROR] Installation failed."
    echo "---------------------------------------------------"
fi

# 5. Cleanup
rm -f "$PKG_FILE"

# 6. Pause so student can see the result
read -p "Press [Enter] to close..."
