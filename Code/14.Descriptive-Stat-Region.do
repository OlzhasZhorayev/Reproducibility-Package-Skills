
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
* 2. Table A3: Descriptive Statistics, Labor Returns Analysis by Region
*******************************************************************************

* Region recode (handles hidden chars/spacing/variants)
tempvar region_clean reg5
gen str120 `region_clean' = ustrtrim(ustrregexra(region, "\s+", " "))
gen str40  `reg5' = ""

replace `reg5' = "Africa"        if regexm(ustrlower(`region_clean'), "africa")
replace `reg5' = "Asia"          if regexm(ustrlower(`region_clean'), "asia")
replace `reg5' = "Europe"        if regexm(ustrlower(`region_clean'), "europe")
replace `reg5' = "Latin America" if regexm(ustrlower(`region_clean'), "latin")
replace `reg5' = "North America" if regexm(ustrlower(`region_clean'), "north")

* If anything didn't get classified, keep original
replace `reg5' = `region_clean' if missing(`reg5')

* Quick check: should show 5 groups
* tab `reg5', missing

* Denominators (N)
quietly count
local N_all = r(N)

quietly count if `reg5'=="Africa"
local N1 = r(N)
quietly count if `reg5'=="Asia"
local N2 = r(N)
quietly count if `reg5'=="Europe"
local N3 = r(N)
quietly count if `reg5'=="Latin America"
local N4 = r(N)
quietly count if `reg5'=="North America"
local N5 = r(N)

* Percent formatter (1 decimal)
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

* Decode Gender to string
tempvar gender_str
capture confirm numeric variable gender
if _rc==0 {
    decode gender, gen(`gender_str')
}
else {
    gen str30 `gender_str' = gender
}

* Build Table A3
capture postclose TA3
capture postutil clear

tempfile ta3
postfile TA3 str70 Row str12 Overall str12 Africa str12 Asia str12 Europe str12 Latin_America str12 North_America ///
    using `ta3', replace

post TA3 ("Number of estimates") ("`N_all'") ("`N1'") ("`N2'") ("`N3'") ("`N4'") ("`N5'")

* ---------------- Estimate type (%)
post TA3 ("Estimate type (%)") ("") ("") ("") ("") ("") ("")
foreach v in "Big Five" "Cognitive Skills" {
    quietly count if type=="`v'"
    local n_all = r(N)
    quietly count if type=="`v'" & `reg5'=="Africa"
    local n1 = r(N)
    quietly count if type=="`v'" & `reg5'=="Asia"
    local n2 = r(N)
    quietly count if type=="`v'" & `reg5'=="Europe"
    local n3 = r(N)
    quietly count if type=="`v'" & `reg5'=="Latin America"
    local n4 = r(N)
    quietly count if type=="`v'" & `reg5'=="North America"
    local n5 = r(N)

    quietly _pctstr, num(`n_all') den(`N_all')
    local p_all `r(s)'
    quietly _pctstr, num(`n1') den(`N1')
    local p1 `r(s)'
    quietly _pctstr, num(`n2') den(`N2')
    local p2 `r(s)'
    quietly _pctstr, num(`n3') den(`N3')
    local p3 `r(s)'
    quietly _pctstr, num(`n4') den(`N4')
    local p4 `r(s)'
    quietly _pctstr, num(`n5') den(`N5')
    local p5 `r(s)'

    post TA3 ("  `v'") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'")
}

