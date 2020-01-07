/*******************************************************************************
This do-file will generate the results presented in my Werther Effect paper.
*******************************************************************************/

/*********************************************************************
This do-file will make a dataset of all suicides at the nation-day level from 1973
 to 1988
*********************************************************************/

*do "C:\Users\dmockus2\Dropbox\werther_effect\scripts\build_suicides_nation_day_1973_1988.do"

/*********************************************************************
This do-file will create a list of celebrity suicide dates.
*********************************************************************/

*do "C:\Users\dmockus2\Dropbox\werther_effect\scripts\build_final_celebrity_suicides.do"

/*********************************************************************
This do-file will create a list of holidays and Jonestown and date controls.
*********************************************************************/

*do "C:\Users\dmockus2\Dropbox\werther_effect\scripts\build_date_controls.do"

/*********************************************************************
This do-file will create the nation-day population.
*********************************************************************/

*do "C:\Users\dmockus2\Dropbox\werther_effect\scripts\build_population_data.do"

/*********************************************************************
This do-file will build the event-study dataset (the variables on the right hand
 side).
*********************************************************************/

*do "C:\Users\dmockus2\Dropbox\werther_effect\scripts\build_event_study_dataset_rhs.do"

/*********************************************************************
This do-file will run the analysis.
*********************************************************************/

*do "C:\Users\dmockus2\Dropbox\werther_effect\scripts\analysis.do"
