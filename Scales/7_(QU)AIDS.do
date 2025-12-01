* 7. (QU)AIDS specifications
* Luke Duggan, 31/05/'25

* Generate adults - 1 variable following (Michelini, 2000)
gen hhadults_star = hhadults - 1
gen hh18plus_star = hh18plus - 1

gen ln_p_misc_star = ln(p_misc)

* AIDS

**** demandsys 

demandsys aids $aids_shares resid_share, prices($prices p_misc) expenditure($expenditure) demographics(hhnumu14 hhadults_star, scaling)

putexcel set "${tables}/ds_aids.xlsx", sheet(${y}) modify
putexcel A2 = matrix(r(table)), names

demandsys aids $aids_shares resid_share, prices($avg_prices p_misc) expenditure($expenditure) demographics(hhnumu5 hhnum5to13 hhnum14to17 hh18plus_star, scaling)


putexcel set "${tables}/ds_aids_childages", sheet(${y}) modify
putexcel A2 = matrix(r(table)), names

***** quaids
	
quaids $aids_shares resid_share, lnprices($log_prices ln_p_misc_star) lnexpenditure(ln_expenditure) demog(hhnumu14 hhadults_star) anot($a_0) noquadratic level(95)

putexcel set "${tables}/poi_aids.xlsx", sheet(${y}) modify
putexcel A1 = "AIDS Results, Adult and Child Scales"
putexcel A3 = matrix(r(table)), names nformat(number_d3)

quaids $aids_shares resid_share, lnprices($log_prices ln_p_misc_star) lnexpenditure(ln_expenditure) demog(hhnumu5 hhnum5to13 hhnum14to17 hh18plus_star) anot($a_0) noquadratic level(95)

putexcel A15 = "AIDS Results, Adult and Child Scales by Age Group"
putexcel A17 = matrix(r(table)), names nformat(number_d3)


* QUAIDS

demandsys quaids $aids_shares resid_share, prices($prices p_misc) expenditure($expenditure) demographics(hhnumu14 hhadults_star, scaling)

putexcel set "${tables}/ds_quaids.xlsx", sheet(${y}) modify
putexcel A2 = matrix(r(table)), names

demandsys quaids $aids_shares resid_share, prices($prices p_misc) expenditure($expenditure) demographics(hhnumu5 hhnum5to13 hhnum14to17 hh18plus_star, scaling)

putexcel set "${tables}/ds_quaids_childages", sheet(${y}) modify
putexcel A2 = matrix(r(table)), names

****

/* For revision: re-estimate models by total expenditure quartile

xtile totexpend_quartile = totexpend, nq(4)

foreach x in 1 2 3 4 {
	
demandsys aids $aids_shares resid_share if totexpend_quartile == `x', prices($prices p_misc) expenditure($expenditure) demographics(hhnumu14 hhadults_star, scaling)

putexcel set "${tables}\aids\ds_quartiles_${y}", sheet(Quartile `x') modify
putexcel A1 = "AIDS Results, Adult and Child Scales, By Quartile"
putexcel A3 = matrix(r(table)), names nformat(number_d3)

demandsys quaids $aids_shares resid_share if totexpend_quartile == `x', prices($prices p_misc) expenditure($expenditure) demographics(hhnumu14 hhadults_star, scaling)

putexcel set "${tables}\quaids\ds_quartiles_${y}", sheet(Quartile `x') modify
putexcel A1 = "QUAIDS Results, Adult and Child Scales, By Quartile"
putexcel A3 = matrix(r(table)), names nformat(number_d3)
	
*/	