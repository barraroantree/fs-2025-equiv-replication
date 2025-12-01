/* 4_estimation.do
Estimate QUAIDS budget share equations using nlsur

	(a) Create gamma matrix
	(b) Create good_i gamma linear combination
	(c) Create gamma quadratic form
	(d) Create (minus) ln_a_p price index
	(e) Create b_p product term
	(f) Define terms for demographic scaling
	(g) Define terms for 3SLS
	(h) Create system of estimating equations
	(i) Estimate system using nlsur
	
*/

***** (a) Create (symmetric) gamma matrix

forvalues i = 1/$k {
forvalues j = 1/$k {
	
	if `i' >= `j' {
		
		local gamma_`i'_`j' {gamma_`i'_`j'}*ln_p_`j'
		
	}
	
	else {
		
		local gamma_`i'_`j' {gamma_`j'_`i'}*ln_p_`j'
		
	}

}
}

***** (b) Create good_i gamma linear combination

forvalues i = 1/$k {
	
	local gamma_lincom_`i' 0
	
forvalues j = 1/$k {
	
	local gamma_lincom_`i' `gamma_lincom_`i'' + `gamma_`i'_`j''

}
}

***** (c) Create gamma quadratic form

local quadform 0

forvalues i = 1/$k {
forvalues j = 1/$k {
	
	local quadform `quadform' + `gamma_`i'_`j''*ln_p_`i'

}
}

local quadform ($k/2)*(`quadform')

***** (d) Create (minus) ln_a_p price index

local ln_a_p $a_0

forvalues i = 1/$k {

local ln_a_p `ln_a_p' - {a_`i'}*ln_p_`i'

}

local ln_a_p `ln_a_p' - `quadform'

***** (e) Create b_p product term

local b_p 1

forvalues i = 1/$k {
	
local b_p `b_p'*((p_`i')^({b_`i'}))

}

***** (f) Define terms for demographic scaling

local log_arg = 1

forvalues i = 1/$z {
	
	local log_arg `log_arg' + {rho_`i'}*d_`i'
	
}

local ln_m_0 ln(`log_arg')

forvalues i = 1/$k {
	
	local eta_lincom_`i' 0
	
	forvalues j = 1/$z {
		
		local eta_lincom_`i' `eta_lincom_`i'' + {eta_`i'_`j'}*d_`j'
	
}
}

local c_p_d 1

forvalues i = 1/$k {
	
	local c_p_d `c_p_d'*((p_`i')^(`eta_lincom_`i''))

}

***** (g) Define term for 3SLS

forvalues i = 1/$k {
	
	local xi_lincom_`i' 0
	
forvalues j = 1/$l {
	
	local xi_lincom_`i' `xi_lincom_`i'' + {xi_`i'_`j'}*fs_resid_`j'

}
}

***** (h) Create system of estimating equations

local estimating_system 

forvalues i = 1/$k {

local estimating_system `estimating_system' ///
(share_`i' = {a_`i'} + `gamma_lincom_`i'' + ({beta_`i'} + ///
`eta_lincom_`i'')*(ln_expenditure + `ln_a_p' - `ln_m_0') + ///
$quadratic * ({lambda_`i'}/(`b_p'*`c_p_d'))*((ln_expenditure + `ln_a_p' - `ln_m_0')^(2)) + ///
`xi_lincom_`i'')

}

***** (i) Estimate system using nlsur

nlsur `estimating_system'

return list
putexcel set "$output\childage_estimates.xlsx", sheet($year) modify
putexcel A2 = matrix(r(table)), names
// end 