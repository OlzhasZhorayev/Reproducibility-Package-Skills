
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
* 2. Set Meta Variables
*******************************************************************************

meta set effectsize2 std_error2, studylabel(studylbl)

*******************************************************************************
* 3. Heterogeneity / Grouping Variables
*******************************************************************************

replace methodology = "2" if methodology == "2,3"

gen group1 = type
gen group2 = vble2 if type == "Big Five"
gen group3 = educ_control if inlist(type, "Big Five")
gen group4 = inc_class if inlist(type, "Big Five")
gen group5 = sample_popn if inlist(sample_popn, "Male", "Female")
gen group6 = methodology if inlist(type, "Big Five")

*******************************************************************************
* 4. Run Meta-Analysis (Fixed Effects) and Export Group Results
*******************************************************************************

putexcel set "${temp}/Pooled_Estimates_FE_All.xlsx", replace sheet("Sheet1")
putexcel A1 = "Group" B1 = "Subgroup" C1 = "Theta" D1 = "SE" E1 = "p-value" F1 = "N"
local row1 = 2

putexcel set "${temp}/Pooled_Estimates_FE_All.xlsx", modify sheet("Sheet2")
putexcel A1 = "Group" B1 = "Subgroup" C1 = "Theta" D1 = "SE" E1 = "p-value" F1 = "N"
local row2 = 2

label var group1 "Skill type"
label var group2 "Big Five"
label var group3 "Education"
label var group4 "Income level"
label var group5 "Gender"
label var group6 "Methodology"

local groups "group1 group2 group3 group4 group5 group6"

tempvar w wy
gen double `w'  = 1/(std_error2^2)
gen double `wy' = `w' * effectsize2

foreach group of local groups {

    local group_label : variable label `group'
    quietly levelsof `group', local(subgroups)

    foreach subgroup of local subgroups {

        * Detect whether `group' is string or numeric
        local vtype : type `group'

        * Build condition for subgroup (string vs numeric)
        if substr("`vtype'",1,3) == "str" {
            local cond `"`group' == "`subgroup'""'
        }
        else {
            local cond `"`group' == `subgroup'"'
        }

        * Subgroup label for export (use value label if numeric-labeled)
        local subgroup_out "`subgroup'"
        if substr("`vtype'",1,3) != "str" {
            local vallbl : value label `group'
            if "`vallbl'" != "" local subgroup_out : label `vallbl' `subgroup'
        }

        * N in subgroup
        quietly count if `cond'
        local N = r(N)
        if `N' == 0 continue

        * Fixed-effect inverse-variance pooled estimate
        quietly summarize `w' if `cond', meanonly
        local sw = r(sum)

        quietly summarize `wy' if `cond', meanonly
        local swy = r(sum)

        if `sw' == 0 continue

        local theta = `swy' / `sw'
        local se    = sqrt(1/`sw')
        local z     = `theta' / `se'
        local pval  = 2 * (1 - normal(abs(`z')))

        if "`group'" == "group1" {
            putexcel set "${temp}/Pooled_Estimates_FE_All.xlsx", ///
				modify sheet("Sheet1")
            putexcel A`row1' = "`group_label'" B`row1' = "`subgroup_out'" ///
                C`row1' = `theta' D`row1' = `se' E`row1' = `pval' F`row1' = `N'
            local row1 = `row1' + 1
        }
        else {
            putexcel set "${temp}/Pooled_Estimates_FE_All.xlsx", ///
			modify sheet("Sheet2")
            putexcel A`row2' = "`group_label'" B`row2' = "`subgroup_out'" ///
                C`row2' = `theta' D`row2' = `se' E`row2' = `pval' F`row2' = `N'
            local row2 = `row2' + 1
        }
    }
}

* End of do-file **************************************************************	






