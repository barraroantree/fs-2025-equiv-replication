**********************************************************************************************************
global hbs1999 "${rawdata}//0022-03_HBS_1999/0022-03_HBS_1999_Data/0022-03_HBS_1999.dta"
use "${hbs1999}", clear


* household chars 
**********************************************************************************************************

gen hhid=_n

gen hhsize = HDR3
gen hhnumu5 = HDR33 + HDR39
gen hhnum5to13 = HDR34 + HDR40
gen hhnumu14 = HDR33 + HDR34 + HDR39 + HDR40
gen hhnum14to17 = HDR124 + HDR127

gen grossfac= (grossf/100000)*(factra/100000)*(factrb/100000)
label var grossfac "grossing factor"

gen hbsyear = 1999

gen year 	= 1999
replace year=2000 if HDR5==5 

gen month = HDR14

gen quarter = .
replace quarter = 1 if inlist(HDR6,5)
replace quarter = 2 if inlist(HDR6,2,6)
replace quarter = 3 if inlist(HDR6,3,7)
replace quarter = 4 if inlist(HDR6,4)


gen hhedu = .
replace hhedu = 1 if inlist(HDR342,0,1)
replace hhedu = 2 if inlist(HDR342,2)
replace hhedu = 3 if inlist(HDR342,3)
replace hhedu = 4 if inrange(HDR342,4,6)

clonevar hhtenure = HDR16
recode hhtenure (1=1) (2=2) (5/6 = 3) (4 = 4) (3 7 = 5), gen(hhtenure3way)
label define tenure 1 "owned outright" 2 "owned w/mortgage" 3 "private rented" 4 "LA rented" 5 "other (rent free, tenant purchased, etc)" , replace
label values hhtenure3way tenure

gen hohage = HDR45

gen hohcohort = .
replace hohcohort = 1 if inlist(hohage,6,7,8)		// ~ pre-WWI
replace hohcohort = 2 if inlist(hohage,4,5)			// ~ boomer 
replace hohcohort = 3 if inlist(hohage,1,2,3)		// ~ generation something 



******************************* housing costs **********************************

// housing costs, for construction of AHC income definition 
* following UK HBAI methodology and calculate as rent (gross of housing benefit); water rates, community water charges and council water charges; mortgage interest payments; structural insurance premiums (for owner occupiers); ground rent and service charges
	* should this include tenant purchase payments TRL233? Don't think so
	* 

/*
gen housingcosts 		= TRL585 												// rent 
replace housingcosts 	= housingcosts + TRL229 + TRL230 + TRL231 +  ///
											TRL232 + TRL586 + TRL587			// ground rent & charges
replace housingcosts 	= housingcosts + TRL234 								// mortgage interest 
replace housingcosts 	= housingcosts + TRL238 								// dwellings insurance  
replace housingcosts 	= housingcosts*1.27
label var housingcosts "housing costs pw (EUR)"
*/

gen housingcosts = (TRL229 + TRL230 + TRL231 + TRL232 + TRL234 + TRL238)/100
// have removed the 580's variables, see housingcosts.do




***************************** income variables *********************************

//Prepare income variables
gen equivadults = HDR447/10
label var equivadults "household equivalisation factor (CSO)"

gen HHgrossinc = TRL494/100
label var HHgrossinc "gross income (EUR)"

gen equivHHgrossinc=HHgrossinc/equivadults
label var equivHHgrossinc "CSO equivalised gross income"

gen HHdispinc = TRL498/100
label var HHdispinc "disposable income (EUR)"

gen equivHHdispinc=HHdispinc/equivadults
label var equivHHdispinc "CSO equivalised disposable income"


gen AHCdispinc = HHdispinc - housingcosts
label var AHCdispinc "AHC disposable income (EUR)"

gen equivAHCdispinc=AHCdispinc/equivadults
label var equivAHCdispinc "CSO equivalised AHC disposable income"




******************************* consumption variables **************************

// expenditure categories 
* clean fuel and energy variables 
gen v_diesel=(TRL337+TRL339)/100 	// NB: diesel also includes "oil"
gen v_petrol=TRL336/100
gen v_lpgcar=TRL338/100

label var v_diesel "expenditure on diesel"
label var v_petrol "expenditure on petrol"
label var v_lpgcar "expenditure on lpg car"

