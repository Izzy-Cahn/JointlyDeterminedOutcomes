*fig 1
global data "/Users/yisroelcahn/Documents/Min Wage Puzzle 3/Data/Cleaned Data/"
global tables "/Users/yisroelcahn/Documents/Min Wage Puzzle 3/Tables/"
global figures "/Users/yisroelcahn/Documents/Min Wage Puzzle 3/Figures/"
set more off


*make excel variables
putexcel (A1) = ("AverageMW") using "${tables}fig1.xlsx", modify
putexcel (B1) = ("FederalMW") using "${tables}fig1.xlsx", modify
putexcel (C1) = ("TotalWorkers") using "${tables}fig1.xlsx", modify
putexcel (D1) = ("TotalWorkersAtMW") using "${tables}fig1.xlsx", modify
putexcel (E1) = ("TotalMaleWorkers") using "${tables}fig1.xlsx", modify
putexcel (F1) = ("TotalMaleWorkersAtMW") using "${tables}fig1.xlsx", modify
putexcel (G1) = ("TotalFemaleWorkers") using "${tables}fig1.xlsx", modify
putexcel (H1) = ("TotalFemaleWorkersAtMW") using "${tables}fig1.xlsx", modify
putexcel (I1) = ("year") using "${tables}fig1.xlsx", modify


putexcel (J1) = ("MWpaidhr") using "${tables}fig1.xlsx", modify
putexcel (K1) = ("MWpaidhrMen") using "${tables}fig1.xlsx", modify
putexcel (L1) = ("MWpaidhrWomen") using "${tables}fig1.xlsx", modify	

putexcel (M1) = ("MWpart") using "${tables}fig1.xlsx", modify
putexcel (N1) = ("MWpartMen") using "${tables}fig1.xlsx", modify
putexcel (O1) = ("MWpartWomen") using "${tables}fig1.xlsx", modify


forvalues i=1979/2019{

use "${data}morg_cleaned_`i'.dta", clear

rename hr_wage wage

rename intmonth month

drop if uhours==.

******match cps to census*******
if year >= 2014{

*2014's year variable is messed up
if year==2014{
drop state
}

gen state=0
replace state=11 if stfips==23
replace state=12 if stfips==33
replace state=13 if stfips==50
replace state=14 if stfips==25
replace state=15 if stfips==44
replace state=16 if stfips==9
replace state=21 if stfips==36
replace state=22 if stfips==34
replace state=23 if stfips==42
replace state=31 if stfips==39
replace state=32 if stfips==18
replace state=33 if stfips==17
replace state=34 if stfips==26
replace state=35 if stfips==55
replace state=41 if stfips==27
replace state=42 if stfips==19
replace state=43 if stfips==29
replace state=44 if stfips==38
replace state=45 if stfips==46
replace state=46 if stfips==31
replace state=47 if stfips==20
replace state=51 if stfips==10
replace state=52 if stfips==24
replace state=53 if stfips==11
replace state=54 if stfips==51
replace state=55 if stfips==54
replace state=56 if stfips==37
replace state=57 if stfips==45
replace state=58 if stfips==13
replace state=59 if stfips==12
replace state=61 if stfips==21
replace state=62 if stfips==47
replace state=63 if stfips==1
replace state=64 if stfips==28
replace state=71 if stfips==5
replace state=72 if stfips==22
replace state=73 if stfips==40
replace state=74 if stfips==48
replace state=81 if stfips==30
replace state=82 if stfips==16
replace state=83 if stfips==56
replace state=84 if stfips==8
replace state=85 if stfips==35
replace state=86 if stfips==4
replace state=87 if stfips==49
replace state=88 if stfips==32
replace state=91 if stfips==53
replace state=92 if stfips==41
replace state=93 if stfips==6
replace state=94 if stfips==2
replace state=95 if stfips==15
}
*******


*merge minw data 
merge m:1 year month state using "/Users/yisroelcahn/Documents/Min Wage Puzzle 3/Data/mw_state_monthly.dta"

keep if year==`i'

*rename a few variables 
rename MonthlyFederalAverage fedmin
rename MonthlyStateAverage minw

*average minimum wage across states variable
egen avgstateminw = mean(minw), by(year state month)

*minwage variable
gen minwage=0
replace minwage=1 if wage <= minw*gdp


*real min wage
gen rminw=minw*gdp
gen rfedmin=fedmin*gdp
gen avgmin=avgstateminw*gdp 

display `i'

*k starts at 2 and increments by 1 each year
local k=`i'-1977

*year
putexcel (I`k') = (`i') using "${tables}fig1.xlsx", modify

