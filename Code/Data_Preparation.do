*Data Preparation
global data "/Users/yisroelcahn/Documents/GitHub/JointlyDeterminedOutcomes/Data/Cleaned Data/"
set more off

*Base Year*
******************************
******Can Change Year*********
******************************

use "${data}morg_cleaned_1989.dta", clear

****if you want to only use workers paid by the hour:
*drop if hr_alloc==0

*rename and create variables to match DFL (1996) & CFM (2013)
rename wgt eweight
rename hr_wage wage

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
merge m:1 year month state using "/Users/yisroelcahn/Documents/GitHub/JointlyDeterminedOutcomes/Data/mw_state_monthly.dta"

**change for appropriate year
keep if year==1989

*rename a few variables 
rename MonthlyFederalAverage fedmin
rename MonthlyStateAverage minw

*minwage variable
gen minwage=0
replace minwage=1 if wage<=minw*gdp
***************************************************************




if year>=1979 & year<=1982{
rename docc70 nocc
rename dind nind
tab nocc, gene(oc)
tab nind, gene(ind)

keep minwage eweight wage smsa partt nonwhite educ exper female union state oc1-oc45 ind1-ind46 year uhours ch05 married
generate byte wave=1
}

if year>=1983 & year<=2002{
rename docc80 nocc
rename dind nind
tab nocc, gene(oc)
tab nind, gene(ind)

keep minwage eweight wage smsa partt nonwhite educ exper female union state oc1-oc45 ind1-ind47 year uhours ch05 married
generate byte wave=1
}

if year>=2003 & year<=2019{
rename docc00 nocc
rename dind02 nind
tab nocc, gene(oc)
tab nind, gene(ind)

keep minwage eweight wage smsa partt nonwhite educ exper female union state oc1-oc22 ind1-ind51 year uhours ch05 married
generate byte wave=1
}

save "${data}data.dta", replace


*A Subsequent Year*
******************************
******Can Change Year*********
******************************

use "${data}morg_cleaned_1992.dta", clear

*** if you want to only use workers paid by the hour:
*drop if hr_alloc==0

*rename and create variables to match DFL (1996) & CFM (2013)
rename wgt eweight
rename hr_wage wage

gen smsa=0
replace smsa=1 if smsastat==1
gen partt=1 if ft==0
gen nonwhite=0
replace nonwhite=1 if black==1 | other==1

rename educomp educ
rename exp exper
gen union=0
replace union=1 if unionmme==1


drop if uhours==.

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

rename intmonth month

*merge minw data 
merge m:1 year month state using "/Users/yisroelcahn/Documents/GitHub/JointlyDeterminedOutcomes/Data/mw_state_monthly.dta"

**change for appropriate year
keep if year==1992

*rename a few variables 
rename MonthlyFederalAverage fedmin
rename MonthlyStateAverage minw

*minwage variable
gen minwage=0
replace minwage=1 if wage<=minw*gdp
***************************************************************


if year>=1979 & year<=1982{
rename docc70 nocc
rename dind nind
tab nocc, gene(oc)
tab nind, gene(ind)

keep minwage eweight wage smsa partt nonwhite educ exper female union state oc1-oc45 ind1-ind46 year uhours ch05 married
generate byte wave=2
}

if year>=1983 & year<=2002{
rename docc80 nocc
rename dind nind
tab nocc, gene(oc)
tab nind, gene(ind)

keep minwage eweight wage smsa partt nonwhite educ exper female union state oc1-oc45 ind1-ind47 year uhours ch05 married
generate byte wave=2
}

if year>=2003 & year<=2019{
rename docc00 nocc
rename dind02 nind
tab nocc, gene(oc)
tab nind, gene(ind)

keep minwage eweight wage smsa partt nonwhite educ exper female union state oc1-oc22 ind1-ind51 year uhours ch05 married
generate byte wave=2
}

append using "${data}data.dta"


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
gen select10=(wave==1)*(female==0)
gen select20=(wave==2)*(female==0)
gen select11=(wave==1)*(female==1)
gen select21=(wave==2)*(female==1)


save "${data}data.dta", replace












