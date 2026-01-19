***
*Descriptives for mortality data
***
use "$data_loc/interim/vs_raw_data.dta", replace
merge m:1 statefip countyfip using "$data_loc/interim/city_county_cw.dta"
drop if _merge==2
drop _merge
merge m:1 cityfip using "$data_loc/interim/apids_cities.dta"
gen in_apids=_merge==3

putexcel set "$output_loc/tableA3.xls", sheet(Sheet1) replace
gen age_0_17= age_years<18
gen age_18_64= age_years>=18&age_years<65
gen age_65p= age_years>=65&age_years!=.
tabstat male female age_0_17 age_18_64 age_65p age_years black white othrace in_apids if aids_dths==1 , stat(mean ) save
matrix results = r(StatTotal)'
putexcel A1 = "AIDS Deaths"
putexcel A2 = matrix(results), names nformat(number_d2)
putexcel A14 = "N"
count if aids_dths==1
putexcel A15 = `r(N)'

tabstat male female age_0_17 age_18_64 age_65p age_years black white othrace in_apids if aids_dths==0 , stat(mean ) save
matrix results = r(StatTotal)'
putexcel D1 = "Non-AIDS Deaths"
putexcel D2 = matrix(results), names nformat(number_d2)
count if aids_dths==0
putexcel D15 = `r(N)'