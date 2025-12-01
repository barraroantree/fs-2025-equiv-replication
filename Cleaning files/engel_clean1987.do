* path to raw data
global hbs1987 "${rawdata}//0022-01_HBS_1987/0022-01_HBS_1987_Data/0022-01_HBS_1987.dta"	// set path to 1987 data
use "${hbs1987}", clear

*************************** household characteristics **************************


gen hhid=_n

gen hhsize = hdr3
gen hhnumu5 = hdr33 + hdr39
gen hhnum5to13 = hdr34 + hdr40
gen hhnumu14 = hdr33 + hdr34 + hdr39 + hdr40
gen hhnum14to17 = hdr124 + hdr127

gen grossfac= (grossf/100000)*(factra/100000)*(factrb/100000)
label var grossfac "grossing factor"

gen hbsyear = 1987

gen year 	= 1987
replace year=1988 if hdr5==8

gen month = hdr14

gen quarter = .
replace quarter = 1 if inlist(hdr6,5)
replace quarter = 2 if inlist(hdr6,2,6)
replace quarter = 3 if inlist(hdr6,3,7)
replace quarter = 4 if inlist(hdr6,4)


gen hhedu = .
replace hhedu = 1 if inrange(hdr342,0,3) // no formal education
replace hhedu = 2 if inrange(hdr342,4,16) // primary, junior cert
replace hhedu = 3 if inrange(hdr342,17,19) // leaving cert
replace hhedu = 4 if inrange(hdr342,20,40) // 3rd level


clonevar hhtenure = hdr16
recode hhtenure (1=1) (2=2) (5/6 = 3) (4 = 4) (3 7 = 5), gen(hhtenure3way)
label define tenure 1 "owned outright" 2 "owned w/mortgage" 3 "private rented" 4 "LA rented" 5 "other (rent free, tenant purchased, etc)" , replace
label values hhtenure3way tenure

gen hohage = hdr45

gen hohcohort = .
replace hohcohort = 1 if inlist(hohage,6,7,8)		// ~ pre-WWI
replace hohcohort = 2 if inlist(hohage,4,5)			// ~ boomer 
replace hohcohort = 3 if inlist(hohage,1,2,3)		// ~ generation something 




**************************** housing costs **********************************

// housing costs, for construction of AHC income definition 
* following UK HBAI methodology and calculate as rent (gross of housing benefit); water rates, community water charges and council water charges; mortgage interest payments; structural insurance premiums (for owner occupiers); ground rent and service charges
	* should this include tenant purchase payments TRL233? Don't think so
	* 

/*
gen housingcosts 		= trl585 												// rent 
replace housingcosts 	= housingcosts + trl229 + trl230 + trl231 +  ///
											trl232 + trl586 + trl587			// ground rent & charges
replace housingcosts 	= housingcosts + trl234 								// mortgage interest 
replace housingcosts 	= housingcosts + trl238 								// dwellings insurance  
replace housingcosts 	= housingcosts*1.27
label var housingcosts "housing costs pw (EUR)"
*/

gen housingcosts = (trl229 + trl230 + trl231 + trl232 + trl234 + trl238)*1.27/100
// have removed the 580's variables, see housingcosts.do

***************************** income variables ********************************


gen equivadults = hdr447/10
label var equivadults "household equivalisation factor (CSO)"

gen HHgrossinc = trl494*1.27/100 // are these in cents too?
label var HHgrossinc "gross income (EUR)"

gen equivHHgrossinc=HHgrossinc/equivadults
label var equivHHgrossinc "CSO equivalised gross income"

gen HHdispinc = trl498*1.27/100
label var HHdispinc "disposable income (EUR)"

gen equivHHdispinc=HHdispinc/equivadults
label var equivHHdispinc "CSO equivalised disposable income"


gen AHCdispinc = HHdispinc - housingcosts
label var AHCdispinc "AHC disposable income (EUR)"

gen equivAHCdispinc=AHCdispinc/equivadults
label var equivAHCdispinc "CSO equivalised AHC disposable income"





*************************** consumption ***************************************



// expenditure categories 
* clean fuel and energy variables 
* NB: diesel also includes "oil"
gen v_diesel=(trl337+trl339)/100
gen v_petrol=trl336/100
gen v_lpgcar=trl338/100

label var v_diesel "expenditure on diesel"
label var v_petrol "expenditure on petrol"
label var v_lpgcar "expenditure on lpg car"

gen v_fuel=(trl215+trl216+trl217+trl218+trl219+trl220+trl221+trl222+ ///
			trl223+trl224+trl225+trl227)/100
label var v_fuel "expenditure on fuel and light"

* Get quantities of heating fuels
gen q_gas=trl547
label var q_gas "m3"
gen q_elect=trl548
label var q_elect "units"
gen q_anthrac=trl549
label var q_anthrac "KGs"
gen q_coal=trl550
label var q_coal "KGs"
gen q_turfl=trl551
label var q_turfl "cwt"
gen q_turfb=trl552
label var q_turfb "bales"
gen q_heatoil=trl553
label var q_heatoil "litres"
gen q_paraf=trl554
label var q_paraf "pints"
gen q_lpg=trl555
label var q_lpg "KGs"


