
* Load data
do "Setup.do"
import excel "${data}\Training_data_clean.xlsx", sheet("Database") firstrow clear

*******************************************************************************
* 1. Set Meta Variables
*******************************************************************************

replace ES = abs(ES)
meta set ES SE, studylabel(Filename)

*******************************************************************************
* 2. Recode Variable Categories 
*******************************************************************************

* Recode Agreeableness
replace BigFive = "Disagreeableness" if BigFive == "Agreeableness"

* Recode School level categories
replace Schoollevel = "Pre-K" if Schoollevel == "PE"
replace Schoollevel = "Primary" if Schoollevel == "ES"
replace Schoollevel = "Secondary" if Schoollevel == "HS"
replace Schoollevel = "Post-secondary" if Schoollevel == "PS"

* Merge School level categories
replace Schoollevel = "Primary or less" ///
	if Schoollevel == "Pre-K" | Schoollevel == "Primary" 
replace Schoollevel = "Post-secondary" ///
	if Schoollevel == "Post-secondary" | Schoollevel == "Out of school" 

* Assign Big Five classification
replace BigFive = "Openness" ///
	if Groupingvariable == "Overall" & missing(BigFive)	
replace BigFive = "" ///
	if Groupingvariable == "Design" & Evaluation == "Follow-up"	
replace BigFive = "Openness" if !missing(Learningenvironment) & No == 3	
replace BigFive = "Extraversion" if !missing(Learningenvironment) & No == 38	
replace BigFive = "Conscientiousness" ///
	if !missing(Learningenvironment) & No == 51	
replace BigFive = "Disagreeableness" if !missing(Facilitator) & No == 16	
replace BigFive = "Multiple" if !missing(Facilitator) & No == 29	
replace BigFive = "Multiple" if !missing(Facilitator) & No == 35 
replace BigFive = "Multiple" if !missing(Facilitator) & No == 38
replace BigFive = "Conscientiousness" if !missing(Facilitator) & No == 48	
replace BigFive = "Openness" if !missing(Targeting) & No == 1	
replace BigFive = "Openness" if !missing(Targeting) & No == 3	
replace BigFive = "Multiple" if !missing(Targeting) & No == 29	
replace BigFive = "Extraversion" if !missing(Targeting) & No == 31
replace BigFive = "Conscientiousness" if !missing(Targeting) & No == 51	
	
*******************************************************************************
* 3. Heterogeneity 
*******************************************************************************

* Define grouping variables
local groups "group1 group2 group3 group4 group5 group6 group7"

* Generate grouping variables
gen overall = "Overall effect" if Groupingvariable == "Overall"
gen group1 = overall
gen group2 = BigFive if Groupingvariable == "Overall"
gen group3 = Schoollevel
gen group4 = Learningenvironment
gen group5 = Facilitator
gen group6 = Targeting 
gen group7 = Technologyenhanced

*******************************************************************************
* 4. Run Meta-Analysis and Export Group Results 
*******************************************************************************
      
* Create Excel sheets and set up headers for both sheets

putexcel set "${temp}/Pooled_Estimates_Training.xlsx", replace sheet("Sheet1")
putexcel A1 = "Group" B1 = "Subgroup" C1 = "Theta" ///
		 D1 = "SE" E1 = "p-value" F1 = "N"
local row1 = 2

putexcel set "${temp}/Pooled_Estimates_Training.xlsx", modify sheet("Sheet2")
putexcel A1 = "Group" B1 = "Subgroup" C1 = "Theta" ///
		 D1 = "SE" E1 = "p-value" F1 = "N"
local row2 = 2

* Apply value labels to grouping variables 
label var group1 "Main"
label var group2 "Big Five"
label var group3 "Grade level"
label var group4 "Setting"
label var group5 "Instructor"
label var group6 "Targeting"
label var group7 "Technology"

* Loop over each group
local groups "group1 group2 group3 group4 group5 group6 group7 group8 group9"
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

        * Allocate group1 to Sheet1 and others to Sheet2
        if "`group'" == "group1" {
            putexcel set "${temp}/Pooled_Estimates_Training.xlsx", ///
				modify sheet("Sheet1")
            putexcel A`row1' = "`group_label'" B`row1' = "`subgroup'" ///
                C`row1' = `theta' D`row1' = `se' E`row1' = `pval' F`row1' = `N'
            local row1 = `row1' + 1
        }
        else {
            putexcel set "${temp}/Pooled_Estimates_Training.xlsx", ///
			modify sheet("Sheet2")
            putexcel A`row2' = "`group_label'" B`row2' = "`subgroup'" ///
                C`row2' = `theta' D`row2' = `se' E`row2' = `pval' F`row2' = `N'
            local row2 = `row2' + 1
        }
    }
}

* End of do-file **************************************************************	





