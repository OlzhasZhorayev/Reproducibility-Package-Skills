
*******************************************************************************
* Paper: Returns to Socio-Emotional Skills and the Effectiveness of Training:
*		 A Meta-Analysis of Recent Evidence

	* Created by:	Olzhas Zhorayev
	* Date created: December 12, 2025
	* Updated by:	Olzhas Zhorayev
	* Date updated: December 26, 2025
	* Purpose:		Replication of Paper Analysis (Tables and Figures)
*******************************************************************************


*******************************************************************************
* SETTINGS AND DIRECTORY
*******************************************************************************

	clear all
	set more off
	set varabbrev on
	est clear
	
	* Set Stata version
	version 18

	* Start timer
	timer clear
	timer on 1  
	
	* Seeds for reproducibility
/*	set seed 4353443
	set sortseed 3534547 */
	
	* Set project directory and structure
	*global dir		"C:\Users\wb627960\OneDrive - WBG\Documents\Skills\Reproducibility Package"
	global dir		"C:\Users\Admin\OneDrive - George Mason University - O365 Production\Documents\GMU\Dr Kugler\Skills\Reproducibility Package"
	global data 	"${dir}/Data"
	global code 	"${dir}/Code"
	global tables 	"${dir}/Tables"
	global figures 	"${dir}/Figures"
	global temp 	"${dir}/Temp"
		
	* Set ado folder in the Code folder
	sysdir set PLUS "${code}/ado"

	* Install packages in the ado folder 
/*	local programs = "labutil estout ietoolkit distinct tabout winsor"  // Add required user-written commands
	local install = 0
	if (`install'==1) {
		foreach p in `programs' {
			ssc install `p'
	   }
	}
*/	
	
*******************************************************************************
* DATA PREPARATION
*******************************************************************************

	do "${code}\1.Pool-Estimates-RE-All.do"
	do "${code}\2.Pool-Estimates-Training.do"
	do "${code}\3.Pool-Estimates-RE-Main.do"
	*do "${code}\4.Pool-Estimates-FE-All.do"
	do "${code}\5.Pool-Estimates-RE-Big5.do"


*******************************************************************************
* ANALYSIS
*******************************************************************************

	* Table 3: Descriptive Statistics, Labor Returns Analysis by Income Group
	*do "${code}\6.Descriptive-Statistics.do"

	* Figure 1: Wage Returns to Big Five Traits vs Cognitive Skills, RE, All Sample
	do "${code}\7.Wage-Returns-RE.py"

	* Figure 2: Heterogeneity Effects, RE, All Sample
	do "${code}\8.Heterogeneity.py"

	* Figure 3: Returns Estimation: Publication Bias
	do "${code}\9.Funnel-Plot.do"

	* Table 4: Descriptive Statistics, Non-Cognitive Skill Training Programs
	*do "${code}\10.Descriptive-Stat-Training.do"

	* Figure 4: Training Impact on Big Five Personality Traits, RE, All Sample
	do "${code}\11.Training-Impact.py"

	* Figure 5: Heterogeneity of Training Impacts, RE, All Sample
	do "${code}\12.Training-Heterogeneity.py"

	* Figure 6: Training Estimation Publication Bias
	do "${code}\13.Funnel-Plot-Training.do"

	* Table A3: Descriptive Statistics, Labor Returns Analysis by Region
	*do "${code}\14.Descriptive-Stat-Region.do"

	* Figure A7: Wage Returns to Big Five Personality Traits, RE
	do "${code}\15.Wage-Returns-RE-Main.py"

	* Figure A8: Wage Returns to Big Five Personality Traits, FE, All Sample
	*do "${code}\16.Wage-Returns-FE-All.py"

	* Figure A9: Wage Returns to Big Five Personality Traits, RE, Only Big Five
	do "${code}\17.Wage-Returns-RE-Big5.py"


*******************************************************************************
* TIMER CHECK 
*******************************************************************************

	* Stops timer
	timer off 1  
	
	* Display time to see how long the process took to run
	timer list 1 
	return list
	display r(r) " minutes"
	display "Elapsed time: " r(t1) " seconds"


* End of do-file **************************************************************	
	