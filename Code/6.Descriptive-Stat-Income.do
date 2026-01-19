
* Load Data
do "Setup.do"
use "${data}/Data_clean.dta", clear

*******************************************************************************
* 1. Data Cleaning
*******************************************************************************

* Remove estimates based on training
drop if training == "yes"

* Drop if estimates are expressed as standard deviation
keep if ind_var_measure == "Standard deviation"

replace methodology = "IV" if methodology == "2,3" | methodology == "2"
replace methodology = "OLS" if methodology == "3"

replace vble2 =  "" if strpos(vble2, "tenure") > 0
keep if inlist(type, "Big Five", "Cognitive")
replace type = "Cognitive Skills" if type == "Cognitive"

replace region = "Latin America" if region == "Latin America and the Caribbean"
replace region = "North America" if region == "Northern America"

* Additional cleaning

replace inc_class = "Developing Countries" ///
	if inc_class == "Lower Middle Income" | inc_class == "Upper Middle Income"

replace educ_control = "Controlled" if educ_control == "Yes"
replace educ_control = "Not Controlled" if educ_control == "No"

replace sample_popn = "Female" if sample_popn == "female"
replace sample_popn = "Male" if sample_popn == "male"

gen gender = .
replace gender = 1 if sample_popn == "Female"
replace gender = 2 if sample_popn == "Male"
replace gender = 3 if sample_popn != "Female" & sample_popn != "Male"
label define gender_lbl 1 "Female" 2 "Male" 3 "Mixed"
label values gender gender_lbl

drop if studylbl == "Chowdhury (2017)"

*******************************************************************************
* 2. Descriptive Statistics, Labor Returns Analysis by Income Group
*******************************************************************************

local dev  "Developing Countries"
local high "High Income"

quietly count
local N_all = r(N)

quietly count if inc_class == "`dev'"
local N_dev = r(N)

quietly count if inc_class == "`high'"
local N_high = r(N)

capture postclose T3
capture postutil clear

capture program drop _pctstr
program define _pctstr, rclass
    syntax , NUM(integer) DEN(integer)
    if (`den'==0) return local s ""
    else {
        local p = 100*(`num'/`den')
        local p = round(`p', 0.1)
        return local s : display %4.1f `p'
    }
end

tempfile t3
postfile T3 str70 Row str12 All str12 High str12 Developing using `t3', replace

post T3 ("Number of estimates") ("`N_all'") ("`N_high'") ("`N_dev'")

post T3 ("Estimate type (%)") ("") ("") ("")
foreach v in "Big Five" "Cognitive Skills" {
    quietly count if type == "`v'"
    local n_all = r(N)
    quietly count if type == "`v'" & inc_class == "`high'"
    local n_high = r(N)
    quietly count if type == "`v'" & inc_class == "`dev'"
    local n_dev = r(N)

    quietly _pctstr, num(`n_all') den(`N_all')
    local p_all `r(s)'
    quietly _pctstr, num(`n_high') den(`N_high')
    local p_high `r(s)'
    quietly _pctstr, num(`n_dev') den(`N_dev')
    local p_dev `r(s)'

    post T3 ("  `v'") ("`p_all'") ("`p_high'") ("`p_dev'")
}

post T3 ("Education control (%)") ("") ("") ("")
foreach v in "Controlled" "Not Controlled" {
    quietly count if educ_control == "`v'"
    local n_all = r(N)
    quietly count if educ_control == "`v'" & inc_class == "`high'"
    local n_high = r(N)
    quietly count if educ_control == "`v'" & inc_class == "`dev'"
    local n_dev = r(N)

    quietly _pctstr, num(`n_all') den(`N_all')
    local p_all `r(s)'
    quietly _pctstr, num(`n_high') den(`N_high')
    local p_high `r(s)'
    quietly _pctstr, num(`n_dev') den(`N_dev')
    local p_dev `r(s)'

    local lab = cond("`v'"=="Controlled","Yes","No")
    post T3 ("  `lab'") ("`p_all'") ("`p_high'") ("`p_dev'")
}

tempvar gender_str
capture confirm numeric variable gender
if _rc==0 {
    decode gender, gen(`gender_str')
}
else {
    gen str20 `gender_str' = gender
}

post T3 ("Gender (%)") ("") ("") ("")
foreach v in "Female" "Male" "Mixed" {
    quietly count if `gender_str' == "`v'"
    local n_all = r(N)
    quietly count if `gender_str' == "`v'" & inc_class == "`high'"
    local n_high = r(N)
    quietly count if `gender_str' == "`v'" & inc_class == "`dev'"
    local n_dev = r(N)

    quietly _pctstr, num(`n_all') den(`N_all')
    local p_all `r(s)'
    quietly _pctstr, num(`n_high') den(`N_high')
    local p_high `r(s)'
    quietly _pctstr, num(`n_dev') den(`N_dev')
    local p_dev `r(s)'

    post T3 ("  `v'") ("`p_all'") ("`p_high'") ("`p_dev'")
}

post T3 ("Methodology (%)") ("") ("") ("")
foreach v in "OLS" "IV" {
    quietly count if methodology == "`v'"
    local n_all = r(N)
    quietly count if methodology == "`v'" & inc_class == "`high'"
    local n_high = r(N)
    quietly count if methodology == "`v'" & inc_class == "`dev'"
    local n_dev = r(N)

    quietly _pctstr, num(`n_all') den(`N_all')
    local p_all `r(s)'
    quietly _pctstr, num(`n_high') den(`N_high')
    local p_high `r(s)'
    quietly _pctstr, num(`n_dev') den(`N_dev')
    local p_dev `r(s)'

    post T3 ("  `v'") ("`p_all'") ("`p_high'") ("`p_dev'")
}

postclose T3
use `t3', clear

* Export, then blank A1 and set Excel headers
export excel using "${tables}/Table2_DescriptiveStats_Income.xlsx", firstrow(variables) replace
putexcel set "${tables}/Table2_DescriptiveStats_Income.xlsx", modify
putexcel A1 = ""  
putexcel B1 = "All"
putexcel C1 = "High income countries"
putexcel D1 = "Developing countries"

* End of do-file **************************************************************	
	   
	   
	 