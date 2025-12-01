/* 2_vars.do
Create ancilliary variables and locals

	(a) Copy variables
	(b) Get number of goods, endogenous vars, and demographics
	(c) Create expenditure shares, log prices, and average log prices
	(d) Create residual share
	(e) Creare log expenditure and average log expenditure
	(f) Create a_0 parameter for AIDS/QUAIDS

*/

*****	(a) Copy variables

local counter = 1
global ngoods

foreach g in $goods {
	gen g_`counter' = `g'
	global ngoods $ngoods g_`counter'
	local counter = `counter' + 1
}

local counter = 1
global nprices

foreach p in $prices {
	gen p_`counter' = `p'
	global nprices $nprices p_`counter'
	local counter = `counter' + 1
}

local counter = 1
global ndemographics

foreach d in $demographics {
	gen d_`counter' = `d'
	global ndemographics $ndemographics d_`counter'
	local counter = `counter' + 1
}

local counter = 1
global nendogenous

foreach e in $endogenous_vars {
	gen e_`counter' = `e'
	global nendogenous $nendogenous e_`counter'
	local counter = `counter' + 1
}
	

*****	(b) Get number of goods

global k = `:word count $goods'
global l = `:word count $endogenous_vars'
global z = `:word count $demographics'

*****	(c) Create expenditure shares, log prices, and average prices

global shares
global avg_prices

forvalues i = 1/$k {
	
	gen share_`i' = g_`i'/$expenditure
	global shares $shares share_`i'
	
	gen ln_p_`i' = ln(p_`i')
	egen avg_ln_p_`i' = mean(ln_p_`i')
	global avg_prices $avg_prices avg_ln_p_`i'

}

****** (d) Create residual share

egen others = rowtotal($shares)
gen share_resid = 1 - others
replace share_resid = 0 if share_resid<0 // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
replace share_resid = 1 if share_resid>1

***** (e) Creare log expenditure and average log expenditure

gen ln_expenditure = ln($expenditure)
egen avg_ln_expenditure = mean(ln_expenditure)

***** (f) Create a_0 parameter for AIDS/QUAIDS

summ ln_expenditure
return list 
global a_0 = r(min)

// end 