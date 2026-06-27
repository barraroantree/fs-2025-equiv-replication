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

* colour version
set scheme stcolor
colorpalette plasma, n(5) nograph locals
local mcolors "mcolor("`r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'" )"
local lcolors "lcolor("`r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'" )"
local msymbs  "msymbol(O T O T O T O T O T)"

tw connect ${scales_to_plot} year, `mcolors' `lcolors' `msymbs' xlab(1985(5)2015)
graph export "${outdir_scales}//adult_scales.png", replace

* greyscale version
* color = method family; line pattern = spec (_wl/OLS=solid, _kl/3SLS=dash); shape = good (food=O, comb=T)
* series order: modoecd cso | food_wl comb_wl food_kl comb_kl | AIDS AIDS3sls | QUAIDS QUAIDS3sls
local mcolors   "mcolor(  black    black    gs7  gs7  gs7  gs7  gs13  gs13   gs13 gs13)"
local lcolors   "lcolor(  black    black    gs7  gs7  gs7  gs7  gs13 gs13   gs13 gs13)"
local lpatterns "lpattern(solid solid  solid solid dash dash  solid solid  dash dash)"
local msymbs    "msymbol( O    T           O     T    O    T    O     T    O     T   )"

tw connect ${scales_to_plot} year, `mcolors' `lcolors' `lpatterns' `msymbs' xlab(1985(5)2015)
graph export "${outdir_scales}//adult_scales_grey.png", replace
graph export "${graphs}//figure1a.png", replace


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

* colour version
set scheme stcolor
colorpalette plasma, n(5) nograph locals
local mcolors "mcolor("`r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'" "grey" "grey" )"
local lcolors "lcolor("`r(p1)'" "`r(p1)'" "`r(p2)'" "`r(p2)'" "`r(p3)'" "`r(p3)'" "`r(p4)'" "`r(p4)'" "`r(p5)'" "`r(p5)'"  "grey" "grey")"
local msymbs  "msymbol(O T O T O T O T O T O T)"

tw connect ${scales_to_plot} year, `mcolors' `lcolors' `msymbs' xlab(1985(5)2015)
graph export "${outdir_scales}//child_scales.png", replace

* greyscale version
* color = method family; line pattern = spec (_wl/OLS=solid, _kl/3SLS=dash); shape = good (food=O, comb=T)
* series order: modoecd cso | food_wl comb_wl food_kl comb_kl | AIDS AIDS3sls | QUAIDS QUAIDS3sls | rothbarth_a rothbarth_c
local mcolors   "mcolor(  black    black    gs7  gs7  gs7  gs7  gs13  gs13   gs13 gs13  gs2  gs2 )"
local lcolors   "lcolor(  black    black    gs7  gs7  gs7  gs7  gs13 gs13   gs13 gs13  gs2  gs2 )"
local lpatterns "lpattern(solid solid  solid solid dash dash  solid solid  dash dash  dot dot)"
local msymbs    "msymbol( O    T           O     T    O    T    O     T    O     T    O     T  )"

tw connect ${scales_to_plot} year, `mcolors' `lcolors' `lpatterns' `msymbs' xlab(1985(5)2015)
graph export "${outdir_scales}//child_scales_grey.png", replace
graph export "${graphs}//figure1b.png", replace


// end 