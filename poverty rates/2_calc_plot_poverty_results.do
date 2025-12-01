* set paths and directories 
********************************************************************************
global moddata "C:/moddata" // path where modified data files and output are stored

global outdir_povrates "${moddata}/poverty rates/"
global outdir_scales "${moddata}/scales/"
global outdir_ranks "${moddata}/ranks/"


cd "${outdir_povrates}"



/* Import overall price index   */
*********************************************************************************************
insheet using "${rawdata}//CPM02.20240322231856.csv", clear names
ren month strmonth
encode strmonth, gen(month) 
keep if selectedbasereferenceperiod=="Base December 2023=100"
drop STATISTICLabel strmonth unit  selectedbasereferenceperiod
rename value basenov2023

su basenov2023 if year==2023 & month==1
gen basejan2023 = basenov2023*100/`r(mean)'
drop basenov2023
save "${moddata}//cpi_basejan2023.dta", replace



* Load data and create missing vars 
********************************************************************************

use "${moddata}//HBS_1987_analysis.dta", clear
append using "${moddata}//HBS_1994_analysis.dta"
append using "${moddata}//HBS_1999_analysis.dta"
append using "${moddata}//HBS_2004_analysis.dta"
append using "${moddata}//HBS_2009_analysis.dta"
append using "${moddata}//HBS_2015_analysis.dta"



* some missing/differently named vars used below
rename hhsize numinhh
rename hhnumu14 numU14inhh
rename hhnum14to17 num14to17inhh



gen datayear = hbsyear 

gen hhwgt = grossfac	
gen ahhwgt = grossfac*numinhh
gen chhwgt = grossfac*numU14inhh

bysort datayear hhid: gen firinhh = _n



/* Put disposable income in real terms  */
*********************************************************************************************

global incvars  HHdispinc equivHHdispinc AHCdispinc equivAHCdispinc HHgrossinc equivHHgrossinc


sort hbsyear year month
merge m:1 year month using "${moddata}//cpi_basejan2023.dta", keep(1 3) nogen

foreach var of varlist $incvars {
	gen real`var' = `var'*100/basejan2023
	label var real`var' "January 2023 prices"
}



* and set income var
gen realBHCincome = realHHdispinc



* Set scales 
********************************************************************************


* Adult scales 
matrix adult_scales = ( ///
	0.653, 0.658, 0.663, 0.663, 0.576, 0.548, 0.584, 0.533 \ ///
	0.67,  0.607, 0.664, 0.654, 0.602, 0.611, 0.604, 0.585 \ ///
	0.684, 0.748, 0.683, 0.703, 0.529, 0.467, 0.533, 0.331 \ ///
	0.685, 0.684, 0.668, 0.661, 0.567, 0.395, 0.604, 0.361 \ ///
	0.717, 0.775, 0.630, 0.625, 0.598, 0.477, 0.003, 0.354 \ ///
	0.701, 0.712, 0.664, 0.649, 0.513, 0.115, 0.471, 0.180 ///
)

matrix rownames adult_scales = 1987 1994 1999 2004 2009 2015
matrix colnames adult_scales = food_wl food_kl comb_wl comb_kl AIDS AIDS3sls QUAIDS QUAIDS3sls

* Child scales 
matrix child_scales = ( ///
	0.304, 0.299, 0.302, 0.294, 0.117, 0.114, 0.094, 0.196, 0.164, 0.21 \ ///
	0.28,  0.289, 0.269, 0.28,  0.245, 0.254, 0.273, 0.248, 0.281, 0.31 \ ///
	0.276, 0.306, 0.252, 0.186, 0.192, 0.148, 0.146, 0.098, 0.244, 0.24 \ ///
	0.291, 0.283, 0.26,  0.261, 0.212, 0.098, 0.144, 0.158, 0.246, 0.246 \ ///
	0.343, 0.368, 0.304, 0.245, 0.202, 0.118, -0.033, 0.066, 0.46, 0.334 \ ///
	0.362, 0.372, 0.263, 0.24,  0.173, 0.011, 0.039, 0.092, 0.324, 0.217 ///
)


matrix rownames child_scales = 1987 1994 1999 2004 2009 2015
matrix colnames child_scales = food_wl food_kl comb_wl comb_kl AIDS AIDS3sls QUAIDS QUAIDS3sls rothbarth_a rothbarth_c

* Check scales
matlist adult_scales
matlist child_scales





* Generate scales fromn matrices above
********************************************************************************
* Generate equivalence scale variables from matrices for each scale and year
local scalelist food_wl food_kl comb_wl comb_kl AIDS AIDS3sls QUAIDS QUAIDS3sls
local yearlist 1987 1994 1999 2004 2009 2015

foreach scale of local scalelist {
	gen eqscale_`scale' = .
	foreach y of local yearlist {
		local row = 0
		if "`y'"=="1987" local row = 1
		if "`y'"=="1994" local row = 2
		if "`y'"=="1999" local row = 3
		if "`y'"=="2004" local row = 4
		if "`y'"=="2009" local row = 5
		if "`y'"=="2015" local row = 6

		* Get adult and child scale from matrices
		local a = adult_scales[`row', "`scale'"]
		local c = child_scales[`row', "`scale'"]

		di in yellow "`scale' `y' a=`a' c=`c'"

		gen eqscale_`scale'_`y' = 1 + (numinhh - numU14inhh - 1)*`a' + (numU14inhh)*`c' 
		replace eqscale_`scale' = 1 + (numinhh - numU14inhh - 1)*`a' + (numU14inhh)*`c' if hbsyear==`y'
	}
}

* Other scales  
********************************************************************************

* modified OECD scale 
gen eqscale_modoecd = 1 + (numinhh - numU14inhh - 1)*0.50 + 0.30*numU14inhh
gen eqscale_modoecd_1987 = eqscale_modoecd
gen eqscale_modoecd_2015 = eqscale_modoecd

* CSO national scale 
gen eqscale_cso = 1 + (numinhh - numU14inhh - 1)*0.66 + 0.33*numU14inhh
gen eqscale_cso_1987 = eqscale_cso
gen eqscale_cso_2015 = eqscale_cso

* Assigning 1 to each member
gen eqscale_eq1 = 1 + (numinhh - numU14inhh - 1) + numU14inhh
gen eqscale_eq1_1987 = eqscale_eq1
gen eqscale_eq1_2015 = eqscale_eq1

* sqrt household size
gen eqscale_sqrt = sqrt(numinhh)
gen eqscale_sqrt_1987 = eqscale_sqrt
gen eqscale_sqrt_2015 = eqscale_sqrt

* no equivalisation
gen eqscale_noeq = 1
gen eqscale_noeq_1987 = eqscale_noeq
gen eqscale_noeq_2015 = eqscale_noeq


* Equivalise income with these scales 
********************************************************************************
global scales noeq modoecd cso sqrt food_wl comb_wl food_kl comb_kl AIDS AIDS3sls QUAIDS QUAIDS3sls
foreach s of global scales {
	gen eqdispy_`s' = realBHCincome/eqscale_`s'
	gen eqdispy1987_`s' = realBHCincome/eqscale_`s'_1987
	gen eqdispy2015_`s' = realBHCincome/eqscale_`s'_2015
}



* create poverty lines and tag households below them 
********************************************************************************
levelsof datayear, local(scaleyears)
foreach scale of global scales  {
	di in yellow "`scale'"
	gen povline_`scale' = .	
	gen povline1987_`scale' = .
	gen povline2015_`scale' = .

	* poverty lines 
	// data at the household level but want poverty rates for individuals
	// so compute poverty line at household level but weight by number of people in household
	// using ahhwgt (firinhh redundant as one ob per hh)
	foreach y of local scaleyears  {

		* changing scales 
		qui su eqdispy_`scale' if firinhh & datayear==`y' [aw=ahhwgt], de
		qui replace povline_`scale' = 0.60*`r(p50)' if datayear==`y'

		* constant 1987 scale 
		qui su eqdispy1987_`scale' if firinhh & datayear==`y' [aw=ahhwgt], de
		qui replace povline1987_`scale' = 0.60*`r(p50)' if datayear==`y'


		* constant 2015 scale 
		qui su eqdispy2015_`scale' if firinhh & datayear==`y' [aw=ahhwgt], de
		qui replace povline2015_`scale' = 0.60*`r(p50)' if datayear==`y'

	} 


	* tag households below poverty line 
	gen arop_`scale' = (eqdispy_`scale' < povline_`scale')  
	replace arop_`scale' = . if mi(eqdispy_`scale') | mi(povline_`scale')

	gen arop1987_`scale' = (eqdispy1987_`scale' < povline1987_`scale')
	gen arop2015_`scale' = (eqdispy2015_`scale' < povline2015_`scale')

	* store number of people in a household below poverty line 
	gen n_arop_`scale' = arop_`scale'*numinhh
	gen n_arop1987_`scale' = arop1987_`scale'*numinhh
	gen n_arop2015_`scale' = arop2015_`scale'*numinhh

	* store number of kids below poverty line
	gen nchild_arop_`scale' = arop_`scale'*numU14inhh 
	gen nchild_arop1987_`scale' = arop1987_`scale'*numU14inhh
	gen nchild_arop2015_`scale' = arop2015_`scale'*numU14inhh

}
// end scale loop


