***
*Create sample for AIDS deaths RD analysis
***
use "$data_loc/cleaned/rwca_sample.dta", replace
gen aids_dths_1990 =aids_dths_all if year==1990
gen aids_dths_96_06=aids_dths_all if year>=1996&year<=2006
gen laids_ever_1995_imp=log(aids_ever_1995_imp)

collapse (firstnm) laids_ever_1995_imp year_rwca_status within25 rank_1995 (sum) aids_dths_96_06 aids_dths_1990, by(cityfip)

count if year_rwca_status>1997
gen rank_1995_from_cutoff=rank_1995-`r(N)'
replace rank_1995_from_cutoff=rank_1995_from_cutoff-1 if rank_1995_from_cutoff<=0

foreach var in aids_dths_96_06 aids_dths_1990{
	gen l`var'=log(`var')
}
drop year_rwca_status aids_dths_96_06 aids_dths_1990 

label var cityfip `"city fips code"'
label var laids_ever_1995_imp `"ln of aids cases reported by march 31, 1995 (imputed)"'
label var within25 `"25 cities on either side of cutoff"'
label var rank_1995 `"rank in 1995 aids case distribution"'
label var rank_1995_from_cutoff `"distance from cutoff in rank in 1995 aids case distribution"'
label var laids_dths_96_06 `"ln of aids deaths from 1996 to 2006"'
label var laids_dths_1990 `"ln of aids deaths in 1990"'

save "$data_loc/cleaned/rwca_rd_sample_aids_dths.dta", replace

***
*Create sample for AIDS diagnoses RD analysis
***
use "$data_loc/cleaned/rwca_sample.dta", replace
gen aids_diag_1990 =aids_diagnosis_all if year==1990
gen aids_diag_96_06=aids_diagnosis_all if year>=1996&year<=2006
gen laids_ever_1995_imp=log(aids_ever_1995_imp)
drop if aids_diagnosis_all==.

collapse (firstnm) laids_ever_1995_imp year_rwca_status within25 (sum) aids_diag_96_06 aids_diag_1990, by(cityfip)

sort laids_ever_1995_imp cityfip
gen rank_1995_hiv= _n 

count if year_rwca_status>1997
gen rank_1995_from_cutoff_hiv=rank_1995_hiv-`r(N)'
replace rank_1995_from_cutoff_hiv=rank_1995_from_cutoff_hiv-1 if rank_1995_from_cutoff_hiv<=0

foreach var in aids_diag_96_06 aids_diag_1990{
	gen l`var'=log(`var')
}
drop aids_diag_1990 year_rwca_status aids_diag_96_06 

label var cityfip `"city fips code"'
label var laids_ever_1995_imp `"ln of aids cases reported by march 31, 1995 (imputed)"'
label var within25 `"25 cities on either side of cutoff"'
label var rank_1995_hiv `"rank in 1995 aids case distribution"'
label var rank_1995_from_cutoff_hiv `"distance from cutoff in rank in 1995 aids case distribution"'
label var laids_diag_96_06 `"ln of aids diagnoses from 1996 to 2006"'
label var laids_diag_1990 `"ln of aids diagnoses in 1990"'

save "$data_loc/cleaned/rwca_rd_sample_aids.dta", replace