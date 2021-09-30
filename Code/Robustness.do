*Robustness
global data "/Users/yisroelcahn/Documents/Min Wage Puzzle 3/Data/Cleaned Data/"
global tables "/Users/yisroelcahn/Documents/Min Wage Puzzle 3/Tables/"
global figures "/Users/yisroelcahn/Documents/Min Wage Puzzle 3/Figures/"
set more off


*Prepare data
forvalues i=2003/2019{
*Fixed Effects 
use "${data}morg_cleaned_`i'.dta", clear

rename hr_wage wage

rename wgt eweight

xtile quart = wage [fw=wgtrd], nq(5)

gen smsa=0
replace smsa=1 if smsastat==1
gen partt=0
replace partt=1 if ft==0
gen nonwhite=0
replace nonwhite=1 if black==1 | other==1

rename educomp educ
rename exp exper
gen union=0
replace union=1 if unionmme==1


***********************Min Wage Maker*******************************
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

*rename month
rename intmonth month

*merge minw data 
merge m:1 year month state using "/Users/yisroelcahn/Documents/Min Wage Puzzle 3/Data/mw_state_monthly.dta"

**change for appropriate year
keep if year==`i'

*rename a few variables 
rename MonthlyFederalAverage fedmin
rename MonthlyStateAverage minw

*real minw
gen rminw=minw*gdp

*minwage variable
gen minwage=0
replace minwage=1 if wage<=rminw
***************************************************************




if year>=1979 & year<=1982{
rename docc70 nocc
rename dind nind
tab nocc, gene(oc)
tab nind, gene(ind)

keep minwage rminw eweight wage smsa partt nonwhite educ exper female union state oc1-oc45 ind1-ind46 year uhours ch05 quart married
}

if year>=1983 & year<=2002{
rename docc80 nocc
rename dind nind
tab nocc, gene(oc)
tab nind, gene(ind)

keep minwage rminw eweight wage smsa partt nonwhite educ exper female union state oc1-oc45 ind1-ind47 year uhours ch05 quart married
}

if year>=2003 & year<=2019{
rename docc00 nocc
rename dind02 nind
tab nocc, gene(oc)
tab nind, gene(ind)

keep minwage rminw eweight wage smsa partt nonwhite educ exper female union state oc1-oc22 ind1-ind51 year uhours ch05 quart married
}

if `i'==2003{
save "${data}FEdata.dta", replace
}
if `i'!=2003{
append using "${data}FEdata.dta"
save "${data}FEdata.dta", replace
}
}

use "${data}FEdata.dta", clear

***Create Variables
gen byte grade1to4=(educ<=4)
gen byte grade5to6=(educ<=6)
gen byte grade7to8=(educ<=8)
gen byte grade9=(educ<=9)
gen byte grade10=(educ<=10)
gen byte grade11=(educ<=11)
gen byte highschool=(educ<=12)
gen byte somecollege=(educ<=15)
gen byte college=(educ<=16)
gen byte egrade1to4=exper*grade1to4
gen byte egrade5to6=exper*grade5to6
gen byte egrade7to8=exper*grade7to8
gen byte egrade9=exper*grade9
gen byte egrade10=exper*grade10
gen byte egrade11=exper*grade11
gen byte ehighschool=exper*highschool
gen byte esomecollege=exper*somecollege
gen byte ecollege=exper*college
gen exper2=exper^2
gen exper3=exper^3
gen exper4=exper^4
gen logw=log(wage)


save "${data}FEdata.dta", replace


**************************
*Fixed Effects Regression* 
**************************

use "${data}FEdata.dta", clear

egen state_year = group(state year)

global reg1 = "married union ch05 smsa partt nonwhite grade1to4 grade5to6 grade7to8 grade9 grade10 grade11 highschool somecollege college egrade1to4 egrade5to6 egrade7to8 egrade9 egrade10 egrade11 ehighschool esomecollege ecollege exper exper2 exper3 exper4 oc2-oc22 ind2-ind51"


**men

*state and year fixed effects regression of real minimum wage on hours worked
xtreg uhours rminw $reg1 if female==0, fe i(state_year)

mat W = r(table)
putexcel (B4) = (W[1,1]) using "${tables}FE.xlsx", modify
putexcel (C4) = (W[2,1]) using "${tables}FE.xlsx", modify
putexcel (D4) = (W[4,1]) using "${tables}FE.xlsx", modify

forvalues i=1/5{
local k=`i'+4

