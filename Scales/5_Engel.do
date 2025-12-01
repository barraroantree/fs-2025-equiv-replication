* 5. Engel method specifications
* Luke Duggan, 30/05/'25

* Define local of outcome goods

generate com = food+clothing+housingcosts
generate com_share = com/totexpend

local outcomes $engel_goods com

/* Loop through specifications
Specifications are estimated three times:
 (A) with children as <14's.
 (B) with age distinctions among children aged 0-4, 5-13, and 14-17.
 (C) with children as <14's and separately by total expenditure quartile.
*/

foreach g in `outcomes' {
	
********************************************************************************
*** (A): Children aged <14
	
* Set up excel sheet

putexcel set "${tables}/engel_results_${y}.xlsx", sheet(`g') modify

putexcel A1 = "`g', Working-Leser Form"

putexcel B3 = "Estimate"
putexcel C3 = "Standard Error"
putexcel D3 = "95% CI Lower"
putexcel E3 = "95% CI Upper"

putexcel A4 = "One Adult, No Children"
putexcel A5 = "One Adult, One Child"
putexcel A6 = "One Adult, Two Children"
putexcel A7 = "One Adult, Three Children"

putexcel A8 = "Two Adults, No Children"
putexcel A9 = "Two Adults, One Child"
putexcel A10 = "Two Adults, Two Children"
putexcel A11 = "Two Adults, Three Children"

* Estimate models

* Working-Leser parameteric form - write estimates, s.e.'s, and CI's to sheet.

regress `g'_share ln_expenditure hhnumu14 hhadults

local rowcounter = 4

forvalues i = 1/2 {
    forvalues j = 0/3 {
	    
	    nlcom ((`i'+`j')/ref_adults+ref_children)*exp((_b[hhnumu14]/_b[ln_expenditure])*(`j'-ref_children) + (_b[hhadults]/_b[ln_expenditure])*(`i'-ref_adults))
		
		return list
		putexcel B`rowcounter' = (r(b)[1,1])
		putexcel C`rowcounter' = (sqrt(r(V)[1,1]))
		putexcel D`rowcounter' = (r(b)[1,1] - 1.96*(sqrt(r(V)[1,1])))
		putexcel E`rowcounter' = (r(b)[1,1] + 1.96*(sqrt(r(V)[1,1])))
		
		local ++rowcounter
		
		}
	}
	
if $run_ker == 1 {
	
* Kernel regression estimates 

putexcel O1 = "`g', Kernel Regression"

putexcel P3 = "Estimate"
putexcel Q3 = "Standard Error"
putexcel R3 = "95% CI Lower"
putexcel S3 = "95% CI Upper"

putexcel O4 = "One Adult, No Children"
putexcel O5 = "One Adult, One Child"
putexcel O6 = "One Adult, Two Children"
putexcel O7 = "One Adult, Three Children"

putexcel O8 = "Two Adults, No Children"
putexcel O9 = "Two Adults, One Child"
putexcel O10 = "Two Adults, Two Children"
putexcel O11 = "Two Adults, Three Children"

npregress kernel `g'_share ln_expenditure i.hhnumu14 i.hhadults, vce(bootstrap, rep($ker_reps) seed(113))

local rowcounter = 4

forvalues i = 1/2 {
    forvalues j = 0/3 {
	    
	    nlcom ((`i'+`j')/ref_adults+ref_children)*exp(([Effect]_b[r1vs0.hhnumu14]/[Effect]_b[ln_expenditure])*(`j'-ref_children) + ([Effect]_b[r2vs1.hhadults]/[Effect]_b[ln_expenditure])*(`i'-ref_adults))
		
		return list
		putexcel P`rowcounter' = (r(b)[1,1])
		putexcel Q`rowcounter' = (sqrt(r(V)[1,1]))
		putexcel R`rowcounter' = (r(b)[1,1] - 1.96*(sqrt(r(V)[1,1])))
		putexcel S`rowcounter' = (r(b)[1,1] + 1.96*(sqrt(r(V)[1,1])))
		
		local ++rowcounter
		
		}
	}
	
}
	
