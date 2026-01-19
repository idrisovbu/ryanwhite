***
*Import SEER data to attribute each city's share of title 1 funding to state
***
clear
infix using "$do_loc/build/seer_population_data.dct", using("$data_loc/data_public/us.1990_2018.singleages.adjusted.txt")

keep if year>1987
keep if year==1990
gen pop_county= population
collapse (sum) pop_county , by ( countyfip statefip )

merge m:1 statefip countyfip using "$data_loc/interim/city_county_cw.dta"
keep if _merge==3
drop _merge

merge m:1 cityfip using "$data_loc/interim/t1years.dta"
keep if _merge==3
drop _merge

collapse (sum) pop_county , by (cityfip statefip)
egen tot_city_pop=sum(pop_county), by( cityfip)
gen state_sh=pop_county/tot_city_pop 
save "$data_loc/interim/seer_info_by_statecity.dta", replace

***
*Calculate each city's share of title 1 funding to state
***
use "$data_loc/cleaned/rwca_sample.dta", replace

keep year cityfip within25 
merge 1:1 cityfip year using "$data_loc/interim/title1_funding_by_cityyear.dta"
drop _merge
replace title1_funding=0 if title1_funding==.

joinby cityfip using "$data_loc/interim/seer_info_by_statecity.dta"

foreach var in within25 title1_funding {
	replace `var'=`var'*state_sh
}
collapse (sum) within25 title1_funding pop_county, by(statefip year )
keep if year>1992

***
*Merge Title 2 funding and aids cases
***
merge 1:1 statefip year using "$data_loc/interim/title2_funding_by_stateyear.dta"
drop _merge

merge 1:1 statefip year using "$data_loc/interim/aids_state_year.dta"
drop _merge
compress
replace title1_funding=0 if title1_funding==.
replace within25=0 if within25==.
egen total_ann_aids=sum(aids_state_year), by (year)
gen share_aids=aids_state_year/total_ann_aids
drop statefip aids_state_year total_ann_aids pop_county

label var year `"year"'
label var within25 `"25 cities on either side of cutoff"'
label var title1_funding `"title 1 funding"'
label var title2_funding_annual `"title 2 funding"'
label var share_aids `"share of aids cases in state"'

save "$data_loc/cleaned/rwca_state_funding.dta", replace