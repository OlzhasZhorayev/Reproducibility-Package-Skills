
/*******************************************************************************
* Setup.do
*
* Purpose:
* This setup file defines the project directory structure (Data, Code, Temp,
* Tables, Figures) using a single project root path provided via REPRO_DIR. 
*
* This file is designed to support the Python master runner (run_all.py),
* which calls Stata in batch mode. It ensures that all Stata do-files can be
* executed reproducibly from Python without manually editing file paths.
*
* All subsequent do-files rely on the global macros defined here.
*******************************************************************************/

clear all
set more off

* Read project root from environment variable set by run_all.py

** If called from Python, REPRO_DIR should be available
local repro = "$REPRO_DIR"

** Fallback: if REPRO_DIR is not available, infer project root from the
** location of the current working directory
if "`repro'" == "" {
    * If running from within the Code/ folder, go one level up to the project root
    local repro = c(pwd)
    if substr("`repro'", -5, .) == "\Code" {
        local repro = substr("`repro'", 1, length("`repro'")-5)
    }
}

** Define project root directory
global dir "`repro'"

* Project folders
global data    "${dir}\Data"
global code    "${dir}\Code"
global tables  "${dir}\Tables"
global figures "${dir}\Figures"
global temp    "${dir}\Temp"

* Project ado folder
sysdir set PLUS "${code}\ado"
	