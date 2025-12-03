* 1. Load in data and merge price series
* Luke Duggan, 30/05/'25

    * location of cleaning code 
    global cleaningcode "${repo}//Cleaning files" 

   * Load and clean raw data
    do "${cleaningcode}/engel_clean${y}.do"
    save "${moddata}/HBS_${y}.dta", replace

    * Load prices and save as .dta
    import excel using "${pricedata}/prices_${y}_base_2011.xlsx", clear firstrow 
    save "${moddata}/prices_${y}_base_2011.dta", replace

    * Merge in prices and save analysis data
    use "${moddata}/HBS_${y}.dta", clear
    merge m:m year month using "${moddata}/prices_${y}_base_2011.dta"
    drop if hbsyear==.
    drop _merge
    
    save "${moddata}/HBS_${y}_analysis.dta", replace
// end