********************************************************************************
*** (B): Children aged 0-4, 5-13, 14-17

* Set up Excel sheet 

putexcel set "${tables}/engel_results_childage_${y}.xlsx", sheet(`g') modify

putexcel A1 = "`g', Working-Leser Form"

putexcel B3 = "Estimate"
putexcel C3 = "Standard Error"
putexcel D3 = "95% CI Lower"
putexcel E3 = "95% CI Upper"

putexcel A13 = "One Adult, No Children"
putexcel A14 = "One Adult, One Young Child"
putexcel A15 = "One Adult, Two Young Children"
putexcel A16 = "One Adult, One Middle Child"
putexcel A17 = "One Adult, One Middle Child, One Young Child"
putexcel A18 = "One Adult, One Middle Child, Two Young Children"
putexcel A19 = "One Adult, Two Middle Children"
putexcel A20 = "One Adult, Two Middle Children, One Young Child"
putexcel A21 = "One Adult, Two Middle Children, Two Young Children"
putexcel A22 = "One Adult, One Old Child"
putexcel A23 = "One Adult, One Old Child, One Young Child"
putexcel A24 = "One Adult, One Old Child, Two Young Children"
putexcel A25 = "One Adult, One Old Child, One Middle Child"
putexcel A26 = "One Adult, One Old Child, One Middle Child, One Young Child"
putexcel A27 = "One Adult, One Old Child, One Middle Child, Two Young Children"
putexcel A28 = "One Adult, One Old Child, Two Middle Children"
putexcel A29 = "One Adult, One Old Child, Two Middle Children, One Young Child"
putexcel A30 = "One Adult, One Old Child, Two Middle Children, Two Young Children"
putexcel A31 = "One Adult, Two Old Children"
putexcel A32 = "One Adult, Two Old Children, One Young Child"
putexcel A33 = "One Adult, Two Old Children, Two Young Children"
putexcel A34 = "One Adult, Two Old Children, One Middle Child"
putexcel A35 = "One Adult,Two Old Children, One Middle Child, One Young Child"
putexcel A36 = "One Adult, Two Old Children, One Middle Child, Two Young Children"
putexcel A37 = "One Adult, Two Old Children, Two Middle Children"
putexcel A38 = "One Adult,Two Old Children, Two Middle Children, One Young Child"
putexcel A39 = "One Adult, Two Old Children, Two Middle Children, Two Young Children"
putexcel A41 = "Two Adults, No Children"
putexcel A42 = "Two Adults, One Young Child"
putexcel A43 = "Two Adults, Two Young Children"
putexcel A44 = "Two Adults, One Middle Child"
putexcel A45 = "Two Adults, One Middle Child, One Young Child"
putexcel A46 = "Two Adults, One Middle Child, Two Young Children"
putexcel A47 = "Two Adults, Two Middle Children"
putexcel A48 = "Two Adults, Two Middle Children, One Young Child"
putexcel A49 = "Two Adults, Two Middle Children, Two Young Children"
putexcel A50 = "Two Adults, One Old Child"
putexcel A51 = "Two Adults, One Old Child, One Young Child"
putexcel A52 = "Two Adults, One Old Child, Two Young Children"
putexcel A53 = "Two Adults, One Old Child, One Middle Child"
putexcel A54 = "Two Adults, One Old Child, One Middle Child, One Young Child"
putexcel A55 = "Two Adults, One Old Child, One Middle Child, Two Young Children"
putexcel A56 = "Two Adults, One Old Child, Two Middle Children"
putexcel A57 = "Two Adults, One Old Child, Two Middle Children, One Young Child"
putexcel A58 = "Two Adults, One Old Child, Two Middle Children, Two Young Children"
putexcel A59 = "Two Adults, Two Old Children"
putexcel A60 = "Two Adults, Two Old Children, One Young Child"
putexcel A61 = "Two Adults, Two Old Children, Two Young Children"
putexcel A62 = "Two Adults, Two Old Children, One Middle Child"
putexcel A63 = "Two Adults,Two Old Children, One Middle Child, One Young Child"
putexcel A64 = "Two Adults, Two Old Children, One Middle Child, Two Young Children"
putexcel A65 = "Two Adults, Two Old Children, Two Middle Children"
putexcel A66 = "Two Adults,Two Old Children, Two Middle Children, One Young Child"
putexcel A67 = "Two Adults, Two Old Children, Two Middle Children, Two Young Children"

* Estimate models

* Working-Leser parameteric form - write estimates, s.e.'s, and CI's to sheet.

regress `g'_share ln_expenditure hhnumu5 hhnum5to13 hhnum14to17 hh18plus

local rowcounter = 13

forvalues i = 1/2 {
    forvalues j = 0/2 {
		forvalues k = 0/2 {
			forvalues l = 0/2 {
				
				nlcom ((`i'+`j'+`k'+ `l')/ref_adults)*exp((_b[hh18plus]/_b[ln_expenditure])*(`i'-ref_adults) + (_b[hhnumu5]/_b[ln_expenditure])*(`j') + (_b[hhnum5to13]/_b[ln_expenditure]*(`k')) + (_b[hhnum14to17])*(`l'))
				
				return list
				putexcel B`rowcounter' = (r(b)[1,1])
				putexcel C`rowcounter' = (sqrt(r(V)[1,1]))
				putexcel D`rowcounter' = (r(b)[1,1] - 1.96*(sqrt(r(V)[1,1])))
				putexcel E`rowcounter' = (r(b)[1,1] + 1.96*(sqrt(r(V)[1,1])))
				
				if `rowcounter' != 39 {
					local ++rowcounter
				}
				else {
					local rowcounter = `rowcounter' + 2
				}
		
			}
		}
	}
}