* aggregate consumption categories 
gen v_food= (trl1+	trl2+	trl3+	trl4+	trl5+	trl6+	trl7+	trl8+	trl9+	trl10+	trl11+	trl12+	trl13+	trl14+	trl15+	///
			trl16+	trl17+	trl18+	trl19+	trl20+	trl21+	trl22+	trl23+	trl24+	trl25+	trl26+	trl27+	trl28+	trl29+	trl30+	///
			trl31+	trl32+	trl33+	trl34+	trl35+	trl36+	trl37+	trl38+	trl39+	trl40+	trl41+	trl42+	trl43+	trl44+	trl45+	///
			trl46+	trl47+	trl48+	trl49+	trl50+	trl51+	trl52+	trl53+	trl54+	trl55+	trl56+	trl57+	trl58+	trl59+	trl60+	///
			trl61+	trl62+	trl63+	trl64+	trl65+	trl66+	trl67+	trl68+	trl69+	trl70+	trl71+	trl72+	trl73+	trl74+	trl75+	///
			trl76+	trl77+	trl78+	trl79+	trl80+	trl81+	trl82+	trl83+	trl84+	trl85+	trl86+	trl87+	trl88+	trl89+	trl90+	///
			trl91+	trl92+	trl93+	trl94+	trl95+	trl96+	trl97+	trl98+	trl99+	trl100+	trl101+	trl102+	trl103+	trl104+	trl105+	///
			trl106+	trl107+	trl108+	trl109+	trl110+	trl111+	trl112+	trl113+	trl114+	trl115+	trl116+	trl117+	trl118+	trl119+	trl120+	///
			trl121+	trl122+	trl123+	trl124+	trl125+	trl126+	trl127+	trl128+	trl129+	trl130+	trl131+	trl132+	trl133+	trl134)/100					

					
gen v_adultgoods= (trl135+	trl136+	trl137+	trl138+	trl139+	trl140+	trl141+	trl142+	trl143+	trl144)/100

gen subv_drinks = (trl135+	trl136+	trl137+	trl138+	trl139+	trl140+	trl141)/100
				
				
gen v_clothing= (trl145+	trl146+	trl147+	trl148+	trl149+	trl150+	trl151+	trl152+	trl153+	trl154+	trl155+	trl156+	trl157+	trl158+	///
				trl159+	trl160+	trl161+	trl162+	trl163+	trl164+	trl165+	trl166+	trl167+	trl168+	trl169+	trl170+	trl171+	trl172+	trl173+	///
				trl174+	trl175+	trl176+	trl177+	trl178+	trl179+	trl180+	trl181+	trl182+	trl183+	trl184+	trl185+	trl186+	trl187+	trl188+	///
				trl189+	trl190+	trl191+	trl192+	trl193+	trl194+	trl195+	trl196+	trl197+	trl198+	trl199+	trl200+	trl201+	trl202+	trl203+	///
				trl204+	trl205+	trl206+	trl207+	trl208+	trl209+	trl210+	trl211+	trl212+	trl213+	trl214)/100
				
gen subv_adultclothing = (trl145+	trl146+	trl147+	trl148+	trl149+	trl150+	trl151+	trl152+	trl153+	trl154+	trl155+	trl156+	trl157+	trl158+	///
				trl159+	trl160+	trl161+	trl162+	trl163+ trl175+	trl176+	trl177+	trl178+	trl179+	trl180+	trl181+	trl182+	trl183+	trl184+	trl185+	trl186+	trl187+	trl188+	///
				trl189+	trl190+	trl191+	trl192+	trl193+	trl194+	trl195+	trl196+	trl197+	trl198)/100


gen v_housing= (trl229+	trl230+	trl231+	trl232+	trl233+	trl234+	trl235+	trl236+	trl237+	trl238+	trl239+	trl240+	trl241+	trl242+	trl243+	///
				trl244+	trl613+	trl614+	trl616+	trl616+	trl245+	trl247+	trl246)/100
			
*includes firelighters and candles			
gen v_hhnondurable= (trl248+	trl249+	trl250+	trl251+	trl252+	trl253+	trl254+	trl255+	trl256+	trl257+	trl258+	trl259+	trl260)/100
			
				
gen v_hhdurable= (trl261+	trl262+	trl263+	trl264+	trl265+	trl266+	trl273+	trl274+	trl275+	trl276+	trl277+	trl278+	trl279+	trl280+	///
				trl281+	trl282+	trl267+	trl268+	trl269+	trl270+	trl271+	trl272+	trl283+	trl284+	trl285+	trl286+	trl287+	trl288+	trl289+	///
				trl290+	trl291+	trl292+	trl293+	trl294+	trl295+	trl296+	trl297+	trl298+	trl299)/100

				
