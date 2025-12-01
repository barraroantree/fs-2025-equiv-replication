**********************************************************************************************************
* 2004-2005
**********************************************************************************************************

global hbs2004 "${rawdata}//0022-04_HBS_2004/0022-04_HBS_2004_Data/0022-04_HBS_2004.dta"
use "${hbs2004}", clear

*************************** household characteristics **************************


gen hhid=hld_ref


gen hhsize = hdr3
gen hhnumu5 = hdr33 + hdr39
gen hhnum5to13 = hdr34 + hdr40
gen hhnumu14 = hdr33 + hdr34 + hdr39 + hdr40
gen hhnum14to17 = hdr124 + hdr127

gen grossfac= (we/100000)*(factra/100000)*(factrb/100000)
label var grossfac "grossing factor"

gen hbsyear = 2004

gen year 	= 2004
replace year= 2005 if hdr5==5

gen month = hdr14

gen quarter = .
replace quarter = 1 if inlist(hdr6,2)
replace quarter = 2 if inlist(hdr6,3)
replace quarter = 3 if inlist(hdr6,1,4)
replace quarter = 4 if inlist(hdr6,5)


gen hhedu = .
replace hhedu = 1 if inlist(hdr342,0,1)
replace hhedu = 2 if inlist(hdr342,2)
replace hhedu = 3 if inlist(hdr342,3)
replace hhedu = 4 if inrange(hdr342,4,6)

clonevar hhtenure = hdr16
recode hhtenure (1=1) (2=2) (5/6 = 3) (4 = 4) (3 7 = 5), gen(hhtenure3way)
label define tenure 1 "owned outright" 2 "owned w/mortgage" 3 "private rented" 4 "LA rented" 5 "other (rent free, tenant purchased, etc)" , replace
label values hhtenure3way tenure

clonevar hohage = hdr45

gen hohcohort = .
replace hohcohort = 1 if inlist(hohage,7,8)			// ~ pre-WWI
replace hohcohort = 2 if inlist(hohage,5,6)			// ~ boomer 
replace hohcohort = 3 if inlist(hohage,1,2,3,4)		// ~ generation something 


****************************** housing costs ***********************************

// housing costs, for construction of AHC income definition 
* again following UK HBAI methodology (see 1999 code above) 
	* t234 listed in documentation as being endowment policy. Does this mean excludes others? CHECK
	* should I be adding on mortgage interest relief?
	* is rent here gross or net of rent supplement/allowance 
	
/*
gen housingcosts 		= t229 + t230 + t231 + t232 + t586 + t587				// rent & charges
replace housingcosts 	= housingcosts + t234 									// mortgage interest 
replace housingcosts 	= housingcosts + t238 									// dwellings insurance  
label var housingcosts "housing costs pw (EUR)"
*/

gen housingcosts = t229 + t230 + t232 + t234 + t238
// have removed the 580's variables, see housingcosts.do



******************************** income variables ******************************



//Prepare income variables
gen equivadults = hdr447/10
label var equivadults "household equivalisation factor (CSO)"

gen HHgrossinc = t494
label var HHgrossinc "gross income (EUR)"

gen equivHHgrossinc=HHgrossinc/equivadults
label var equivHHgrossinc "CSO equivalised gross income"

gen HHdispinc = t498 
label var HHdispinc "disposable income (EUR)"

gen equivHHdispinc=HHdispinc/equivadults
label var equivHHdispinc "CSO equivalised disposable income"


gen AHCdispinc = HHdispinc - housingcosts
label var AHCdispinc "AHC disposable income (EUR)"

gen equivAHCdispinc=AHCdispinc/equivadults
label var equivAHCdispinc "CSO equivalised AHC disposable income"



***************************** consumption variables ****************************

// expenditure categories 
* clean fuel and energy variables 
gen v_diesel=t337+t339
gen v_petrol=t336
gen v_lpgcar=t338

