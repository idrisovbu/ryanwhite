************
* Read HIV/AIDS data from APIDS and CDC
************
*import 1994 AIDS cases
import delimited "$data_loc/data_public/aids_cases_rwca_1994.txt", clear 
drop if locationcode==.
keep cases locationcode location
rename locationcode cityfip
rename cases aids_reported_by_1995
save "$data_loc/interim/aids_cases_rwca_1994.dta", replace

*import 1995 AIDS cases
import delimited "$data_loc/data_public/aids_cases_rwca_1995.txt", clear 
drop if locationcode==.
keep cases locationcode location
rename locationcode cityfip
rename cases aids_reported_in_1995
save "$data_loc/interim/aids_cases_rwca_1995.dta", replace

*import Title 1 info
import excel "$data_loc/data_public/t1years.xlsx", sheet("Sheet1") firstrow clear
drop if city=="Honolulu, HI"
drop if city=="San Juan, PR"
gen state_postal=substr(city,length(city)-1,2)
replace state_postal ="NM" if state_postal=="M."
destring cityfip, replace
merge m:1 cityfip using "$data_loc/interim/aids_cases_rwca_1995.dta"
drop if _merge==2
drop _merge
merge m:1 cityfip using "$data_loc/interim/aids_cases_rwca_1994.dta"
drop if _merge==2
drop _merge
gen aids_ever_1995_imp=round(aids_reported_by_1995+.25*aids_reported_in_1995)
sort aids_ever_1995_imp aids_reported_by_1995
gen rank_1995=_n 
keep cityfip year_rwca_status aids_ever_1995_imp rank_1995 state_postal
compress
save "$data_loc/interim/t1years.dta", replace
keep cityfip
save "$data_loc/interim/apids_cities.dta", replace

*import AIDS cases reported by year from APIDS
import delimited "$data_loc/data_public/aids_cases_rep_year.txt",  clear
gen aids_rep= cases
gen year=yearreportedcode
rename locationcode cityfip
drop if cityfip==.
keep aids_rep cityfip year
save "$data_loc/interim/aids_cases_reported.dta", replace

*import AIDS cases diagnosed by year from APIDS
import delimited "$data_loc/data_public/aids_cases_diag_year.txt",  clear
gen aids_diag_apids= cases
gen year=yeardiagnosedcode
rename locationcode cityfip
drop if cityfip==.
keep aids_diag_apids cityfip year
save "$data_loc/interim/aids_cases_diagnosed.dta", replace

*import aids_diagnosis from CDC
import delimited "$data_loc/data_public/AIDS Diagnosis by MSA.csv", clear 
reshape long aids_diagnosis_all, i(locationcode) j(year)
rename locationcode cityfip
save "$data_loc/interim/cdc_city_aids_diagnosis", replace

*import aids_prev (estimates of people living with AIDS) from CDC
import delimited "$data_loc/data_public/AIDS Prevalence by MSA.csv", clear 
reshape long aids_prev_all, i(locationcode) j(year)
*Greenville, SC fluctuates a lot in certain years for this variable. When I reached out to the CDC, the contact looked into the issue and told me that there appears to be a data quality issue for AIDS prevalence for Greenville. However, Panels C and D of Figure 10 (the only places this information is used) are very similar if original data is used. 
replace aids_prev_all=. if locationcode==3160
rename locationcode cityfip
keep if inlist(year, 1990, 2006, 2012, 2018)==1
save "$data_loc/interim/cdc_city_aids_prev", replace

*import hiv_diagnosis from CDC
import delimited "$data_loc/data_public/HIV Diagnosis by MSA.csv", clear 
keep locationcode hiv_diagnosis_all2008
rename locationcode cityfip
rename hiv_diagnosis_all2008 hiv_diag
compress
save "$data_loc/interim/cdc_city_hiv_diagnosis", replace

*import hiv_prev from CDC
import delimited "$data_loc/data_public/HIV Prevalence by MSA.csv", clear 
keep locationcode hiv_prev_all2008
rename locationcode cityfip
rename hiv_prev_all2008 hiv_prev
compress
save "$data_loc/interim/cdc_city_hiv_prev", replace