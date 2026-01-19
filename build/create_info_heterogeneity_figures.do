***
*Calculate demographic information for all deaths
***
use "$data_loc/interim/vs_raw_data.dta", replace
gen age_0_17= age_years<18
gen age_18_64= age_years>=18&age_years<65
gen age_65p= age_years>=65&age_years!=.
collapse (sum) male female age_0_17 age_18_64 age_65p black white othrace all
foreach var in male female age_0_17 age_18_64 age_65p black white othrace{
	gen all_deaths`var'=(`var'/all)*100
}
gen id=1
drop male female age_0_17 age_18_64 age_65p black white othrace all
reshape long all_deaths, i(id) j(type) string
gen group="Younger than 18" if type== "age_0_17"
replace group="Ages 18 to 64" if type== "age_18_64"
replace group="65 or Older" if type== "age_65p"
replace group="Black" if type== "black"
replace group="White" if type== "white"
replace group="Not Black or White" if type== "othrace"
replace group="Male" if type== "male"
replace group="Female" if type== "female"
drop id
tempfile for_desc
save `for_desc', replace

use "$data_loc/data_public/usa_ipums_download.dta", replace
gen male= sex==1
gen female = sex==2
gen age_0_17= age<18
gen age_18_64= age>=18&age<65
gen age_65p= age>=65&age!=.
gen white=race ==1
gen black=race ==2
gen othrace=white==0&black==0
collapse (mean) male female age_0_17 age_18_64 age_65p black white othrace [fweight=perwt]
foreach var in male female age_0_17 age_18_64 age_65p black white othrace {
	gen pop_2018`var'=(`var')*100
}
drop male female age_0_17 age_18_64 age_65p black white othrace 
gen id=1
reshape long pop_2018, i(id) j(type) string
gen group="Younger than 18" if type== "age_0_17"
replace group="Ages 18 to 64" if type== "age_18_64"
replace group="65 or Older" if type== "age_65p"
replace group="Black" if type== "black"
replace group="White" if type== "white"
replace group="Not Black or White" if type== "othrace"
replace group="Male" if type== "male"
replace group="Female" if type== "female"
drop id
merge 1:1 group using `for_desc'
drop _merge
sort type
export excel using "$output_loc/deaths_pop.xls", firstrow(variables) replace

***
*Show correlation between city and state insurance coverage
***
use "$data_loc/data_public/usa_ipums_download.dta", clear
keep if age<65&age>17
merge m:1 statefip countyfip  using "$data_loc/interim/city_county_cw.dta"
drop if _merge==2
drop _merge
gen year=2018
merge m:1 cityfip year using  "$data_loc/cleaned/rwca_sample.dta", keepusing(within25 year_rwca )
drop if _merge==2
gen unins_samp=hcovany==1 if within25==1
gen mcaid_samp=hinscaid==2 if within25==1
gen pop=1

preserve
gen unins=hcovany==1 
gen mcaid=hinscaid==2 
collapse (mean) unins mcaid [aweight=perwt], by (statefip)

tempfile acs_state
save `acs_state', replace
restore
keep if within25==1
collapse (mean) unins_samp mcaid_samp (sum) pop [fweight=perwt], by (statefip cityfip)

merge m:1 statefip using `acs_state'
drop if _merge==2
drop _merge

collapse (mean) unins_samp mcaid_samp unins mcaid [fweight=pop], by ( cityfip)

capture log close
log using "$output_loc/state_city_ins_corr", replace
*Insurance correlation between cities and states
display "Correlation for uninsured rates: " 
corr unins_samp unins
display "Correlation for Medicaid rates: " 
corr mcaid_samp mcaid
capture log close