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

* raw data directory
local droprawdir "`Dropbox'\werther_effect\data\raw"

* work data directory
local dropworkdir "`Dropbox'\werther_effect\data\work"

* processed data directory
local dropprocdir "`Dropbox'\werther_effect\data\proc"

/***********************************************************
Merge suicide data with rhs data
***********************************************************/

use "`droprawdir'\suicides_nation_day_1973_1988.dta"

drop month day year yearmon

* drop 79 suicides with missing dates
count if date == .
assert r(N) == 79
drop if date == .

* count 
generate suicides = 1
collapse (sum) suicides, by(date)

merge 1:1 date using "`dropworkdir'\event_study_dataset_rhs.dta", assert(match) nogen // all dates have non-missing suicide count

/***********************************************************
Save
***********************************************************/

save "`dropprocdir'\event_study_dataset", replace