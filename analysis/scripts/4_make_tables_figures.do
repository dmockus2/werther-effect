/*******************************************************************************
This do-file will produce the figures.
*******************************************************************************/

/*********************************************************************
Set up workspace
*********************************************************************/

clear all

* Parallel package
*net install parallel, from(https://raw.github.com/gvegayon/parallel/stable/) replace
*mata mata mlib index

* parallel version
parallel version

* number of parallel clusters
parallel initialize 3, f

* final data
local final "$werther_effect/analysis/processed"

* figures
local figures "$werther_effect/analysis/results/figures"


/*********************************************************************
Event Study
https://twitter.com/agoodmanbacon/status/1165643395844493313
*********************************************************************/
	
/***********************************************************
Figure 1
***********************************************************/

capture erase "`figures'/figure_1.gph"

* load data
use "`final'/figure_1.dta"
		
* edit coefficient data to add event times
split var, parse(: _) 
destring var3, replace
replace var3 = -var3 if var2 == "pre"
replace var3 = 0 if var2 == "story"
sort var3

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

graph save "Graph" "`figures'/figure_1.gph"

/*********************************************************************
Figure 2
*********************************************************************/

capture erase "`figures'/figure_2.gph"

clear

* load data
use "`final'/figure_2.dta"

* edit coefficient data to add event times
split var, parse(: _) 
destring var3, replace
replace var3 = -var3 if var2 == "pre"
replace var3 = 0 if var2 == "story"
sort var3

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
	
graph save "Graph" "`figures'/figure_2.gph", replace

* end of file
