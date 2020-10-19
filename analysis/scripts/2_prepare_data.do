/*******************************************************************************
This do-file will prepare the data for analysis.
*******************************************************************************/

/*********************************************************************
Set up workspace
*********************************************************************/

* start fresh
clear all

* raw data
local data "$werther_effect/analysis/data"

* intermediate data
local intermediate "$werther_effect/analysis/processed/intermediate"

* final data
local final "$werther_effect/analysis/processed"

/*********************************************************************
Compile 1973 - 1988 suicide data
*********************************************************************/

capture erase "`intermediate'/suicides_1973_1988.dta"
capture erase "`intermediate'/suicides_nation_day_1973_1988.dta"

cd "`data'"

forvalues year = 1973/1988 {	
	
	* load data
	use "`data'/mort`year'.dta"

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
	
		append using "`intermediate'/suicides_1973_1988.dta"
	
	}
	
	save "`intermediate'/suicides_1973_1988.dta", replace
	
}

/***********************************************************
Final Edits
***********************************************************/

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

* save data
compress
save "`intermediate'/suicides_1973_1988.dta", replace

/***********************************************************
Descriptive statistics
***********************************************************/

preserve

* 450359 suicides total
count
assert r(N) == 450359

* 450280 suicides with exact day of death
count if date != .
assert r(N) == 450280

* 79 suicides without exact day of death
count if date == .
assert r(N) == 79

restore

/***********************************************************
Number of daily suicides
***********************************************************/

* drop 79 suicides with missing dates
drop if date == .

generate suicides = 1
collapse (sum) suicides, by(date)
label variable suicides "Number of Suicides"

* save data
compress
save "`intermediate'/suicides_nation_day_1973_1988.dta"

/*********************************************************************
Edit list of celebrity suicide dates
*********************************************************************/

capture erase "`intermediate'/celebrity_suicides.dta"

clear

* load data
use "`data'/celebrity_suicides.dta"

* clean up notes to self
drop W Step1 httpsenwikipediaorgwikiLi

* mark celebrities for whom all the papers reported (this step excludes Jonestown)
gen national_celebrity = (NYTpage != "" & WPpage != "" & CTpage != "" & LATpage != "")

* mark scandalous people
/*
Suicide Date	Name				Description	General Method
9-May-76	Ulrike Meinhof			German RAF terrorist	Hanging
18-Oct-77	Gudrun Ensslin			German RAF terrorist	Hanging
18-Oct-77	Andreas Baader			German RAF terrorist	Firearm
18-Oct-77	Jan-Carl Raspe			German RAF terrorist	Firearm
19-Oct-78	Gig Young				American actor, notable for his role on the TV series Get Smart, muder-suicide	Firearm
19-Aug-79	Mary Millington			English model and softcore pornographic actress	Poison
15-Sep-80	Jim Tyrer				American football player, murder-suicide	Firearm
3-Oct-80	Gustav Wagner			Nazi	Other
26-Dec-80	Richard Chase			American serial killer	Poison
23-Mar-84	Shauna Grant			American porn actress	Firearm
6-Jun-85	Leonard Lake			American serial killer	Poison
21-Oct-85	Dan White				San Francisco politician and criminal	Poison
13-Mar-86	Donald R. Manes			American politician, suspected of corruption (had pled guilty)	Other
22-Jan-87	R. Budd Dwyer			American politician, convicted of corruption	Firearm
19-May-87	Alice Bradley Sheldon (James Tiptree, Jr.)	American writer, murder-suicide	Firearm
17-Aug-87	Rudolf Hess				German Nazi leader	Hanging
8-Dec-87	Frank Vitkovic			Australian mass murderer	Other
*/
gen immoral = (inlist(Name, "Stephen Ward", "Dan Burros", "David Meirhofer", "Li Tobler", "Ulrike Meinhof") | ///
	inlist(Name, "Gudrun Ensslin", "Andreas Baader", "Jan-Carl Raspe", "Gig Young", "Mary Millington") | ///
	inlist(Name, "Jim Tyrer", "Gustav Wagner", "Richard Chase", "Shauna Grant", "Leonard Lake") | ///
	inlist(Name, "Dan White", "Donald R. Manes", "R. Budd Dwyer", "Alice Bradley Sheldon (James Tiptree, Jr.)", "Rudolf Hess") | ///
	inlist(Name, "Frank Vitkovic"))
	
* mark possible (not confirmed) suicides
generate possible_suicide = Notes == "Possible suicide"

* look at differences between suicide date and report date
gen diff = ReportDate - SuicideDate

* mark if report date is more than a month (30 days) out
generate late = (diff > 30)

