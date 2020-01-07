/*********************************************************************
This do-file will create a list of holidays and Jonestown.
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
Get all dates
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

save "`dropworkdir'\date_controls.dta", replace