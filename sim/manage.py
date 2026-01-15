import os
import sys
import subprocess
import argparse
import shutil
import platform

# --- Auto-configure PATH ---
BASE_PATH = os.path.dirname(__file__)
TOOLCHAIN_BIN = os.path.abspath(os.path.join(BASE_PATH, "oss-cad-suite", "bin"))
TOOLCHAIN_LIB = os.path.abspath(os.path.join(BASE_PATH, "oss-cad-suite", "lib"))

# Prepend BOTH bin and lib to the PATH
paths_to_add = []
if os.path.exists(TOOLCHAIN_BIN):
    paths_to_add.append(TOOLCHAIN_BIN)
if os.path.exists(TOOLCHAIN_LIB):
    paths_to_add.append(TOOLCHAIN_LIB)

if paths_to_add:
    new_paths = os.pathsep.join(paths_to_add)
    os.environ["PATH"] = new_paths + os.pathsep + os.environ["PATH"]

# --- Configuration ---
TOP_MODULE = "fpmul"
RTL_SOURCES = ["fpmul.v"] 
TESTBENCH = "fpmul_stim1_new.v"
SYN_OUTPUT = "fpmul_syn.v"

IS_WINDOWS = platform.system() == "Windows"
EXE_EXT = ".exe" if IS_WINDOWS else ""

# Tool definitions
YOSYS = "yosys" + EXE_EXT
YOSYS_CONFIG = "yosys-config" 
IVERILOG = "iverilog" + EXE_EXT
VVP = "vvp" + EXE_EXT

RTL_EXE = "simrtl"
GATES_EXE = "simgates"

def run_command(cmd, capture_output=False, allow_fail=False):
    """
    Runs a command. 
    If allow_fail=True, it raises the exception to the caller instead of exiting.
    """
    try:
        result = subprocess.run(
            cmd, 
            check=True, 
            text=True, 
            capture_output=capture_output,
            shell=False 
        )
        return result.stdout.strip() if capture_output else None
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        # If the caller wants to handle the error (e.g. try a fallback), re-raise it.
        if allow_fail:
            raise e

        # Otherwise, print a helpful error and kill the script.
        print(f"\n[ERROR] Command failed: {' '.join(cmd)}")
        if isinstance(e, subprocess.CalledProcessError):
            print(f"Return Code: {e.returncode}")
            if e.returncode == -1073741515:
                print("-> Diagnosis: Missing DLLs (0xC0000135).")
        elif isinstance(e, FileNotFoundError):
             print(f"-> Diagnosis: Command not found in PATH.")
             
        if capture_output and hasattr(e, 'stderr') and e.stderr:
            print("Error Output:")
            print(e.stderr)
        sys.exit(1)

def get_yosys_datdir():
    """Finds the Yosys data directory dynamically."""
    print("[...] Finding Yosys data directory...")
    
    # 1. First, try the standard relative path for OSS CAD Suite (Robust on Windows)
    # This avoids calling the 'yosys-config' script which fails on Windows.
    fallback = os.path.abspath(os.path.join(TOOLCHAIN_BIN, "..", "share", "yosys"))
    if os.path.exists(fallback):
        return fallback

    # 2. If that fails, try asking the tool (works better on Linux/macOS)
    try:
        datdir = run_command([YOSYS_CONFIG, "--datdir"], capture_output=True, allow_fail=True)
        return datdir
    except Exception:
        print(f"[ERROR] Could not determine Yosys data directory.")
        print(f"Checked relative path: {fallback}")
        print(f"Tried command: {YOSYS_CONFIG} --datdir")
        sys.exit(1)

def clean():
    print("--- Cleaning ---")
    files_to_remove = [RTL_EXE, GATES_EXE, SYN_OUTPUT, "synthesis_successful"]
    files_to_remove.extend([f"{RTL_EXE}.exe", f"{GATES_EXE}.exe"]) 

    for filename in files_to_remove:
        if os.path.exists(filename):
            os.remove(filename)
            print(f"Removed {filename}")

def synthesize():
    print("--- Synthesizing ---")
    
    # 1. Run Yosys
    yosys_cmd = [
        YOSYS, 
        "-p", 
        f"read_verilog {TOP_MODULE}.v; synth -top {TOP_MODULE} -flatten; abc -g gates; opt_clean; rename -hide */w:*; write_verilog -noattr {SYN_OUTPUT}"
    ]
    run_command(yosys_cmd)
    
    # 2. Append simlib.v
    datdir = get_yosys_datdir()
    simlib_path = os.path.join(datdir, "simlib.v")
    
    if not os.path.exists(simlib_path):
        print(f"Error: Simulation library not found at {simlib_path}")
        sys.exit(1)

    print(f"Appending {simlib_path} to {SYN_OUTPUT}...")
    try:
        with open(SYN_OUTPUT, "a") as outfile:
            with open(simlib_path, "r") as infile:
                outfile.write("\n// Appended simlib.v \n")
                shutil.copyfileobj(infile, outfile)
    except IOError as e:
        print(f"Error appending library file: {e}")
        sys.exit(1)

def sim_rtl():
    print("--- RTL Simulation ---")
    cmd_compile = [IVERILOG, "-o", RTL_EXE, TESTBENCH] + RTL_SOURCES
    run_command(cmd_compile)
    cmd_run = [VVP, RTL_EXE]
    run_command(cmd_run)

def sim_gates():
    if not os.path.exists(SYN_OUTPUT):
        synthesize()
    print("--- Gate Simulation ---")
    cmd_compile = [IVERILOG, "-o", GATES_EXE, TESTBENCH, SYN_OUTPUT]
    run_command(cmd_compile)
    cmd_run = [VVP, GATES_EXE]
    run_command(cmd_run)

def main():
    parser = argparse.ArgumentParser(description="Build and Simulate FPMul")
    parser.add_argument("target", nargs="?", choices=["clean", "syn", "simrtl", "simgates"], help="Build target")
    args = parser.parse_args()

    if args.target is None:
        print("Usage: python manage.py [command]")
        print("\nAvailable commands:")
        print("  clean     : Remove generated files")
        print("  syn       : Run Yosys synthesis (creates fpmul_syn.v)")
        print("  simrtl    : Run RTL simulation (uses fpmul.v)")
        print("  simgates  : Run Gate-level simulation (uses fpmul_syn.v)")
        sys.exit(0)

    if args.target == "clean": clean()
    elif args.target == "syn": synthesize()
    elif args.target == "simrtl": sim_rtl()
    elif args.target == "simgates": sim_gates()

if __name__ == "__main__":
    main()