/***********************************************************
Count suicides
***********************************************************/

* 75 celebrities from Wikipedia
count
assert r(N) == 75

* 33 national celebrities
count if national_celebrity
assert r(N) == 33

* 12 national celebrities immoral
count if (national_celebrity & immoral)
assert r(N) == 12

* 1 national celebrity found very late (Richard Brautigan)
count if (national_celebrity & late & !immoral)
assert r(N) == 1

* 1 national celebrity a possible suicide (Jean Seberg)
count if (national_celebrity & possible_suicide & !immoral)
assert r(N) == 1

keep if national_celebrity
drop if immoral
drop if late // drops Richard Brautigan

* 20 moral national celebrities left
count
assert r(N) == 20

save "`intermediate'/celebrity_suicides", replace

/*********************************************************************
Create a list of holidays and Jonestown
*********************************************************************/

capture erase "`intermediate'/date_controls.dta"

clear

/***********************************************************
Get all dates (1973 - 1988)
************************************************************/

input str9 (Name ReportDate)
	"First Day" "01jan1973"
	"Last Day"	"31dec1988"
end

* generate all the dates in between
generate date = date(ReportDate,"DMY")
drop ReportDate
format %td date
tsset date
tsfill

* 16 years * 365 days/year + 4 leap years (76, 80, 84, 88) = 5844 days
count
assert r(N) == 5844

drop Name

/***********************************************************
Mark holidays and four leads and four lags
Original Law (enacted September 6, 1966): http://uscode.house.gov/codification/t5/PubL89-554.pdf (section 6103)
Uniform Monday Holiday Act, effective 1971: https://www.govinfo.gov/content/pkg/STATUTE-82/pdf/STATUTE-82-Pg250-3.pdf
***********************************************************/

* New Years Day (always Jan 1)
gen hol_nyd = (month(date) == 1 & day(date) == 1)
count if hol_nyd
* Check and make sure that there are correct number of holidays
assert r(N) == 16
* 4 leads and lags (note that fourth lead is third Christmas lag)
forvalues i = 1/4 {
	gen hol_nyd_lag_`i' = (hol_nyd[_n - `i'] == 1)
	gen hol_nyd_lead_`i' = (hol_nyd[_n + `i'] == 1)
}
drop hol_nyd_lead_4

* MLK Day (third Monday in Jan)
* established 1983
* floats between Jan 15 - 21
gen hol_mlk = (year(date) >= 1983 & month(date) == 1 & dow(date) == 1 & inrange(day(date), 15, 21))
count if hol_mlk
assert r(N) == 6
forvalues i = 1/4 {
	gen hol_mlk_lag_`i' = (hol_mlk[_n - `i'] == 1)
	gen hol_mlk_lead_`i' = (hol_mlk[_n + `i'] == 1)
}

* Washington's Birthday
* the third Monday in February
* floats between Feb 15-21
gen hol_wash = ((year(date) <= 1970 & month(date) == 2 & day(date) == 22) | ///
	(year(date) >= 1971 & month(date) == 1 & dow(date) == 1 & inrange(day(date), 15, 21)))
count if hol_wash
assert r(N) == 16
forvalues i = 1/4 {
	gen hol_wash_lag_`i' = (hol_wash[_n - `i'] == 1)
	gen hol_wash_lead_`i' = (hol_wash[_n + `i'] == 1)
}

* Memorial Day 
* the last Monday in May
* the last Monday in May (31 days) is between the 25th and 31st
gen hol_mem = ((year(date) <= 1970 & month(date) == 5 & day(date) == 30) | ///
	(year(date) >= 1971 & month(date) == 5 & dow(date) == 1 & inrange(day(date), 25, 31)))
count if hol_mem
assert r(N) == 16
forvalues i = 1/4 {
	gen hol_mem_lag_`i' = (hol_mem[_n - `i'] == 1)
	gen hol_mem_lead_`i' = (hol_mem[_n + `i'] == 1)
}

* Independence Day (Jul 4)
gen hol_ind = (month(date) == 7 & day(date) == 4)
count if hol_ind
assert r(N) == 16
forvalues i = 1/4 {
	gen hol_ind_lag_`i' = (hol_ind[_n - `i'] == 1)
	gen hol_ind_lead_`i' = (hol_ind[_n + `i'] == 1)
}

* Columbus Day 
* the second Monday in October
* the second Monday in October is between the 8th and 14th
gen hol_col = ((year(date) <= 1970 & month(date) == 10 & day(date) == 12) | ///
	(year(date) >= 1971 & month(date) == 10 & dow(date) == 1 & inrange(day(date), 8, 14)))