label var v_diesel "expenditure on diesel"
label var v_petrol "expenditure on petrol"
label var v_lpgcar "expenditure on lpg car"

gen v_fuel=t215+t216+t1417+t217+t218+t219+t220+t221+t222+t1894+t1895+ ///
			t223+t224+t225+t227
label var v_fuel "expenditure on fuel and light"



* Aggregate expenditure categories 
gen v_food= t001+	t002+	t003+	t1483+	t1808+	t1878+	t004+	t005+	t006+	t1879+	t1481+	///
			t007+	t008+	t1566+	t1484+	t009+	t1567+	t1485+	t1558+	t010+	t011+	t012+	t013+	t014+ ///
			t1487+	t015+	t016+	t017+	t1486+	t018+	t1488+	t1489+	t019+	t1490+	t646+	t1491+	t020+ ///
			t021+	t022+	t1492+	t023+	t1493+	t024+	t1494+	t1495+	t1496+	t1498+	t1499+	t038+	t025+ ///
			t1497+	t026+	t027+	t1502+	t1501+	t1503+	t1504+	t1505+	t1500+	t028+	t1506+	t1507+	t1508+	///
			t1509+	t1510+	t029+	t030+	t1511+	t031+	t032+	t033+	t034+	t035+	t036+	t1513+	t1514+	///
			t1515+	t1516+	t1517+	t1518+	t1519+	t1521+	t037+	t039+	t1512+	t1520+	t040+	t041+	t042+	///
			t043+	t044+	t045+	t1522+	t1523+	t1525+	t046+	t047+	t1526+	t1524+	t1527+	t1528+	t048+	///
			t049+	t050+	t051+	t052+	t053+	t1005+	t054+	t1578+	t1919+	t055+	t056+	t057+	t058+	///
			t059+	t060+	t061+	t062+	t063+	t064+	t065+	t1556+	t066+	t1003+	t1577+	t1004+	t1589+	///
			t1848+	t1850+	t1852+	t1854+	t1855+	t1857+	t1858+	t1859+	t1860+	t1875+	t1876+	t1903+	t1904+	///
			t1877+	t1992+	t1535+	t1856+	t067+	t068+	t069+	t070+	t071+	t072+	t1822+	t073+	t074+	///
			t075+	t1762+	t1828+	t1829+	t1905+	t076+	t077+	t078+	t079+	t080+	t081+	t082+	t083+	///
			t084+	t085+	t1015+	t1542+	t1543+	t1861+	t1862+	t1864+	t1866+	t1868+	t1870+	t1872+	t1874+	///
			t1902+	t086+	t087+	t088+	t089+	t090+	t1544+	t1545+	t092+	t093+	t094+	t095+	t096+	///
			t659+	t097+	t098+	t099+	t100+	t1548+	t101+	t1910+	t102+	t1550+	t103+	t1551+	t104+	///
			t105+	t106+	t107+	t108+	t1552+	t1553+	t1554+	t1555+	t109+	t110+	t111+	t112+	t113+	///
			t114+	t115+	t1579+	t116+	t1559+	t1898+	t1560+	t1561+	t1562+	t1563+	t1984+	t117+	t1843+	///
			t1564+	t1565+	t1834+	t118+	t1568+	t1569+	t119+	t120+	t121+	t122+	t123+	t1572+	t1573+	///
			t124+	t1576+	t125+	t126+	t1574+	t127+	t1001+	t1707+	t1820+	t1126+	t1127+	t1128+	t1557+	///
			t128+	t1763+	t1764+	t1881+	t129+	t130+	t131+	t132+	t1837+	t133+	t134+	t1575+	t1836+	///
			t1838+	t1006+	t1570+	t1571+	t1882 

					
gen v_adultgoods= t135+	t136+	t137+	t138+	t139+	t1580+	t1581+	t1582+	t1765+	t1766+	t1767+	t1768+	///
				t1583+	t1584+	t1585+	t1586+	t1769+	t1770+	t1771+	t1587+	t1772+	t140+	t141+	t142+	///
				t143+	t144
				
