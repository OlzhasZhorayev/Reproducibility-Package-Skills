
* Load Data
do "Setup.do"
import excel "${data}\Training_data_clean.xlsx", sheet("Database") firstrow clear

*******************************************************************************
* 1. Recode BigFive and Variable Categories 
*******************************************************************************

* Recode BigFive
replace BigFive = BigFiveeducation if missing(BigFive)

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
* 2. Check Variables
*******************************************************************************

tab Schoollevel
tab BigFive Schoollevel, col

tab Learningenvironment	// Setting: classroom or outside
tab BigFive Learningenvironment, col

tab Facilitator 		// Instructor
tab BigFive Facilitator, col

tab Targeting 
tab BigFive Targeting, col

tab Technologyenhanced 
tab BigFive Technologyenhanced, col

tab Trainingduration
tab BigFive Trainingduration, col

tab Evaluation			// Time
tab BigFive Evaluation, col

*******************************************************************************
* 3. Descriptive Statistics, Socio-Emotional Skill Training Programs
*******************************************************************************

* Percent formatter (2 decimals)
capture program drop _pctstr
program define _pctstr, rclass
    syntax , NUM(integer) DEN(integer)
    if (`den'==0) return local s ""
    else {
        local p = 100*(`num'/`den')
        local p = round(`p', 0.01)
        return local s : display %9.2f `p'
    }
end

* Create string variables 
capture drop BigFive_s Schoollevel_s Learningenvironment_s Facilitator_s Targeting_s Technologyenhanced_s 

capture confirm numeric variable BigFive
if _rc==0  decode BigFive, gen(BigFive_s)
else       gen str120 BigFive_s = BigFive

capture confirm numeric variable Schoollevel
if _rc==0  decode Schoollevel, gen(Schoollevel_s)
else       gen str120 Schoollevel_s = Schoollevel

capture confirm numeric variable Learningenvironment
if _rc==0  decode Learningenvironment, gen(Learningenvironment_s)
else       gen str120 Learningenvironment_s = Learningenvironment

capture confirm numeric variable Facilitator
if _rc==0  decode Facilitator, gen(Facilitator_s)
else       gen str120 Facilitator_s = Facilitator

capture confirm numeric variable Targeting
if _rc==0  decode Targeting, gen(Targeting_s)
else       gen str120 Targeting_s = Targeting

capture confirm numeric variable Technologyenhanced
if _rc==0  decode Technologyenhanced, gen(Technologyenhanced_s)
else       gen str120 Technologyenhanced_s = Technologyenhanced

* Column definitions (fixed order)

local BF1 "Disagreeableness"
local BF2 "Conscientiousness"
local BF3 "Emotional stability"
local BF4 "Extraversion"
local BF5 "Openness"
local BF6 "Multiple"

quietly count if !missing(BigFive_s) /// Number of BigFive estimates only 
	& Groupingvariable == "Overall"  // for 61 overall estimates
local N_overall = r(N)

quietly count if BigFive_s=="`BF1'" & Groupingvariable == "Overall"
local N1 = r(N)
quietly count if BigFive_s=="`BF2'" & Groupingvariable == "Overall"
local N2 = r(N)
quietly count if BigFive_s=="`BF3'" & Groupingvariable == "Overall"
local N3 = r(N)
quietly count if BigFive_s=="`BF4'" & Groupingvariable == "Overall"
local N4 = r(N)
quietly count if BigFive_s=="`BF5'" & Groupingvariable == "Overall"
local N5 = r(N)
quietly count if BigFive_s=="`BF6'" & Groupingvariable == "Overall"
local N6 = r(N)

* Build Table 4

capture postclose T4
capture postutil clear
tempfile t4

postfile T4 str70 Row str12 Overall str12 Disagreeableness str12 Conscientiousness str12 Emotional_stability ///
               str12 Extraversion str12 Openness str12 Multiple using `t4', replace

* Overall (N)
post T4 ("Overall (N)") ("`N_overall'") ("`N1'") ("`N2'") ("`N3'") ("`N4'") ("`N5'") ("`N6'")

* Grade level (N) + (%)

quietly count if !missing(Schoollevel_s)
local N_edu = r(N)

quietly count if !missing(Schoollevel_s) & BigFive_s=="`BF1'"
local N1e = r(N)
quietly count if !missing(Schoollevel_s) & BigFive_s=="`BF2'"
local N2e = r(N)
quietly count if !missing(Schoollevel_s) & BigFive_s=="`BF3'"
local N3e = r(N)
quietly count if !missing(Schoollevel_s) & BigFive_s=="`BF4'"
local N4e = r(N)
quietly count if !missing(Schoollevel_s) & BigFive_s=="`BF5'"
local N5e = r(N)
quietly count if !missing(Schoollevel_s) & BigFive_s=="`BF6'"
local N6e = r(N)

