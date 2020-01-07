/*********************************************************************
This do-file will create the nation-day population.
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

/************************************************************
SEER Population Data (https://seer.cancer.gov/popdata/download.html)
https://seer.cancer.gov/popdata/yr1969_2017.19ages/us.1969_2017.19ages.adjusted.exe
************************************************************/

* import data
infix ///
	year 1-4 population 19-26 ///
using "`droprawdir'\us.1969_2017.19ages.adjusted.txt"

* collapse to year
collapse (sum) population, by(year)

gen month = "jul"
*replace month = "apr" if inlist(year, 1980)
gen day = 1
egen tdate = concat(day month year)
gen date = date(tdate, "DMY")
format date %td
drop year month day tdate
tsset date
tsfill
mipolate population date, cubic generate(national_pop_mip_cub)
keep if inrange(year(date), 1973, 1988)
drop population
rename national_pop_mip_cub population

save "`dropworkdir'\population_data.dta", replace