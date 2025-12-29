
* Load data
do "Setup.do"
use "${data}/Data_clean.dta", clear

*******************************************************************************
* 1. Data Cleaning and Restrictions
*******************************************************************************

* Remove estimates based on training
drop if training == "yes"

* Remove if estimates are based on robustness checks,
* keeping only the authors' preferred specification
drop if missing(preferred)

* Papers controlling for all Big Five personality traits

	** Tag if the variable is "Openness"
	gen openness_tag = 1 if vble2 == "Openness"
	bysort paper_id (variable): egen has_openness = max(openness_tag)

	** Tag if the variable is "Conscientiousness"
	gen conscientiousness_tag = 1 if vble2 == "Conscientiousness"
	bysort paper_id (variable): egen has_conscientiousness = max(conscientiousness_tag)

	** Tag if the variable is "Agreeableness"
	gen agreeableness_tag = 1 if vble2 == "Disagreeableness"
	bysort paper_id (variable): egen has_agreeableness = max(agreeableness_tag)

	** Tag if the variable is "Extraversion"
	gen extraversion_tag = 1 if vble2 == "Extraversion"
	bysort paper_id (variable): egen has_extraversion = max(extraversion_tag)

	** Tag if the variable is "Neuroticism"
	gen neuroticism_tag = 1 if vble2 == "Emotional Stability"
	bysort paper_id (variable): egen has_neuroticism = max(neuroticism_tag)

	** Create the "complete" variable
	gen complete = (has_openness == 1 & has_conscientiousness == 1 & has_agreeableness == 1 & has_extraversion == 1 & has_neuroticism == 1)

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
* 3. Heterogeneity 
*******************************************************************************

* Define grouping variables
local groups "group1 group2 group3 group4 group5 group6"

replace methodology = "2" if methodology == "2,3"

* Create grouping variables
gen group1 = type
gen group2 = vble2 if type == "Big Five"
gen group3 = educ_control if inlist(type, "Big Five")
gen group4 = inc_class if inlist(type, "Big Five")
gen group5 = sample_popn if inlist(sample_popn, "Male", "Female")
gen group6 = methodology if inlist(type, "Big Five")

*******************************************************************************
* 4. Run Meta-Analysis (RE) and Export Group Results
*******************************************************************************

* Create Excel sheet and set up headers
putexcel set "${temp}/Pooled_Estimates_RE_Big5.xlsx", replace sheet("Sheet1")
putexcel A1 = "Group" B1 = "Subgroup" C1 = "Theta" ///
         D1 = "SE" E1 = "p-value" F1 = "N"
local row = 2

* Apply value labels to grouping variables 
label var group1 "Skill type"
label var group2 "Big Five"
label var group3 "Education"
label var group4 "Income level"
label var group5 "Gender"
label var group6 "Methodology"

* Loop over each group
local groups "group1 group2 group3 group4 group5 group6"
foreach group of local groups {

    * Get the label of the group
    local group_label : variable label `group'

    * Get the distinct values for the current group
    levelsof `group', local(subgroups)

    * Loop through each subgroup within the current group
    foreach subgroup of local subgroups {

        * Run the meta-analysis for the current subgroup
        quietly meta summarize if `group' == "`subgroup'"
        if _rc != 0 continue  // Skip problematic subgroups 

        * Store the results for the current subgroup
        local theta = r(theta)
        local se = r(se)
        local N = r(N)
        local z = `theta' / `se'
        local pval = 2 * (1 - normal(abs(`z')))

        * Export all results to Sheet1
        putexcel set "${temp}/Pooled_Estimates_RE_Big5.xlsx", ///
            modify sheet("Sheet1")
        putexcel A`row' = "`group_label'" B`row' = "`subgroup'" ///
            C`row' = `theta' D`row' = `se' E`row' = `pval' F`row' = `N'
        local row = `row' + 1
    }
}

* End of do-file **************************************************************	

