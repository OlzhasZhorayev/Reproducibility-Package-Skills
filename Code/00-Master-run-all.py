import os
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
CODE_DIR = REPO_ROOT / "Code"

env = os.environ.copy()
env["REPRO_DIR"] = str(REPO_ROOT)

stata_exe = env.get("STATA_EXE")
if not stata_exe:
    raise RuntimeError(
        "STATA_EXE is not set.\n"
        "Please set it to the full path of your local Stata.exe.\n"
        "Example (Windows):\n"
        r'STATA_EXE="C:\Program Files\Stata18\StataMP-64.exe"'
        "The exact path and Stata version may differ across systems."
    )

def run_stata(do_file: str):
    cmd = [stata_exe, "/e", "do", str(CODE_DIR / do_file)]
    print("Running:", " ".join(cmd))
    subprocess.run(cmd, check=True, env=env, cwd=str(CODE_DIR))

def run_py(py_file: str):
    cmd = [sys.executable, str(CODE_DIR / py_file)]
    print("Running:", " ".join(cmd))
    subprocess.run(cmd, check=True, env=env, cwd=str(CODE_DIR))

if __name__ == "__main__":
    
    run_stata("Setup.do")

    # --- DATA PREPARATION (Stata) ---
    run_stata("1.Pool-Estimates-RE-All.do")
    run_stata("2.Pool-Estimates-Training.do")
    run_stata("3.Pool-Estimates-RE-Main.do")
    run_stata("4.Pool-Estimates-FE-All.do") 
    run_stata("5.Pool-Estimates-RE-Big5.do")

    # --- STATA TABLES ---
    run_stata("6.Descriptive-Stat-Income.do")
    run_stata("10.Descriptive-Stat-Training.do")
    run_stata("14.Descriptive-Stat-Region.do")

    # --- PYTHON FIGURES ---
    run_py("7.Wage-Returns-RE.py")
    run_py("8.Heterogeneity.py")
    run_py("11.Training-Impact.py")
    run_py("12.Training-Heterogeneity.py")
    run_py("15.Wage-Returns-RE-Main.py")
    run_py("16.Wage-Returns-FE-All.py")
    run_py("17.Wage-Returns-RE-Big5.py")

    # --- STATA FIGURES ---
    run_stata("9.Funnel-Plot.do")
    run_stata("13.Funnel-Plot-Training.do")

    print("\n✅ All done!")
