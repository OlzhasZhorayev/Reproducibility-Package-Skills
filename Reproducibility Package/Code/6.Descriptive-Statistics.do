
* Load data
//use "${data}/Data_clean.dta", clear


use "C:\Users\wb627960\OneDrive - WBG\Documents\Skills\Reproducibility Package\Data\Data_clean.dta", clear

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
* 2. Descriptive Statistics
*******************************************************************************


* By region
tab type region
tab type region, cell
tab type region, row

tab type region, col
tab educ_control region, col
tab gender region, col
tab methodology region, col

* By income group
tab type inc_class, col
tab educ_control inc_class, col
tab gender inc_class, col
tab methodology inc_class, col

* End of do-file **************************************************************	

* Install required package (if not already installed)
ssc install estout

* Create and export tables to Excel
estpost tab type inc_class
esttab using "table1_type.xlsx", cell(b pct(fmt(2))) unstack noobs replace

estpost tab educ_control inc_class
esttab using "table2_educ.xlsx", cell(b pct(fmt(2))) unstack noobs replace

estpost tab gender inc_class
esttab using "table3_gender.xlsx", cell(b pct(fmt(2))) unstack noobs replace

estpost tab methodology inc_class
esttab using "table4_method.xlsx", cell(b pct(fmt(2))) unstack noobs replace


* Create a combined workbook with multiple sheets
putexcel set "descriptive_tables.xlsx", replace

* Table 1: Type
putexcel A1 = "Table 1: Type by Income Class"
estpost tab type inc_class
eststo table1
esttab table1 using "descriptive_tables.xlsx", cell(b pct(fmt(2))) sheet("Type") modify

* Table 2: Education Control
estpost tab educ_control inc_class
eststo table2
esttab table2 using "descriptive_tables.xlsx", cell(b pct(fmt(2))) sheet("Education") modify

* Table 3: Gender
estpost tab gender inc_class
eststo table3
esttab table3 using "descriptive_tables.xlsx", cell(b pct(fmt(2))) sheet("Gender") modify

* Table 4: Methodology
estpost tab methodology inc_class
eststo table4
esttab table4 using "descriptive_tables.xlsx", cell(b pct(fmt(2))) sheet("Methodology") modify




* Export to RTF (can be opened in Word and saved as PDF)
estpost tab type inc_class
esttab using "tables.rtf", cell(b pct(fmt(2))) unstack noobs replace title("Type by Income Class")

estpost tab educ_control inc_class
esttab using "tables.rtf", cell(b pct(fmt(2))) unstack noobs append title("Education Control by Income Class")

estpost tab gender inc_class
esttab using "tables.rtf", cell(b pct(fmt(2))) unstack noobs append title("Gender by Income Class")

estpost tab methodology inc_class
esttab using "tables.rtf", cell(b pct(fmt(2))) unstack noobs append title("Methodology by Income Class")




putexcel set "descriptive_stats.xlsx", replace

* Table 1: Type
tab type inc_class, matcell(freq1) matcol(col1)
tab type inc_class, col matcell(pct1)

putexcel A1 = "Type by Income Class"
putexcel A2 = matrix(freq1), names
putexcel A8 = "Percentages"
putexcel A9 = matrix(pct1), names




* Simple export maintaining structure
preserve
contract type inc_class, freq(count) percent(pct)
export delimited using "type_inc_class.csv", replace
restore



estpost tab type inc_class
esttab using "tables.tex", cell(b pct(fmt(2))) unstack noobs replace ///
       title("Type by Income Class") ///
       booktabs

	   
	   
	   
* Install if needed
ssc install estout

* Export to Excel (separate files)
estpost tabulate type inc_class
esttab using "table1.csv", cell(b pct(fmt(2))) unstack noobs replace

estpost tabulate educ_control inc_class
esttab using "table2.csv", cell(b pct(fmt(2))) unstack noobs replace

estpost tabulate gender inc_class
esttab using "table3.csv", cell(b pct(fmt(2))) unstack noobs replace

estpost tabulate methodology inc_class
esttab using "table4.csv", cell(b pct(fmt(2))) unstack noobs replace
	   
	   
	* Create combined dataset with all percentages
tempfile master
postfile results str30 variable str30 category double(pct_all pct_dev pct_high) using `master'

* Calculate totals
count
local n_all = r(N)
count if inc_class == "Developing"
local n_dev = r(N)
count if inc_class == "High Income"
local n_high = r(N)

post results ("Total N") ("") (`n_all') (`n_dev') (`n_high')

* Type
quietly tabulate type, matrow(type_levels)
local nrows = r(r)
forvalues i = 1/`nrows' {
    local lev = type_levels[`i',1]
    count if type == `lev'
    local pct_all = (r(N) / `n_all') * 100
    count if type == `lev' &amp; inc_class == "Developing"
    local pct_dev = (r(N) / `n_dev') * 100
    count if type == `lev' &amp; inc_class == "High Income"
    local pct_high = (r(N) / `n_high') * 100
    
    local lev_label : label (type) `lev'
    post results ("Type") ("`lev_label'") (`pct_all') (`pct_dev') (`pct_high')
}

* Education Control
quietly tabulate educ_control, matrow(educ_levels)
local nrows = r(r)
forvalues i = 1/`nrows' {
    local lev = educ_levels[`i',1]
    count if educ_control == `lev'
    local pct_all = (r(N) / `n_all') * 100
    count if educ_control == `lev' &amp; inc_class == "Developing"
    local pct_dev = (r(N) / `n_dev') * 100
    count if educ_control == `lev' &amp; inc_class == "High Income"
    local pct_high = (r(N) / `n_high') * 100
    
    local lev_label : label (educ_control) `lev'
    post results ("Education Control") ("`lev_label'") (`pct_all') (`pct_dev') (`pct_high')
}

* Gender
quietly tabulate gender, matrow(gender_levels)
local nrows = r(r)
forvalues i = 1/`nrows' {
    local lev = gender_levels[`i',1]
    count if gender == `lev'
    local pct_all = (r(N) / `n_all') * 100
    count if gender == `lev' &amp; inc_class == "Developing"
    local pct_dev = (r(N) / `n_dev') * 100
    count if gender == `lev' &amp; inc_class == "High Income"
    local pct_high = (r(N) / `n_high') * 100
    
    local lev_label : label (gender) `lev'
    post results ("Gender") ("`lev_label'") (`pct_all') (`pct_dev') (`pct_high')
}

* Methodology
quietly tabulate methodology, matrow(method_levels)
local nrows = r(r)
forvalues i = 1/`nrows' {
    local lev = method_levels[`i',1]
    count if methodology == `lev'
    local pct_all = (r(N) / `n_all') * 100
    count if methodology == `lev' &amp; inc_class == "Developing"
    local pct_dev = (r(N) / `n_dev') * 100
    count if methodology == `lev' &amp; inc_class == "High Income"
    local pct_high = (r(N) / `n_high') * 100
    
    local lev_label : label (methodology) `lev'
    post results ("Methodology") ("`lev_label'") (`pct_all') (`pct_dev') (`pct_high')
}

postclose results

* Load results and export
use `master', clear
format pct_all pct_dev pct_high %9.2f
export excel using "descriptive_table.xlsx", firstrow(variables) replace

* Also export as tab-delimited for Word
export delimited using "descriptive_table.txt", delimiter(tab) replace

* Display the table
list, clean noobs

	   