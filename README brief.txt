
1. In the VS Code Terminal, set the path to Stata.exe:
    
    Examples:
        $env:STATA_EXE="C:\Program Files\Stata18\StataMP-64.exe"
        or
        $env:STATA_EXE="C:\Users\Admin\OneDrive - George Mason University - O365 Production\Documents\Progs\STATA\Stata12\Stata.exe"
    
    Verify the path:
        echo $env:STATA_EXE

2. Run the master script: 

    python Code\00-Master-run-all.py

