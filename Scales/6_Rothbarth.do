* 6. Rothbarth method specifications
* Luke Duggan, 30/05/'25

* Define local of outcome goods

generate rcombined = alcohol + adultclothing + gambling
generate rcombined_share = rcombined/totexpend

local outcomes $roth_goods rcombined

* Generate scalars for sample means and medians of total expenditure.
	
_pctile totexpend, p(50)
scalar median_exp = r(r1)
summarize totexpend
scalar mean_exp = r(mean)

_pctile ln_expenditure, p(50)
scalar median_lnexp = r(r1)
summarize ln_expenditure
scalar mean_lnexp = r(mean)

/* Loop through specifications
Specifications are estimated three times:
 (A) with children as <14's.
 (B) with age distinctions among children aged 0-4, 5-13, and 14-17.
*/

foreach g in `outcomes' {
	
********************************************************************************
*** (A): Children aged <14
	
	* Set up excel sheet

putexcel set "${tables}/rothbarth_${y}.xlsx", sheet(`g') modify

putexcel A1 = "`g'"
putexcel A2 = "Evaluated at Sample Median"

putexcel B16 = "Estimate"
putexcel C16 = "Standard Error"
putexcel D16 = "95% CI Lower"
putexcel E16 = "95% CI Upper"

putexcel A5 = "One Adult, No Children"
putexcel A6 = "One Adult, One Child"
putexcel A7 = "One Adult, Two Children"
putexcel A8 = "One Adult, Three Children"

putexcel A9 = "Two Adults, No Children"
putexcel A10 = "Two Adults, One Child"
putexcel A11 = "Two Adults, Two Children"
putexcel A12 = "Two Adults, Three Children"

putexcel A14 = "Evaluated at Sample Mean"

putexcel B4 = "Estimate"
putexcel C4 = "Standard Error"
putexcel D4 = "95% CI Lower"
putexcel E4 = "95% CI Upper"

putexcel A17 = "One Adult, No Children"
putexcel A18 = "One Adult, One Child"
putexcel A19 = "One Adult, Two Children"
putexcel A20 = "One Adult, Three Children"

putexcel A21 = "Two Adults, No Children"
putexcel A22 = "Two Adults, One Child"
putexcel A23 = "Two Adults, Two Children"
putexcel A24 = "Two Adults, Three Children"

* Run model, compute scales and write estimates, s.e.'s, and CI's to sheet.

regress `g'_share ln_expenditure hhnumu14 hhadults

local rowcounter1 = 5
local rowcounter2 = 17

scalar median_ref_expend = ((_b[_cons] + _b[ln_expenditure]*median_lnexp + _b[hhnumu14]*ref_children + _b[hhadults]*ref_adults)*median_exp)
scalar mean_ref_expend = ((_b[_cons] + _b[ln_expenditure]*mean_lnexp + _b[hhnumu14]*ref_children + _b[hhadults]*ref_adults)*mean_exp)

forvalues i = 1/2 {
    forvalues j = 0/3 {
	    
	    nlcom median_ref_expend / ((_b[_cons] + _b[ln_expenditure]*median_lnexp + _b[hhnumu14]*`j' + _b[hhadults]*`i')*median_exp)
		
		return list
		putexcel B`rowcounter1' = (r(b)[1,1])
		putexcel C`rowcounter1' = (sqrt(r(V)[1,1]))
		putexcel D`rowcounter1' = (r(b)[1,1] - 1.96*(sqrt(r(V)[1,1])))
		putexcel E`rowcounter1' = (r(b)[1,1] + 1.96*(sqrt(r(V)[1,1])))
		
		local ++rowcounter1
		
		} 
	}
	
