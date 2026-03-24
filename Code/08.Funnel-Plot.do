
* Load data
do "Setup.do"
use "${data}/Data_clean.dta", clear

*******************************************************************************
* 1. Data Restrictions
*******************************************************************************

* Remove estimates based on training
drop if training == "yes"

* Drop if estimates are expressed as standard deviation
keep if ind_var_measure == "Standard deviation"

keep if type == "Big Five"
drop if studylbl == "Chowdhury (2017)"

*******************************************************************************
* 2. Set Meta Variables (Random Effects)
*******************************************************************************

meta set effectsize2 std_error2, studylabel(studylbl) 

*******************************************************************************
* 3. Create Funnel Plot
*******************************************************************************

meta funnelplot, random
graph export "${figures}/Figure3.FunnelPlot.png", as(png) replace

* End of do-file **************************************************************	
