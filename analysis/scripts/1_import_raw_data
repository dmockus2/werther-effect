/*******************************************************************************
This do-file will download and import raw data.
*******************************************************************************/

/*********************************************************************
Set up workspace
*********************************************************************/

* start fresh
clear all

* raw data
local data "$werther_effect/analysis/data"

/*********************************************************************
Download 1973 - 1988 mortality data
*********************************************************************/

cd "`data'"

forvalues year = 1973/1988 {	

	capture erase "mort`year'.dta.zip"
	capture erase "mort`year'.dta"

	* download data
	copy "https://data.nber.org/mortality/`year'/mort`year'.dta.zip" "`data'/"
	
	* unzip file
	unzipfile mort`year'.dta.zip
	
}

/*********************************************************************
Import celebrity suicide data
*********************************************************************/

capture erase "`data'/celebrity_suicides.dta"

clear

* import compiled list of celebrity suicides from Wikipedia
import excel "`data'/celebrity_suicides.xlsx", sheet("Sheet12") firstrow clear

* save data
save "`data'/celebrity_suicides.dta"

/*********************************************************************
Import population data

SEER Population Data (https://seer.cancer.gov/popdata/download.html)
I already downloaded and ran the data from https://seer.cancer.gov/popdata/yr1969_2017.19ages/us.1969_2017.19ages.adjusted.exe
*********************************************************************/

capture erase "`data'/population_data.dta"

clear

* import data
infix ///
	year 1-4 population 19-26 ///
using "`data'/us.1969_2017.19ages.adjusted.txt"

save "`data'/population_data.dta"

* end of file
