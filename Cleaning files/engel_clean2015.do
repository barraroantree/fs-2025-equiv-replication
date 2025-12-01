**********************************************************************************************************
* 2015-16
**********************************************************************************************************

global hbs2015 "${rawdata}//0022-06_HBS_2015-2016/0022-06_HBS_2015-2016_Data/0022-06_HBS_2015-2016.csv"
insheet using "${hbs2015}", clear
rename h*, upper // code below written with these variables in upper case

*************************** household characteristics **************************

gen hbsyear = 2015
gen year 	= var005

gen month = var014

gen quarter = .
replace quarter = 1 if inlist(var006,1,5)
replace quarter = 2 if inlist(var006,2)
replace quarter = 3 if inlist(var006,3)
replace quarter = 4 if inlist(var006,4)

gen hhid = _n // hhold_id saved as string 

gen hhsize = var003
gen hhnumu5 = var033 + var039
gen hhnum5to13 = var034 + var040
gen hhnumu14 = var033 + var034 + var039 + var040
gen hhnum14to17 = var124 + var127


gen grossfac = gf

gen hhedu = .
replace hhedu = 1 if inlist(var342,0,1)	// no formal or primary
replace hhedu = 2 if inlist(var342,2)		// lower secondary 
replace hhedu = 3 if inlist(var342,3)		// higher secondary 
replace hhedu = 4 if inrange(var342,4,10) // post-secondary 

	
clonevar hhtenure = var016
recode hhtenure (1=1) (2=2) (5/6 = 3) (4 = 4) (3 7 = 5), gen(hhtenure3way)
label define tenure 1 "owned outright" 2 "owned w/mortgage" 3 "private rented" 4 "LA rented" 5 "other (rent free, tenant purchased, etc)" , replace
label values hhtenure3way tenure

clonevar hohage = var045

gen hohcohort = .
replace hohcohort = 1 if inlist(hohage,8)			// ~ pre-WWI
replace hohcohort = 2 if inlist(hohage,6,7)			// ~ boomer 
replace hohcohort = 3 if inlist(hohage,3,4,5)		// ~ generation something 


****************************** housing costs ***********************************


// housing costs, for construction of AHC income definition 
* again following UK HBAI methodology (see 1999 code above) 
	* stupidly mortgage repayment lumps together principal and interest!
	* is rent here gross or net of rent supplement/allowance 
gen housingcosts 		= H05_01 												// rent on primary dwelling
replace housingcosts	= housingcosts + H05_02 + H05_09 + H05_10				// ground rent and charges 
replace housingcosts	= housingcosts + H05_08									// dwelling insurance 
// replace housingcosts	= housingcosts + H05_04									// mortgage repayments (INCLUDES PRINCIPAL!) 
label var housingcosts "housing costs pw (EUR)"

// can no longer include H05_04 since it includes principal


******************************* income variables *******************************

// incomes 
gen numchildren = var033 + var034 + var039 + var040
gen numpersons = var053 + var054
gen numadults=numpersons-numchildren
gen equivadults=1+(numadults-1)*0.66+numchildren*(0.33)


gen HHgrossinc = HE071
label var HHgrossinc "gross income (EUR)"

gen equivHHgrossinc=HHgrossinc/equivadults
label var equivHHgrossinc "CSO equivalised gross income"


gen HHdispinc = HE073
label var HHdispinc "disposable income (EUR)"

gen equivHHdispinc=HHdispinc/equivadults
label var equivHHdispinc "CSO equivalised disposable income"


gen AHCdispinc = HHdispinc - housingcosts
label var AHCdispinc "AHC disposable income (EUR)"

gen equivAHCdispinc=AHCdispinc/equivadults
label var equivAHCdispinc "CSO equivalised AHC disposable income"




*************************** consumption variables ******************************


// expenditure categories 
gen v_diesel=H08_02_02+H08_02_03

gen v_petrol=H08_02_01


label var v_diesel "Expenditure on diesel"
label var v_petrol "Expenditure on petrol"


gen v_fuel=H04
label var v_fuel "expenditure on fuel and light"





* label fuel expenditure variables

gen v_gas=H04_02
label var v_gas "expenditure on natural gas"
gen v_elec=H04_01
label var v_elec "expenditure on electricity"
gen v_liqfuel=H04_03
label var v_liqfuel "expenditure on liquid fuel"
gen v_solfuel=H04_04
label var v_solfuel "expenditure on solid fuel"


