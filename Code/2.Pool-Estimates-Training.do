
* Load data
import excel "${data}\Training_data_clean.xlsx", sheet("Database") firstrow clear

*******************************************************************************
* 1. Descriptive Statistics
*******************************************************************************

tab Schoollevel
tab BigFive Schoollevel, col
tab Learningenvironment Schoollevel, col 	// Setting: classroom or outside
tab Learningenvironment
tab Facilitator Schoollevel, col 			// Instructor
tab Facilitator
tab Targeting Schoollevel, col
tab Technologyenhanced Schoollevel, col
tab Trainingduration Schoollevel, col
tab Trainingduration
tab Evaluation Schoollevel, col				// Time

*******************************************************************************
* 2. Set Meta Variables
*******************************************************************************

replace ES = abs(ES)
meta set ES SE, studylabel(Filename)

*******************************************************************************
* 3. Recode Variable Categories 
*******************************************************************************

* Recode Agreeableness
replace BigFive = "Disagreeableness" if BigFive == "Agreeableness"

* Recode School level categories
replace Schoollevel = "Pre-K" if Schoollevel == "PE"
replace Schoollevel = "Primary" if Schoollevel == "ES"
replace Schoollevel = "Secondary" if Schoollevel == "HS"
replace Schoollevel = "Post-secondary" if Schoollevel == "PS"

*******************************************************************************
* 4. Heterogeneity 
*******************************************************************************

* Define grouping variables
local groups "group1 group2 group3 group4 group5 group6 group7 group8 group9"

* Generate grouping variables
gen overall = "Overall effect" if Groupingvariable == "Overall"
gen group1 = overall
gen group2 = BigFive
gen group3 = Schoollevel
gen group4 = Learningenvironment
gen group5 = Facilitator
gen group6 = Targeting 
gen group7 = Technologyenhanced
gen group8 = Trainingduration  
gen group9 = Evaluation  

*******************************************************************************
* 5. Export Group Results 
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
label var group8 "Duration"
label var group9 "Time"

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





