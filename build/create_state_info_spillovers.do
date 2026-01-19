***
*Import SEER at State level
***
clear
infix using "$do_loc/build/seer_population_data.dct", using("$data_loc/data_public/us.1969_2018.singleages.adjusted.txt")
keep if year>1987
gen pop_male= population if sex==1
gen pop_female=  population if sex==2
gen pop_white= population if race==1
gen pop_black= population if race==2
gen pop_othrace= population if race==3
gen pop_0_17= population if age<18
gen pop_18_64= population if age>=18&age<65
gen pop_65p= population if age>=65
gen pop_all= population
collapse (sum) pop_male pop_female pop_white pop_black pop_othrace pop_0_17 pop_18_64 pop_65p pop_all , by(year countyfip statefip)
merge m:1 statefip countyfip  using "$data_loc/interim/city_county_cw.dta"
drop if _merge==2
drop _merge
merge m:1  cityfip using "$data_loc/interim/apids_cities.dta"
drop if _merge==2
replace cityfip =0 if _merge!=3
drop _merge
sort cityfip year statefip 
collapse (sum) pop_male pop_female pop_white pop_black pop_othrace pop_0_17 pop_18_64 pop_65p pop_all, by(year cityfip statefip)
compress
save "$data_loc/interim/rwca_non_city", replace

***
*Bring in info for state-level hisp control
***
clear
infix using "$do_loc/build/seer_population_data.dct", using("$data_loc/data_public/us.1990_2018.singleages.adjusted.txt")
label define origin 0 "non-hispanic" 1 "hispanic"
gen pop_hisp=  population if origin==1
collapse (sum) pop_hisp, by(year countyfip statefip)
merge m:1 statefip countyfip  using "$data_loc/interim/city_county_cw.dta"
drop if _merge==2
drop _merge
merge m:1  cityfip using "$data_loc/interim/apids_cities.dta"
drop if _merge==2
replace cityfip =0 if _merge!=3
drop _merge
collapse (sum) pop_hisp, by(year cityfip statefip)
merge 1:1 year cityfip statefip using  "$data_loc/interim/rwca_non_city"
drop _merge
compress
save "$data_loc/interim/rwca_non_city", replace

***
*AIDS deaths
***
use  "$data_loc/interim/vs_cty_year.dta", replace
merge m:1 statefip countyfip  using "$data_loc/interim/city_county_cw.dta"
drop if _merge==2
drop _merge
merge m:1  cityfip using "$data_loc/interim/apids_cities.dta"
drop if _merge==2
replace cityfip =0 if _merge!=3
drop _merge
sort cityfip year statefip 
collapse (sum) aids_dths_all , by(year cityfip statefip)
merge 1:1 year cityfip statefip using  "$data_loc/interim/rwca_non_city"
drop _merge
compress
save "$data_loc/interim/rwca_non_city", replace

***
*Create state-level measures outside of apids cities
***
use "$data_loc/interim/rwca_non_city", replace
keep if cityfip==0
collapse (sum) pop_male pop_female pop_white pop_black pop_othrace pop_0_17 pop_18_64 pop_65p pop_hisp pop_all aids_dths_all, by(year statefip)
foreach var in _white _black _othrace _male _female  _0_17 _18_64  _65p _hisp{
gen perc`var'=pop`var'/pop_all
}
gen aids_dths_all_100k=aids_dths_all/pop_all*100000
keep year statefip aids_dths_all_100k perc*
tempfile file2
save `file2', replace

use "$data_loc/interim/rwca_non_city", replace
sort statefip cityfip year
by statefip cityfip: gen pop_weight = pop_all[3]
keep if cityfip!=0&cityfip!=.
joinby   statefip year  using `file2'
collapse (mean) perc_white-aids_dths_all_100k   [fweight= pop_weight], by  (year cityfip)

foreach var in perc_white perc_black  perc_male  perc_0_17  perc_65p perc_hisp {
	rename `var' `var'_st
}
gen laids_dths_all_100k_st=log(aids_dths_all_100k)
drop aids_dths_all_100k perc_othrace perc_female perc_18_64
compress
save "$data_loc/interim/rwca_non_city", replace