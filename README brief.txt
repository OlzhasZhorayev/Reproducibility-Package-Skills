
In VS Code’s Terminal, set up a path to Stata.exe:

Olzhas's home laptop:
$env:STATA_EXE="C:\Users\Admin\OneDrive - George Mason University - O365 Production\Documents\Progs\STATA\Stata12\Stata.exe"

Olzhas's WB laptop:
$env:STATA_EXE="C:\Program Files\Stata18\StataMP-64.exe"

Verify:
echo $env:STATA_EXE

Run the Master code:
python Code\00-Master-run-all.py


