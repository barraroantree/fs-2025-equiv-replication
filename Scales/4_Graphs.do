* 4. Descriptive graphs
* Luke Duggan, 30/05/'25

graph drop _all

* Scatterplots

foreach g in $goods {	
	
scatter `g'_share $expenditure, mcolor(%20) xtitle("Household Expenditure") name(`g')
graph save "$graphs/`g'_${y}.gph", replace
graph export "$graphs/`g'_${y}.pdf", replace

}

graph combine $goods
graph save "$graphs/combined_${y}.gph", replace
graph export "$graphs/combined_${y}.pdf", replace