count if hol_col
assert r(N) == 16
forvalues i = 1/4 {
	gen hol_col_lag_`i' = (hol_col[_n - `i'] == 1)
	gen hol_col_lead_`i' = (hol_col[_n + `i'] == 1)
}

* Labor Day (always first Monday in September)
gen hol_lab = (month(date) == 9 & dow(date) == 1 & inrange(day(date), 1, 7))
count if hol_lab
assert r(N) == 16
forvalues i = 1/4 {
	gen hol_lab_lag_`i' = (hol_lab[_n - `i'] == 1)
	gen hol_lab_lead_`i' = (hol_lab[_n + `i'] == 1)
}

* Veteran's Day
* Original Law: November 11
* As of 1971, the fourth Monday in October
* Effectively moved back to Nov 11 in 1978
gen hol_vet = ((year(date) <= 1970 & month(date) == 11 & day(date) == 11) | ///
	(inrange(year(date), 1971, 1977) & month(date) == 10 & dow(date) == 1 & inrange(day(date), 15, 21)) | ///
	(year(date) >= 1978 & month(date) == 11 & day(date) == 11))
count if hol_vet
assert r(N) == 16
forvalues i = 1/4 {
	gen hol_vet_lag_`i' = (hol_vet[_n - `i'] == 1)
	gen hol_vet_lead_`i' = (hol_vet[_n + `i'] == 1)
}

* Thanksgiving Day (always fourth Thursday in November)
gen hol_thank = (month(date) == 11 & dow(date) == 4 & inrange(day(date), 22, 28))
count if hol_thank
assert r(N) == 16
forvalues i = 1/4 {
	gen hol_thank_lag_`i' = (hol_thank[_n - `i'] == 1)
	gen hol_thank_lead_`i' = (hol_thank[_n + `i'] == 1)
}

* Christmas Day (always Dec 25)
gen hol_chr = (month(date) == 12 & day(date) == 25)
count if hol_chr
assert r(N) == 16
forvalues i = 1/4 {
	gen hol_chr_lag_`i' = (hol_chr[_n - `i'] == 1)
	gen hol_chr_lead_`i' = (hol_chr[_n + `i'] == 1)
}
* note that fourth lag is third New Year's Day lead)
drop hol_chr_lag_4

/***********************************************************
Mark Jonestown
Control for Jonestown until the end of the month because Jonestown would just affect the U.S. in an odd way
Luckily there's no suicides around this time
***********************************************************/

gen jonestown = inrange(date, date("18nov1978", "DMY"), date("30nov1978", "DMY"))

/***********************************************************
Date controls
Day of week, day of month, yearmonth
***********************************************************/

* day of week
generate day_of_week = dow(date)

* day of month
generate day_of_month = day(date)

* year-month
generate yearmon = ym(year(date), month(date))
format yearmon %tm

/***********************************************************
Save data
***********************************************************/

save "`intermediate'/date_controls.dta"

/*********************************************************************
Create population at nation-day level
*********************************************************************/

capture erase "`intermediate'/population_data.dta"

clear

* load data
use "`data'/population_data.dta"

* collapse to year-level
collapse (sum) population, by(year)

gen month = "jul"
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

save "`intermediate'/population_data.dta"

/*********************************************************************
Combine all variables on right hand side
*********************************************************************/

capture erase "`intermediate'/dataset_rhs.dta"

clear

/***********************************************************
Create event-study indicators for suicides
***********************************************************/

use "`intermediate'/celebrity_suicides", clear

* keep report date and name of celebrity (to mark time 0)
keep ReportDate Name
rename ReportDate date
format date %td

* merge with all dates (and date controls)
merge 1:1 date using "`intermediate'/date_controls.dta", assert(using match) nogen

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

merge 1:1 date using "`intermediate'/population_data.dta", assert(match) nogen 

save "`intermediate'/dataset_rhs.dta"

/*********************************************************************
Add mortality (left-hand side)
*********************************************************************/

capture erase "`final'/final_data.dta"

merge 1:1 date using "`intermediate'/suicides_nation_day_1973_1988.dta", assert(match) nogen // there are no days with 0 suicides

* save dataset
keep suicides pre_* story post_* ///
	day_of_week day_of_month yearmon ///
	hol* jonestown population outside
compress
save "`final'/final_data.dta"

/*********************************************************************
Summary statistics
*********************************************************************/

* comparison mean of excluded group
summarize suicides if outside

* average daily number of suicides
summarize suicides

* average population per month
*preserve
collapse (mean) population (sum) suicides, by(yearmon)
summarize population

* average number of suicides per month
summarize suicides

* end of file