* Gini 
********************************************************************************
// again here use ahhwgt here to assign each person their equiv household income 
levelsof datayear, local(scaleyears)
foreach scale of global scales {
	qui {
		di in yellow "`scale'"

		* changing scale 
		gen gini_`scale' = .
		foreach y of local scaleyears  {
			inequal7 eqdispy_`scale' if firinhh & datayear==`y' [aw=ahhwgt]
			replace  gini_`scale'=`r(gini)' if firinhh & datayear==`y'
		
		}

		* constant 1987 scale
		gen gini1987_`scale' = .
		foreach y of local scaleyears  {
			inequal7 eqdispy1987_`scale' if firinhh & datayear==`y' [aw=ahhwgt]
			replace  gini1987_`scale'=`r(gini)' if firinhh & datayear==`y'
		}
		

		* constant 2015 scale
		gen gini2015_`scale' = .
		foreach y of local scaleyears  {
			inequal7 eqdispy2015_`scale' if firinhh & datayear==`y' [aw=ahhwgt]
			replace  gini2015_`scale'=`r(gini)' if firinhh & datayear==`y'
		}
	}
}





* Plot results with year specific scales 
********************************************************************************

* set marker colors and symbols 
set scheme stcolor
colorpalette plasma, n(5) nograph locals 
local marker_1 "marker(1, mc(`r(p1)') ms(O))"   
local marker_2 "marker(2, mc(`r(p1)') ms(T))"   
local marker_3 "marker(3, mc(`r(p1)') ms(D))"   
local marker_4 "marker(4, mc(`r(p1)') ms(S))"   
local marker_5 "marker(5, mc(`r(p2)') ms(O))"   
local marker_6 "marker(6, mc(`r(p2)') ms(T))"   
local marker_7 "marker(7, mc(`r(p3)') ms(O))"   
local marker_8 "marker(8, mc(`r(p3)') ms(T))"   
local marker_9 "marker(9, mc(`r(p4)') ms(O))"   
local marker_10 "marker(10, mc(`r(p4)') ms(T))"   
local marker_11 "marker(11, mc(`r(p5)') ms(O))"   
local marker_12 "marker(12, mc(`r(p5)') ms(T))"   
local markers ""
forvalues m=1/12 {
	local markers "`markers' `marker_`m''"   
}
global markers "`markers'"
di "$markers"



