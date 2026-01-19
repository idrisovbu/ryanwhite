***
*Master do file for Evidence and Lessons on the Health Impacts of Public Health Funding from the Fight against HIV/AIDS
***

*For replication, set root directory
global root ""

global do_loc "$root/code"
global data_loc "$root/data"
global output_loc "$root/output"

clear all
set rmsg on, permanently
set more off, permanently
set maxvar 5000, permanently
version 17

*Code to have Stata use locally installed packages
tokenize `"$S_ADO"', parse(";")
while `"`1'"' != "" {
  if `"`1'"'!="BASE" cap adopath - `"`1'"'
  macro shift
}
adopath ++ "$do_loc/stata_packages"

***
*Build do files
***

*Reads mortality data and creates city-level data set with death information
do "$do_loc/build/mortality_data.do"

*Reads HIV/AIDS data
do "$do_loc/build/import_cdc_city_data.do"

*Creates city-year level data sets from SEER data. Also reads in BLS LAUS data and creates age-adjusted mortality rates
do "$do_loc/build/create_pop_emp.do"

*Create data set with years lost for AIDS death by year
do "$do_loc/build/life_years_saved.do"

*Creates year-city level data set as well as city level data set with funding information. This code also creates data set with Title 2 funding
do "$do_loc/build/rwca_allocations.do"

*Creates state-year data set with health insurance information and information on HIV criminalization laws
do "$do_loc/build/create_state_year_HI_HIVcrim_info.do"

*Creates state-level measures of AIDS deaths
do "$do_loc/build/create_state_info_spillovers.do"

*Combine data sets into analysis data set
do "$do_loc/build/combine_data.do"

*Produces summary statistics for mortality data for appendix (Table A.3)
do "$do_loc/build/death_stats_table_A3.do"

*Produces demographic information for Figure 8
do "$do_loc/build/create_info_heterogeneity_figures.do"

*Creates data set for RD analysis of HIV
do "$do_loc/build/create_rd_sample.do"

*Creates data set for RD analysis of AIDS outcomes
do "$do_loc/build/create_rd_sample_aids.do"

*Creates data sets with title 2 information  
do "$do_loc/build/create_title2.do"

*appendix figure A1
do "$do_loc/analysis/figure_A1.do"

*Calculates number of people in demographic groups in 2008 and 2018 and deletes interim files
do "$do_loc/build/create_info_for_pop_dynamics.do"
 
***
*Analysis do files
***

*table 1
do "$do_loc/analysis/table_1.do"

*table 2
do "$do_loc/analysis/table_2.do"

*table 3
do "$do_loc/analysis/table_3.do"

*table 4, appendix table A4, and figure 5
do "$do_loc/analysis/tables_4_A4_figure_5.do"

*table 5 and figures 6 and 7
do "$do_loc/analysis/table_5_figures_6_7.do"

*The following do file produces analysis not summarized in an exhibit. The do file produces the Goodman-Bacon Decomposition analysis described in the subsection titled "The Impact of Title 1 Status on HIV/AIDS Death Rates"
do "$do_loc/analysis/decomp_gb.do"

*The following do file produces analysis not summarized in an exhibit. The do file produces an estimate of the Title 2 offset mentioned in "Spending per Live Saved, Total Lives Saved, and Cost-Benefit Analysis" and described in more detail in Appendix C. Estimates from this do file are used in the table_6 do file.
do "$do_loc/analysis/title2.do"

*table 6
do "$do_loc/analysis/table_6.do"

*table 7 and figure 8
do "$do_loc/analysis/table_7_figure_8.do"

*table 8
do "$do_loc/analysis/table_8.do"

*table 9
do "$do_loc/analysis/table_9.do"

*The following do file produces analysis not summarized in an exhibit. The do file produces the analysis described in the subsection titled "Population Dynamics" 
do "$do_loc/analysis/pop_dynamics.do"

*The following do file produces analysis not summarized in an exhibit. The do file produces the analysis described in the subsection titled "Spillovers and HIV Transmission"
do "$do_loc/analysis/hiv_cases_avoided.do"

*figure 1
do "$do_loc/analysis/figure_1.do"

*figures 2, 9, and 10 and appendix figures A2 and A9
do "$do_loc/analysis/figures_2_9_10_A2_A9.do"

*figures 3 and 11 and appendix figures A3 and A10
do "$do_loc/analysis/figures_3_11_A3_A10.do"

*figure 4
do "$do_loc/analysis/figure_4.do"

*figure 12
do "$do_loc/analysis/figure_12.do"

*figure 13
do "$do_loc/analysis/figure_13.do"

*figure 14
do "$do_loc/analysis/figure_14.do"

*appendix table A1
do "$do_loc/analysis/table_A1.do"

*appendix table A2
do "$do_loc/analysis/table_A2.do"

*appendix table A5
do "$do_loc/analysis/table_A5.do"

*appendix table A6 and appendix figure A4
do "$do_loc/analysis/table_A6_figure_A4.do"

*appendix table A7
do "$do_loc/analysis/table_A7.do"

*appendix figure A5
do "$do_loc/analysis/figure_A5.do"

*appendix figure A6
do "$do_loc/analysis/figure_A6.do"

*appendix figure A7
do "$do_loc/analysis/figure_A7.do"

*appendix figure A8
do "$do_loc/analysis/figure_A8.do"

*appendix figure A11
do "$do_loc/analysis/figure_A11.do"

*appendix table B1 and appendix figure B1
do "$do_loc/analysis/table_B1_figure_B1.do"

*Delete text and temp files from output
cd "$output_loc/"
foreach filetype in "*.txt" "*.tmp"{
	local files_to_delete: dir "`workdir'" files "`filetype'" 
	foreach file_to_delete of local files_to_delete {
		rm "`file_to_delete'"
		}
}