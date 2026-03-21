
* Load data
do "Setup.do"
import excel "${data}\Training_data_clean.xlsx", sheet("Database") firstrow clear

*******************************************************************************
* 1. Restriction
*******************************************************************************

keep if Groupingvariable == "Overall"

*******************************************************************************
* 2. Set Meta Variables
*******************************************************************************

replace ES = abs(ES)
meta set ES SE, studylabel(Filename)

*******************************************************************************
* 3. Create Funnel Plot
*******************************************************************************

meta funnelplot, random
graph export "${figures}/Figure5.FunnelPlotTraining.png", as(png) replace

* End of do-file **************************************************************	
