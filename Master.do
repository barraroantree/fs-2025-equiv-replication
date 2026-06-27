*** Equivalisation (Once Again) -- Master replication file
*** Doorley, Duggan, Kakoulidou and Roantree (2026)

********************************************************************************
* Paths 
********************************************************************************


* set $repo to your local clone of this repository
global repo "/Users/barratree/Code/fs-2025-equiv-replication/" // SET THIS TO YOUR LOCAL REPO FOLDER


* rest 
global rawdata "${repo}/Data/rawdata/"  // raw data location — extract ISSDA HBS files here
global moddata "${repo}/Data/moddata"   // modified data location (gitignored in repo)

global code   "${repo}/Scales"          // OLS/kernel scale estimation code
global c3SLS  "${repo}/Scales 3SLS"    // 3SLS scale estimation code
global pricedata "${repo}/Prices"       // price files

global results "${repo}/Results"        // output tables and graphs (gitignored)
global tables  "${results}/tables"
global graphs  "${results}/graphs"

global outdir_povrates "${graphs}/poverty rates/"
global outdir_scales   "${graphs}/scales/"
global outdir_ranks    "${graphs}/ranks/"

* make directories if they don't exist
cap mkdir "${rawdata}"
cap mkdir "${moddata}"
cap mkdir "${results}"
cap mkdir "${tables}"
cap mkdir "${graphs}"
cap mkdir "${outdir_povrates}"
cap mkdir "${outdir_scales}"
cap mkdir "${outdir_ranks}"


********************************************************************************
* Set years and total expenditure var
********************************************************************************

* Data years
global years 1987 1994 1999 2004 2009 2015

* Expenditure variable
global expenditure totexpend


********************************************************************************
* Install dependencies if not already installed
********************************************************************************

ssc install binscatter 
ssc install inequal7

// add any others you might uncover as you run the code here  


********************************************************************************
*** Part 1: OLS/kernel scale estimation (Engel, Rothbarth, AIDS/QUAIDS, Buhmann)
********************************************************************************

* Commodities
global aids_goods food alcohol tobacco clothing energy transport
global engel_goods food housing clothing
global roth_goods alcohol adultclothing gambling

* Demographic variables and ref household type
global demographics hhnumu14 hhadults hhnumu5 hhnum5to13 hhnum14to17
scalar ref_adults = 2
scalar ref_children = 0

/* Kernel regression globals 
Set run_ker = 1 to rerun kernel regressions and rewrite results. 
ker_reps specifies the number of bootstrap rep's when computing s.e.'s.
Bear in mind that running the kernel regressions increases the runtime of the
code by a factor of maybe 10. */ 

global run_ker = 0
global ker_reps = 50




timer clear
timer on 1

foreach year in $years {

    global y `year' // referred to in sub-do-files

    * 1. Load data and merge price series
    do "$code/1_Data.do"

    * 2. Create ancillary variables
    do "$code/2_Vars.do"

    * 3. Summary statistics
    do "$code/3_Summ_stats.do"

    * 4. Descriptive graphs
    do "$code/4_Graphs.do"

    * 5. Engel specifications
    do "$code/5_Engel.do"

    * 6. Rothbarth specifications
    do "$code/6_Rothbarth.do"

    * 7. (QU)AIDS specifications
    do "$code/7_(QU)AIDS.do"

}

* Buhmann et al. and two-parameter scales
do "$code/Buhmann_et_al.do"

timer off 1
timer list


********************************************************************************
*** Part 2: 3SLS scale estimation (AIDS/QUAIDS via nlsur)
********************************************************************************


global output "${tables}"   // output directory for 3SLS results


* Define demand system arguments
global goods totfood totdrink tobacco clothing fuel transport
global prices p_food p_alcohol p_tobacco p_clothing p_energy p_transport
global expenditure totexpend
global demographics hhnumu5 hhnum5to13 hhnum14to17 hhadults_1star
global quadratic 0 // 1 = QUAIDS, 0 = AIDS

* Define endogenous variables

global endogenous_vars totexpend

* For each endogenous variable, define a list of instruments
global instruments_1 HHdispinc
* global instruments2
* global instruments3, and so on ...


* Run 3SLS estimation for each year, timing things 
timer on 2
foreach y in $years {

    global year = `y'

    * load analysis data produced in Part 1
    use "${moddata}/HBS_${y}_analysis.dta", clear

    * 2. Create demand-system variables
    do "$c3SLS/2_vars.do"

    * 3. First-stage regressions
    do "$c3SLS/3_firststage.do"

    * 4. Estimate system via nlsur
    do "$c3SLS/4_estimation.do", nostop

}

timer off 2
timer list


********************************************************************************
*** Part 3: Poverty rates and inequality figures
********************************************************************************
* Equivalence scales to plot and use in poverty analysis
global scales noeq modoecd cso sqrt food_wl comb_wl food_kl comb_kl AIDS AIDS3sls QUAIDS QUAIDS3sls


* read or set the scales
do "${repo}/poverty rates/0_set_scales.do"

* Plot the estimated scales 
do "${repo}/poverty rates/1_plot_scales.do"

* Calculate and plot poverty results 
do "${repo}/poverty rates/2_calc_plot_poverty_results.do"



// ends