*post T4 ("Grade level (N)") ("`N_edu'") ("`N1e'") ("`N2e'") ("`N3e'") ("`N4e'") ("`N5e'") ("`N6e'")
post T4 ("Grade level (%)") ("") ("") ("") ("") ("") ("") ("")

levelsof Schoollevel_s if !missing(Schoollevel_s), local(SL_levels)
foreach sl of local SL_levels {
    quietly count if Schoollevel_s=="`sl'"
    local n_all = r(N)
    quietly _pctstr, num(`n_all') den(`N_edu')
    local p_all `r(s)'

    quietly count if Schoollevel_s=="`sl'" & BigFive_s=="`BF1'"
    local n1 = r(N)
    quietly _pctstr, num(`n1') den(`N1e')
    local p1 `r(s)'

    quietly count if Schoollevel_s=="`sl'" & BigFive_s=="`BF2'"
    local n2 = r(N)
    quietly _pctstr, num(`n2') den(`N2e')
    local p2 `r(s)'

    quietly count if Schoollevel_s=="`sl'" & BigFive_s=="`BF3'"
    local n3 = r(N)
    quietly _pctstr, num(`n3') den(`N3e')
    local p3 `r(s)'

    quietly count if Schoollevel_s=="`sl'" & BigFive_s=="`BF4'"
    local n4 = r(N)
    quietly _pctstr, num(`n4') den(`N4e')
    local p4 `r(s)'

    quietly count if Schoollevel_s=="`sl'" & BigFive_s=="`BF5'"
    local n5 = r(N)
    quietly _pctstr, num(`n5') den(`N5e')
    local p5 `r(s)'

    quietly count if Schoollevel_s=="`sl'" & BigFive_s=="`BF6'"
    local n6 = r(N)
    quietly _pctstr, num(`n6') den(`N6e')
    local p6 `r(s)'

    post T4 ("  `sl'") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'") ("`p6'")
}

* Setting (N) + (%)

quietly count if !missing(Learningenvironment_s)
local N_set = r(N)

quietly count if !missing(Learningenvironment_s) & BigFive_s=="`BF1'"
local N1s = r(N)
quietly count if !missing(Learningenvironment_s) & BigFive_s=="`BF2'"
local N2s = r(N)
quietly count if !missing(Learningenvironment_s) & BigFive_s=="`BF3'"
local N3s = r(N)
quietly count if !missing(Learningenvironment_s) & BigFive_s=="`BF4'"
local N4s = r(N)
quietly count if !missing(Learningenvironment_s) & BigFive_s=="`BF5'"
local N5s = r(N)
quietly count if !missing(Learningenvironment_s) & BigFive_s=="`BF6'"
local N6s = r(N)

*post T4 ("Setting (N)") ("`N_set'") ("`N1s'") ("`N2s'") ("`N3s'") ("`N4s'") ("`N5s'") ("`N6s'")
post T4 ("Setting (%)") ("") ("") ("") ("") ("") ("") ("")

levelsof Learningenvironment_s if !missing(Learningenvironment_s), local(LE_levels)
foreach le of local LE_levels {
    quietly count if Learningenvironment_s=="`le'"
    local n_all = r(N)
    quietly _pctstr, num(`n_all') den(`N_set')
    local p_all `r(s)'

    quietly count if Learningenvironment_s=="`le'" & BigFive_s=="`BF1'"
    local n1 = r(N)
    quietly _pctstr, num(`n1') den(`N1s')
    local p1 `r(s)'

    quietly count if Learningenvironment_s=="`le'" & BigFive_s=="`BF2'"
    local n2 = r(N)
    quietly _pctstr, num(`n2') den(`N2s')
    local p2 `r(s)'

    quietly count if Learningenvironment_s=="`le'" & BigFive_s=="`BF3'"
    local n3 = r(N)
    quietly _pctstr, num(`n3') den(`N3s')
    local p3 `r(s)'

    quietly count if Learningenvironment_s=="`le'" & BigFive_s=="`BF4'"
    local n4 = r(N)
    quietly _pctstr, num(`n4') den(`N4s')
    local p4 `r(s)'

    quietly count if Learningenvironment_s=="`le'" & BigFive_s=="`BF5'"
    local n5 = r(N)
    quietly _pctstr, num(`n5') den(`N5s')
    local p5 `r(s)'

    quietly count if Learningenvironment_s=="`le'" & BigFive_s=="`BF6'"
    local n6 = r(N)
    quietly _pctstr, num(`n6') den(`N6s')
    local p6 `r(s)'

    post T4 ("  `le'") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'") ("`p6'")
}

* Instructor (N) + (%)

quietly count if !missing(Facilitator_s)
local N_inst = r(N)

quietly count if !missing(Facilitator_s) & BigFive_s=="`BF1'"
local N1i = r(N)
quietly count if !missing(Facilitator_s) & BigFive_s=="`BF2'"
local N2i = r(N)
quietly count if !missing(Facilitator_s) & BigFive_s=="`BF3'"
local N3i = r(N)
quietly count if !missing(Facilitator_s) & BigFive_s=="`BF4'"
local N4i = r(N)
quietly count if !missing(Facilitator_s) & BigFive_s=="`BF5'"
local N5i = r(N)
quietly count if !missing(Facilitator_s) & BigFive_s=="`BF6'"
local N6i = r(N)

*post T4 ("Instructor (N)") ("`N_inst'") ("`N1i'") ("`N2i'") ("`N3i'") ("`N4i'") ("`N5i'") ("`N6i'")
post T4 ("Instructor (%)") ("") ("") ("") ("") ("") ("") ("")

levelsof Facilitator_s if !missing(Facilitator_s), local(FAC_levels)
foreach f of local FAC_levels {
    quietly count if Facilitator_s=="`f'"
    local n_all = r(N)
    quietly _pctstr, num(`n_all') den(`N_inst')
    local p_all `r(s)'

    quietly count if Facilitator_s=="`f'" & BigFive_s=="`BF1'"
    local n1 = r(N)
    quietly _pctstr, num(`n1') den(`N1i')
    local p1 `r(s)'

    quietly count if Facilitator_s=="`f'" & BigFive_s=="`BF2'"
    local n2 = r(N)
    quietly _pctstr, num(`n2') den(`N2i')
    local p2 `r(s)'

    quietly count if Facilitator_s=="`f'" & BigFive_s=="`BF3'"
    local n3 = r(N)
    quietly _pctstr, num(`n3') den(`N3i')
    local p3 `r(s)'

    quietly count if Facilitator_s=="`f'" & BigFive_s=="`BF4'"
    local n4 = r(N)
    quietly _pctstr, num(`n4') den(`N4i')
    local p4 `r(s)'

    quietly count if Facilitator_s=="`f'" & BigFive_s=="`BF5'"
    local n5 = r(N)
    quietly _pctstr, num(`n5') den(`N5i')
    local p5 `r(s)'

    quietly count if Facilitator_s=="`f'" & BigFive_s=="`BF6'"
    local n6 = r(N)
    quietly _pctstr, num(`n6') den(`N6i')
    local p6 `r(s)'

    post T4 ("  `f'") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'") ("`p6'")
}

* Targeting (N) + (%)

quietly count if !missing(Targeting_s)
local N_tar = r(N)

quietly count if !missing(Targeting_s) & BigFive_s=="`BF1'"
local N1t = r(N)
quietly count if !missing(Targeting_s) & BigFive_s=="`BF2'"
local N2t = r(N)
quietly count if !missing(Targeting_s) & BigFive_s=="`BF3'"
local N3t = r(N)
quietly count if !missing(Targeting_s) & BigFive_s=="`BF4'"
local N4t = r(N)
quietly count if !missing(Targeting_s) & BigFive_s=="`BF5'"
local N5t = r(N)
quietly count if !missing(Targeting_s) & BigFive_s=="`BF6'"
local N6t = r(N)

*post T4 ("Targeting (N)") ("`N_tar'") ("`N1t'") ("`N2t'") ("`N3t'") ("`N4t'") ("`N5t'") ("`N6t'")
post T4 ("Targeting (%)") ("") ("") ("") ("") ("") ("") ("")

levelsof Targeting_s if !missing(Targeting_s), local(TAR_levels)
foreach t of local TAR_levels {
    quietly count if Targeting_s=="`t'"
    local n_all = r(N)
    quietly _pctstr, num(`n_all') den(`N_tar')
    local p_all `r(s)'

    quietly count if Targeting_s=="`t'" & BigFive_s=="`BF1'"
    local n1 = r(N)
    quietly _pctstr, num(`n1') den(`N1t')
    local p1 `r(s)'

    quietly count if Targeting_s=="`t'" & BigFive_s=="`BF2'"
    local n2 = r(N)
    quietly _pctstr, num(`n2') den(`N2t')
    local p2 `r(s)'

    quietly count if Targeting_s=="`t'" & BigFive_s=="`BF3'"
    local n3 = r(N)
    quietly _pctstr, num(`n3') den(`N3t')
    local p3 `r(s)'

    quietly count if Targeting_s=="`t'" & BigFive_s=="`BF4'"
    local n4 = r(N)
    quietly _pctstr, num(`n4') den(`N4t')
    local p4 `r(s)'

    quietly count if Targeting_s=="`t'" & BigFive_s=="`BF5'"
    local n5 = r(N)
    quietly _pctstr, num(`n5') den(`N5t')
    local p5 `r(s)'

    quietly count if Targeting_s=="`t'" & BigFive_s=="`BF6'"
    local n6 = r(N)
    quietly _pctstr, num(`n6') den(`N6t')
    local p6 `r(s)'

    post T4 ("  `t'") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'") ("`p6'")
}

* Technology (N) + (%)

quietly count if !missing(Technologyenhanced_s)
local N_tech = r(N)

quietly count if !missing(Technologyenhanced_s) & BigFive_s=="`BF1'"
local N1x = r(N)
quietly count if !missing(Technologyenhanced_s) & BigFive_s=="`BF2'"
local N2x = r(N)
quietly count if !missing(Technologyenhanced_s) & BigFive_s=="`BF3'"
local N3x = r(N)
quietly count if !missing(Technologyenhanced_s) & BigFive_s=="`BF4'"
local N4x = r(N)
quietly count if !missing(Technologyenhanced_s) & BigFive_s=="`BF5'"
local N5x = r(N)
quietly count if !missing(Technologyenhanced_s) & BigFive_s=="`BF6'"
local N6x = r(N)

*post T4 ("Technology (N)") ("`N_tech'") ("`N1x'") ("`N2x'") ("`N3x'") ("`N4x'") ("`N5x'") ("`N6x'")
post T4 ("Technology (%)") ("") ("") ("") ("") ("") ("") ("")

levelsof Technologyenhanced_s if !missing(Technologyenhanced_s), local(TECH_levels)
foreach tt of local TECH_levels {
    quietly count if Technologyenhanced_s=="`tt'"
    local n_all = r(N)
    quietly _pctstr, num(`n_all') den(`N_tech')
    local p_all `r(s)'

    quietly count if Technologyenhanced_s=="`tt'" & BigFive_s=="`BF1'"
    local n1 = r(N)
    quietly _pctstr, num(`n1') den(`N1x')
    local p1 `r(s)'

    quietly count if Technologyenhanced_s=="`tt'" & BigFive_s=="`BF2'"
    local n2 = r(N)
    quietly _pctstr, num(`n2') den(`N2x')
    local p2 `r(s)'

    quietly count if Technologyenhanced_s=="`tt'" & BigFive_s=="`BF3'"
    local n3 = r(N)
    quietly _pctstr, num(`n3') den(`N3x')
    local p3 `r(s)'

    quietly count if Technologyenhanced_s=="`tt'" & BigFive_s=="`BF4'"
    local n4 = r(N)
    quietly _pctstr, num(`n4') den(`N4x')
    local p4 `r(s)'

    quietly count if Technologyenhanced_s=="`tt'" & BigFive_s=="`BF5'"
    local n5 = r(N)
    quietly _pctstr, num(`n5') den(`N5x')
    local p5 `r(s)'

    quietly count if Technologyenhanced_s=="`tt'" & BigFive_s=="`BF6'"
    local n6 = r(N)
    quietly _pctstr, num(`n6') den(`N6x')
    local p6 `r(s)'

    post T4 ("  `tt'") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'") ("`p6'")
}

postclose T4
use `t4', clear

* Export, blank A1 and set Excel headers
export excel using "${tables}/Table3_DescriptiveStats_Training.xlsx", firstrow(variables) replace
putexcel set "${tables}/Table3_DescriptiveStats_Training.xlsx", modify
putexcel A1 = ""
putexcel B1 = "Overall"
putexcel C1 = "Disagreeableness"
putexcel D1 = "Conscientiousness"
putexcel E1 = "Emotional stability"
putexcel F1 = "Extraversion"
putexcel G1 = "Openness"
putexcel H1 = "Multiple"

* End of do-file **************************************************************	





