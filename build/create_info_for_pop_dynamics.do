***
*GSS Data for Injection Drug Use
***
use "$data_loc/data_public/GSS2018.dta", clear
gen drug_use= evidu==1 if evidu==1|evidu==2
sum drug_use [aweight=adults]
local share_adults_inj_drugs=r(mean)

***
*SEER Data for Information on 2008 and 2018 Populations
***
clear
infix using "$do_loc/build/seer_population_data.dct", using("$data_loc/data_public/us.1990_2018.singleages.adjusted.txt")
keep if year==2018|year==2008
merge m:1 statefip countyfip using "$data_loc/interim/city_county_cw.dta"
keep if _merge==3
drop _merge
merge m:1 cityfip using "$data_loc/interim/t1years.dta"
drop if _merge==2
drop _merge
gen pop_black_male_adults=population if sex==1&race==2&age>17
gen pop_black=population if race==2
gen pop_male_adults= population if sex==1&age>17
gen pop_adults=population if age>17
gen pop_males= population if sex==1
gen pop_all=population
*For 2008, need to drop later Title 1 cities to be consistent with HIV analysis
drop if year_rwca_status>1996 & year==2008
collapse (sum) pop_black_male_adults-pop_all, by (cityfip year)
tempfile file1
save `file1', replace

***
*Combine with Gallup data for information on LGBT people 
***
import excel "$data_loc/data_public/gallup.xlsx", sheet("Sheet1") firstrow clear
destring cityfip, replace
merge 1:m cityfip using `file1'
keep if _merge==3
drop _merge
sum gays_gallup_2012_2014
replace gays_gallup_2012_2014=r(mean) if gays_gallup_2012_2014==.
gen gay_black_men=gays_gallup_2012_2014/100*pop_black_male_adults
gen gay_men=gays_gallup_2012_2014/100*pop_male_adults
gen inj_users=`share_adults_inj_drugs' *(pop_adults)
collapse (sum) pop_black pop_all  pop_males gay_black_men gay_men inj_users, by(year)
foreach var in pop_black pop_all  pop_males gay_black_men gay_men inj_users{
	replace `var'=int(`var')
}
order year pop_all pop_males  pop_black gay_black_men gay_men inj_users
sort year 
compress

label var year `"year"'
label var pop_all `"number of people"'
label var pop_males `"number of males"'
label var pop_black `"number of black people"'
label var gay_black_men `"number of black males"'
label var gay_men `"number of gay men"'
label var inj_users `"number of injection drug users"'

save "$data_loc/cleaned/pop_08_18.dta", replace

*Run code to delete interim files
cd "$data_loc/interim/"
local datafiles: dir "`workdir'" files "*"
foreach datafile of local datafiles {
		rm "`datafile'"
}