gen v_fuel=(TRL215+TRL216+TRL217+TRL218+TRL219+TRL220+TRL221+TRL222+ ///
			TRL223+TRL224+TRL225+TRL227)/100
label var v_fuel "expenditure on fuel and light"

* Get quantities of heating fuels
gen q_gas=TRL547
label var q_gas "m3"
gen q_elect=TRL548
label var q_elect "units"
gen q_anthrac=TRL549
label var q_anthrac "KGs"
gen q_coal=TRL550
label var q_coal "KGs"
gen q_turfl=TRL551
label var q_turfl "cwt"
gen q_turfb=TRL552
label var q_turfb "bales"
gen q_heatoil=TRL553
label var q_heatoil "litres"
gen q_paraf=TRL554
label var q_paraf "pints"
gen q_lpg=TRL555
label var q_lpg "KGs"


* aggregate consumption categories 
gen v_food= (TRL1+	TRL2+	TRL3+	TRL4+	TRL5+	TRL6+	TRL7+	TRL8+	TRL9+	TRL10+	TRL11+	TRL12+	///
			TRL13+	TRL14+	TRL15+	TRL16+	TRL17+	TRL18+	TRL19+	TRL646+	TRL20+	TRL21+	TRL22+	TRL23+	///
			TRL24+	TRL25+	TRL26+	TRL27+	TRL28+	TRL29+	TRL30+	TRL31+	TRL32+	TRL33+	TRL34+	TRL35+	///
			TRL36+	TRL37+	TRL38+	TRL39+	TRL40+	TRL41+	TRL42+	TRL43+	TRL44+	TRL45+	TRL46+	TRL47+	///
			TRL48+	TRL49+	TRL50+	TRL51+	TRL52+	TRL53+	TRL1005+	TRL54+	TRL55+	TRL56+	TRL57+	TRL58+	///
			TRL59+	TRL60+	TRL61+	TRL62+	TRL63+	TRL64+	TRL65+	TRL1003+	TRL1004+	TRL66+	TRL67+	TRL68+	///
			TRL69+	TRL70+	TRL71+	TRL72+	TRL73+	TRL74+	TRL75+	TRL76+	TRL77+	TRL78+	TRL79+	TRL80+	TRL81+	///
			TRL82+	TRL83+	TRL84+	TRL85+	TRL1015+	TRL86+	TRL87+	TRL88+	TRL89+	TRL90+	TRL92+	///
			TRL93+	TRL94+	TRL95+	TRL96+	TRL659+	TRL97+	TRL98+	TRL99+	TRL100+	TRL101+	TRL102+	TRL103+	TRL104+	///
			TRL105+	TRL106+	TRL107+	TRL108+	TRL109+	TRL110+	TRL111+	TRL112+	TRL113+	TRL114+	TRL115+	TRL116+	TRL117+	///
			TRL118+	TRL119+	TRL120+	TRL121+	TRL122+	TRL123+	TRL124+	TRL125+	TRL126+	TRL127+	TRL1001+	TRL1126+	///
			TRL1127+	TRL1128+	TRL128+	TRL129+	TRL130+	TRL131+	TRL132+	TRL133+	TRL134+	TRL1006)/100						

					
gen v_adultgoods= (TRL135+	TRL136+	TRL137+	TRL138+	TRL139+	TRL140+	TRL141+	TRL142+	TRL143+	TRL144)/100

gen subv_drinks = (TRL135+	TRL136+	TRL137+	TRL138+	TRL139+	TRL140+	TRL141)/100
				
gen v_clothing= (TRL145+	TRL146+	TRL147+	TRL148+	TRL149+	TRL150+	TRL151+	TRL152+	TRL153+	TRL154+	TRL155+	TRL156+	///
				TRL157+	TRL158+	TRL159+	TRL160+	TRL161+	TRL162+	TRL163+	TRL164+	TRL165+	TRL166+	TRL167+	TRL168+	///
				TRL169+	TRL170+	TRL171+	TRL172+	TRL173+	TRL174+	TRL175+	TRL176+	TRL177+	TRL178+	TRL179+	TRL180+	///
				TRL181+	TRL182+	TRL183+	TRL184+	TRL185+	TRL186+	TRL187+	TRL188+	TRL189+	TRL190+	TRL191+	TRL192+	///
				TRL193+	TRL194+	TRL195+	TRL196+	TRL197+	TRL198+	TRL199+	TRL200+	TRL201+	TRL202+	TRL203+	TRL204+	///
				TRL205+	TRL206+	TRL207+	TRL208+	TRL209+	TRL210+	TRL211+	TRL212+	TRL213+	TRL214)/100
				