* ---------------- Education control (%)
post TA3 ("Education control (%)") ("") ("") ("") ("") ("") ("")
foreach v in "Controlled" "Not Controlled" {
    quietly count if educ_control=="`v'"
    local n_all = r(N)
    quietly count if educ_control=="`v'" & `reg5'=="Africa"
    local n1 = r(N)
    quietly count if educ_control=="`v'" & `reg5'=="Asia"
    local n2 = r(N)
    quietly count if educ_control=="`v'" & `reg5'=="Europe"
    local n3 = r(N)
    quietly count if educ_control=="`v'" & `reg5'=="Latin America"
    local n4 = r(N)
    quietly count if educ_control=="`v'" & `reg5'=="North America"
    local n5 = r(N)

    quietly _pctstr, num(`n_all') den(`N_all')
    local p_all `r(s)'
    quietly _pctstr, num(`n1') den(`N1')
    local p1 `r(s)'
    quietly _pctstr, num(`n2') den(`N2')
    local p2 `r(s)'
    quietly _pctstr, num(`n3') den(`N3')
    local p3 `r(s)'
    quietly _pctstr, num(`n4') den(`N4')
    local p4 `r(s)'
    quietly _pctstr, num(`n5') den(`N5')
    local p5 `r(s)'

    local lab = cond("`v'"=="Controlled","Yes","No")
    post TA3 ("  `lab'") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'")
}

* ---------------- Gender (%)
post TA3 ("Gender (%)") ("") ("") ("") ("") ("") ("")
foreach v in "Female" "Male" "Mixed" {
    quietly count if `gender_str'=="`v'"
    local n_all = r(N)
    quietly count if `gender_str'=="`v'" & `reg5'=="Africa"
    local n1 = r(N)
    quietly count if `gender_str'=="`v'" & `reg5'=="Asia"
    local n2 = r(N)
    quietly count if `gender_str'=="`v'" & `reg5'=="Europe"
    local n3 = r(N)
    quietly count if `gender_str'=="`v'" & `reg5'=="Latin America"
    local n4 = r(N)
    quietly count if `gender_str'=="`v'" & `reg5'=="North America"
    local n5 = r(N)

    quietly _pctstr, num(`n_all') den(`N_all')
    local p_all `r(s)'
    quietly _pctstr, num(`n1') den(`N1')
    local p1 `r(s)'
    quietly _pctstr, num(`n2') den(`N2')
    local p2 `r(s)'
    quietly _pctstr, num(`n3') den(`N3')
    local p3 `r(s)'
    quietly _pctstr, num(`n4') den(`N4')
    local p4 `r(s)'
    quietly _pctstr, num(`n5') den(`N5')
    local p5 `r(s)'

    post TA3 ("  `v'") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'")
}

* ---------------- Methodology (%)
post TA3 ("Methodology (%)") ("") ("") ("") ("") ("") ("")
foreach v in "OLS" "IV" {
    quietly count if methodology=="`v'"
    local n_all = r(N)
    quietly count if methodology=="`v'" & `reg5'=="Africa"
    local n1 = r(N)
    quietly count if methodology=="`v'" & `reg5'=="Asia"
    local n2 = r(N)
    quietly count if methodology=="`v'" & `reg5'=="Europe"
    local n3 = r(N)
    quietly count if methodology=="`v'" & `reg5'=="Latin America"
    local n4 = r(N)
    quietly count if methodology=="`v'" & `reg5'=="North America"
    local n5 = r(N)

    quietly _pctstr, num(`n_all') den(`N_all')
    local p_all `r(s)'
    quietly _pctstr, num(`n1') den(`N1')
    local p1 `r(s)'
    quietly _pctstr, num(`n2') den(`N2')
    local p2 `r(s)'
    quietly _pctstr, num(`n3') den(`N3')
    local p3 `r(s)'
    quietly _pctstr, num(`n4') den(`N4')
    local p4 `r(s)'
    quietly _pctstr, num(`n5') den(`N5')
    local p5 `r(s)'

    post TA3 ("  `v'") ("`p_all'") ("`p1'") ("`p2'") ("`p3'") ("`p4'") ("`p5'")
}

postclose TA3
use `ta3', clear

* Export, then blank A1 and set Excel headers
export excel using "${tables}/TableA3_DescriptiveStats_Region.xlsx", ///
	firstrow(variables) replace
putexcel set "${tables}/TableA3_DescriptiveStats_Region.xlsx", modify
putexcel A1 = ""
putexcel B1 = "Overall"
putexcel C1 = "Africa"
putexcel D1 = "Asia"
putexcel E1 = "Europe"
putexcel F1 = "Latin America"
putexcel G1 = "North America"

* End of do-file **************************************************************	