* Kernel regression estimates 

if $run_ker == 1 {

putexcel H13 = "One Adult, No Children"
putexcel H14 = "One Adult, One Young Child"
putexcel H15 = "One Adult, Two Young Children"
putexcel H16 = "One Adult, One Middle Child"
putexcel H17 = "One Adult, One Middle Child, One Young Child"
putexcel H18 = "One Adult, One Middle Child, Two Young Children"
putexcel H19 = "One Adult, Two Middle Children"
putexcel H20 = "One Adult, Two Middle Children, One Young Child"
putexcel H21 = "One Adult, Two Middle Children, Two Young Children"
putexcel H22 = "One Adult, One Old Child"
putexcel H23 = "One Adult, One Old Child, One Young Child"
putexcel H24 = "One Adult, One Old Child, Two Young Children"
putexcel H25 = "One Adult, One Old Child, One Middle Child"
putexcel H26 = "One Adult, One Old Child, One Middle Child, One Young Child"
putexcel H27 = "One Adult, One Old Child, One Middle Child, Two Young Children"
putexcel H28 = "One Adult, One Old Child, Two Middle Children"
putexcel H29 = "One Adult, One Old Child, Two Middle Children, One Young Child"
putexcel H30 = "One Adult, One Old Child, Two Middle Children, Two Young Children"
putexcel H31 = "One Adult, Two Old Children"
putexcel H32 = "One Adult, Two Old Children, One Young Child"
putexcel H33 = "One Adult, Two Old Children, Two Young Children"
putexcel H34 = "One Adult, Two Old Children, One Middle Child"
putexcel H35 = "One Adult,Two Old Children, One Middle Child, One Young Child"
putexcel H36 = "One Adult, Two Old Children, One Middle Child, Two Young Children"
putexcel H37 = "One Adult, Two Old Children, Two Middle Children"
putexcel H38 = "One Adult,Two Old Children, Two Middle Children, One Young Child"
putexcel H39 = "One Adult, Two Old Children, Two Middle Children, Two Young Children"
putexcel H41 = "Two Adults, No Children"
putexcel H42 = "Two Adults, One Young Child"
putexcel H43 = "Two Adults, Two Young Children"
putexcel H44 = "Two Adults, One Middle Child"
putexcel H45 = "Two Adults, One Middle Child, One Young Child"
putexcel H46 = "Two Adults, One Middle Child, Two Young Children"
putexcel H47 = "Two Adults, Two Middle Children"
putexcel H48 = "Two Adults, Two Middle Children, One Young Child"
putexcel H49 = "Two Adults, Two Middle Children, Two Young Children"
putexcel H50 = "Two Adults, One Old Child"
putexcel H51 = "Two Adults, One Old Child, One Young Child"
putexcel H52 = "Two Adults, One Old Child, Two Young Children"
putexcel H53 = "Two Adults, One Old Child, One Middle Child"
putexcel H54 = "Two Adults, One Old Child, One Middle Child, One Young Child"
putexcel H55 = "Two Adults, One Old Child, One Middle Child, Two Young Children"
putexcel H56 = "Two Adults, One Old Child, Two Middle Children"
putexcel H57 = "Two Adults, One Old Child, Two Middle Children, One Young Child"
putexcel H58 = "Two Adults, One Old Child, Two Middle Children, Two Young Children"
putexcel H59 = "Two Adults, Two Old Children"
putexcel H60 = "Two Adults, Two Old Children, One Young Child"
putexcel H61 = "Two Adults, Two Old Children, Two Young Children"
putexcel H62 = "Two Adults, Two Old Children, One Middle Child"
putexcel H63 = "Two Adults,Two Old Children, One Middle Child, One Young Child"
putexcel H64 = "Two Adults, Two Old Children, One Middle Child, Two Young Children"
putexcel H65 = "Two Adults, Two Old Children, Two Middle Children"
putexcel H66 = "Two Adults,Two Old Children, Two Middle Children, One Young Child"
putexcel H67 = "Two Adults, Two Old Children, Two Middle Children, Two Young Children"

npregress kernel `g'_share ln_expenditure i.hhnumu5 i.hhnum5to13 i.hhnum14to17 i.hh18plus, vce(bootstrap, rep($ker_reps) seed(113))

local rowcounter = 13

forvalues i = 1/2 {
    forvalues j = 0/2 {
		forvalues k = 0/2 {
			forvalues l = 0/2 {
				
				nlcom ((`i'+`j'+`k'+ `l')/ref_adults)*exp(([Effect]_b[r1vs0.hh18plus]/[Effect]_b[ln_expenditure])*(`i'-ref_adults) + ([Effect]_b[r1vs0.hhnumu5]/[Effect]_b[ln_expenditure])*(`j') + ([Effect]_b[r1vs0.hhnum5to13]/[Effect]_b[ln_expenditure]*(`k')) + ([Effect]_b[r1vs0.hhnum14to17])*(`l'))
				
				return list
				putexcel P`rowcounter' = (r(b)[1,1])
				putexcel Q`rowcounter' = (sqrt(r(V)[1,1]))
				putexcel R`rowcounter' = (r(b)[1,1] - 1.96*(sqrt(r(V)[1,1])))
				putexcel S`rowcounter' = (r(b)[1,1] + 1.96*(sqrt(r(V)[1,1])))
				
				if `rowcounter' != 39 {
					local ++rowcounter
				}
				else {
					local rowcounter = `rowcounter' + 2
				}
		
			}
		}
	}
}

}

