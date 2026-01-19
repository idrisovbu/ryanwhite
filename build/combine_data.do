use "$data_loc/interim/seer_info_by_city.dta", replace 

merge 1:1 year cityfip using "$data_loc/interim/seer_info_by_city_hisp.dta"
drop _merge

merge m:1 cityfip year using "$data_loc/interim/vs_city_year.dta"
drop if _merge==2
drop _merge

merge 1:1 cityfip year using "$data_loc/interim/laus_city_data.dta"
drop if _merge==2
drop _merge

merge m:1 cityfip using "$data_loc/interim/t1years.dta"
drop if _merge==2
drop _merge

merge m:1 cityfip year using "$data_loc/interim/aids_cases_reported.dta"
drop if _merge==2
drop _merge

merge m:1 cityfip year using "$data_loc/interim/aids_cases_diagnosed.dta"
drop if _merge==2
drop _merge

merge 1:1 cityfip year using "$data_loc/interim/cdc_city_aids_prev"
drop if _merge==2
drop _merge

merge 1:1 cityfip year using "$data_loc/interim/cdc_city_aids_diagnosis"
drop if _merge==2
drop _merge

merge 1:1 year cityfip using "$data_loc/interim/rwca_non_city"
drop if _merge==2
drop _merge

merge m:1 cityfip using "$data_loc/interim/agg_title1_funding_by_city.dta"
drop if _merge==2
drop _merge

merge 1:1 cityfip year using "$data_loc/interim/state_year_controls.dta"
drop if _merge==2
drop _merge

merge 1:1 year cityfip using "$data_loc/interim/vs_city_age_adjusted.dta"
drop _merge

merge m:1 year using "$data_loc/interim/ann_years_lost_aids.dta"
drop _merge

foreach var in aids_dths_all {
gen `var'_100k=`var'/pop_all*100000
gen l`var'_100k = log(`var'_100k)
}

foreach var in funding_1991_1995 funding_1996_2006 funding_2007_2018 funding_1991_2018{
	replace `var'= 0 if `var'==.
}
gen within30= aids_ever_1995_imp<7500 & aids_ever_1995_imp>750
gen within5= aids_ever_1995_imp<2180 & aids_ever_1995_imp>1550
gen within25= aids_ever_1995_imp<4700 & aids_ever_1995_imp>883
gen within20= aids_ever_1995_imp<4150 & aids_ever_1995_imp>1010

gen treatment_group= aids_ever_1995_imp>2000 if within25==1
gen rwca_status=year>=year_rwca_status&aids_ever_1995_imp>2000

sort cityfip year

