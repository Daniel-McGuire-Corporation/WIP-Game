import subprocess
import sys
import platform

def run_make_ps1(args):
    os_name = platform.system()

    if os_name == "Windows":
        print("Please report an issue on github.")
        print("Error 102")
    elif os_name == "Darwin":  # macOS
        subprocess.run(["pwsh", "-ExecutionPolicy", "Bypass", "./tools/src/make/makeosx.ps1"] + args)
    elif os_name == "Linux":
        print("Linux version is coming soon! Stay tuned.")
    else:
        print(f"Unsupported OS: {os_name}")

if __name__ == "__main__":
    run_make_ps1(sys.argv[1:])