gen subv_adultclothing = (TRL145+	TRL146+	TRL147+	TRL148+	TRL149+	TRL150+	TRL151+	TRL152+	TRL153+	TRL154+	TRL155+	TRL156+	///
				TRL157+	TRL158+	TRL159+	TRL160+	TRL161+	TRL162+	TRL163+ TRL175+	TRL176+	TRL177+	TRL178+	TRL179+	TRL180+	///
				TRL181+	TRL182+	TRL183+	TRL184+	TRL185+	TRL186+	TRL187+	TRL188+	TRL189+	TRL190+	TRL191+	TRL192+	///
				TRL193+	TRL194+	TRL195+	TRL196+	TRL197+	TRL198)/100
				
gen v_housing= (TRL229+	TRL230+	TRL231+	TRL232+	TRL233+	TRL234+	TRL235+	TRL236+	TRL237+	TRL238+	TRL239+	TRL1201+	///
				TRL1202+	TRL1017+	TRL1203+	TRL1204+	TRL1205+	TRL1206+	TRL1207+	TRL1209+	TRL1210+	///
				TRL1211+	TRL1212+	TRL1213+	TRL1214+	TRL1215+	TRL1216+	TRL1217+	TRL1218+	TRL1219+	///
				TRL1220+	TRL1221+	TRL1222+	TRL1223+	TRL1224+	TRL1225+	TRL1226+	TRL1227+	TRL1228+	///
				TRL1229+	TRL1230+	TRL1231+	TRL1232+	TRL1233+	TRL1234+	TRL1235+	TRL1236+	TRL240+	TRL241+	///
				TRL242+	TRL243+	TRL244+	TRL613+	TRL614+	TRL615+	TRL665+	TRL616+	TRL1008+	TRL1009+	TRL245+	TRL247+	TRL246+	///
				TRL1257+	TRL645+	TRL1258+	TRL1259+	TRL1012)/100
			
*includes firelighters and candles			
gen v_hhnondurable= (TRL248+	TRL249+	TRL250+	TRL251+	TRL252+	TRL253+	TRL254+	TRL255+	TRL256+	TRL257+	TRL258+	TRL259+	TRL260+	TRL1368+	///
					TRL1369+	TRL1370+	TRL1371+	TRL1372+	TRL1373+	TRL1374+	TRL918+	TRL662+TRL228+TRL226+TRL228)/100

			
				
gen v_hhdurable= (TRL261+	TRL262+	TRL263+	TRL1237+	TRL1238+	TRL1239+	TRL1241+	TRL1242+	TRL1243+	TRL1244+	///
				TRL1245+	TRL1246+	TRL1247+	TRL1248+	TRL1249+	TRL1250+	TRL1251+	TRL1252+	TRL1253+	///
				TRL1254+	TRL1255+	TRL1256+	TRL264+	TRL265+	TRL266+	TRL1260+	TRL1261+	TRL1262+	TRL1263+	///
				TRL1264+	TRL1265+	TRL1266+	TRL1267+	TRL1268+	TRL1269+	TRL1270+	TRL1271+	TRL1272+	///
				TRL1273+	TRL1274+	TRL1275+	TRL1276+	TRL1277+	TRL1278+	TRL1279+	TRL1280+	TRL1281+	///
				TRL1282+	TRL1283+	TRL1284+	TRL1285+	TRL1286+	TRL1287+	TRL1288+	TRL1289+	TRL1290+	///
				TRL1291+	TRL1292+	TRL1293+	TRL1294+	TRL1295+	TRL273+	TRL274+	TRL275+	TRL276+	TRL277+	TRL278+	///
				TRL661+	TRL279+	TRL281+	TRL282+	TRL267+	TRL1016+	TRL268+	TRL270+	TRL271+	TRL1296+	TRL1297+	TRL1298+	///
				TRL1299+	TRL1301+	TRL1302+	TRL1303+	TRL1304+	TRL654+	TRL1305+	TRL272+	TRL1010+	///
				TRL1014+	TRL283+	TRL284+	TRL285+	TRL269+	TRL1387+	TRL1388+	TRL1389+	TRL1390+	TRL1391+	///
				TRL1392+	TRL1393+	TRL1394+	TRL1395+	TRL1396+	TRL1397+	TRL1398+	TRL1007+	TRL322+	TRL286+	///
				TRL287+	TRL1307+	TRL1308+	TRL1129+	TRL1309+	TRL1310+	TRL1311+	TRL1312+	TRL1313+	///
				TRL1314+	TRL1315+	TRL288+	TRL289+	TRL290+	TRL291+	TRL292+	TRL293+	TRL294+	TRL295+	TRL296+	TRL297+	///
				TRL298+	TRL299)/100

				
