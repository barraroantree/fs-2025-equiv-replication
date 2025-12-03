*** Equivalisation (Once Again) -- Final code
*** Luke Duggan and Barra Roantree 

********************************************************************************

* Globals

* set paths 
// global onedrive "/Users/barratree/Library/CloudStorage/OneDrive-TrinityCollegeDublin/" // set by profile.do
global rawdata "${onedrive}//Research/Data/ISSDA 0022-00 HBS DIP/"  // raw data location (on onedrive for me)
global moddata "C:/moddata"          // modified data location on local machine

global repo "C:/Users/broantre/Documents/GitHub/fs-2025-equiv-replication/" // local repo folder 
global code "${repo}/Scales"        // code folder in repo for non-3SLS code  
global pricedata "${repo}//Prices"     // location of price files in repo 

global dir "${moddata}"             // output directory - use same as local modified data location

global data "$dir"
global tables "$dir/tables"
global graphs "$dir/graphs"


* make directories if they don't exist
cap mkdir "${dir}"
cap mkdir "${tables}"
cap mkdir "${graphs}"


* Data years
global years 1987 1994 1999 2004 2009 2015  

* Commodities
global aids_goods food alcohol tobacco clothing energy transport
global engel_goods food housing clothing
global roth_goods alcohol adultclothing gambling

* Demographic variables and ref household type
global demographics hhnumu14 hhadults hhnumu5 hhnum5to13 hhnum14to17
global demographics_3sls hhnumu14 hhadults
scalar ref_adults = 2
scalar ref_children = 0

* Total expenditure variable
global expenditure totexpend

/* Kernel regression globals 
Set run_ker = 1 to rerun kernel regressions and rewrite results. 
ker_reps specifies the number of bootstrap rep's when computing s.e.'s.
Bear in mind that running the kernel regressions increases the runtime of the
code by a factor of maybe 10. */ 

global run_ker = 0
global ker_reps = 50

********************************************************************************

*** Run code

timer clear
timer on 1

foreach year in $years {
	
    global y `year' // To refer to current year in slave do-files

    * 1. Load data and merge in price series
    do "$code\1_Data.do"

    * 2. Create anciliary variables
    do "$code\2_Vars.do"

    * 3. Summary statistics
    do "$code\3_Summ_stats.do"

    * 4. Descriptive graphs
    do "$code\4_Graphs.do"

    * 5. Estimate Engel specifications
    do "$code\5_Engel.do"

    * 6. Estimate Rothbarth specifications
    do "$code\6_Rothbarth.do"

    * 7. Estimate (QU)AIDS specifications
    do "$code\7_(QU)AIDS.do"

}


********************************************************************************

* then separately run code to compute Buhmann et al and two-parameter scales
do "${code}//Buhmann_et_al.do"

timer off 1
timer list