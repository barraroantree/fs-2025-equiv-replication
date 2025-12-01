* 3. Create summary statistics
* Luke Duggan, 30/05/'25

* Summarise commodity shares

estpost tabstat $shares, stats(n mean median sd min max)
esttab using "${tables}/shares_${y}.rtf", cells("$shares") ///
title("Commodity Share Summary Stats, ${y}") replace rtf nonumber

* Summarise household characteristics

estpost tabstat $expenditure $demographics, stats(n mean median sd min max)
esttab using "${tables}/households_${y}.rtf", cells("$expenditure $demographics") ///
title("Household Characteristics Summary Stats, ${y}") replace rtf nonumber