gen subv_drinks= t135+	t136+	t137+	t138+	t139+	t1580+	t1581+	t1582+	t1765+	t1766+	t1767+	t1768+	///
				t1583+	t1584+	t1585+	t1586+	t1769+	t1770+	t1771+	t1587+	t1772+	t140+	t141 // note that this replicates drinks from adult goods above so not used to aggregate total consumption
				
				
gen v_clothing= t145+	t146+	t1621+	t1622+	t1623+	t1624+	t1625+	t147+	t148+	t149+	t150+	t151+	///
				t152+	t153+	t154+	t155+	t156+	t157+	t158+	t159+	t160+	t161+	t162+	t163+	///
				t164+	t1588+	t1590+	t1591+	t1592+	t165+	t166+	t167+	t168+	t169+	t170+	t171+	///
				t1593+	t1594+	t172+	t1598+	t173+	t1595+	t1596+	t174+	t1597+	t1614+	t1615+	t1616+	///
				t1617+	t1618+	t1619+	t1620+	t175+	t176+	t177+	t178+	t179+	t180+	t181+	t182+	///
				t183+	t184+	t185+	t186+	t187+	t188+	t189+	t190+	t191+	t192+	t193+	t194+	///
				t195+	t196+	t197+	t198+	t199+	t1599+	t1600+	t1601+	t1602+	t1603+	t1604+	t1605+	///
				t1606+	t1607+	t1609+	t1613+	t200+	t201+	t202+	t203+	t204+	t205+	t1612+	t1611+	///
				t1608+	t1610+	t206+	t207+	t208+	t209+	t210+	t211+	t212+	t213+	t214
				
gen subv_adultclothing = t145+	t146+	t1621+	t1622+	t1623+	t1624+	t1625+	t147+	t148+	t149+	t150+	t151+	///
				t152+	t153+	t154+	t155+	t156+	t157+	t158+	t159+	t160+	t161+	t162+	t163+ t1614+ ///
				t1615+	t1616+ t1617+	t1618+	t1619+	t1620+	t175+	t176+	t177+	t178+	t179+	t180+	t181+ ///
				t182+ t183+	t184+	t185+	t186+	t187+	t188+	t189+	t190+	t191+	t192+	t193+	t194+	///
				t195+	t196+	t197+	t198
				
				
gen v_housing= t229+	t230+	t231+	t232+	t233+	t234+ t235+	t236+	t237+	t238+	t1965+	t1846+	///
			t1798+	t1909+	t1911+	t239+	t1201+	t1202+	t1203+	t1204+	t1205+	t1206+	t1207+	t1209+	t1210+	///
			t1211+	t1212+	t1213+	t1214+	t1215+	t1216+	t1217+	t1218+	t1219+	t1220+	t1221+	t1222+	t1223+	///
			t1224+	t1225+	t1226+	t1227+	t1228+	t1229+	t1230+	t1231+	t1232+	t1233+	t1234+	t1235+	t1236+	///
			t1825+	t1824+	t240+	t1017+	t1413+	t1463+	t241+	t242+	t243+	t1656+	t244+	t1414+	t1415+	///
			t1433+	t665+	t613+	t614+	t615+	t616+	t1008+	t1009+	t1931+	t1932+	t1933+	t1934+	t1659+	///
			t1989+	t1990+	t1660+	t245+	t246+	t247+	t1257+	t1830+	t1258+	t1259+	t645+	t1012+	t1921+	///
			t1922+	t1923+	t1924+	t1925+	t1926+	t1400+	t1401+	t1402+	t1403+	t1464
			