xtreg uhours rminw $reg1 if quart==`i' & female==0, fe i(state_year)

mat W = r(table)
putexcel (B`k') = (W[1,1]) using "${tables}FE.xlsx", modify
putexcel (C`k') = (W[2,1]) using "${tables}FE.xlsx", modify
putexcel (D`k') = (W[4,1]) using "${tables}FE.xlsx", modify
}

**women

*state and year fixed effects regression of real minimum wage on hours worked
xtreg uhours rminw $reg1 if female==1, fe i(state_year)

mat W = r(table)
putexcel (E4) = (W[1,1]) using "${tables}FE.xlsx", modify
putexcel (F4) = (W[2,1]) using "${tables}FE.xlsx", modify
putexcel (G4) = (W[4,1]) using "${tables}FE.xlsx", modify

forvalues i=1/5{
local k=`i'+4

xtreg uhours rminw $reg1 if quart==`i' & female==1, fe i(state_year)

mat W = r(table)
putexcel (E`k') = (W[1,1]) using "${tables}FE.xlsx", modify
putexcel (F`k') = (W[2,1]) using "${tables}FE.xlsx", modify
putexcel (G`k') = (W[4,1]) using "${tables}FE.xlsx", modify
}

***wages
global reg2 = "union smsa partt nonwhite grade1to4 grade5to6 grade7to8 grade9 grade10 grade11 highschool somecollege college egrade1to4 egrade5to6 egrade7to8 egrade9 egrade10 egrade11 ehighschool esomecollege ecollege exper exper2 exper3 exper4 oc2-oc22 ind2-ind51"

*men
xtreg logw rminw $reg2 if female==0, fe i(state_year)

mat W = r(table)
putexcel (H4) = (W[1,1]) using "${tables}FE.xlsx", modify
putexcel (I4) = (W[2,1]) using "${tables}FE.xlsx", modify
putexcel (J4) = (W[4,1]) using "${tables}FE.xlsx", modify

forvalues i=1/5{
local k=`i'+4

xtreg logw rminw $reg2 if quart==`i' & female==0, fe i(state_year)

mat W = r(table)
putexcel (H`k') = (W[1,1]) using "${tables}FE.xlsx", modify
putexcel (I`k') = (W[2,1]) using "${tables}FE.xlsx", modify
putexcel (J`k') = (W[4,1]) using "${tables}FE.xlsx", modify
}

*women
xtreg logw rminw $reg2 if female==1, fe i(state_year)

mat W = r(table)
putexcel (K4) = (W[1,1]) using "${tables}FE.xlsx", modify
putexcel (L4) = (W[2,1]) using "${tables}FE.xlsx", modify
putexcel (M4) = (W[4,1]) using "${tables}FE.xlsx", modify

forvalues i=1/5{
local k=`i'+4

xtreg logw rminw $reg2 if quart==`i' & female==1, fe i(state_year)

mat W = r(table)
putexcel (K`k') = (W[1,1]) using "${tables}FE.xlsx", modify
putexcel (L`k') = (W[2,1]) using "${tables}FE.xlsx", modify
putexcel (M`k') = (W[4,1]) using "${tables}FE.xlsx", modify
}





****quadratic min wage
gen minwsquared = rminw^2

**men
xtreg uhours rminw minwsquared $reg1 if female==0, fe i(state_year)

mat W = r(table)
putexcel (B4) = (W[1,1]) using "${tables}FEquad.xlsx", modify
putexcel (C4) = (W[2,1]) using "${tables}FEquad.xlsx", modify
putexcel (D4) = (W[4,1]) using "${tables}FEquad.xlsx", modify
putexcel (E4) = (W[1,2]) using "${tables}FEquad.xlsx", modify
putexcel (F4) = (W[2,2]) using "${tables}FEquad.xlsx", modify
putexcel (G4) = (W[4,2]) using "${tables}FEquad.xlsx", modify

forvalues i=1/5{
local k=`i'+4

xtreg uhours rminw minwsquared $reg1 if quart==`i' & female==0, fe i(state_year)

mat W = r(table)
putexcel (B`k') = (W[1,1]) using "${tables}FEquad.xlsx", modify
putexcel (C`k') = (W[2,1]) using "${tables}FEquad.xlsx", modify
putexcel (D`k') = (W[4,1]) using "${tables}FEquad.xlsx", modify
putexcel (E`k') = (W[1,2]) using "${tables}FEquad.xlsx", modify
putexcel (F`k') = (W[2,2]) using "${tables}FEquad.xlsx", modify
putexcel (G`k') = (W[4,2]) using "${tables}FEquad.xlsx", modify
}

**women
xtreg uhours rminw minwsquared $reg1 if female==1, fe i(state_year)

mat W = r(table)
putexcel (I4) = (W[1,1]) using "${tables}FEquad.xlsx", modify
putexcel (J4) = (W[2,1]) using "${tables}FEquad.xlsx", modify
putexcel (K4) = (W[4,1]) using "${tables}FEquad.xlsx", modify
putexcel (L4) = (W[1,2]) using "${tables}FEquad.xlsx", modify
putexcel (M4) = (W[2,2]) using "${tables}FEquad.xlsx", modify
putexcel (N4) = (W[4,2]) using "${tables}FEquad.xlsx", modify

forvalues i=1/5{
local k=`i'+4

xtreg uhours rminw minwsquared $reg1 if quart==`i' & female==1, fe i(state_year)

mat W = r(table)
putexcel (I`k') = (W[1,1]) using "${tables}FEquad.xlsx", modify
putexcel (J`k') = (W[2,1]) using "${tables}FEquad.xlsx", modify
putexcel (K`k') = (W[4,1]) using "${tables}FEquad.xlsx", modify
putexcel (L`k') = (W[1,2]) using "${tables}FEquad.xlsx", modify
putexcel (M`k') = (W[2,2]) using "${tables}FEquad.xlsx", modify
putexcel (N`k') = (W[4,2]) using "${tables}FEquad.xlsx", modify
}



******************************
*****Min Wage Workers*********
******************************

gen parttminw=rminw*partt

**wages
*men
xtreg logw rminw $reg2 if minwage==1 & female==0, fe i(state_year)

mat W = r(table)
putexcel (A17) = (W[1,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (B17) = (W[2,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (C17) = (W[4,1]) using "${tables}MinWageWorkers.xlsx", modify

*women
xtreg logw rminw $reg2 if minwage==1 & female==1, fe i(state_year)

mat W = r(table)
putexcel (D17) = (W[1,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (E17) = (W[2,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (F17) = (W[4,1]) using "${tables}MinWageWorkers.xlsx", modify

**hours
*men
xtreg uhours rminw $reg1 if minwage==1 & female==0, fe i(state_year)

mat W = r(table)
putexcel (A5) = (W[1,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (B5) = (W[2,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (C5) = (W[4,1]) using "${tables}MinWageWorkers.xlsx", modify

xtreg uhours rminw minwsquared $reg1 if minwage==0 & female==0, fe i(state_year)

mat W = r(table)
putexcel (A6) = (W[1,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (B6) = (W[2,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (C6) = (W[4,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (D6) = (W[1,2]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (E6) = (W[2,2]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (F6) = (W[4,2]) using "${tables}MinWageWorkers.xlsx", modify

*women
xtreg uhours rminw $reg1 if minwage==1 & female==1, fe i(state_year)

mat W = r(table)
putexcel (H5) = (W[1,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (I5) = (W[2,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (J5) = (W[4,1]) using "${tables}MinWageWorkers.xlsx", modify

xtreg uhours rminw minwsquared $reg1 if minwage==1 & female==1, fe i(state_year)

mat W = r(table)
putexcel (H6) = (W[1,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (I6) = (W[2,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (J6) = (W[4,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (K6) = (W[1,2]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (L6) = (W[2,2]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (M6) = (W[4,2]) using "${tables}MinWageWorkers.xlsx", modify


*full-time workers
global reg3 = "married union ch05 smsa nonwhite grade1to4 grade5to6 grade7to8 grade9 grade10 grade11 highschool somecollege college egrade1to4 egrade5to6 egrade7to8 egrade9 egrade10 egrade11 ehighschool esomecollege ecollege exper exper2 exper3 exper4 oc2-oc22 ind2-ind51"

*men
xtreg uhours rminw $reg3 if minwage==1 & female==0 & partt==1, fe i(state_year)

mat W = r(table)
putexcel (A27) = (W[1,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (B27) = (W[2,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (C27) = (W[4,1]) using "${tables}MinWageWorkers.xlsx", modify

xtreg uhours rminw minwsquared $reg3 if minwage==0 & female==0 & partt==1, fe i(state_year)

mat W = r(table)
putexcel (A28) = (W[1,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (B28) = (W[2,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (C28) = (W[4,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (D28) = (W[1,2]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (E28) = (W[2,2]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (F28) = (W[4,2]) using "${tables}MinWageWorkers.xlsx", modify

*women
xtreg uhours rminw $reg3 if minwage==1 & female==1 & partt==1, fe i(state_year)

mat W = r(table)
putexcel (H27) = (W[1,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (I27) = (W[2,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (J27) = (W[4,1]) using "${tables}MinWageWorkers.xlsx", modify

xtreg uhours rminw minwsquared $reg3 if minwage==1 & female==1 & partt==1, fe i(state_year)

mat W = r(table)
putexcel (H28) = (W[1,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (I28) = (W[2,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (J28) = (W[4,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (K28) = (W[1,2]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (L28) = (W[2,2]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (M28) = (W[4,2]) using "${tables}MinWageWorkers.xlsx", modify


*full-time workers
*men
xtreg uhours rminw $reg3 if minwage==1 & female==0 & partt==0, fe i(state_year)

mat W = r(table)
putexcel (A34) = (W[1,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (B34) = (W[2,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (C34) = (W[4,1]) using "${tables}MinWageWorkers.xlsx", modify

xtreg uhours rminw minwsquared $reg3 if minwage==0 & female==0 & partt==0, fe i(state_year)

mat W = r(table)
putexcel (A35) = (W[1,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (B35) = (W[2,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (C35) = (W[4,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (D35) = (W[1,2]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (E35) = (W[2,2]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (F35) = (W[4,2]) using "${tables}MinWageWorkers.xlsx", modify

*women
xtreg uhours rminw $reg3 if minwage==1 & female==1 & partt==0, fe i(state_year)

mat W = r(table)
putexcel (H34) = (W[1,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (I34) = (W[2,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (J34) = (W[4,1]) using "${tables}MinWageWorkers.xlsx", modify

xtreg uhours rminw minwsquared $reg3 if minwage==1 & female==1 & partt==0, fe i(state_year)

mat W = r(table)
putexcel (H35) = (W[1,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (I35) = (W[2,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (J35) = (W[4,1]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (K35) = (W[1,2]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (L35) = (W[2,2]) using "${tables}MinWageWorkers.xlsx", modify
putexcel (M35) = (W[4,2]) using "${tables}MinWageWorkers.xlsx", modify



***part-time status
*lpm, logit, and probit

*men
xtreg partt rminw $reg3 if minwage==1 & female==0, fe i(state_year)

mat W = r(table)
putexcel (A5) = (W[1,1]) using "${tables}partTime.xlsx", modify
putexcel (B5) = (W[2,1]) using "${tables}partTime.xlsx", modify
putexcel (C5) = (W[4,1]) using "${tables}partTime.xlsx", modify

logit partt rminw $reg3 if minwage==1 & female==0

mat W = r(table)
putexcel (D5) = (W[1,1]) using "${tables}partTime.xlsx", modify
putexcel (E5) = (W[2,1]) using "${tables}partTime.xlsx", modify
putexcel (F5) = (W[4,1]) using "${tables}partTime.xlsx", modify

probit partt rminw $reg3 if minwage==1 & female==0

mat W = r(table)
putexcel (G5) = (W[1,1]) using "${tables}partTime.xlsx", modify
putexcel (H5) = (W[2,1]) using "${tables}partTime.xlsx", modify
putexcel (I5) = (W[4,1]) using "${tables}partTime.xlsx", modify

*women
xtreg partt rminw $reg3 if minwage==1 & female==1, fe i(state_year)

mat W = r(table)
putexcel (J5) = (W[1,1]) using "${tables}partTime.xlsx", modify
putexcel (K5) = (W[2,1]) using "${tables}partTime.xlsx", modify
putexcel (L5) = (W[4,1]) using "${tables}partTime.xlsx", modify

logit partt rminw $reg3 if minwage==1 & female==1

mat W = r(table)
putexcel (M5) = (W[1,1]) using "${tables}partTime.xlsx", modify
putexcel (N5) = (W[2,1]) using "${tables}partTime.xlsx", modify
putexcel (O5) = (W[4,1]) using "${tables}partTime.xlsx", modify

probit partt rminw $reg3 if minwage==1 & female==1

mat W = r(table)
putexcel (P5) = (W[1,1]) using "${tables}partTime.xlsx", modify
putexcel (Q5) = (W[2,1]) using "${tables}partTime.xlsx", modify
putexcel (R5) = (W[4,1]) using "${tables}partTime.xlsx", modify






