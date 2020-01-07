/*******************************************************************************
This do-file will make a dataset of all suicides at the nation-day level from 1973
 to 1988
*******************************************************************************/

/*********************************************************************
Set up workspace
*********************************************************************/

* start fresh
clear all

* let script go ahead without waiting
set more off

* set timer on
set rmsg on

* version
version

* directories
* Box directory
local Box  "C:\Users\dmockus2\Box Sync" // CHANGE THIS PATH

* Box raw data directory
local boxrawdir "`Box'\UIUC\Research\Data_Storage\raw_data\nber\mortality_data"

* Dropbox directory
local Dropbox "C:\Users\dmockus2\Dropbox" // CHANGE THIS PATH

* raw data directory
local droprawdir "`Dropbox'\werther_effect\data\raw"

/***********************************************************
Compile
***********************************************************

capture erase "`droprawdir'\suicides_1973_1988.dta"

forvalues year = 1973/1988 {
	
	* load data
	if inrange(`year', 1973, 1978) {
	
		use "`boxrawdir'\1968_1978\\`year'\mort`year'.dta", clear
		
	}
	
	if inrange(`year', 1979, 1988) {
	
		use "`boxrawdir'\1979_1998\\`year'\mort`year'.dta", clear
	
	}

	* keep relevant variables
	keep datayear monthdth daydth ucod

	* keep relevant ICD-8/9 codes (950-959)
	generate first_numbers = substr(ucod, 1, 2)
	keep if first_numbers == "95"
	drop first_numbers

	* generate year
	if inrange(`year', 1973, 1978) {
	
		gen year = datayear + 1970
		
	}
	
	if inrange(`year', 1979, 1988) {
	
		generate year = datayear + 1900
	
	}

	* append data	
	if inrange(`year', 1974, 1988) {
	
		append using "`droprawdir'\suicides_nation_day_1973_1988.dta"
	
	}
	
	save "`droprawdir'\suicides_nation_day_1973_1988.dta", replace
	
}

/***************************************
Final Edits
***************************************/

* rename and label variables
drop datayear
label variable year "Year"
rename monthdth month
label variable month "Month"
rename daydth day
label variable day "Day"
label variable ucod "ICD Code"

* generate yearmon and date
generate date = mdy(month, day, year)
format date %td

generate yearmon = ym(year, month)
format yearmon %tm

* all missing dates have missing days
assert inlist(day, 99) if date == .

* save
save "`droprawdir'\suicides_nation_day_1973_1988.dta", replace

*************************************************
Descriptive statistics
*************************************************/

use "`droprawdir'\suicides_nation_day_1973_1988.dta", clear

* 450359 suicides total
count
assert r(N) == 450359

* 450280 suicides with exact day of death
count if date != .
assert r(N) == 450280

* 79 suicides without exact day of death
count if date == .
assert r(N) == 79