label var year `"fiscal year"'
label var cityfip `"city fips code"'
label var pop_male `"number of males"'
label var pop_female `"number of females"'
label var pop_white `"number of white people"'
label var pop_black `"number of black people"'
label var pop_othrace `"number of people of other race"'
label var pop_0_17 `"number of people younger than 18"'
label var pop_18_64 `"number of people 18 to 64"'
label var pop_65p `"number of people 65 or older"'
label var pop_all `"number of people"'
label var perc_white `"share of population white"'
label var perc_black `"share of population black"'
label var perc_othrace `"share of population of other race"'
label var perc_male `"share of population male"'
label var perc_female `"share of population female"'
label var perc_0_17 `"share of population younger than 18"'
label var perc_18_64 `"share of population 18 to 64"'
label var perc_65p `"share of population 65 or older"'
label var percmaleofblack `"share of black population male"'
label var percfemaleofblack `"share of black population female"'
label var perc0_17ofblack `"share of black population younger than 18"'
label var perc18_64ofblack `"share of black population 18 to 64"'
label var perc65pofblack `"share of black population 65 or older"'
label var percmaleofwhite `"share of white population male"'
label var percfemaleofwhite `"share of white population female"'
label var perc0_17ofwhite `"share of white population younger than 18"'
label var perc18_64ofwhite `"share of white population 18 to 64"'
label var perc65pofwhite `"share of white population 65 or older"'
label var percmaleofothrace `"share of other race population male"'
label var percfemaleofothrace `"share of other race population female"'
label var perc0_17ofothrace `"share of other race population younger than 18"'
label var perc18_64ofothrace `"share of other race population 18 to 64"'
label var perc65pofothrace `"share of other race population 65 or older"'
label var percblackofmale `"share of males who are black"'
label var percwhiteofmale `"share of males who are white"'
label var percothraceofmale `"share of males who are not black or white"'
label var perc0_17ofmale `"share of males younger than 18"'
label var perc18_64ofmale `"share of males 18 to 64"'
label var perc65pofmale `"share of males 65 or older"'
label var percblackoffemale `"share of females who are black"'
label var percwhiteoffemale `"share of females who are white"'
label var percothraceoffemale `"share of females who are other race"'
label var perc0_17offemale `"share of females younger than 18"'
label var perc18_64offemale `"share of females 18 to 64"'
label var perc65poffemale `"share of females 65 or older"'
label var percblackof0_17 `"share of under 18 population who is black"'
label var percwhiteof0_17 `"share of under 18 population who is white"'
label var percothraceof0_17 `"share of under 18 population who is not black or white"'
label var percmaleof0_17 `"share of under 18 population who is male"'
label var percfemaleof0_17 `"share of under 18 population who is female"'
label var percblackof18_64 `"share of 18 to 64 population who is black"'
label var percwhiteof18_64 `"share of 18 to 64 population who is white"'
label var percothraceof18_64 `"share of 18 to 64 population who is not black or white"'
label var percmaleof18_64 `"share of 18 to 64 population who is male"'
label var percfemaleof18_64 `"share of 18 to 64 population who is female"'
label var percblackof65p `"share of 65 or older population who is black"'
label var percwhiteof65p `"share of 65 or older population who is white"'
label var percothraceof65p `"share of 65 or older population who is not black or white"'
label var percmaleof65p `"share of 65 or older population who is male"'
label var percfemaleof65p `"share of 65 or older population who is female"'
label var perc_hisp `"share hispanic"'
label var perchispofblack `"share of black population hispanic"'
label var perchispofwhite `"share of white population hispanic"'
label var perchispofothrace `"share of other race population hispanic"'
label var perchispofmale `"share of males who are hispanic"'
label var perchispoffemale `"share of females who are hispanic"'
label var perchispof0_17 `"share of under 18 population who is hispanic"'
label var perchispof18_64 `"share of 18 to 64 population who is hispanic"'
label var perchispof65p `"share of 65 or older population who is hispanic"'
label var aids_dths_black `"aids deaths for black people"'
label var aids_dths_white `"aids deaths for white people"'
label var aids_dths_othrace `"aids deaths for other race"'
label var aids_dths_male `"aids deaths for males"'
label var aids_dths_female `"aids deaths for females"'
label var aids_dths_all `"aids deaths"'
label var aids_dths_0_17 `"aids deaths younger than 18"'
label var aids_dths_18_64 `"aids deaths ages 18 to 64"'
label var aids_dths_65p `"aids deaths ages 65 and older"'
label var cancer `"cancer deaths"'
label var cardio `"cardiovascular disease deaths"'
label var cereb `"cerebrovascular disease deaths"'
label var lower_resp `"lower respiratory disease deaths"'
label var all_acc `"cerebrovascular disease deaths"'
label var suicide `"suicide deaths"'
label var non_aids_all `"non-aids  deaths"'
label var statefip `"statefip code"'
label var unemp_rate `"unemployment rate"'
label var year_rwca_status `"year gained title 1 status"'
label var state_postal `"state postal code"'
label var aids_ever_1995_imp `"aids cases reported by march 31, 1995 (imputed)"'
label var rank_1995 `"rank in 1995 aids case distribution"'
label var aids_rep `"aids cases reported (apids)"'
label var aids_diag_apids `"aids diagnoses (apids)"'
label var aids_prev_all `"aids prevalence"'
label var aids_diagnosis_all `"aids diagnoses (cdc)"'
label var perc_white_st `"share of state white"'
label var perc_black_st `"share of state black"'
label var perc_male_st `"share of state male"'
label var perc_0_17_st `"share of state younger than 18"'
label var perc_65p_st `"share of state 65 or older"'
label var perc_hisp_st `"share of state hispanic"'
label var laids_dths_all_100k_st `"ln of state aids deaths per 100k"'
label var funding_1991_1995 `"title 1 funding from 1991 to 1995"'
label var funding_1996_2000 `"title 1 funding from 1996 to 2000"'
label var funding_1996_2006 `"title 1 funding from 1996 to 2006"'
label var funding_2007_2018 `"title 1 funding from 2007 to 2018"'
label var funding_2001_2006 `"title 1 funding from 2001 to 2006"'
label var funding_1991_2018 `"title 1 funding from 1991 to 2018"'
label var mcaid `"share of state with medicaid"'
label var nohins `"share of state uninsured"'
label var mcaid_m `"share of males with medicaid"'
label var nohins_m `"share of males in state uninsured"'
label var mcaid_pa `"share of prime age in state with medicaid"'
label var nohins_pa `"share of males in state uninsured"'
label var mcaid_mpa `"share of prime aged males in state with medicaid"'
label var nohins_mpa `"share of prime aged males in state uninsured"'
label var afdc96 `"medicaid eligibility income limit as % of fpl in 1996"'
label var med_no_aut `"separate ssi and medicaid applications"'
label var med_childless `"childless adults eligible for medicaid"'
label var num_hiv_crim `"number of hiv disclosure laws"'
label var hiv_crim `"any hiv disclosure law"'
label var aids_dths_100k_aa `"age-adjusted aids deaths per 100k"'
label var years_lost_through_2018 `"additional life years through 2018 from ssa life table"'
label var years_lost_through_2018_10y `"additional life years through 2018 from ssa life table, assuming max of 10"'
label var aids_dths_all_100k `"aids deaths per 100k"'
label var laids_dths_all_100k `"ln aids deaths per 100k"'
label var within30 `"30 cities on either side of cutoff"'
label var within5 `"5 cities on either side of cutoff"'
label var within25 `"25 cities on either side of cutoff"'
label var within20 `"20 cities on either side of cutoff"'
label var treatment_group `"treated city"'
label var rwca_status `"indicator variable for having gained title 1 under the original rules"'

save "$data_loc/cleaned/rwca_sample.dta", replace

capture log close
log using "$output_loc\share_medicaid_childless", replace
display "Mean shares of populations with non-disabled childless adults being eligible for Medicaid"
*treatment
sum med_childless if treat==1
*control
sum med_childless if treat==0
capture log close

