* 2. Create anciliary variables
* Luke Duggan, 30/05/'25

***
/* Some cleaning: generate tobacco, rename variables, generate adults and
adults-1 variable, and 18+ variable: comment out if unnecessary */

gen tobacco = adultgoods - totdrink

gen food = totfood
gen alcohol = totdrink
gen energy = fuel 
gen gambling = betting

gen hhadults = hhsize - hhnumu14
generate hh18plus = hhsize - (hhnumu5 + hhnum5to13 + hhnum14to17)

***

* Create goods global

global tmp_list : list global(engel_goods) | global(roth_goods)
global goods : list global(aids_goods) | global(tmp_list)

* Expenditure shares, log prices, and average log prices

global shares
global aids_shares
global log_prices 
global avg_log_prices
global prices 
global avg_prices

foreach g in $goods {
	
	gen `g'_share = `g'/$expenditure
	global shares $shares `g'_share
	
	drop if `g'<0 //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

}

foreach g in $aids_goods {
	
	global aids_shares $aids_shares `g'_share
	
	gen ln_p_`g' = ln(p_`g')
	global log_prices $log_prices ln_p_`g'
	egen avg_ln_p_`g' = mean(ln_p_`g')
	global avg_log_prices $avg_log_prices avg_ln_p_`g'
	
	global prices $prices p_`g'
	egen avg_p_`g' = mean(p_`g')
	global avg_prices $avg_prices avg_p_`g'

}

* Residual share

egen others = rowtotal($aids_shares)
gen resid_share  = 1 - others
replace resid_share = 0 if resid_share<0
replace resid_share = 1 if resid_share>1

* Log expenditure and average log expenditure

gen ln_expenditure = ln($expenditure)
egen avg_ln_expenditure = mean(ln_expenditure)

* Create a_0 parameter for AIDS/QUAIDS

summ ln_expenditure
return list 
global a_0 = r(min)

// end 