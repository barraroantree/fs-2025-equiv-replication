* Buhmann et al scales, revision
* Luke Duggan 11/06/'25

eststo drop est*

local years 1987 1994 1999 2004 2009 2015
local results "$dir/tables"
local moddata "C:/moddata"          // modified data location on local machine

* Buhmann-type scales

foreach y in `years' {
	
    * Load data
    use "${moddata}/HBS_`y'_analysis.dta", clear


    * Create variables
    gen ln_totexpend = ln(totexpend)
    gen hhadults = hhsize - hhnumu14
    generate hh18plus = hhsize - (hhnumu5 + hhnum5to13 + hhnum14to17)
    gen ln_hhsize = ln(hhsize)

    * Run regression

    eststo: reg ln_totexpend ln_hhsize
        
}

esttab using "`results'/buhmann.rtf", rtf se scalars(F) replace
eststo drop est*

* Two parameter (Banks and Johnson-type) scales 

foreach y in `years' {
	
    * Load data
    global y `y' // To refer to current year in slave do-files
    use "${moddata}/HBS_`y'_analysis.dta", clear

    * Create variables
    gen ln_totexpend = ln(totexpend)
    gen hhadults = hhsize - hhnumu14
    generate hh18plus = hhsize - (hhnumu5 + hhnum5to13 + hhnum14to17)
    gen ln_hhsize = ln(hhsize)

    * Run regression

    eststo: nlsur (ln_totexpend = {cons} + {epsilon}*ln({A}*hhnumu14 + hhadults))
        
}

esttab using "`results'/two_param.rtf", rtf se scalars(F) replace
// ends 