* overall poverty rate 
tabstat arop_* [aw=hhwgt], by(datayear) statistics(mean)	// households
tabstat arop_* [aw=ahhwgt], by(datayear) statistics(mean)	// people 
preserve 
	collapse (sum) numinhh n_arop_* [aw=hhwgt], by(datayear)
	foreach var of varlist n_arop_* {
		replace `var' = `var'/numinhh	
	}	
	rename n_arop_* *

	graph dot "${scales}", over(datayear) nolab ${markers} ytitle("At-risk-of-poverty rate: overall (%)") vertical
	graph export "arop_all.png", replace
restore 


* child poverty rate
tabstat arop* if numU14inhh > 0 [aw=hhwgt], by(datayear) statistics(mean)	// share of households 
tabstat arop* if numU14inhh > 0 [aw=chhwgt], by(datayear) statistics(mean)	// share of children

preserve 
	
	collapse (sum) numU14inhh nchild_arop_* [aw=hhwgt], by(datayear)
	foreach var of varlist nchild_arop_* {
		replace `var' = `var'/numU14inhh
		
	}	
	rename nchild_arop_* *

	graph dot "${scales}", over(datayear) nolab ${markers} ytitle("At-risk-of-poverty rate: children (%)") vertical
	graph export "arop_kids.png", replace

