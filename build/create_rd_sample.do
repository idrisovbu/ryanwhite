***
*Create sample for HIV RD analysis
***
use "$data_loc/cleaned/rwca_sample.dta", replace

gen laids_ever_1995_imp=log(aids_ever_1995_imp)
collapse (firstnm) laids_ever_1995_imp year_rwca_status within25 , by(cityfip)

merge 1:1 cityfip using "$data_loc/interim/cdc_city_hiv_prev"
drop if _merge==2
drop _merge

merge 1:1 cityfip using "$data_loc/interim/cdc_city_hiv_diagnosis"
drop if _merge==2
drop _merge

drop if hiv_diag==.

sort laids_ever_1995_imp cityfip
gen rank_1995_hiv= _n 

count if year_rwca_status>1997
gen rank_1995_from_cutoff_hiv=rank_1995_hiv-`r(N)'
replace rank_1995_from_cutoff_hiv=rank_1995_from_cutoff_hiv-1 if rank_1995_from_cutoff_hiv<=0

foreach var in hiv_diag hiv_prev {
	gen l`var'=log(`var')
}
drop year_rwca_status hiv_prev hiv_diag

label var cityfip `"city fips code"'
label var laids_ever_1995_imp `"ln of aids cases reported by march 31, 1995 (imputed)"'
label var within25 `"25 cities on either side of cutoff"'
label var rank_1995_hiv `"rank in 1995 aids case distribution"'
label var rank_1995_from_cutoff_hiv `"distance from cutoff in rank in 1995 aids case distribution"'
label var lhiv_diag `"ln hiv diagnoses in 2008"'
label var lhiv_prev `"ln hiv cases in 2008"'

save "$data_loc/cleaned/rwca_rd_sample.dta", replace