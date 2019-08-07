*******************************************
************* Main do-file ****************
*******************************************
*use "\Data\egorelevance.dta", clear
set more off

*** Define treatment variables

gen max = 1 if treatment == "Max/IQ" | treatment == "Max/Pattern"
replace max = 0 if treatment == "Min/IQ" | treatment == "Min/Pattern"

gen iq = 1 if treatment == "Max/IQ" | treatment == "Min/IQ"
replace iq = 0 if treatment == "Max/Pattern" | treatment == "Min/Pattern"

*** Destring variables ***
gen female = 0 if Female =="Male"
replace female =1 if Female=="Female"
gen learn = 0
replace learn=1 if learnscore >0

*** Check distributions of variables
* Histogram bar transparency (%15) only works in Stata > 14 
twoway (hist activated if max == 1, disc color(none) lcolor(red)) ///
	(hist activated if max == 0, disc color(blue%15) lcolor(blue)), ///
	legend(order(1 "Max" 2 "Min"))
	
cdfplot activated, by(max) legend(order(1 "Min" 2 "Max"))

twoway (hist activated if iq == 1, disc color(none) lcolor(red)) ///
	(hist activated if iq == 0, disc color(blue%15) lcolor(blue)), ///
	legend(order(1 "IQ" 2 "Pattern"))

ssc install cdfplot
cdfplot activated, by(max) legend(order(1 "Pattern" 2 "IQ"))	

ttest activated, by(max)
ranksum activated, by(max)
ttest activated, by(iq)
ranksum activated, by(iq)

ttest belief_team_act, by(max)
ranksum belief_team_act, by(max)
ttest belief_team_act, by(iq)
ranksum belief_team_act, by(iq)

******************************
* Table 1: Descriptive Stats *
******************************
bys treatment: sum performance_1 guess_1 confidencetop_1 confidencequarter_1  belief_team_act activate_decision performance_2 female age taken_task oneness_teammate learnscore
tab learn iq, exact 

****************************
*** Table 2: OLS Results ***
****************************
reg activate_decision  i.max  i.iq c.belief_team_act performance_1 , robust
outreg2 using main_reg.xls, replace 
reg activate_decision  i.max##c.belief_team_act  i.iq##c.belief_team_act performance_1 , robust
outreg2 using main_reg.xls
reg activate_decision  i.max##c.belief_team_act  i.iq##c.belief_team_act performance_1  guess_1 confidencetop_1 oneness_teammate  female age, robust
outreg2 using main_reg.xls

* Figure 1
margins, at(belief_team_act=(1(1)10) iq=(0 1))
marginsplot, legend(order(1 "Non-Ego" 2 "Ego" )) title("") ///
	scheme(s1mono) xtitle("Beliefs about Teammate's Contribution") ytitle("Own Contribution") ///
	ysize(6) xsize(6)

pwcorr confidencetop_1 confidencequarter_1 performance_1, sig

/* Similar results with UK Nationals
preserve
keep if nationality == "GB"
reg activate_decision i.max##i.iq 
outreg2 using main_GB.xls, replace
reg activate_decision i.max##i.iq Performance_1
outreg2 using main_GB.xls
reg activate_decision i.max##i.iq confidencetop_1 
outreg2 using main_GB.xls
reg activate_decision i.max##i.iq confidencequarter_1 
outreg2 using main_GB.xls
reg activate_decision i.max##i.iq belief_team_act
outreg2 using main_GB.xls
reg activate_decision i.max##i.iq i.max##c.belief_team_act
outreg2 using main_GB.xls
restore
*/


