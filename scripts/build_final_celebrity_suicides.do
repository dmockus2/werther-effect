/*********************************************************************
This do-file will create a list of celebrity suicide dates.
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

/***********************************************************
Celebrity Suicides
***********************************************************/

* import list of celebrities from Wikipedia
import excel "`droprawdir'\celebrity_suicides.xlsx", sheet("Sheet12") firstrow clear

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

/*******************
Count suicides
*******************/

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

save "`dropworkdir'\final_celebrity_suicides", replace