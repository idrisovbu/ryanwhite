************
*Create City-County Crosswalk. (Needed for other parts of the analysis to have same city definitions across time.)
************
clear
infix using "$do_loc/build/vital_stats_1995_dict.dct", using("$data_loc/data_restricted/mortality_from_cdc/MortAC1995/MULT1995.AllCnty/MULT1995.AllCnty.txt")
keep RESIDST CNTYRSID MSARSID
drop if MSARSID=="0000"
gen deaths_1995=1
destring RESIDST, gen(statefip)
destring CNTYRSID, gen (countyfip)
destring MSARSID, gen (cityfip)
local new = _N + 1
set obs `new'
*Miami county code changed
replace cityfip=5000 if cityfip==.
replace countyfip= 86 if countyfip==.
replace statefip =12 if statefip==.
bysort statefip countyfip cityfip: keep if _n==1
keep statefip countyfip cityfip
compress
save "$data_loc/interim/city_county_cw.dta", replace

************
*Read vital statistics mortality files
************
clear
infix using "$do_loc/build/vital_stats_1995_dict.dct", using("$data_loc/data_public/MORT87.pub")
keep STATEOCC CONTYOCC ICD34 RACE_DET DEATHMO SEX ICD9 AGEREC12 AGEDET
gen year =1987
compress
tempfile file1
save `file1', replace 

clear
infix using "$do_loc/build/vital_stats_1995_dict.dct", using("$data_loc/data_public/Vs88mort")
keep STATEOCC CONTYOCC ICD34 RACE_DET DEATHMO SEX ICD9 AGEREC12 AGEDET
gen year=1988
append using `file1' 
save `file1', replace 