sum avgmin
*put into excel file
putexcel (A`k') = (r(mean)) using "${tables}fig1.xlsx", modify

sum rfedmin
*put into excel file
putexcel (B`k') = (r(mean)) using "${tables}fig1.xlsx", modify


tab minwage [aw=wgtrd], matcell(freq) matrow(names)
*put into excel file
putexcel (C`k') = matrix(freq[1,1]) using "${tables}fig1.xlsx", modify
putexcel (D`k') = matrix(freq[2,1]) using "${tables}fig1.xlsx", modify

tab minwage [aw=wgtrd] if female==0, matcell(freq) matrow(names)
*put into excel file
putexcel (E`k') = matrix(freq[1,1]) using "${tables}fig1.xlsx", modify
putexcel (F`k') = matrix(freq[2,1]) using "${tables}fig1.xlsx", modify

tab minwage [aw=wgtrd] if female==1, matcell(freq) matrow(names)
*put into excel file
putexcel (G`k') = matrix(freq[1,1]) using "${tables}fig1.xlsx", modify
putexcel (H`k') = matrix(freq[2,1]) using "${tables}fig1.xlsx", modify


*paid by the hour
tab minwage [aw=wgtrd] if hr_alloc==1, matcell(freq) matrow(names)
putexcel (J`k') = matrix(freq[2,1]) using "${tables}fig1.xlsx", modify
tab minwage [aw=wgtrd] if hr_alloc==1 & female==0, matcell(freq) matrow(names)
putexcel (K`k') = matrix(freq[2,1]) using "${tables}fig1.xlsx", modify
tab minwage [aw=wgtrd] if hr_alloc==1 & female==1, matcell(freq) matrow(names)
putexcel (L`k') = matrix(freq[2,1]) using "${tables}fig1.xlsx", modify


*part time
tab minwage [aw=wgtrd] if ft==0, matcell(freq) matrow(names)
putexcel (M`k') = matrix(freq[2,1]) using "${tables}fig1.xlsx", modify
tab minwage [aw=wgtrd] if ft==0 & female==0, matcell(freq) matrow(names)
putexcel (N`k') = matrix(freq[2,1]) using "${tables}fig1.xlsx", modify
tab minwage [aw=wgtrd] if ft==0 & female==1, matcell(freq) matrow(names)
putexcel (O`k') = matrix(freq[2,1]) using "${tables}fig1.xlsx", modify


}

*Minwage Figure
import excel "${tables}fig1.xlsx", sheet("Sheet1") firstrow clear
label variable AverageMW   "Average State Minimum Wage" 
label variable FederalMW   "Federal Minimum Wage" 
line  AverageMW FederalMW year
graph export "${figures}graph1.pdf", replace


*Percent below MW Figure
gen PBMW = 0
gen PBMWMale = 0
gen PBMWFemale = 0

replace PBMW = TotalWorkersAtMW/TotalWorkers
replace PBMWMale = TotalMaleWorkersAtMW/TotalMaleWorkers
replace PBMWFemale = TotalFemaleWorkersAtMW/TotalFemaleWorkers

label variable PBMW   "% below MW" 
label variable PBMWMale   "% Men below MW" 
label variable PBMWFemale   "% Women below MW" 
line PBMW PBMWMale PBMWFemale year
graph export "${figures}graph2.pdf", replace


*Percent MW paid by the hour 
gen PPPH = 0
gen PPPHMale = 0
gen PPPHFemale = 0

replace PPPH = MWpaidhr/TotalWorkersAtMW
replace PPPHMale = MWpaidhrMen/TotalMaleWorkersAtMW
replace PPPHFemale = MWpaidhrWomen/TotalFemaleWorkersAtMW

label variable PPPH   "% MW paid by hour" 
label variable PPPHMale   "% MW paid by hour (men)" 
label variable PPPHFemale   "% MW paid by hour (women)" 
line PPPH PPPHMale PPPHFemale year
graph export "${figures}graph3.pdf", replace

*Pervent MW part time
gen Part = 0
gen PartMale = 0
gen PartFemale = 0

replace Part = MWpart/TotalWorkersAtMW
replace PartMale = MWpartMen/TotalMaleWorkersAtMW
replace PartFemale = MWpartWomen/TotalFemaleWorkersAtMW

label variable Part   "% MW part-time" 
label variable PartMale   "% MW part-time (men)" 
label variable PartFemale   "% MW part-time (women)" 
line Part PartMale PartFemale year
graph export "${figures}graph4.pdf", replace







*Minimum wage changes in each state figures
import excel "/Users/yisroelcahn/Documents/Min Wage Puzzle 3/Data/mw_state_changes.xlsx", sheet("Sheet1") firstrow clear

tabulate State, generate(state)

drop if year<1979 | year>2019

gen long obs = _n

forvalues i=1/51{
	su obs if state`i' == 1, meanonly
	loc t= State[r(min)]
	twoway (spike state`i' year) (connected  mw year if  state`i'==1), xlabel(1979(5)2019) xmtick(##5) title(`t') legend(off)
	graph export "${figures}StateMWChange`i'.pdf", replace
}




