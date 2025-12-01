/* 3_firststage.do
Run first-stage regressions and extract residuals

	(a) Distinguish endogenous, exogenous, and instrument vars
	(b) Run first-stage regressions and collect residuals
*/

***** (a) Distinguish endogenous, exogenous, and instrument vars

global instrs $instruments_1 $instruments_2 $instruments_3 $instruments_4 $instruments_5

forvalues i = 6/$l {
	
	global instrs $instrs $instruments_`i' // !!!!!!!!! Stata doesn't like this syntax, need to fix...
	
}

global all_vars $ngoods $nprices $expenditure $ndemographics $instrs

global exogenous_vars : list global(all_vars) - global(endogenous_vars)

**** (b) Run first-stage regressions and collect residuals

forvalues i = 1/$l {
	
reg e_`i' $exogenous_vars

predict fs_resid_`i', residuals

return list
putexcel set "$output\childage_firststage_$year.xlsx", sheet(e_`i') modify
putexcel A2 = matrix(r(table)), names

}
// end