*includes candles			
gen v_hhnondurable= t248+	t249+	t250+	t1626+	t1627+	t1827+	t1628+	t251+	t252+	t1629+	t253+	t1892+	///
					t1630+	t254+	t255+	t256+	t1634+	t1637+	t1636+	t1635+	t257+	t1811+	t1812+	t1638+	///
					t1823+	t1639+	t1640+	t1641+	t1642+	t1643+	t1644+	t1645+	t1821+	t1646+	t1647+	t1648+	///
					t1649+	t1650+	t1651+	t1810+	t1652+	t1654+	t1657+	t1658+	t1661+	t258+	t259+	t260+	///
					t1368+	t1369+	t1370+	t662+	t1371+	t1372+	t1373+	t1374+	t1969+	t918+	t228
			
				
gen v_hhdurable= t261+	t262+	t1460+	t263+	t1799+	t1805+	t1237+	t1775+	t1238+	t1239+	t1241+	t1773+	t1794+	///
				t1242+	t1243+	t1244+	t1245+	t1246+	t1247+	t1248+	t1249+	t1250+	t1251+	t1252+	t1253+	t1254+	///
				t1778+	t1255+	t1256+	t264+	t265+	t266+	t1813+	t1776+	t1260+	t1899+	t1261+	t1262+	t1263+	///
				t1264+	t1265+	t1266+	t1267+	t1268+	t1269+	t1270+	t1271+	t1272+	t1273+	t1274+	t1275+	t1276+	///
				t1277+	t1278+	t1279+	t1280+	t1281+	t1282+	t1283+	t1284+	t1285+	t1286+	t1287+	t1288+	t1289+	///
				t1290+	t1291+	t1292+	t1293+	t1294+	t1295+	t273+	t274+	t275+	t276+	t277+	t278+	t279+	///
				t661+	t1997+	t1655+	t1653+	t1818+	t1443+	t1977+	t1446+	t281+	t1662+	t1705+	t1803+	t1759+	///
				t1804+	t282+	t267+	t1016+	t268+	t270+	t271+	t272+	t1296+	t1297+	t1298+	t1299+	t1301+	///
				t1302+	t1304+	t1305+	t654+	t1010+	t1014+	t1451+	t283+	t284+	t1702+	t1986+	t1831+	///
				t1832+	t285+	t269+	t1449+	t1387+	t1388+	t1389+	t1390+	t1391+	t1392+	t1393+	t1408+	t1394+	///
				t1395+	t1978+	t1396+	t1397+	t1398+	t1007+	t322+	t1411+	t1546+	t1547+	t1718+	t1840+	t1942+	///
				t286+	t1663+	t1664+	t1665+	t1896+	t1809+	t1668+	t1788+	t1669+	t1670+	t1671+	t1819+	t287+	///
				t1756+	t1757+	t1758+	t1307+	t1308+	t1309+	t1310+	t1774+	t1311+	t1777+	t1781+	t1782+	t1783+	///
				t1784+	t1785+	t1786+	t1787+	t1791+	t1790+	t1817+	t1312+	t1313+	t1549+	t1760+	t1761+	t1314+	///
				t1315+	t1129+	t288+	t289+	t1891+	t1679+	t1680+	t1681+	t1631+	t1632+	t1633+	t290+	t291+	///
				t292+	t1672+	t1673+	t1814+	t1674+	t1675+	t293+	t294+	t295+	t1676+	t296+	t1677+	t1816+	///
				t297+	t1678+	t298+	t299

				
gen v_misc= t300+	t1683+	t1682+	t1684+	t301+	t302+	t1685+	t1686+	t1687+	t303+	t304+	t305+	t1991+	t1908+	///
			t1688+	t1689+	t1690+	t1691+	t1692+	t306+	t307+	t1693+	t308+	t309+	t310+	t311+	t1694+	t1695+	///
			t1815+	t1696+	t1697+	t1698+	t1699+	t1700+	t1701+	t312+	t313+	t314+	t315+	t316+	t317+	t1792+	///
			t1841+	t319+	t320+	t321+	t323+	t324+	t1802+	t1844+	t1845+	t325
				