forvalues i = 1/2 {
    forvalues j = 0/3 {
	    
	    nlcom mean_ref_expend / ((_b[_cons] + _b[ln_expenditure]*mean_lnexp + _b[hhnumu14]*`j' + _b[hhadults]*`i')*mean_exp)
		
		return list
		putexcel B`rowcounter2' = (r(b)[1,1])
		putexcel C`rowcounter2' = (sqrt(r(V)[1,1]))
		putexcel D`rowcounter2' = (r(b)[1,1] - 1.96*(sqrt(r(V)[1,1])))
		putexcel E`rowcounter2' = (r(b)[1,1] + 1.96*(sqrt(r(V)[1,1])))
		
		local ++rowcounter2
		
		} 
	}

********************************************************************************
*** (B): Children aged 0-4, 5-13, 14-17

* Set up excel sheet

putexcel A26 = "Evaluated at Sample Median"

putexcel A28 = "One Adult, No Children"
putexcel A29 = "One Adult, One Young Child"
putexcel A30 = "One Adult, Two Young Children"
putexcel A31 = "One Adult, One Middle Child"
putexcel A32 = "One Adult, One Middle Child, One Young Child"
putexcel A33 = "One Adult, One Middle Child, Two Young Children"
putexcel A34 = "One Adult, Two Middle Children"
putexcel A35 = "One Adult, Two Middle Children, One Young Child"
putexcel A36 = "One Adult, Two Middle Children, Two Young Children"
putexcel A37 = "One Adult, One Old Child"
putexcel A38 = "One Adult, One Old Child, One Young Child"
putexcel A39 = "One Adult, One Old Child, Two Young Children"
putexcel A40 = "One Adult, One Old Child, One Middle Child"
putexcel A41 = "One Adult, One Old Child, One Middle Child, One Young Child"
putexcel A42 = "One Adult, One Old Child, One Middle Child, Two Young Children"
putexcel A43 = "One Adult, One Old Child, Two Middle Children"
putexcel A44 = "One Adult, One Old Child, Two Middle Children, One Young Child"
putexcel A45 = "One Adult, One Old Child, Two Middle Children, Two Young Children"
putexcel A46 = "One Adult, Two Old Children"
putexcel A47 = "One Adult, Two Old Children, One Young Child"
putexcel A48 = "One Adult, Two Old Children, Two Young Children"
putexcel A49 = "One Adult, Two Old Children, One Middle Child"
putexcel A50 = "One Adult,Two Old Children, One Middle Child, One Young Child"
putexcel A51 = "One Adult, Two Old Children, One Middle Child, Two Young Children"
putexcel A52 = "One Adult, Two Old Children, Two Middle Children"
putexcel A53 = "One Adult,Two Old Children, Two Middle Children, One Young Child"
putexcel A54 = "One Adult, Two Old Children, Two Middle Children, Two Young Children"
putexcel A56 = "Two Adults, No Children"
putexcel A57 = "Two Adults, One Young Child"
putexcel A58 = "Two Adults, Two Young Children"
putexcel A59 = "Two Adults, One Middle Child"
putexcel A60 = "Two Adults, One Middle Child, One Young Child"
putexcel A61 = "Two Adults, One Middle Child, Two Young Children"
putexcel A62 = "Two Adults, Two Middle Children"
putexcel A63 = "Two Adults, Two Middle Children, One Young Child"
putexcel A64 = "Two Adults, Two Middle Children, Two Young Children"
putexcel A65 = "Two Adults, One Old Child"
putexcel A66 = "Two Adults, One Old Child, One Young Child"
putexcel A67 = "Two Adults, One Old Child, Two Young Children"
putexcel A68 = "Two Adults, One Old Child, One Middle Child"
putexcel A69 = "Two Adults, One Old Child, One Middle Child, One Young Child"
putexcel A70 = "Two Adults, One Old Child, One Middle Child, Two Young Children"
putexcel A71 = "Two Adults, One Old Child, Two Middle Children"
putexcel A72 = "Two Adults, One Old Child, Two Middle Children, One Young Child"
putexcel A73 = "Two Adults, One Old Child, Two Middle Children, Two Young Children"
putexcel A74 = "Two Adults, Two Old Children"
putexcel A75 = "Two Adults, Two Old Children, One Young Child"
putexcel A76 = "Two Adults, Two Old Children, Two Young Children"
putexcel A77 = "Two Adults, Two Old Children, One Middle Child"
putexcel A78 = "Two Adults,Two Old Children, One Middle Child, One Young Child"
putexcel A79 = "Two Adults, Two Old Children, One Middle Child, Two Young Children"
putexcel A80 = "Two Adults, Two Old Children, Two Middle Children"
putexcel A81 = "Two Adults,Two Old Children, Two Middle Children, One Young Child"
putexcel A82 = "Two Adults, Two Old Children, Two Middle Children, Two Young Children"

* Run model, compute scales and write estimates, s.e.'s, and CI's to sheet.

regress `g'_share ln_expenditure hhnumu5 hhnum5to13 hhnum14to17 hh18plus

local rowcounter1 = 28

forvalues i = 1/2 {
    forvalues j = 0/2 {
	    forvalues k = 0/2 {
		    forvalues l = 0/2 {
			    
				nlcom median_ref_expend / ((_b[_cons] + _b[ln_expenditure]*median_lnexp + _b[hhnumu5]*`j' + _b[hhnum5to13]*`k' + _b[hhnum14to17]*`l' + _b[hh18plus]*`i')*median_exp)
				
				return list
				putexcel B`rowcounter1' = (r(b)[1,1])
				putexcel C`rowcounter1' = (sqrt(r(V)[1,1]))
				putexcel D`rowcounter1' = (r(b)[1,1] - 1.96*(sqrt(r(V)[1,1])))
				putexcel E`rowcounter1' = (r(b)[1,1] + 1.96*(sqrt(r(V)[1,1])))
				
				if `rowcounter1' != 54 {
				    local ++rowcounter1
					}
				else {
				    local rowcounter1 = `rowcounter1'+2
					}
			}
		}
	}
}

