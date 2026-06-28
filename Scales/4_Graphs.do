* 4. Descriptive graphs
* Luke Duggan, 30/05/'25

graph drop _all

* Scatterplots

foreach g in $goods {	
    binscatter `g'_share $expenditure, xtitle("Household Expenditure") name(`g', replace)
}

graph combine $goods
graph export "$graphs/combined_${y}.pdf", replace