gen v_misc= (TRL300+	TRL301+	TRL302+	TRL303+	TRL304+	TRL305+	TRL306+	TRL307+	TRL308+	TRL309+	TRL310+	TRL311+	TRL312+	TRL313+	///
			TRL314+	TRL315+	TRL316+	TRL317+	TRL318+	TRL319+	TRL320+	TRL321+	TRL323+	TRL324+	TRL325)/100	
				

gen v_transport= (TRL326+	TRL327+	TRL328+	TRL329+	TRL330+	TRL331+	TRL332+	TRL333+	TRL334+	TRL335+	TRL336+	TRL337+	TRL338+	///
				TRL339+	TRL340+	TRL341+	TRL342+	TRL1020+	TRL1316+	TRL1317+	TRL1318+	TRL1319+	TRL343+	TRL344+	///
				TRL345+	TRL346+	TRL347+	TRL348+	TRL349+	TRL350+	TRL351+	TRL352+	TRL353)/100

gen v_betting = (TRL422)/100
						
gen v_other= (TRL354+	TRL355+	TRL356+	TRL357+	TRL358+	TRL359+	TRL620+	TRL360+	TRL361+	TRL362+	TRL363+	TRL364+	TRL365+	TRL366+	///
			TRL367+	TRL621+	TRL622+	TRL623+	TRL624+	TRL368+	TRL369+	TRL370+	TRL371+	TRL372+	TRL373+	TRL374+	TRL919+	TRL376+	///
			TRL1322+	TRL1323+	TRL1324+	TRL1325+	TRL1326+	TRL1327+	TRL1328+	TRL1329+	TRL1330+	TRL1331+	///
			TRL1332+	TRL1333+	TRL1334+	TRL1335+	TRL1336+	TRL1337+	TRL1338+	TRL1339+	TRL1340+	TRL1341+	///
			TRL1342+	TRL1343+	TRL1344+	TRL377+	TRL1114+	TRL1115+	TRL1116+	TRL1117+	TRL1118+	TRL1119+	///
			TRL1120+	TRL1121+	TRL1122+	TRL1123+	TRL1124+	TRL1125+	TRL378+	TRL379+	TRL380+	TRL381+	TRL382+	TRL383+	///
			TRL384+	TRL385+	TRL386+	TRL387+	TRL388+	TRL389+	TRL390+	TRL391+	TRL1399+	TRL1101+	TRL1102+	TRL1103+	TRL1105+	///
			TRL1106+	TRL1133+	TRL392+	TRL393+	TRL1013+	TRL617+	TRL618+	TRL619+	TRL1345+	TRL1346+	TRL1347+	TRL1348+	///
			TRL1349+	TRL1350+	TRL1351+	TRL1352+	TRL1353+	TRL1354+	TRL1355+	TRL1356+	TRL1357+	TRL1358+	///
			TRL1359+	TRL1360+	TRL1361+	TRL1362+	TRL1364+	TRL1365+	TRL1366+	TRL1367+	TRL394+	TRL395+	TRL663+	///
			TRL396+	TRL397+	TRL1112+	TRL398+	TRL1107+	TRL1108+	TRL1109+	TRL1110+	TRL1111+	TRL1113+	TRL399+	TRL400+	///
			TRL401+	TRL402+	TRL403+	TRL404+	TRL405+	TRL406+	TRL407+	TRL408+	TRL409+	TRL410+	TRL411+	TRL412+	TRL413+	TRL414+	TRL415+	///
			TRL416+	TRL417+	TRL418+	TRL420+	TRL421+	TRL422+	TRL1375+	TRL1376+	TRL1377+	TRL1378+	TRL1379+	///
			TRL1380+	TRL1381+	TRL1382+	TRL423+	TRL1002+	TRL1383+	TRL1384+	TRL1385+	TRL425+	TRL426+	TRL655+	///
			TRL656+	TRL657+	TRL658+	TRL639+	TRL1011)/100
						
