
* Load Data
do "Setup.do"
import excel "${data}\Training_data_clean.xlsx", sheet("Database") firstrow clear

*******************************************************************************
* 1. Check Variables
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
* 2. Recode Variable Categories 
*******************************************************************************

* Recode Agreeableness
replace BigFive = "Disagreeableness" if BigFive == "Agreeableness"

* Recode School level categories
replace Schoollevel = "Pre-K" if Schoollevel == "PE"
replace Schoollevel = "Primary" if Schoollevel == "ES"
replace Schoollevel = "Secondary" if Schoollevel == "HS"
replace Schoollevel = "Post-secondary" if Schoollevel == "PS"

*******************************************************************************
* 3. Table 4: Descriptive Statistics, Socio-Emotional Skill Training Programs
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
capture drop BigFive_s Schoollevel_s Learningenvironment_s Facilitator_s Targeting_s Technologyenhanced_s Trainingduration_s Evaluation_s

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

capture confirm numeric variable Trainingduration
if _rc==0  decode Trainingduration, gen(Trainingduration_s)
else       gen str120 Trainingduration_s = Trainingduration

capture confirm numeric variable Evaluation
if _rc==0  decode Evaluation, gen(Evaluation_s)
else       gen str120 Evaluation_s = Evaluation

* Column definitions (fixed order)

local BF1 "Disagreeableness"
local BF2 "Conscientiousness"
local BF3 "Emotional stability"
local BF4 "Extraversion"
local BF5 "Openness"
local BF6 "Multiple"

quietly count
local N_overall = r(N)

quietly count if BigFive_s=="`BF1'"
local N1 = r(N)
quietly count if BigFive_s=="`BF2'"
local N2 = r(N)
quietly count if BigFive_s=="`BF3'"
local N3 = r(N)
quietly count if BigFive_s=="`BF4'"
local N4 = r(N)
quietly count if BigFive_s=="`BF5'"
local N5 = r(N)
quietly count if BigFive_s=="`BF6'"
local N6 = r(N)

* Build Table 4

capture postclose T4
capture postutil clear
tempfile t4

postfile T4 str70 Row str12 Overall str12 Disagreeableness str12 Conscientiousness str12 Emotional_stability ///
               str12 Extraversion str12 Openness str12 Multiple using `t4', replace

* Overall (N)
post T4 ("Overall (N)") ("`N_overall'") ("`N1'") ("`N2'") ("`N3'") ("`N4'") ("`N5'") ("`N6'")

* Education estimates (N) + Schoollevel (%)

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

post T4 ("Education estimates (N)") ("`N_edu'") ("`N1e'") ("`N2e'") ("`N3e'") ("`N4e'") ("`N5e'") ("`N6e'")

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

    post T4 ("  `sl' (%)") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'") ("`p6'")
}

* Setting estimates (N) + Learningenvironment (%)

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

post T4 ("Setting estimates (N)") ("`N_set'") ("`N1s'") ("`N2s'") ("`N3s'") ("`N4s'") ("`N5s'") ("`N6s'")

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

    post T4 ("  `le' (%)") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'") ("`p6'")
}

* Instructor type (N) + Facilitator (%)

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

post T4 ("Instructor type (N)") ("`N_inst'") ("`N1i'") ("`N2i'") ("`N3i'") ("`N4i'") ("`N5i'") ("`N6i'")

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

    post T4 ("  `f' (%)") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'") ("`p6'")
}

* Targeting (N) + Targeting (%)

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

post T4 ("Targeting (N)") ("`N_tar'") ("`N1t'") ("`N2t'") ("`N3t'") ("`N4t'") ("`N5t'") ("`N6t'")

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

    post T4 ("  `t' (%)") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'") ("`p6'")
}

* Technology enhanced (N) + Technologyenhanced (%)

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

post T4 ("Technology enhanced (N)") ("`N_tech'") ("`N1x'") ("`N2x'") ("`N3x'") ("`N4x'") ("`N5x'") ("`N6x'")

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

    post T4 ("  `tt' (%)") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'") ("`p6'")
}

* Training duration (N) + Trainingduration (%)

quietly count if !missing(Trainingduration_s)
local N_dur = r(N)

quietly count if !missing(Trainingduration_s) & BigFive_s=="`BF1'"
local N1d = r(N)
quietly count if !missing(Trainingduration_s) & BigFive_s=="`BF2'"
local N2d = r(N)
quietly count if !missing(Trainingduration_s) & BigFive_s=="`BF3'"
local N3d = r(N)
quietly count if !missing(Trainingduration_s) & BigFive_s=="`BF4'"
local N4d = r(N)
quietly count if !missing(Trainingduration_s) & BigFive_s=="`BF5'"
local N5d = r(N)
quietly count if !missing(Trainingduration_s) & BigFive_s=="`BF6'"
local N6d = r(N)