forvalues i=1989/1995{
clear
infix using "$do_loc/build/vital_stats_1995_dict.dct", using("$data_loc/data_restricted/mortality_from_cdc/MortAC`i'/MULT`i'.AllCnty/MULT`i'.AllCnty.txt")
keep STATEOCC CONTYOCC ICD34 RACE_DET DEATHMO SEX ICD9 AGEREC12 AGEDET
gen year=`i'
compress
append using `file1' 
save `file1', replace 
}

forvalues i=1996/1998{
display `i'
clear 
infix using "$do_loc/build/vital_stats_1996_1998_dict.dct", using("$data_loc/data_restricted/mortality_from_cdc/MortAC`i'/MULT`i'.AllCnty/MULT`i'.AllCnty.txt")
keep STATEOCC CONTYOCC ICD34 RACE_DET DEATHMO SEX ICD9 AGEREC12 AGEDET
gen year=`i'
compress
append using `file1' 
save `file1' , replace
}

forvalues i=1999/1999{
display `i'
clear 
infix using "$do_loc/build/vital_stats_1999_2002_dict.dct", using("$data_loc/data_restricted/mortality_from_cdc/MortAC`i'/MULT`i'.AllCnty/MULT`i'.AllCnty.txt")
keep STATEOCC CONTYOCC ICD39 RACE_DET DEATHMO SEX ICD10 AGEREC12 AGEDET
gen year=`i'
compress
append using `file1' 
save `file1' , replace
}

forvalues i=2000/2001{
display `i'
clear 
infix using "$do_loc/build/vital_stats_1999_2002_dict.dct", using("$data_loc/data_restricted/mortality_from_cdc/MortAC`i'/MULT`i'.AllCnty/MULT`i'.USAllCnty.txt")
keep STATEOCC CONTYOCC ICD39 RACE_DET DEATHMO SEX ICD10 AGEREC12 AGEDET
gen year=`i'
append using `file1' 
save `file1' , replace
}

forvalues i=2002/2002{
display `i'
clear 
infix using "$do_loc/build/vital_stats_1999_2002_dict.dct", using("$data_loc/data_restricted/mortality_from_cdc/MortAC`i'/MULT`i'.USPSAllCnty/MULT`i'.USAllCnty.txt")
keep STATEOCC CONTYOCC ICD39 RACE_DET DEATHMO SEX ICD10 AGEREC12 AGEDET
gen year=`i'
append using `file1' 
save `file1' , replace
}

forvalues i=2003/2017{
display `i'
clear 
infix using "$do_loc/build/vital_stats_2005_current_dict.dct", using("$data_loc/data_restricted/mortality_from_cdc/MortAC`i'/MULT`i'.USPSAllCnty/MULT`i'.USAllCnty.txt")

keep STATEOCC CONTYOCC ICD39 RACE_DET DEATHMO SEX ICD10 AGEREC12 AGEDET
gen year=`i'
append using `file1' 
save `file1' , replace
}

forvalues i=2018/2018{
display `i'
clear 
infix using "$do_loc/build/vital_stats_2005_current_dict.dct", using("$data_loc/data_restricted/mortality_from_cdc/MortAC`i'/MULT`i'.USPSAllCnty/Mort`i'US.AllCnty.txt")
keep STATEOCC CONTYOCC ICD39 RACE_DET DEATHMO SEX ICD10 AGEREC12 AGEDET
gen year=`i'
append using `file1' 
save `file1' , replace
}
compress

*STATEOCC is sometimes postal code and sometimes FIPS code. The following crode creates variables that are consistent over time. 
destring STATEOCC, gen (statefip) force
statastates, fips(statefip)
drop if _merge==2
drop _merge
rename state_abbrev state_postal
rename state_name statename
gen state_postal_cd=STATEOCC if statefip==.
statastates, abbreviation(state_postal_cd)
drop if _merge==2
drop _merge
replace state_postal= state_postal_cd if state_postal==""
replace statefip = state_fips if statefip==.
replace state_name= statename if state_name==""
drop statename state_fips state_postal_cd STATEOCC state_name 

gen aids_dths= inlist(substr(ICD10,1,3), "B20", "B21", "B22", "B23", "B24")==1|inlist(substr(ICD9,1,3),"042", "043", "044")==1
gen cancer= (ICD39>"03"&ICD39<"16")|(ICD34>"039"&ICD34<"120")
gen cardio =(ICD39>"17"&ICD39<"23")|(ICD34>"129"&ICD34<"200")
gen cereb = (ICD39>"23"&ICD39<"27")|(ICD34>"199"&ICD34<"230")
gen lower_resp= ICD39=="28"|ICD34=="240"
gen all_acc= ICD39=="39"|ICD34=="340"|ICD39=="38"|ICD34=="330"
gen suicide= ICD39=="40"|ICD34=="350"
gen non_aids_all= aids_dths!=1

gen age_def=substr(AGEDET,1,1)
gen age_years="0" if (age_def>="2"&age_def<="6")
replace age_years=substr(AGEDET,2,3) if (age_def=="1" &year>2002)|(age_def=="0" &year<=2002)
replace age_years=substr(AGEDET,1,3) if (age_def=="1" &year<=2002)
replace age_years="" if (age_def=="9")| AGEREC12==12
destring age_years, replace

gen age="0_17" if age_years<18
replace age="18_64" if age_years>=18&age_years<65
replace age="65p" if age_years>=65&age_years!=.

gen black=RACE_DET==2
gen white=RACE_DET==1
gen othrace=black==0&white==0
gen male=SEX=="M"|SEX=="1"
gen female=male==0
gen all=1

*Put to fiscal year
replace year=year+1 if DEATHMO>9&DEATHMO<13
keep if year>1987&year<2019
rename CONTYOCC countyfip
keep statefip countyfip year state_postal-all
destring countyfip, replace
compress
save "$data_loc/interim/vs_raw_data.dta", replace
****End Importing Data****

************
*Collapse data to county-year level. I do this separately for each year to ease computational burden.
************
forvalues i=1988/2018{
display `i'
use "$data_loc/interim/vs_raw_data.dta", replace
	keep if year==`i'
foreach var in black white othrace male female all{
	gen aids_dths_`var'=aids_dths if `var'==1
}

foreach age in 0_17 18_64 65p {
gen aids_dths_`age'=aids_dths==1&age=="`age'"
}
collapse (sum) aids_dths_black-aids_dths_65p cancer-non_aids_all, by (year statefip countyfip ) fast
if `i'==1988{
save "$data_loc/interim/vs_cty_year.dta", replace
}
if `i'!=1988{
append using "$data_loc/interim/vs_cty_year.dta"
save "$data_loc/interim/vs_cty_year.dta", replace
}
}
sum aids_dths_all if year>=1991&year<=2018
global num_aids_deaths_91_18= `r(sum)'

************
*Create city-level data set 
************
compress
merge m:1 statefip countyfip using "$data_loc/interim/city_county_cw.dta"
keep if _merge==3
drop _merge
sort cityfip year statefip non_aids_all
collapse (sum) aids_dths_black-aids_dths_65p cancer-non_aids_all (last) statefip, by (year cityfip )
save "$data_loc/interim/vs_city_year.dta", replace