*total household expenditure variable

gen v_tothhexp= v_fuel+v_food+v_adultgoods+v_clothing+v_housing+v_hhnondurable+v_hhdurable+v_misc+v_transport+v_other						

*label expenditure variables

label var v_food "expenditure on food"
label var v_adultgoods "expenditure on drink and tobacco"
label var subv_drinks "expenditure on drink"
label var v_clothing "expenditure on clothing and footwear"
label var subv_adultclothing "expenditure on adult clothing and footwear"
label var v_housing "expenditure on housing"
label var v_hhnondurable "expenditure on household non durable goods"
label var v_hhdurable "expenditure on household durable goods"
label var v_misc "expenditure on miscellaneous"
label var v_transport "expenditure on transport"
label var v_betting "expenditure on betting and gambling"
label var v_other "expenditure on services and other"
label var v_tothhexp "total household expenditure"


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
rename v_betting betting
rename v_other other
rename v_fuel fuel

* equivalised consumption
gen vehicles = (TRL326 + TRL327 + TRL328 + TRL330)/100

/*
foreach var in totexpend nondurable durable totfood totdrink housing adultgoods clothing misc transport fuel vehicles {
 replace `var' = `var'*1.27 // conversion to euro
}
*/ // no conversion as per barra's note


gen consAHC = totexpend - housingcosts - vehicles
gen equivconsAHC = consAHC/equivadults


************************** additional characteristics **************************

gen gender = 0
replace gender = 1 if HDR25 == 1

gen urban = 0 
replace urban = 1 if HDR11 == 1 | HDR11 == 2

gen married = 0
replace married = 1 if HDR123 == 1 | HDR123 == 2 | HDR123 == 3

gen famcomp = HDR12

gen numworking = HDR22

gen workstatus = 0
replace workstatus = 1 if inlist(HDR23, 1, 2, 3, 4, 5, 6, 15, 16) // working
replace workstatus = 2 if inlist(HDR23, 7, 8, 9) // unemployed
replace workstatus = 3 if HDR23 == 11 // retired
replace workstatus = 4 if inlist(HDR23, 10, 12, 13, 14) // other inactive

gen acctype = 0
replace acctype = 1 if inlist(HDR57, 2, 3, 4) // apartment
replace acctype = 2 if inlist(HDR57, 5, 6) // house
replace acctype = 3 if inlist(HDR57, 1, 7) // other

gen rooms = HDR55

gen cars = HDR70

gen seconddwelling = HDR96 // 1 = no, 2 = owned, 3 = rented

gen nummedcard = HDR27

gen stpghi = HDR13 // state transfer payments to gross household income

gen currentac = 0
replace currentac = 1 if HDR69 == 1

gen econcat = HDR130 // 1. Manual workers in Industry & Services 2. Non-manual workers3. Self-employed in Industry & Services 4. Farmers 5. Agricultrual workers 6. Fishermen, Foresters 7. Non-economically active 

gen yrsresident = HDR258

gen hoursworked = HDR350A

keep totexpend nondurable durable totfood totdrink housing housingcosts adultgoods clothing misc transport betting adultclothing fuel consAHC equivconsAHC vehicles ///
hbsyear year month quarter hhid hhsize hhnumu14 hhnum14to17 grossfac hhedu hhtenure hhtenure3way hohage hohcohort ///
gender urban married famcomp numworking workstatus acctype rooms cars seconddwelling nummedcard stpghi ///
currentac econcat yrsresident hoursworked HHdispinc equivHHdispinc AHCdispinc equivAHCdispinc HHgrossinc equivHHgrossinc hhnumu5 hhnum5to13 hhnumu14