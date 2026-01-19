import excel "$data_loc/data_public/ssa_life_tables_2005.xlsx", sheet("Sheet1") firstrow clear
tempfile file1
save `file1'

use "$data_loc/interim/vs_raw_data.dta", replace
keep if year>1987&year<2019
keep if aids_dths==1
drop if age_years==.
keep  year age_years male female
rename age_years age

merge m:1 age using `file1'
drop if _merge==2
drop _merge

gen from_2018=2019-year

gen years_lost_proj=male_life_expectancy if male==1
replace years_lost_proj=female_life_expectancy if female==1

gen years_lost_proj_10y=years_lost_proj 
replace years_lost_proj_10y= 10 if  years_lost_proj >10

gen years_lost_through_2018= years_lost_proj
replace years_lost_through_2018=from_2018 if  years_lost_proj>from_2018

gen years_lost_through_2018_10y=years_lost_through_2018
replace years_lost_through_2018_10y=10 if  years_lost_through_2018>10

collapse (mean) years_lost_through_2018 years_lost_through_2018_10y, by(year )
compress
save "$data_loc/interim/ann_years_lost_aids.dta", replace