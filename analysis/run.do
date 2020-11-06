/*******************************************************************************
This do-file will replicate my Werther Effect paper.
*******************************************************************************/

/*******************************************************************************
Set up workspace
*******************************************************************************/

* start fresh
clear all

version 16

* project folder
global werther_effect "C:/werther_effect" // CHANGE PATH TO POINT TO YOUR PROJECT FOLDER HERE

capture mkdir "$werther_effect/analysis/processed"
capture mkdir "$werther_effect/analysis/processed/intermediate"
capture mkdir "$werther_effect/analysis/results"
capture mkdir "$werther_effect/analysis/results/figures"

* let script go ahead without waiting
set more off

* set timer on
set rmsg on

/*******************************************************************************
This do-file download and import the raw data.
*******************************************************************************/

do "$werther_effect/analysis/scripts/1_import_raw_data.do"

/*******************************************************************************
This do-file will prepare the data for analysis.
*******************************************************************************/

do "$werther_effect/analysis/scripts/2_prepare_data.do"

/*******************************************************************************
This do-file will run the regressions.
*******************************************************************************/

do "$werther_effect/analysis/scripts/3_regressions.do"

/*******************************************************************************
This do-file will produce the figures.
*******************************************************************************/

do "$werther_effect/analysis/scripts/4_make_tables_figures.do"

* end of file
