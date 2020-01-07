/*********************************************************************
This do-file will run the analysis.
*********************************************************************/

/***********************************************************
Set up workspace
***********************************************************/

* start fresh
clear all

* let script go ahead without waiting
set more off

* set timer on
set rmsg on

* version
version

* Parallel package
*net install parallel, from(https://raw.github.com/gvegayon/parallel/stable/) replace
*mata mata mlib index

* parallel version
parallel version

* number of parallel clusters
parallel initialize 3, f

* directories
* Dropbox directory
local Dropbox "C:\Users\dmockus2\Dropbox" // CHANGE THIS PATH

* processed data directory
local dropprocdir "`Dropbox'\werther_effect\data\proc"

* temporary file
tempfile tmprry

* load data
use "`dropprocdir'\event_study_dataset", replace

/*******************************************************************************
1. Summary Statistics
*******************************************************************************

* average daily number of suicides
summarize suicides

* average population per month
*preserve
collapse (mean) population (sum) suicides, by(yearmon)
summarize population

* average number of suicides per month
summarize suicides

*******************************************************************************
2. Event Study
https://twitter.com/agoodmanbacon/status/1165643395844493313
*******************************************************************************/
	
/*******************************************************************************
2.A. Raw Data
*******************************************************************************/

* load data
use "`dropprocdir'\event_study_dataset", clear

*replace outside = pre_1 if !outside // include untreated days in excluded group
*rename pre_1 asdf // excluded group

* comparison mean of excluded group
summarize suicides if outside

keep suicides pre_* story post_* ///
	day_of_week day_of_month yearmon ///
	hol* jonestown population outside
	
* run regression
poisson suicides pre_* story post_*

* save coefficient estimates (but not outer bounds)
regsave pre_10 pre_9 pre_8 pre_7 pre_6 pre_5 pre_4 pre_3 pre_2 pre_1 story ///
	post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8 post_9 post_10 using `tmprry', pval ci 
	
* edit coefficient data to add event times
use `tmprry', clear
split var, parse(: _) 
destring var3, replace
replace var3 = -var3 if var2 == "pre"
replace var3 = 0 if var2 == "story"
sort var3
stop
replace coef = 100 * coef
replace ci_lower = 100 * ci_lower
replace ci_upper = 100 * ci_upper
scatter coef var3, ///
	c(l l l) cmissing(y n n) ///
	msym(i i i) lcolor(blue gray gray) lpattern(solid dash dash) lwidth(thick medthick medthick) ///
	yline(0, lcolor(black)) xline(0, lcolor(black)) ///
	subtitle("~% Effect on Suicide", size(small) j(left) pos(11)) ylabel( , angle(horizontal) labsize(small)) ///
	xtitle("Days Since Celebrity Suicide Report", size(small)) ///
	legend(off)

graph save "Graph" "C:\Users\dmockus2\Dropbox\werther_effect\figures\no_controls.gph", replace

/*******************************************************************************
2.B. With Controls
*******************************************************************************

keep suicides pre_* story post_* ///
	day_of_week day_of_month yearmon ///
	hol* jonestown population
	
set niceness 0

* run regression
parallel bootstrap, rep(1000) seeds(2602 306 2206): poisson suicides pre_* story post_* ///
	i.day_of_week i.day_of_month i.yearmon ///
	hol* jonestown population
	
set niceness 5

* save coefficient estimates (but not outer bounds)
regsave pre_10 pre_9 pre_8 pre_7 pre_6 pre_5 pre_4 pre_3 pre_2 pre_1 story ///
	post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8 post_9 post_10 using `tmprry', pval ci  

* edit coefficient data to add event times
use `tmprry', clear
split var, parse(: _) 
destring var3, replace
replace var3 = -var3 if var2 == "pre"
replace var3 = 0 if var2 == "story"
sort var3

save "C:\Users\dmockus2\Dropbox\werther_effect\data\proc\analysis.dta"
*/
use "C:\Users\dmockus2\Dropbox\werther_effect\data\proc\analysis.dta", clear

replace coef = 100 * coef
replace ci_lower = 100 * ci_lower
replace ci_upper = 100 * ci_upper
scatter coef ci* var3, ///
	c(l l l) cmissing(y n n) ///
	msym(i i i) lcolor(blue gray gray) lpattern(solid dash dash) lwidth(thick medthick medthick) ///
	yline(0, lcolor(black)) xline(0, lcolor(black)) ///
	subtitle("~% Effect on Suicide", size(small) j(left) pos(11)) ylabel( , angle(horizontal) labsize(small)) ///
	xtitle("Days Since Celebrity Suicide Report", size(small)) ///
	legend(off)
	
graph save "Graph" "C:\Users\dmockus2\Dropbox\werther_effect\figures\analysis.gph", replace