***
*To weight means by population, create a data set with number of people in each city in each county/state
***
clear
infix using "$do_loc/build/seer_population_data.dct", using("$data_loc/data_public/us.1969_2018.singleages.adjusted.txt")
keep if year>1987&year<2019
collapse (sum) population, by(statefip countyfip year)
merge m:1 statefip countyfip using "$data_loc/interim/city_county_cw.dta"
keep if _merge==3
drop _merge
merge m:1 cityfip using "$data_loc/interim/t1years.dta"
keep if _merge==3
drop _merge
keep statefip countyfip population cityfip city year
statastates, fips(statefip)
drop state_name
keep if _merge==3
drop _merge
rename state_abbrev state_postal
compress
save "$data_loc/interim/rwca_medicaid_info.dta", replace
import excel "$data_loc/data_public/state_info.xlsx", sheet("Sheet1") firstrow clear
merge 1:m statefip using "$data_loc/interim/rwca_medicaid_info.dta"
keep if _merge==3
drop _merge

***
*Information below comes from Lehman et al. (2014) and McMorrow et al. (2017)
***

***
*Laws criminalizing HIV exposure
***
gen hiv_crim=year>=hiv_crim_first_yr
gen num_hiv_crim=0
replace num_hiv_crim= 3 if state_postal=="FL"
replace num_hiv_crim=4 if state_postal=="FL"&year>1992
replace num_hiv_crim=1 if state_postal=="TN"
replace num_hiv_crim=2 if state_postal=="TN"&year>1990
replace num_hiv_crim=3 if state_postal=="TN"&year>1993
replace num_hiv_crim=1 if state_postal=="WA"
replace num_hiv_crim=1 if state_postal=="LA"
replace num_hiv_crim=1 if state_postal=="NV"
replace num_hiv_crim=2 if state_postal=="NV"&year>1988
replace num_hiv_crim=3 if state_postal=="NV"&year>1992
replace num_hiv_crim=3 if state_postal=="CA"
replace num_hiv_crim=4 if state_postal=="CA"&year>1997
replace num_hiv_crim=1 if state_postal=="GA"
replace num_hiv_crim=2 if state_postal=="GA"&year>2002
replace num_hiv_crim=1 if state_postal=="ID"
replace num_hiv_crim=1 if state_postal=="IN"
replace num_hiv_crim=2 if state_postal=="IN"&year>1992
replace num_hiv_crim=3 if state_postal=="IN"&year>1994
replace num_hiv_crim=5 if state_postal=="IN"&year>2001
replace num_hiv_crim=2 if state_postal=="MI"
replace num_hiv_crim=1 if state_postal=="MO"
replace num_hiv_crim=2 if state_postal=="MO"&year>2001
replace num_hiv_crim=3 if state_postal=="MO"&year>2004
replace num_hiv_crim=1 if state_postal=="NC"
replace num_hiv_crim=1 if state_postal=="OH"
replace num_hiv_crim=4 if state_postal=="OH"&year>1995
replace num_hiv_crim=5 if state_postal=="OH"&year>1996
replace num_hiv_crim=6 if state_postal=="OH"&year>1998
replace num_hiv_crim=1 if state_postal=="OK"
replace num_hiv_crim=1 if state_postal=="SC"
replace num_hiv_crim=2 if state_postal=="SC"&year>1996
replace num_hiv_crim=1 if state_postal=="AR"&year>1988
replace num_hiv_crim=1 if state_postal=="IL"&year>1988
replace num_hiv_crim=1 if state_postal=="MD"&year>1988
replace num_hiv_crim=1 if state_postal=="ND"&year>1988
replace num_hiv_crim=1 if state_postal=="VA"&year>1988
replace num_hiv_crim=2 if state_postal=="VA"&year>1999
replace num_hiv_crim=2 if state_postal=="CO"&year>1989
replace num_hiv_crim=3 if state_postal=="CO"&year>1998
replace num_hiv_crim=2 if state_postal=="KY"&year>1989
replace num_hiv_crim=2 if state_postal=="OK"&year>1990
replace num_hiv_crim=1 if state_postal=="KS"&year>1991
replace num_hiv_crim=1 if state_postal=="UT"&year>1991
replace num_hiv_crim=2 if state_postal=="UT"&year>1992
replace num_hiv_crim=1 if state_postal=="MN"&year>1994
replace num_hiv_crim=1 if state_postal=="PA"&year>1994
replace num_hiv_crim=3 if state_postal=="PA"&year>1997
replace num_hiv_crim=1 if state_postal=="NJ"&year>1996
replace num_hiv_crim=1 if state_postal=="IA"&year>1997
replace num_hiv_crim=1 if state_postal=="SD"&year>1999
replace num_hiv_crim=1 if state_postal=="WI"&year>2001
replace num_hiv_crim=2 if state_postal=="MS"&year>2003
replace num_hiv_crim=1 if state_postal=="AK"&year>2005
replace num_hiv_crim=1 if state_postal=="NE"&year>2010
save "$data_loc/interim/rwca_medicaid_info.dta", replace

***
*Get health insurance information from IPUMS ASEC CPS.
***
use "$data_loc/data_public/cps_ipums_download.dta", replace
drop if age<1
replace year=year-1
keep if year>1987&year<2019
gen mcaid= himcaidly==2 if himcaidly==1| himcaidly==2
gen anyhins=verify==0|hcovany==2| anycovly==2
gen nohins=anyhins==0
gen m=sex==1
gen pa=age>17&age<65
gen mpa=m==1&pa==1
foreach group in m pa mpa{
	foreach var in mcaid nohins{
		gen `var'_`group'=`var'==1 if `group'==1
	}
}
collapse (mean) mcaid nohins mcaid_m nohins_m mcaid_pa nohins_pa mcaid_mpa nohins_mpa [aweight=asecwth], by(year statefip) 
merge 1:m statefip year using "$data_loc/interim/rwca_medicaid_info.dta"
drop if statefip ==15|_merge==1
drop _merge
gen med209b=inlist(state_postal, "CT", "HI", "IL","MN", "MO", "NH")
replace med209b=1 if inlist(state_postal, "ND", "OH", "OK","VA")
replace med209b=1 if state_postal=="IN"&year<2014
gen med_no_aut=med209b==1|inlist(state_postal, "AK", "ID", "KS", "NE", "NV", "OR", "UT")==1
gen med_childless=year>=2001&state_postal=="NY"
replace med_childless=1 if year>=2007&state_postal=="MA"
replace med_childless=1 if year>=1996&state_postal=="DE"
replace med_childless=1 if year>=2014 &(inlist(state_postal, "AZ", "CA", "CO", "CT", "NJ", "MN")==1|inlist(state_postal, "NV", "OH", "OR", "RI", "IN", "WA")==1)
replace med_childless=1 if year>=2015&state_postal=="PA"
replace med_childless=1 if year>=2016&state_postal=="LA"

collapse (mean) mcaid nohins mcaid_m nohins_m mcaid_pa nohins_pa mcaid_mpa nohins_mpa afdc96 med_no_aut med_childless num_hiv_crim hiv_crim [aweight=population], by(year cityfip) 
compress
save "$data_loc/interim/state_year_controls.dta", replace