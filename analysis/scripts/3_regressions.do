/*******************************************************************************
This do-file will run the regressions.
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

/*********************************************************************
Event Study
https://twitter.com/agoodmanbacon/status/1165643395844493313
*********************************************************************/
	
/***********************************************************
Figure 1
***********************************************************/

capture erase "`final'/figure_1.dta"

* load data
use "`final'/final_data.dta"

* run regression
poisson suicides pre_* story post_*

* save coefficient estimates (but not outer bounds)
regsave pre_10 pre_9 pre_8 pre_7 pre_6 pre_5 pre_4 pre_3 pre_2 pre_1 story ///
	post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8 post_9 post_10 using "`final'/figure_1.dta", pval ci 
	
/*********************************************************************
Figure 2
*********************************************************************/

capture erase "`final'/figure_2.dta"

clear

* load data
use "`final'/final_data.dta"

set niceness 0

* run regression
parallel bootstrap, rep(1000) seeds(2602 306 2206): poisson suicides pre_* story post_* ///
	i.day_of_week i.day_of_month i.yearmon ///
	hol* jonestown population
	
set niceness 5

* save coefficient estimates (but not outer bounds)
regsave pre_10 pre_9 pre_8 pre_7 pre_6 pre_5 pre_4 pre_3 pre_2 pre_1 story ///
	post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8 post_9 post_10 using "`final'/figure_2.dta", pval ci  

* end of file