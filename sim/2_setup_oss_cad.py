import os
import sys
import platform
import urllib.request
import subprocess
import shutil

# --- Configuration ---
DATE = "20260112"
BASE_URL = f"https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2026-01-12"

# Map system names to file definitions
# Format: (Remote Filename, Local Filename for Extraction)
PLATFORM_MAP = {
    "Windows": (
        f"oss-cad-suite-windows-x64-{DATE}.exe", 
        f"oss-cad-suite-windows-x64-{DATE}.tar" # Rename to .tar for Windows bsdtar trick
    ),
    "Darwin": (
        f"oss-cad-suite-darwin-arm64-{DATE}.tgz",
        f"oss-cad-suite-darwin-arm64-{DATE}.tgz"
    ),
    "Linux": (
        f"oss-cad-suite-linux-x64-{DATE}.tgz",
        f"oss-cad-suite-linux-x64-{DATE}.tgz"
    )
}

def download_file(url, local_filename):
    """Downloads file with a simple progress print."""
    if os.path.exists(local_filename):
        print(f"File {local_filename} already exists. Skipping download.")
        return

    print(f"Downloading {url}...")
    try:
        # Simple download without progress bar dependency
        urllib.request.urlretrieve(url, local_filename)
        print("Download complete.")
    except Exception as e:
        print(f"Error downloading file: {e}")
        sys.exit(1)

def extract_file(filename):
    """Runs system tar to extract the file."""
    print(f"Extracting {filename}...")
    try:
        # We use subprocess to call system 'tar' because Python's tarfile module
        # cannot handle the Windows 7-Zip SFX (.exe) format.
        subprocess.run(["tar", "-xf", filename], check=True)
    except subprocess.CalledProcessError:
        print("Error: Extraction failed.")
        sys.exit(1)
    except FileNotFoundError:
        print("Error: 'tar' command not found. Please ensure tar is in your PATH.")
        sys.exit(1)

def main():
    # 1. Detect OS
    system = platform.system()
    if system not in PLATFORM_MAP:
        print(f"Error: Unsupported OS '{system}'")
        sys.exit(1)
    
    remote_name, local_name = PLATFORM_MAP[system]
    url = f"{BASE_URL}/{remote_name}"

    print(f"--- Setup OSS CAD Suite ({system}) ---")

    # 2. Idempotency Check
    if os.path.isdir("oss-cad-suite"):
        print("[SKIP] 'oss-cad-suite' folder already exists.")
        print("Installation skipped.")
        return

    # 3. Download
    # On Windows, we download the .exe but save it as .tar so tar can read it
    download_file(url, local_name)

    # 4. Extract
    extract_file(local_name)

    # 5. Cleanup (Optional)
    # if os.path.exists(local_name):
    #     os.remove(local_name)

    print("---------------------------------------------------")
    print("Success! OSS CAD Suite is installed.")
    if system == "Windows":
        print("Run 'manage.py' to start using the tools.")
    else:
        print("Run 'source oss-cad-suite/environment' to manually activate (if needed).")
    print("---------------------------------------------------")

if __name__ == "__main__":
    main()
