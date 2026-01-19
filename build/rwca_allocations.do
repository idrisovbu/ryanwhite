import excel "$data_loc/data_public/prices_fred.xls", sheet("FRED Graph") firstrow clear
gen year =year(date)
collapse (mean) cpi, by(year)
keep if year>1990&year<2019
tempfile file1
save `file1', replace

import excel using "$data_loc/data_public/title1.xls", sheet("Sheet1") firstrow clear
merge m:1 year using `file1'
drop _merge
replace title1_funding = title1_funding*251.10142/cpi
drop cpi
save "$data_loc/interim/title1_funding_by_cityyear.dta", replace

gen funding_1991_1995= title1_funding if year<1996
gen funding_1996_2000=title1_funding if year>1995&year<2001
gen funding_1996_2006=title1_funding if year>1995&year<2007
gen funding_2007_2018=title1_funding if year>2006&year<2019
gen funding_2001_2006=title1_funding if year>2000&year<2007
gen funding_1991_2018=title1_funding if year>1990&year<2019
collapse (sum) funding_1991_1995-funding_1991_2018, by(cityfip)
compress
save "$data_loc/interim/agg_title1_funding_by_city.dta", replace

****
*Used for appendix
****
*https://gis.cdc.gov/grasp/nchhstpatlas/tables.html
import delimited "$data_loc/data_public/AtlasPlusTableData_state.csv", clear 
keep year fips cases 
rename fips statefip
tempfile file2
save `file2'

*from CDC's HIV/AIDS Surveillance Reports
import excel "$data_loc/data_public/surv_report_data.xlsx", sheet("Sheet1") firstrow clear
reshape long living_aids, i(state) j(year)
rename living_aids cases
statastates, name(state)
keep if _merge==3
drop _merge
rename state_fips statefip
drop state state_abbrev
append using  `file2'

rename cases aids_state_year
keep year statefip aids_state_year
save "$data_loc/interim/aids_state_year.dta", replace

import excel "$data_loc/data_public/title2.xls", sheet("Sheet1") firstrow clear
merge m:1 year  using  `file1'
keep if _merge==3
drop _merge
replace title2_funding_annual = title2_funding_annual*251.10142/cpi
drop cpi
compress
sort statefip year
save "$data_loc/interim/title2_funding_by_stateyear.dta", replace