restore 




* Gini coefficient  
tabstat gini_*, by(datayear) statistics(mean)

graph dot gini_*, over(datayear) nolab ${markers} ytitle("Gini coefficient") vertical 
graph export "gini.png", replace

graph dot gini_*, over(datayear) nolab ${markers} ytitle("Gini coefficient") vertical ylab(0.25(0.05)0.35) exclude0
graph export "gini_zoom.png", replace





* Compare constant and changing scales  
********************************************************************************
* encode
// global scales noeq modoecd cso sqrt food_wl comb_wl food_kl comb_kl AIDS AIDS3sls QUAIDS QUAIDS3sls
label define measures 1 "noeq" 2 "modoecd" 3 "cso" 4 "sqrt" 5 "food_wl" 6 "comb_wl" 7 "food_kl" 8 "comb_kl" 9 "AIDS" 10 "QUAIDS" 11 "AIDS3sls" 12"QUAIDS3sls", replace

* overall poverty rate 
preserve 
	collapse (sum) numinhh n_arop_* n_arop1987* [aw=hhwgt], by(datayear)
	foreach var of varlist n_arop_* n_arop1987* {
		replace `var' = `var'/numinhh	
	}	
	rename n_arop_* arop*
	rename n_arop1987_* fixed1987arop*
	drop numinhh

	reshape long arop fixed1987arop, i(datayear) j(measures) string

	encode measure, gen(equiv_measure)  label(measures)

	tw connect arop fixed1987arop datayear, by(equiv_measure, note(""))  ///
		ytitle("Poverty rate (%)")	xtitle("Year") ///
		legend(label(1 "Contemporaneous scale") label(2 "Fixed 1987 scale")) ///
		scheme(stcolor_alt)
	graph export "arop_all_fixedchanging_scale.png", replace
	
	tw connect arop datayear, by(equiv_measure, note(""))  ///
		ytitle("Poverty rate (%)")	xtitle("Year") ///
		scheme(stcolor_alt)
	graph export "arop_all_changing_scale.png", replace

restore 


