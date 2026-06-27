********************************************************************************
* plot estimated adult and child scales over time
********************************************************************************



* Plot adult scales over time
********************************************************************************
clear
cd "${outdir_scales}"

svmat adult_scales, names(col)
gen year = _n
recode year (1=1987) (2=1994) (3=1999) (4=2004) (5=2009) (6=2014)
order year *

gen modoecd = 0.6
gen cso = 0.66

global scales_to_plot :  subinstr global scales "sqrt" ""
global scales_to_plot :  subinstr global scales_to_plot "noeq" ""

set scheme stcolor
colorpalette plasma, n(5) nograph locals
local mcolors "mcolor("`r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'" )"
local lcolors "lcolor("`r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'" )"
local msymbs  "msymbol(O T O T O T O T O T)"

tw connect ${scales_to_plot} year, `mcolors' `lcolors' `msymbs' xlab(1985(5)2015)
graph export "${outdir_scales}//adult_scales.png", replace


* Plot child scales over time
********************************************************************************
clear

svmat child_scales, names(col)
gen year = _n
recode year (1=1987) (2=1994) (3=1999) (4=2004) (5=2009) (6=2014)
order year *

gen modoecd = 0.6
gen cso = 0.66

global scales_to_plot :  subinstr global scales "sqrt" ""
global scales_to_plot :  subinstr global scales_to_plot "noeq" ""
global scales_to_plot "${scales_to_plot} rothbarth_a rothbarth_c"

set scheme stcolor
colorpalette plasma, n(5) nograph locals
local mcolors "mcolor("`r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'" "grey" "grey" )"
local lcolors "lcolor("`r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'"  "grey" "grey")"
local msymbs  "msymbol(O T O T O T O T O T O T)"

tw connect ${scales_to_plot} year, `mcolors' `lcolors' `msymbs' xlab(1985(5)2015)
graph export "${outdir_scales}//child_scales.png", replace


// end 