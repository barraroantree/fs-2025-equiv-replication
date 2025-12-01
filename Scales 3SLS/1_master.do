***********************************
* QUAIDS Equivalence Scales Code  *
* Luke Duggan, 09/02/'25          *
*                                 *
***********************************

* Define paths
// global onedrive "/Users/barratree/Library/CloudStorage/OneDrive-TrinityCollegeDublin/" // set by profile.do
global rawdata "${onedrive}//Research/Data/ISSDA 0022-00 HBS DIP/"  // raw data location on onedrive
global moddata "C:/moddata"          // modified data location on local machine


global repo "C:/Users/broantre/Documents/GitHub/fs-2025-equiv-replication/" // local repo folder 
global c3SLS "${repo}/Scales 3SLS" // code folder in repo for 3SLS code 

global dir "${moddata}"        // output directory - use same as local modified data location
global data "$dir"
global tables "$dir/tables"
global graphs "$dir/graphs"

global output "${tables}"       // sets the dir to output 3SLS estimation results


* Define years of data
global years 1987 1994 1999 2004 2009 2015

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

********************************************************************************
***************** Edit below this line at your own risk ... ******************** 
********************************************************************************

foreach y in $years {
        
    global year = `y' // Need to be able to refer to this in do-files called below

    * load data created earlier by 1_Data.do
    use "${moddata}/HBS_${y}_analysis.dta", clear

    * add some variables 
    do "$c3SLS/convenience.do" ///  This creates specific var's I normally use, can be commented out / deleted

    * 2. Create ancilliary locals and variables
    do "$c3SLS/2_vars.do"

    * 3. Run first-stage regressions (if applicable)
    do "$c3SLS/3_firststage.do"

    * 4. Estimate system using nlsur
    do "$c3SLS/4_estimation.do", nostop


}