post T4 ("Training duration (N)") ("`N_dur'") ("`N1d'") ("`N2d'") ("`N3d'") ("`N4d'") ("`N5d'") ("`N6d'")

levelsof Trainingduration_s if !missing(Trainingduration_s), local(DUR_levels)
foreach d of local DUR_levels {
    quietly count if Trainingduration_s=="`d'"
    local n_all = r(N)
    quietly _pctstr, num(`n_all') den(`N_dur')
    local p_all `r(s)'

    quietly count if Trainingduration_s=="`d'" & BigFive_s=="`BF1'"
    local n1 = r(N)
    quietly _pctstr, num(`n1') den(`N1d')
    local p1 `r(s)'

    quietly count if Trainingduration_s=="`d'" & BigFive_s=="`BF2'"
    local n2 = r(N)
    quietly _pctstr, num(`n2') den(`N2d')
    local p2 `r(s)'

    quietly count if Trainingduration_s=="`d'" & BigFive_s=="`BF3'"
    local n3 = r(N)
    quietly _pctstr, num(`n3') den(`N3d')
    local p3 `r(s)'

    quietly count if Trainingduration_s=="`d'" & BigFive_s=="`BF4'"
    local n4 = r(N)
    quietly _pctstr, num(`n4') den(`N4d')
    local p4 `r(s)'

    quietly count if Trainingduration_s=="`d'" & BigFive_s=="`BF5'"
    local n5 = r(N)
    quietly _pctstr, num(`n5') den(`N5d')
    local p5 `r(s)'

    quietly count if Trainingduration_s=="`d'" & BigFive_s=="`BF6'"
    local n6 = r(N)
    quietly _pctstr, num(`n6') den(`N6d')
    local p6 `r(s)'

    post T4 ("  `d' (%)") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'") ("`p6'")
}

* Evaluation timing (N) + Evaluation (%)

quietly count if !missing(Evaluation_s)
local N_eval = r(N)

quietly count if !missing(Evaluation_s) & BigFive_s=="`BF1'"
local N1v = r(N)
quietly count if !missing(Evaluation_s) & BigFive_s=="`BF2'"
local N2v = r(N)
quietly count if !missing(Evaluation_s) & BigFive_s=="`BF3'"
local N3v = r(N)
quietly count if !missing(Evaluation_s) & BigFive_s=="`BF4'"
local N4v = r(N)
quietly count if !missing(Evaluation_s) & BigFive_s=="`BF5'"
local N5v = r(N)
quietly count if !missing(Evaluation_s) & BigFive_s=="`BF6'"
local N6v = r(N)

post T4 ("Evaluation timing (N)") ("`N_eval'") ("`N1v'") ("`N2v'") ("`N3v'") ("`N4v'") ("`N5v'") ("`N6v'")

levelsof Evaluation_s if !missing(Evaluation_s), local(EVAL_levels)
foreach e of local EVAL_levels {
    quietly count if Evaluation_s=="`e'"
    local n_all = r(N)
    quietly _pctstr, num(`n_all') den(`N_eval')
    local p_all `r(s)'

    quietly count if Evaluation_s=="`e'" & BigFive_s=="`BF1'"
    local n1 = r(N)
    quietly _pctstr, num(`n1') den(`N1v')
    local p1 `r(s)'

    quietly count if Evaluation_s=="`e'" & BigFive_s=="`BF2'"
    local n2 = r(N)
    quietly _pctstr, num(`n2') den(`N2v')
    local p2 `r(s)'

    quietly count if Evaluation_s=="`e'" & BigFive_s=="`BF3'"
    local n3 = r(N)
    quietly _pctstr, num(`n3') den(`N3v')
    local p3 `r(s)'

    quietly count if Evaluation_s=="`e'" & BigFive_s=="`BF4'"
    local n4 = r(N)
    quietly _pctstr, num(`n4') den(`N4v')
    local p4 `r(s)'

    quietly count if Evaluation_s=="`e'" & BigFive_s=="`BF5'"
    local n5 = r(N)
    quietly _pctstr, num(`n5') den(`N5v')
    local p5 `r(s)'

    quietly count if Evaluation_s=="`e'" & BigFive_s=="`BF6'"
    local n6 = r(N)
    quietly _pctstr, num(`n6') den(`N6v')
    local p6 `r(s)'

    post T4 ("  `e' (%)") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'") ("`p6'")
}

postclose T4
use `t4', clear

export excel using "${tables}/Table4_DescriptiveStats_Training.xlsx", firstrow(variables) replace
putexcel set "${tables}/Table4_DescriptiveStats_Training.xlsx", modify
putexcel A1 = ""
putexcel B1 = "Overall"
putexcel C1 = "Disagreeableness"
putexcel D1 = "Conscientiousness"
putexcel E1 = "Emotional stability"
putexcel F1 = "Extraversion"
putexcel G1 = "Openness"
putexcel H1 = "Multiple"

* End of do-file **************************************************************	