********************************************************************************
*** (C): Children aged <14, separate estimation by total expenditure quartile

/*

* Get quartile cutoffs

_pctile totexpend, p(25)
scalar expend_q1 = r(r1)
_pctile totexpend, p(50) 
scalar expend_median = r(r1)
_pctile totexpend, p(75)
scalar expend_q3 = r(r1)

* Estimate and write results to sheet

putexcel set "${tables}\engel\engel_results_quartiles_${y}.xlsx", sheet(`g') modify

* First quartile

regress `g'_share ln_expenditure hhnumu14 hhadults if totexpend <= expend_q1

local rowcounter = 4

forvalues i = 1/2 {
    forvalues j = 0/3 {
	    
	    nlcom ((`i'+`j')/ref_adults+ref_children)*exp((_b[hhnumu14]/_b[ln_expenditure])*(`j'-ref_children) + (_b[hhadults]/_b[ln_expenditure])*(`i'-ref_adults))
		
		return list
		putexcel B`rowcounter' = (r(b)[1,1])
		putexcel C`rowcounter' = (sqrt(r(V)[1,1]))
		putexcel D`rowcounter' = (r(b)[1,1] - 1.96*(sqrt(r(V)[1,1])))
		putexcel E`rowcounter' = (r(b)[1,1] + 1.96*(sqrt(r(V)[1,1])))
		
		local ++rowcounter
		
		}
	}

* Second quartile

regress `g'_share ln_expenditure hhnumu14 hhadults if (totexpend > expend_q1 & totexpend <= expend_median)

local rowcounter = 4

forvalues i = 1/2 {
    forvalues j = 0/3 {
	    
	    nlcom ((`i'+`j')/ref_adults+ref_children)*exp((_b[hhnumu14]/_b[ln_expenditure])*(`j'-ref_children) + (_b[hhadults]/_b[ln_expenditure])*(`i'-ref_adults))
		
		return list
		putexcel I`rowcounter' = (r(b)[1,1])
		putexcel J`rowcounter' = (sqrt(r(V)[1,1]))
		putexcel K`rowcounter' = (r(b)[1,1] - 1.96*(sqrt(r(V)[1,1])))
		putexcel L`rowcounter' = (r(b)[1,1] + 1.96*(sqrt(r(V)[1,1])))
		
		local ++rowcounter
		
		}
	}

* Third quartile

regress `g'_share ln_expenditure hhnumu14 hhadults if (totexpend > expend_median & totexpend <= expend_q3)

local rowcounter = 4

forvalues i = 1/2 {
    forvalues j = 0/3 {
	    
	    nlcom ((`i'+`j')/ref_adults+ref_children)*exp((_b[hhnumu14]/_b[ln_expenditure])*(`j'-ref_children) + (_b[hhadults]/_b[ln_expenditure])*(`i'-ref_adults))
		
		return list
		putexcel P`rowcounter' = (r(b)[1,1])
		putexcel Q`rowcounter' = (sqrt(r(V)[1,1]))
		putexcel R`rowcounter' = (r(b)[1,1] - 1.96*(sqrt(r(V)[1,1])))
		putexcel S`rowcounter' = (r(b)[1,1] + 1.96*(sqrt(r(V)[1,1])))
		
		local ++rowcounter
		
		}
	}

* Fourth quartile

regress `g'_share ln_expenditure hhnumu14 hhadults if (totexpend > expend_q3 & totexpend!=.)

local rowcounter = 4

forvalues i = 1/2 {
    forvalues j = 0/2 {
	    
	    nlcom ((`i'+`j')/ref_adults+ref_children)*exp((_b[hhnumu14]/_b[ln_expenditure])*(`j'-ref_children) + (_b[hhadults]/_b[ln_expenditure])*(`i'-ref_adults))
		
		return list
		putexcel V`rowcounter' = (r(b)[1,1])
		putexcel W`rowcounter' = (sqrt(r(V)[1,1]))
		putexcel X`rowcounter' = (r(b)[1,1] - 1.96*(sqrt(r(V)[1,1])))
		putexcel Y`rowcounter' = (r(b)[1,1] + 1.96*(sqrt(r(V)[1,1])))
		
		local ++rowcounter
		
		}
	}
	
*/


}