gen v_misc= (trl300+	trl301+	trl302+	trl303+	trl304+	trl305+	trl306+	trl307+	trl308+	trl309+	trl310+	trl311+	trl312+	trl313+	trl314+	///
trl315+	trl316+	trl317+	trl318+	trl319+	trl320+	trl321+	trl322+	trl323+	trl324+	trl325)/100


				
gen v_transport= (trl326+	trl327+	trl328+	trl329+	trl330+	trl331+	trl332+	trl333+	trl334+	trl335+	trl336+	trl337+	trl338+	trl339+	///
				trl340+	trl341+	trl342+	trl343+	trl344+	trl345+	trl346+	trl347+	trl348+	trl349+	trl350+	trl351+	trl352+	trl353)/100

						
						
gen v_other= (trl354+	trl355+	trl356+	trl357+	trl358+	trl359+	trl620+	trl360+	trl361+	trl362+	trl363+	trl364+	trl365+	trl366+	trl367+	///
			trl368+	trl369+	trl370+	trl371+	trl372+	trl373+	trl374+	trl375+	trl376+	trl377+	trl378+	trl379+	///
			trl380+	trl381+	trl382+	trl383+	trl384+	trl385+	trl386+	trl387+	trl388+	trl389+	trl390+	trl391+	trl392+	trl393+	trl617+	trl618+	///
			trl619+	trl394+	trl395+	trl396+	trl397+	trl398+	trl399+	trl400+	trl401+	trl402+	trl403+	trl404+	trl405+	trl406+	trl407+	trl408+	///
			trl409+	trl410+	trl411+	trl412+	trl413+	trl414+	trl415+	trl416+	trl417+	trl418+	trl419+	trl420+	trl421+	trl422+	trl423+	trl424+	///
			trl425+	trl426)/100
			
gen subv_betting = (trl422)/100
						
*total household expenditure variable

gen v_tothhexp= v_fuel+v_food+v_adultgoods+v_clothing+v_housing+v_hhnondurable+v_hhdurable+v_misc+v_transport+v_other							

*label expenditure variables

label var v_food "expenditure on food"
label var v_adultgoods "expenditure on drink and tobacco"
label var v_clothing "expenditure on clothing and footwear"
label var subv_adultclothing "expenditure on adult clothing and footwear"
label var v_housing "expenditure on housing"
label var v_hhnondurable "expenditure on household non durable goods"
label var v_hhdurable "expenditure on household durable goods"
label var v_misc "expenditure on miscellaneous"
label var v_transport "expenditure on transport"
label var v_other "expenditure on services and other"
label var subv_betting "expenditure on betting and gambling"
label var v_tothhexp "total household expenditure"
label var subv_drinks "total household expenditure"

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
rename v_transport transport
rename v_other other
rename subv_betting betting
rename v_fuel fuel

gen vehicles = (trl326 + trl327 + trl328 + trl330)/100

foreach var in totexpend nondurable durable totfood totdrink housing adultgoods clothing misc transport fuel vehicles {
	replace `var' = `var'*1.27 // conversion to euro
}

* equivalised consumption


gen consAHC = totexpend - housingcosts - vehicles
gen equivconsAHC = consAHC/equivadults


**************************** additional characteristics ************************

gen gender = 0
replace gender = 1 if hdr25 == 1

gen urban = 0 
replace urban = 1 if hdr11 == 1 | hdr11 == 2

gen married = 0
replace married = 1 if hdr123 == 1 | hdr123 == 2 | hdr123 == 3

gen famcomp = hdr12

gen numworking = hdr22

gen workstatus = 0
replace workstatus = 1 if inlist(hdr23, 1, 2, 3, 4, 5, 6) // working
replace workstatus = 2 if inlist(hdr23, 7, 8, 9) // unemployed
replace workstatus = 3 if hdr23 == 11 // retired
replace workstatus = 4 if inlist(hdr23, 10, 12, 13, 14) // other inactive

gen acctype = 0
replace acctype = 1 if inlist(hdr57, 2, 3, 4) // apartment
replace acctype = 2 if inlist(hdr57, 5, 6) // house
replace acctype = 3 if inlist(hdr57, 1, 7) // other

gen rooms = hdr55

gen cars = hdr70
replace cars = 3 if cars > 3

gen seconddwelling = hdr96 // 1 = no, 2 = owned, 3 = rented

gen nummedcard = hdr27

gen stpghi = hdr13 // state transfer payments to gross household income

gen currentac = 0
replace currentac = 1 if hdr69 == 1 

gen econcat = hdr130 // 1. Manual workers in Industry & Services 2. Non-manual workers3. Self-employed in Industry & Services 4. Farmers 5. Agricultrual workers 6. Fishermen, Foresters 7. Non-economically active 

gen yrsresident = hdr258

gen hoursworked = hdr350a

keep totexpend nondurable durable totfood totdrink housing housingcosts adultgoods clothing misc transport betting adultclothing fuel consAHC equivconsAHC vehicles ///
hbsyear year month quarter hhid hhsize hhnumu14 hhnum14to17 grossfac hhedu hhtenure hhtenure3way hohage hohcohort ///
gender urban married famcomp numworking workstatus acctype rooms cars seconddwelling nummedcard stpghi ///
currentac econcat yrsresident hoursworked HHdispinc equivHHdispinc AHCdispinc equivAHCdispinc HHgrossinc equivHHgrossinc hhnumu5 hhnum5to13