********************************************************************************
*** (C) : First and Third Quartiles

* Generate scalars for sample means and medians of total expenditure.
	
_pctile totexpend, p(25)
scalar low_exp = r(r1)
_pctile totexpend, p(75)
scalar high_exp = r(r1)

_pctile ln_expenditure, p(25)
scalar low_lnexp = r(r1)
_pctile ln_expenditure, p(75)
scalar high_lnexp = r(r1)

* Get estimated scales and standard errors

* Set up excel sheet

putexcel set "${tables}/rothbarth_${y}.xlsx", sheet(`g') modify

putexcel G2 = "Evaluated at Sample First Quartile"

putexcel H16 = "Estimate"
putexcel I16 = "Standard Error"
putexcel J16 = "95% CI Lower"
putexcel K16 = "95% CI Upper"

putexcel G5 = "One Adult, No Children"
putexcel G6 = "One Adult, One Child"
putexcel G7 = "One Adult, Two Children"
putexcel G8 = "One Adult, Three Children"

putexcel G9 = "Two Adults, No Children"
putexcel G10 = "Two Adults, One Child"
putexcel G11 = "Two Adults, Two Children"
putexcel G12 = "Two Adults, Three Children"

putexcel G14 = "Evaluated at Sample Third Quartile"

putexcel H4 = "Estimate"
putexcel I4 = "Standard Error"
putexcel J4 = "95% CI Lower"
putexcel K4 = "95% CI Upper"

putexcel G17 = "One Adult, No Children"
putexcel G18 = "One Adult, One Child"
putexcel G19 = "One Adult, Two Children"
putexcel G20 = "One Adult, Three Children"

putexcel G21 = "Two Adults, No Children"
putexcel G22 = "Two Adults, One Child"
putexcel G23 = "Two Adults, Two Children"
putexcel G24 = "Two Adults, Three Children"

* Run model, compute scales and write estimates, s.e.'s, and CI's to sheet.

regress `g'_share ln_expenditure hhnumu14 hhadults

local rowcounter1 = 5
local rowcounter2 = 17

scalar low_ref_expend = ((_b[_cons] + _b[ln_expenditure]*low_lnexp + _b[hhnumu14]*ref_children + _b[hhadults]*ref_adults)*low_exp)
scalar high_ref_expend = ((_b[_cons] + _b[ln_expenditure]*high_lnexp + _b[hhnumu14]*ref_children + _b[hhadults]*ref_adults)*high_exp)

forvalues i = 1/2 {
    forvalues j = 0/3 {
	    
	    nlcom low_ref_expend / ((_b[_cons] + _b[ln_expenditure]*low_lnexp + _b[hhnumu14]*`j' + _b[hhadults]*`i')*low_exp)
		
		return list
		putexcel H`rowcounter1' = (r(b)[1,1])
		putexcel I`rowcounter1' = (sqrt(r(V)[1,1]))
		putexcel J`rowcounter1' = (r(b)[1,1] - 1.96*(sqrt(r(V)[1,1])))
		putexcel K`rowcounter1' = (r(b)[1,1] + 1.96*(sqrt(r(V)[1,1])))
		
		local ++rowcounter1
		
		} 
	}
	
forvalues i = 1/2 {
    forvalues j = 0/3 {
	    
	    nlcom high_ref_expend / ((_b[_cons] + _b[ln_expenditure]*high_lnexp + _b[hhnumu14]*`j' + _b[hhadults]*`i')*high_exp)
		
		return list
		putexcel H`rowcounter2' = (r(b)[1,1])
		putexcel I`rowcounter2' = (sqrt(r(V)[1,1]))
		putexcel J`rowcounter2' = (r(b)[1,1] - 1.96*(sqrt(r(V)[1,1])))
		putexcel K`rowcounter2' = (r(b)[1,1] + 1.96*(sqrt(r(V)[1,1])))
		
		local ++rowcounter2
		
		} 
	}

}