gen v_transport= t326+	t327+	t328+	t1706+	t329+	t1708+	t1826+	t330+	t331+	t332+	t333+	t334+	t335+	t336+	///
				t337+	t338+	t339+	t1711+	t1713+	t340+	t1712+	t1716+	t341+	t342+	t1020+	t1963+	t1316+	t1317+	///
				t1318+	t1319+	t343+	t344+	t345+	t346+	t347+	t348+	t1434+	t1435+	t1455+	t1835+	t1996+	t349+	///
				t350+	t351+	t352+	t1715+	t1714+	t353
				
gen v_betting = t660 + t422						
						
gen v_other= t354+	t355+	t356+	t357+	t358+	t359+	t1721+	t1886+	t1722+	t1723+	t1724+	t1725+	t1726+	t1727+	t1728+	///
			t1729+	t1730+	t1731+	t1732+	t1733+	t1734+	t1735+	t1736+	t1737+	t620+	t360+	t361+	t362+	t363+	t364+	///
			t365+	t1738+	t621+	t622+	t623+	t624+	t366+	t367+	t368+	t369+	t370+	t371+	t372+	t373+	t374+	///
			t1458+	t1979+	t1884+	t919+	t1897+	t1839+	t376+	t1322+	t1323+	t1324+	t1325+	t1326+	t1327+	t1328+	///
			t1329+	t1330+	t1331+	t1332+	t1333+	t1334+	t1335+	t1336+	t1337+	t1338+	t1339+	t1340+	t1341+	t1342+	t1793+	///
			t1343+	t1344+	t1795+	t1796+	t1907+	t377+	t1114+	t1115+	t1116+	t1117+	t1118+	t1119+	t1120+	t1906+	t1121+	///
			t1122+	t1123+	t1124+	t1125+	t378+	t1739+	t1740+	t1741+	t1742+	t1743+	t1744+	t379+	t1962+	t1995+	t380+	///
			t1994+	t381+	t382+	t383+	t384+	t1421+	t1456+	t1457+	t385+	t1745+	t386+	t1746+	t1747+	t1748+	t1749+	///
			t387+	t1750+	t1752+	t388+	t389+	t1751+	t390+	t391+	t392+	t393+	t1399+	t1101+	t1102+	t1103+	t1105+	///
			t1106+	t1013+	t1133+	t617+	t618+	t619+	t1885+	t318+	t1345+	t1346+	t1347+	t1797+	t1348+	t1349+	t1350+	///
			t1351+	t1352+	t1353+	t1354+	t1355+	t1356+	t1357+	t1358+	t1359+	t1360+	t1361+	t1362+	t1364+	t1365+	t1366+	///
			t1367+	t394+	t1717+	t1789+	t1985+	t1987+	t395+	t396+	t397+	t663+	t1887+	t398+	t1459+	t1107+	t1108+	///
			t1109+	t1110+	t1111+	t1457+	t1893+	t1112+	t1113+	t399+	t400+	t401+	t402+	t403+	t404+	t405+	t406+	///
			t407+	t408+	t409+	t1405+	t1406+	t1833+	t410+	t411+	t412+	t413+	t1465+	t414+	t415+	t416+	t417+	///
			t1883+	t1927+	t1928+	t1929+	t1930+	t1971+	t418+	t419+	t420+	t421+	t660+	t422+	t1375+	t1376+	t1377+	///
			t1378+	t1379+	t1380+	t1381+	t1382+	t423+	t1002+	t1383+	t1384+	t1385+	t425+	t426+	t655+	t656+	///
			t657+	t658+	t1754+	t1755+	t1980+	t1982+	t639+	t1011+	t1753
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
gen vehicles = t326 + t327 + t328 + t330
gen consAHC = totexpend - housingcosts - vehicles
gen equivconsAHC = consAHC/equivadults


*********************** additional characteristics *****************************

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
currentac econcat yrsresident hoursworked HHdispinc equivHHdispinc AHCdispinc equivAHCdispinc HHgrossinc equivHHgrossinc hhnum5to13 hhnumu5