* child poverty rate 
preserve 
	collapse (sum) numU14inhh nchild_arop_* nchild_arop1987* [aw=hhwgt], by(datayear)
	foreach var of varlist nchild_arop_* nchild_arop1987* {
		replace `var' = `var'/numU14inhh	
	}	
	rename nchild_arop_* arop*
	rename nchild_arop1987_* fixed1987arop*
	drop numU14inhh

	reshape long arop fixed1987arop, i(datayear) j(measure) string
	encode measure, gen(equiv_measure)  label(measures)


	tw connect arop fixed1987arop datayear, by(equiv_measure, note(""))  ///
		ytitle("Poverty rate: children (%)")	xtitle("Year") ///
		legend(label(1 "Contemporaneous scale") label(2 "Fixed 1987 scale")) ///
		scheme(stcolor_alt)
	graph export "arop_kids_fixedchanging_scale.png", replace

	tw connect arop datayear, by(equiv_measure, note(""))  ///
		ytitle("Poverty rate: children (%)")	xtitle("Year") ///
		scheme(stcolor_alt)
	graph export "arop_kids_changing_scale.png", replace


restore 


* gini 
preserve 
	collapse (mean) gini_* gini1987_* [aw=hhwgt], by(datayear)

	rename gini_* gini*
	rename gini1987_* fixed1987gini*

	reshape long gini fixed1987gini, i(datayear) j(measure) string
	encode measure, gen(equiv_measure)  label(measures)


	tw connect gini fixed1987gini datayear, by(equiv_measure, note(""))  ///
		ytitle("Gini coefficient")	xtitle("Year") ///
		legend(label(1 "Contemporaneous scale") label(2 "Fixed 1987 scale")) ///
		scheme(stcolor_alt)

	graph export "gini_fixedchanging_scale.png", replace


	tw connect gini datayear, by(equiv_measure, note(""))  ///
		ytitle("Gini coefficient")	xtitle("Year") ///
		scheme(stcolor_alt)

	graph export "gini_changing_scale.png", replace

restore






* Compare rankings
********************************************************************************
cd "${outdir_ranks}"


* create ranks of equivalised income for each scale and year
levelsof datayear, local(scaleyears)
foreach scale of global scales {

	egen r_eqdispy_`scale' = rank(eqdispy_`scale'), by(datayear) 


}
// end scale loop 


* plot change in ranks of equivalised income for each scale against ranks of unequivalised income
levelsof datayear, local(scaleyears)

local n_scales : word count ${scales}
local n_scaleyears : word count `scaleyears'
local n_rows = `n_scales' + 1

