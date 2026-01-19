************
*Create data at city-year level for controls and to calculate rates from 1987.
************
clear
infix using "$do_loc/build/seer_population_data.dct", using("$data_loc/data_public/us.1969_2018.singleages.adjusted.txt")
keep if year>1987

merge m:1 statefip countyfip using "$data_loc/interim/city_county_cw.dta"
keep if _merge==3
drop _merge

merge m:1 cityfip using "$data_loc/interim/apids_cities.dta"
keep if _merge==3
drop _merge

preserve
collapse (sum) population , by(year cityfip age)
save "$data_loc/interim/seer_city_for_age_adjust.dta", replace
restore

gen pop_male= population if sex==1
gen pop_female= population if sex==2
gen pop_white= population if race==1
gen pop_black= population if race==2
gen pop_othrace= population if race==3
gen pop_0_17= population if age<18
gen pop_18_64= population if age>=18&age<65
gen pop_65p= population if age>=65
gen pop_all= population

*For controls and for calculating rates by demographic characteristics
foreach var in black white othrace male female 0_17 18_64 65p{
foreach group in black white othrace male female 0_17 18_64 65p{
	if "`group'"!="`var'"{
		gen pop`var'_`group' = pop_`group' if pop_`var'!=.
		}
}
}
collapse (sum) pop_male-pop65p_18_64 , by (year cityfip)

foreach var in _white _black _othrace _male _female _0_17 _18_64 _65p{
	gen perc`var'=pop`var'/pop_all
}

foreach group in black white othrace male female 0_17 18_64 65p{
foreach var in black white othrace male female 0_17 18_64 65p{
	if "`group'"!="`var'"{
		gen perc`var'of`group'= pop`var'_`group'/pop_`group'
		}
}
}
drop popblack_white-pop65p_18_64 
drop percwhiteofblack percothraceofblack percblackofwhite percothraceofwhite percblackofothrace percwhiteofothrace
drop perc18_64of0_17 perc65pof0_17 perc0_17of18_64 perc65pof18_64 perc0_17of65p perc18_64of65p
drop percmaleoffemale percmaleoffemale percfemaleofmale

compress
save "$data_loc/interim/seer_info_by_city.dta", replace

************
*Create data set for calculating age-adjusted rates.
************
clear
infix using "$do_loc/build/seer_population_data.dct", using("$data_loc/data_public/us.1990_2018.singleages.adjusted.txt")
keep if year==2000
collapse (sum) population, by(age )
egen pop_us=sum(population)
gen share_pop=population/ pop_us
drop population pop_us
compress
save "$data_loc/interim/seer_aa_weights.dta", replace

************
*Create age-adjusted mortality rates for AIDS deaths
************
use "$data_loc/interim/vs_raw_data.dta", replace
keep age_years year statefip countyfip aids_dths 
drop if age_years==.

merge m:1 statefip countyfip using "$data_loc/interim/city_county_cw.dta"
keep if _merge==3
drop _merge

merge m:1 cityfip using "$data_loc/interim/apids_cities.dta"
keep if _merge==3
drop _merge

collapse (sum) aids_dths , by (age_years cityfip year)
rename age_years age

merge 1:1 cityfip year age using "$data_loc/interim/seer_city_for_age_adjust.dta" 
keep if _merge==3
drop _merge

merge m:1 age using "$data_loc/interim/seer_aa_weights.dta"
keep if _merge==3
drop _merge

gen aids_dths_100k_aa= aids_dths /population*100000*share_pop
collapse (sum) aids_dths_100k_aa, by(year cityfip)
keep year cityfip aids_dths_100k_aa

compress
save "$data_loc/interim/vs_city_age_adjusted.dta", replace

************
*Create data at city-year level for 1990+ for Hispanic pop.
************
clear
infix using "$do_loc/build/seer_population_data.dct", using("$data_loc/data_public/us.1990_2018.singleages.adjusted.txt")

merge m:1 statefip countyfip using "$data_loc/interim/city_county_cw.dta"
keep if _merge==3
drop _merge

merge m:1 cityfip using "$data_loc/interim/apids_cities.dta"
keep if _merge==3
drop _merge

gen pop_male= population if sex==1
gen pop_female= population if sex==2
gen pop_white= population if race==1
gen pop_black= population if race==2
gen pop_othrace= population if race==3|race==4
gen pop_hisp= population if origin==1
gen pop_0_17= population if age<18
gen pop_18_64= population if age>=18&age<65
gen pop_65p= population if age>=65
gen pop_all= population

*For controls and for calculating rates by demographic characteristics
foreach var in hisp{
	foreach group in black white othrace male female 0_17 18_64 65p{
		gen pop`var'_`group' = pop_`group' if pop_`var'!=.
	}
}
collapse (sum) pop_male-pophisp_65p , by (year cityfip)
gen perc_hisp=pop_hisp/pop_all

foreach group in black white othrace male female 0_17 18_64 65p {
	foreach var in hisp{
		gen perc`var'of`group'= pop`var'_`group'/pop_`group'
	}
}
drop *pop* 
keep year cityfip *hisp*
compress
save "$data_loc/interim/seer_info_by_city_hisp.dta", replace

***********
*Create employment outcomes from BLS data at the county level
***********
import delimited "$data_loc/data_public/la.data.64.txt", clear 
gen statefip=substr(series_id,6,2 )
gen countyfip=substr(series_id,8,3 )
keep if period=="M13"
gen measure=substr(series_id,20,1)
destring statefip countyfip , replace
drop if measure=="3"|measure=="5"
gen unemp_total= value if measure=="4"
gen lf_total= value if measure=="6"

merge m:1 statefip countyfip using "$data_loc/interim/city_county_cw.dta"
keep if _merge==3
drop _merge

merge m:1 cityfip using "$data_loc/interim/apids_cities.dta"
keep if _merge==3
drop _merge

destring unemp_total lf_total, replace force

collapse (sum) unemp_total lf_total , by (cityfip year) 
gen unemp_rate=unemp_total/lf_total
keep year cityfip unemp_rate
compress
save "$data_loc/interim/laus_city_data.dta", replace