/*********************************************************************
This do-file will build the event-study dataset (the variables on the right hand
 side).
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

* directories
* Dropbox directory
local Dropbox "C:\Users\dmockus2\Dropbox" // CHANGE THIS PATH

* work data directory
local dropworkdir "`Dropbox'\werther_effect\data\work"

/***********************************************************
Create event-study indicators for suicides.
***********************************************************/

use "`dropworkdir'\final_celebrity_suicides", clear

* keep report date and name of celebrity (to mark time 0)
keep ReportDate Name
rename ReportDate date
format date %td

* merge with all dates (and date controls)
merge 1:1 date using "`dropworkdir'\date_controls.dta", assert(using match) nogen

/*************************************************
Create event-study indicators
*************************************************/

sort date

* generate event-time
generate eventtime = 99

* set date 0 to be the date of story
generate story = (Name != "")
replace eventtime = 0 if story
drop Name
* there should be 20
count if story
assert r(N) == 20

 
* 10 pre/post
forvalues i = 1/10 {

	generate pre_`i' = story[_n + `i']
	label variable pre_`i' "-`i'"
	replace pre_`i' = 0 if pre_`i' == . // There were not suicides near the endpoints that are not in my data
	replace eventtime = -`i' if story[_n + `i']
	generate post_`i' = story[_n - `i']
	label variable post_`i' "`i'"
	replace post_`i' = 0 if post_`i' == . // There were not suicides near the endpoints that are not in my data
	replace eventtime = `i' if story[_n - `i']
	
}

* outside days -10 to 10
egen not_outside = anymatch(pre_* story post_*), values(1)
generate outside = 1 - not_outside

/************************************************************
Add population
************************************************************/

merge 1:1 date using "`dropworkdir'\population_data.dta", assert(match) nogen 

save "`dropworkdir'\event_study_dataset_rhs.dta", replace