* initialize matrix to store spearman rho
matrix def spear_rho = J(`n_rows',`n_scaleyears',.)
matrix colnames spear_rho = `scaleyears'
matrix rownames spear_rho = year $scales

* and to store kendall taus
matrix def kendall_taua = J(`n_rows',`n_scaleyears',.)
matrix colnames kendall_taua = `scaleyears'
matrix rownames kendall_taua = year $scales

matrix def kendall_taub = J(`n_rows',`n_scaleyears',.)
matrix colnames kendall_taub = `scaleyears'
matrix rownames kendall_taub = year $scales


* loop over scales and years 
local row = 2
foreach scale of global scales {
	local ranking_to_combine ""
	local dranking_to_combine ""


	local col=1
	foreach year of local scaleyears  {
		local vars r_eqdispy_`scale' r_eqdispy_noeq

		* compute spearman rho 
		matrix spear_rho[1, `col'] = `year'
		qui spearman `vars' if datayear==`year'
		local rho = string(`r(rho)', "%4.3f")
		matrix spear_rho[`row', `col'] = `rho'

		* compute kendall taus
		matrix kendall_taua[1, `col'] = `year'
		matrix kendall_taub[1, `col'] = `year'

		qui ktau `vars' if datayear==`year'

		local tau_a = string(`r(tau_a)', "%4.3f")
		matrix kendall_taua[`row', `col'] = `tau_a'

		local tau_b = string(`r(tau_b)', "%4.3f")
		matrix kendall_taub[`row', `col'] = `tau_b'
		
		* plot rankings
		lpoly `vars' if datayear==`year', ///
			name(ranking_`year', replace) ///
			title("") ///
			subtitle("`year'") ///
			xtitle("Income rank, unequivalised") ///
			ytitle("Income rank, `scale' scale") ///
			note("(Spearman {&rho}=`rho'), Kendall {&tau}{sub:a}=`tau_a' {&tau}{sub:b}=`tau_b')")
			
		local ranking_to_combine "`ranking_to_combine' ranking_`year'"

		* plot change in rankings 
		tempvar delta 
		gen `delta' = r_eqdispy_`scale' - r_eqdispy_noeq if datayear==`year'
		lpoly `delta' r_eqdispy_noeq if datayear==`year', ///
			name(dranking_`year', replace) ///
			title("") ///			
			subtitle("`year'") ///
			xtitle("Income rank, unequivalised") ///
			ytitle("Difference in rank, `scale' scale") ///
			note("(Spearman {&rho}=`rho'), Kendall {&tau}{sub:a}=`tau_a' {&tau}{sub:b}=`tau_b')")
			
		local dranking_to_combine "`dranking_to_combine' dranking_`year'"

		local col = `col' + 1
	}
	
	* combine ranking plots
	graph combine `ranking_to_combine'
	graph export "ranking_`scale'.png", replace

	* combine reranking plots
	graph combine `dranking_to_combine'
	graph export "dranking_`scale'.png", replace
	
	
	local row = `row' + 1
}
// end scale loop

* Compare percentile rankings
********************************************************************************

* create percentiles of equivalised income for each scale and year
levelsof datayear, local(scaleyears)
foreach scale of global scales {
	qui gen p_eqdispy_`scale' = .
	foreach year of local scaleyears  {
		tempvar temp_eqdispy_`scale'
		xtile `temp_eqdispy_`scale'' = eqdispy_`scale' if datayear==`year' [aw=ahhwgt], nq(100)
		qui replace p_eqdispy_`scale' = `temp_eqdispy_`scale'' if datayear==`year'
	}
	// end y loop 
}
// end scale loop 


* plot percentiles of equivalised income for each scale against percentiles of unequivalised income
levelsof datayear, local(scaleyears)

local n_scales : word count ${scales}
local n_scaleyears : word count `scaleyears'
local n_rows = `n_scales' + 1
matrix def corr_rho = J(`n_rows',`n_scaleyears',.)
matrix colnames corr_rho = `scaleyears'
matrix rownames corr_rho = year $scales

mat list corr_rho

local row = 2
foreach scale of global scales {

	local bs_to_combine ""
	local dbs_to_combine ""

	local col=1
	foreach year of local scaleyears  {
		local vars p_eqdispy_`scale' p_eqdispy_noeq
		qui corr `vars' if datayear==`year'
		matrix corr_rho[1, `col'] = `year'
		local rho = string(`r(rho)', "%4.3f")	
		matrix corr_rho[`row', `col'] = `rho'
		
		* plot percentile rankings 
		binscatter `vars' if datayear==`year', ///
			xq(p_eqdispy_noeq) name(bs_`year', replace) ///
			subtitle("`year'") xtitle("Income percentile, unequivalised") ///
			ytitle("Income percentile, `scale' scale") ///
			note("Pearson's {&rho}=`rho'")
		local bs_to_combine "`bs_to_combine' bs_`year'"
		
		* average change in percentile rankings
		tempvar delta 
		gen `delta' = p_eqdispy_`scale' - p_eqdispy_noeq
		binscatter `delta' p_eqdispy_noeq if datayear==`year', ///
			xq(p_eqdispy_noeq) name(dbs_`year', replace) ///
			subtitle("`year'") xtitle("Income percentile, unequivalised") ///
			ytitle("Avg change in percentile, `scale' scale") ///
			ylabel(-10(10)30) /// 
			note("Pearson's {&rho}=`rho'")
		local dbs_to_combine "`dbs_to_combine' dbs_`year'"

		local col = `col' + 1
	}
	
	
	graph combine `bs_to_combine'
	graph export "percentiles_`scale'.png", replace
	
	graph combine `dbs_to_combine'
	graph export "dpercentiles_`scale'.png", replace
	
	
	
	local row = `row' + 1
}
// end scale loop 



* plot correlation matrix of percentiles over time
********************************************************************************


* export correlation matrix of correlations
mat def t_corr_rho = corr_rho'
clear
svmat t_corr_rho, names(col)

global scales_to_plot :  subinstr global scales "noeq" ""

* and plot the correlation matrix using same colors as above
set scheme stcolor
colorpalette plasma, n(5) nograph locals 
local mcolors "mcolor( "`r(p1)'"" `r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'" )"
local lcolors "lcolor( "`r(p1)'"" `r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'" )"
local msymbs  "msymbol(O T S O T O T O T O T O T)"
 
tw connect ${scales_to_plot} year, `mcolors' `lcolors' `msymbs' ytitle("{&rho}") xlab(1985(5)2015)
graph export "${outdir_ranks}//ranking_corrs_time.png", replace


* plot correlation matrix of rankings over time
********************************************************************************
foreach corr in spear_rho kendall_taua kendall_taub {


	* export correlation matrix of correlations
	mat def t_`corr' = `corr''
	clear
	svmat t_`corr', names(col)

	global scales_to_plot :  subinstr global scales "noeq" ""

	* and plot the correlation matrix using same colors as above
	set scheme stcolor
	colorpalette plasma, n(5) nograph locals 
	local mcolors "mcolor( "`r(p1)'"" `r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'" )"
	local lcolors "lcolor( "`r(p1)'"" `r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'" )"
	local msymbs  "msymbol(O T S O T O T O T O T O T)"
	
	tw connect ${scales_to_plot} year, ///
		`mcolors' `lcolors' `msymbs' ///
		ytitle("`corr'") ///
		xlab(1985(5)2015) ///
		name("ranking_`corr'_time", replace)
		
	graph export "${outdir_ranks}//ranking_`corr'_time.png", replace
}



* Plot adult child scales over time
********************************************************************************
clear 
cd "${outdir_scales}"


svmat adult_scales, names(col)
gen year = _n
recode year (1=1987) (2=1994) (3=1999) (4=2004) (5=2009) (6=2014)
order year *

gen modoecd = 0.6
gen cso = 0.66

global scales_to_plot :  subinstr global scales "sqrt" ""
global scales_to_plot :  subinstr global scales_to_plot "noeq" ""

* and plot the correlation matrix using same colors as above
set scheme stcolor
colorpalette plasma, n(5) nograph locals 
local mcolors "mcolor("`r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'" )"
local lcolors "lcolor("`r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'" )"
local msymbs  "msymbol(O T O T O T O T O T)"

tw connect ${scales_to_plot} year, `mcolors' `lcolors' `msymbs' xlab(1985(5)2015)
graph export "${outdir_scales}//adult_scales.png", replace



* Plot child child scales over time
********************************************************************************
clear 

svmat child_scales, names(col)
gen year = _n
recode year (1=1987) (2=1994) (3=1999) (4=2004) (5=2009) (6=2014)
order year *

gen modoecd = 0.6
gen cso = 0.66

global scales_to_plot :  subinstr global scales "sqrt" ""
global scales_to_plot :  subinstr global scales_to_plot "noeq" ""
global scales_to_plot "${scales_to_plot} rothbarth_a rothbarth_c"

* and plot the correlation matrix using same colors as above
set scheme stcolor
colorpalette plasma, n(5) nograph locals 
local mcolors "mcolor("`r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'" "grey" "grey" )"
local lcolors "lcolor("`r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'"  "grey" "grey")"
local msymbs  "msymbol(O T O T O T O T O T O T)"

tw connect ${scales_to_plot} year, `mcolors' `lcolors' `msymbs' xlab(1985(5)2015)
graph export "${outdir_scales}//child_scales.png", replace


// end  