*Prepare household expenditure variables

gen v_food= H01					

					
gen v_adultgoods= H02

gen subv_drinks = H02_01 + H02_02
				
				
gen v_clothing= H03

gen subv_adultclothing = H03_02 + H03_03 + H03_04 + H03_05 + H03_11 + H03_12 + ///
H03_16 + H03_17

				
gen v_housing= H05
			
*includes firelighters and candles			
gen v_hhnondurable= H06

			
				
gen v_hhdurable= H07

				
gen v_misc= H09

gen subv_betting = H09_05

gen v_transport= H08
						
						
						
*total household expenditure variable

gen v_tothhexp= v_fuel+v_food+v_adultgoods+v_clothing+v_housing+v_hhnondurable+v_hhdurable+v_misc+v_transport
gen v_totalexprec = v_tothhexp		

*label expenditure variables

label var v_food "expenditure on food"
label var v_adultgoods "expenditure on drink and tobacco"
label var v_clothing "expenditure on clothing and footwear"
label var v_housing "expenditure on housing"
label var v_hhnondurable "expenditure on household non durable goods"
label var v_hhdurable "expenditure on household durable goods"
label var v_misc "expenditure on miscellaneous"
label var subv_betting "expenditure on betting and gambling"
label var v_transport "expenditure on transport"
label var v_tothhexp "total household expenditure"
label var v_totalexprec "total household expenditure recorded"

rename v_tothhexp totexpend  		// derrived from sub categories
rename v_food totfood				// " "
rename subv_drinks totdrink  		// sub-category of v_adultgoods that strip out for analysis		
rename v_hhdurable durable 			// check categories consistent with derrived ones provided in HBS in recent years 
gen nondurable= totexpend-durable


rename v_adultgoods adultgoods
rename v_clothing clothing
rename subv_adultclothing adultclothing
rename v_housing housing
rename v_misc misc
rename subv_betting betting
rename v_transport transport
rename v_fuel fuel

* equivalised consumption
gen vehicles = H08_01 - H08_01_04
gen consAHC = totexpend - housingcosts - vehicles
gen equivconsAHC = consAHC/equivadults



************************ additional characteristics ****************************

gen gender = 0
replace gender = 1 if var025 == 1

gen urban = 0 
replace urban = 1 if var011 == 1

gen married = 0
replace married = 1 if var123 == 2

gen famcomp = var012

gen numworking = var022

gen workstatus = 0
replace workstatus = 1 if inlist(var023, 1, 2, 3, 4, 5, 6) // working
replace workstatus = 2 if inlist(var023, 7, 8, 9) // unemployed
replace workstatus = 3 if var023 == 11 // retired
replace workstatus = 4 if inlist(var023, 10, 12, 13, 14) // other inactive

gen acctype = 0
replace acctype = 1 if inlist(var057, 2, 3, 4) // apartment
replace acctype = 2 if inlist(var057, 5, 6) // house
replace acctype = 3 if inlist(var057, 1, 7) // other

gen rooms = var055

gen cars = var070
replace cars = 3 if cars > 3

gen seconddwelling = var096 // 1 = no, 2 = owned, 3 = rented

gen nummedcard = var027

gen stpghi = var013 // state transfer payments to gross household income

gen currentac = 0
replace currentac = 1 if var069 == 1

gen econcat = var130 // 1. Manual workers in Industry & Services 2. Non-manual workers3. Self-employed in Industry & Services 4. Farmers 5. Agricultrual workers 6. Fishermen, Foresters 7. Non-economically active 

gen yrsresident = var258

gen hoursworked = var350a
destring hoursworked, replace force

keep totexpend nondurable durable totfood totdrink housing housingcosts adultgoods clothing misc transport betting adultclothing fuel consAHC equivconsAHC vehicles ///
hbsyear year month quarter hhid hhsize hhnumu14 hhnum14to17 grossfac hhedu hhtenure hhtenure3way hohage hohcohort ///
gender urban married famcomp numworking workstatus acctype rooms cars seconddwelling nummedcard stpghi ///
currentac econcat yrsresident hoursworked HHdispinc equivHHdispinc AHCdispinc equivAHCdispinc HHgrossinc equivHHgrossinc hhnumu5 hhnum5to13