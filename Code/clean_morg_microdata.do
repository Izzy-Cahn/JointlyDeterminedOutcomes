*for cleaning MORG CPS microdata as provided by NBER.
*(available here: https://data.nber.org/morg/annual/)  
*this cleaner is derived from "clean_morg_microdata," used by David Autor in a number of papers (e.g. Autor, Katz, and Kearney ReStat 2008; data and cleaners
*available here: http://economics.mit.edu/faculty/dautor/data/autkatkear08 )
*Yisroel Cahn 11/15/19
set more off
clear
graph drop _all
capture close log


/* --------------------------------------
This program cleans the morg data sets
year by year.  The code is based on 
Michael Anderson's original cleaner:
/proj/akk-ineq/cleaners/clean_morg_microdata 
for the morg.

After this program runs, some restrictions
still must be imposed:
- Drop those that are self-employed
- Drop those with more than 38 years of 
potential experience
- Restrict operations based on hr_wage_sample.  These take care of allocators,
missing wages, and those that have wages that are 
too low.
- Note, wages are in real terms.

Tal Gross                        
2004                             

Updated D. Autor, 8/30/06 to accomdate 2005 MORG

Updated T. Gross, 8/09/2007 to accomodate the 
2006 MORG

Updated M. Wasserman, 10/01/2009 to accommodate 2007/2009 MORG 

Updated Y. Cahn, 11/15/2019 to accomodate NBER documentation
--------------------------------------- */

*fold: {{{ */

clear
set mem 100m

use "/Users/yisroelcahn/Documents/JointlyDeterminedOutcomes/Data/Raw Data/morg`1'.dta", clear



/*
************************************
* Preliminary Vars (mostly from Anderson)
************************************/


   /* keep age 18-64 wage and salary workers who had job wk before survey. */

   keep if age>=18 & age<=64
   
   /*removing self-employed, never worked, or worked without pay */
   if (year>=1973  & year<=1988) keep if (classer >= 1 & classer <= 2)
   if (year>=1989 & year<=1993) keep if (classer>=1 & classer<=4)
   if (year>=1994 & year<=2019) keep if (class94>=1 & class94<=5)  
   
   
   /*keep if mlr==1 | mlr==2 (monthly labor force recode: 1 & 2-employed) */
   if (year>=1973  & year<=1988) keep if (esr==1 | esr==2)
   if (year>=1989 & year<=1993) keep if (lfsr89==1 | lfsr89==2)
   if (year>=1994 & year<=2019) keep if (lfsr94==1 | lfsr94==2)
   
   
   /* race */
   gen byte black=race==2
   gen byte other=race>=3
   replace race=3 if race>=3
   
   /* marital status */
   gen married=1
   replace married=0 if marital>=4


   /* create variable "female" equals one if the individual is female, zero 
   otherwise. */
   gen byte female=sex==2
     

   /* create variable "educomp" to indicate the number of years of completed 
   schooling.  If the individual did not complete the highest grade he 
   attended, his years of completed schooling is assigned to be one less than 
   the highest grade attended.*/
   
   /*****(YC: I'm adding this so variable names match NBER data) */
   if (year>=1973 & year<=1991) {
		rename gradeat grdhi
		rename gradecp grdcom
   }
   if (year>=1992 & year<=2019) {
		rename grade92 grdatn
   }
   /*****/
   

   if (year>=1973 & year<=1991) {
       rename grdhi _grdhi
	   gen educomp=_grdhi if grdcom==1 & _grdhi~=0
	   replace educomp=_grdhi-1 if grdcom==2 & _grdhi~=0
	   replace educomp=0 if _grdhi==0
   }

   /* create variable "exp" to indicate the number of years of experience, 1979-1991. this calculation assumes that minors do not start working until age 16 regardless of education status*/

   if (year>=1973 & year<=1991) {
	   gen exp=max(min(age-educomp-6, age-16),0)
   }
   
     
/**********************from cps_exper_post92.do**************************/
   /* create variable "exp" to indicate the number of years of experience, 1992-2009. this calculation assumes that minors do not start working until age 16 regardless of education status*/
   if (year>=1992 & year<=2019) {
		/* men, white */
		gen educomp =  0
		replace educomp = .32  if (race==1 & female==0 & (grdatn ==31 | grdatn==00))
		replace educomp = 3.19 if (race==1 & female==0 & grdatn ==32)
		replace educomp = 7.24 if (race==1 & female==0 & (grdatn ==33 | grdatn==34))
		replace educomp = 8.97 if (race==1 & female==0 & grdatn == 35)
		replace educomp = 9.92 if (race==1 & female==0 & grdatn == 36)
		replace educomp = 10.86 if (race==1 & female==0 & grdatn ==37)
		replace educomp = 11.58 if (race==1 & female==0 & grdatn ==38)
		replace educomp = 11.99 if (race==1 & female==0 & grdatn ==39)
		replace educomp = 13.48 if (race==1 & female==0 & grdatn ==40)
		replace educomp = 14.23 if (race==1 & female==0 & (grdatn ==41 | grdatn==42))
		replace educomp = 16.17 if (race==1 & female==0 & grdatn ==43)
		replace educomp = 17.68 if (race==1 & female==0 & grdatn ==44)
		replace educomp = 17.71 if (race==1 & female==0 & grdatn ==45)
		replace educomp = 17.83 if (race==1 & female==0 & grdatn ==46)

		/* female, white */
		replace educomp = 0.62 if (race==1 & female==1 & (grdatn ==31|grdatn==00))
		replace educomp = 3.15 if (race==1 & female==1 & grdatn ==32)
		replace educomp = 7.23 if (race==1 & female==1 & (grdatn ==33 | grdatn==34))
		replace educomp = 8.99 if (race==1 & female==1 & grdatn == 35)
		replace educomp = 9.95 if (race==1 & female==1 & grdatn == 36)
		replace educomp = 10.87 if (race==1 & female==1 & grdatn ==37)
		replace educomp = 11.73 if (race==1 & female==1 & grdatn ==38)
		replace educomp = 12.00 if (race==1 & female==1 & grdatn ==39)
		replace educomp = 13.35 if (race==1 & female==1 & grdatn ==40)
		replace educomp = 14.22 if (race==1 & female==1 & (grdatn ==41 | grdatn==42))
		replace educomp = 16.15 if (race==1 & female==1 & grdatn ==43)
		replace educomp = 17.64 if (race==1 & female==1 & grdatn ==44)
		replace educomp = 17.00 if (race==1 & female==1 & grdatn ==45)
		replace educomp = 17.76 if (race==1 & female==1 & grdatn ==46)

		/* men, black */
		replace educomp = .92  if (race==2 & female==0 & (grdatn ==31|grdatn==00))
		replace educomp = 3.28 if (race==2 & female==0 & grdatn ==32)
		replace educomp = 7.04 if (race==2 & female==0 & (grdatn ==33 | grdatn==34))
		replace educomp = 9.02 if (race==2 & female==0 & grdatn == 35)
		replace educomp = 9.91 if (race==2 & female==0 & grdatn == 36)
		replace educomp = 10.90 if (race==2 & female==0 & grdatn ==37)
		replace educomp = 11.41 if (race==2 & female==0 & grdatn ==38)
		replace educomp = 11.98 if (race==2 & female==0 & grdatn ==39)
		replace educomp = 13.57 if (race==2 & female==0 & grdatn ==40)
		replace educomp = 14.33 if (race==2 & female==0 & (grdatn ==41 | grdatn==42))
		replace educomp = 16.13 if (race==2 & female==0 & grdatn ==43)
		replace educomp = 17.51 if (race==2 & female==0 & grdatn ==44)
		replace educomp = 17.83 if (race==2 & female==0 & grdatn ==45)
		replace educomp = 18.00 if (race==2 & female==0 & grdatn ==46)

		/* female, black */
		replace educomp = 0.00 if (race==2 & female==1 & (grdatn ==31|grdatn==00))
		replace educomp = 2.90 if (race==2 & female==1 & grdatn ==32)
		replace educomp = 7.03 if (race==2 & female==1 & (grdatn ==33 | grdatn==34))
		replace educomp = 9.05 if (race==2 & female==1 & grdatn == 35)
		replace educomp = 9.99 if (race==2 & female==1 & grdatn == 36)
		replace educomp = 10.85 if (race==2 & female==1 & grdatn ==37)
		replace educomp = 11.64 if (race==2 & female==1 & grdatn ==38)
		replace educomp = 12.00 if (race==2 & female==1 & grdatn ==39)
		replace educomp = 13.43 if (race==2 & female==1 & grdatn ==40)
		replace educomp = 14.33 if (race==2 & female==1 & (grdatn ==41 | grdatn==42))
		replace educomp = 16.04 if (race==2 & female==1 & grdatn ==43)
		replace educomp = 17.69 if (race==2 & female==1 & grdatn ==44)
		replace educomp = 17.40 if (race==2 & female==1 & grdatn ==45)
		replace educomp = 18.00 if (race==2 & female==1 & grdatn ==46)

		/* men, other */
		replace educomp = .62  if (race==3 & female==0 & (grdatn ==31|grdatn==00))
		replace educomp = 3.24 if (race==3 & female==0 & grdatn ==32)
		replace educomp = 7.14 if (race==3 & female==0 & (grdatn ==33 | grdatn==34))
		replace educomp = 9.00 if (race==3 & female==0 & grdatn == 35)
		replace educomp = 9.92 if (race==3 & female==0 & grdatn == 36)
		replace educomp = 10.88 if (race==3 & female==0 & grdatn ==37)
		replace educomp = 11.50 if (race==3 & female==0 & grdatn ==38)
		replace educomp = 11.99 if (race==3 & female==0 & grdatn ==39)
		replace educomp = 13.53 if (race==3 & female==0 & grdatn ==40)
		replace educomp = 14.28 if (race==3 & female==0 & (grdatn ==41 | grdatn==42))
		replace educomp = 16.15 if (race==3 & female==0 & grdatn ==43)
		replace educomp = 17.60 if (race==3 & female==0 & grdatn ==44)
		replace educomp = 17.77 if (race==3 & female==0 & grdatn ==45)
		replace educomp = 17.92 if (race==3 & female==0 & grdatn ==46)

		/* female, other */
		replace educomp = 0.31 if (race==3 & female==1 & (grdatn ==31|grdatn==00))
		replace educomp = 3.03 if (race==3 & female==1 & grdatn ==32)
		replace educomp = 7.13 if (race==3 & female==1 & (grdatn ==33 | grdatn==34))
		replace educomp = 9.02 if (race==3 & female==1 & grdatn == 35)
		replace educomp = 9.97 if (race==3 & female==1 & grdatn == 36)
		replace educomp = 10.86 if (race==3 & female==1 & grdatn ==37)
		replace educomp = 11.69 if (race==3 & female==1 & grdatn ==38)
		replace educomp = 12.00 if (race==3 & female==1 & grdatn ==39)
		replace educomp = 13.47 if (race==3 & female==1 & grdatn ==40)
		replace educomp = 14.28 if (race==3 & female==1 & (grdatn ==41 | grdatn==42))
		replace educomp = 16.10 if (race==3 & female==1 & grdatn ==43)
		replace educomp = 17.67 if (race==3 & female==1 & grdatn ==44)
		replace educomp = 17.20 if (race==3 & female==1 & grdatn ==45)
		replace educomp = 17.88 if (race==3 & female==1 & grdatn ==46)

		/* Calculate experience: this calculation assumes that minors do not start working until age 16 regardless of education status */

		gen exp_unrounded=max(min(age-educomp-6, age-16),0)
		gen exp=round(exp_unrounded,1)
		drop exp_unrounded 
   }
/********************************************************/
   /*assert exp!=. */
   if (year>=1992 & year<=2019) assert exp!=.
   if (year>=1992 & year<=2019) summ exp
   
   /* hours variables. */
   if year>=1979 & year<=1993{
   drop uhours
   rename hourslw uhours
   }
   if year>=1994 & year<=2019{
   rename hourslw uhours
   }

   replace uhours=99 if uhours>=99 & uhours<.
   
   

/* create variable to indicate fulltime workers (hours>=35).  We cannot use the MORG provided flag because of inconsistency. */
gen byte ft=uhours>=35
replace ft=0 if uhours==.
label var ft "Hours >= 35 last week"

 
/************************************
* Handle Wage Inconsistencies Across Years  
************************************/  

replace earnhre=earnhre/100


replace earnhre=. if earnhre<0
replace earnwke=. if earnwke<0
  


/************************************
* Create Wages and make allocation flags  
************************************/


/********make an hourly wage for everyone */
gen hr_wage = earnwke/uhours 
/* We must 'windsorize' hourly wages that are based on top coded earnings */
replace hr_wage=(earnwke*1.5)/uhours if earnwke==999 

/* We now allow hourly workers to use their hourly rate of pay */
replace hr_wage=earnhre if paidhre==1 & earnhre!=. & earnhre>0



/*flag if this wage is allocated or not */
gen hr_alloc=0
replace hr_alloc=1 if paidhre>0 & paidhre==1
replace hr_alloc=0 if hr_wage==.
label var hr_alloc "Flag for when both earning/hours flagged and payed by the hour flagged"



/*remove other problematic data */
replace hr_wage=. if hr_wage<=0
drop if uhours==0  | hr_wage==.
drop if uhours==.


/*fold: }}}s */



   /* Redo weights.  According to Unicon:
   When the Outgoing Rotation files are produced, two rotations are extracted from each of the 
   twelve months and gathered into a single annual file. The weights on the file must be modified 
   by the user before they will give reliable counts. Since the final weight is gathered from 12 
   months but only 2/8 rotations, the weight on the outgoing file should be divided by 3 (12/4) 
   before it is applied. The earner weight is gathered from 12 months from the 2 rotations. Since 
   those two rotations were originally weighted to give a full sample, the earner weight must be 
   divided by 12, not 3. 
    */

   rename earnwt wgt
   replace wgt=wgt/12
   replace wgt=wgt/100 

   label variable wgt "earnings weight"
   /*drop if wgt==. */
   gen wgtrd=round(wgt,1)
   label variable wgtrd "earnings weight, rounded to nearest integer"


/************************************
*   Handle Wage Restrictions  
************************************/


/*************gdp.do*****************/
gen gdp=0


replace gdp=255.7/72.6	if year==1979
replace gdp=255.7/82.4 	if year==1980
replace gdp=255.7/90.9 	if year==1981
replace gdp=255.7/96.5 	if year==1982
replace gdp=255.7/99.6 	if year==1983
replace gdp=255.7/103.9 	if year==1984
replace gdp=255.7/107.6  	if year==1985
replace gdp=255.7/109.6 	if year==1986
replace gdp=255.7/113.6 	if year==1987
replace gdp=255.7/118.3 	if year==1988
replace gdp=255.7/124.0  	if year==1989
replace gdp=255.7/130.7 	if year==1990
replace gdp=255.7/136.2 	if year==1991
replace gdp=255.7/140.3 	if year==1992
replace gdp=255.7/144.5 	if year==1993
replace gdp=255.7/148.2 	if year==1994
replace gdp=255.7/152.4 	if year==1995
replace gdp=255.7/156.9  	if year==1996
replace gdp=255.7/160.5 	if year==1997
replace gdp=255.7/163.0 	if year==1998
replace gdp=255.7/166.6 	if year==1999
replace gdp=255.7/172.2 	if year==2000
replace gdp=255.7/177.1 	if year==2001
replace gdp=255.7/179.9 	if year==2002
replace gdp=255.7/184.0 	if year==2003
replace gdp=255.7/188.9 	if year==2004
replace gdp=255.7/195.3  	if year==2005
replace gdp=255.7/201.6 	if year==2006
replace gdp=255.7/207.3 	if year==2007
replace gdp=255.7/215.3 	if year==2008
replace gdp=255.7/214.5     if year==2009
replace gdp=255.7/218.1 if year==2010
replace gdp=255.7/224.9 if year==2011
replace gdp=255.7/229.6 if year==2012
replace gdp=255.7/233.0 if year==2013
replace gdp=255.7/236.7 if year==2014
replace gdp=255.7/237.0 if year==2015
replace gdp=255.7/240.0 if year==2016
replace gdp=255.7/245.1 if year==2017
replace gdp=255.7/251.1 if year==2018
replace gdp=255.7/255.7 if year==2019
assert gdp!=0                  

label variable gdp "GDP Personal Consumption Expenditure Deflator, 2019$"
/****************************************/

/** We flag those who are earning more than the current earnings top coded times 1.5 divided by 35 hours/week */

gen byte hr_w2hi=0
replace hr_w2hi=1 if ((hr_wage)>((999*1.5 )/35)) & year>=1973 & year<=1985
replace hr_w2hi=1 if ((hr_wage)>((1999*1.5)/35)) & year>=1986 & year<=1988
replace hr_w2hi=1 if ((hr_wage)>((1923*1.5)/35)) & year>=1989 & year<=1997
replace hr_w2hi=1 if ((hr_wage)>((2884*1.5)/35)) & year>=1998 & year<=2019
replace hr_w2hi=0 if hr_wage==.
label var hr_w2hi "Equal to one if earning more than the current earnings top code times 1.5 divided by 35 hours/week"


/* Also we 'windsorize' these wages (set these hourly wages to the top code times 1.5) */
replace hr_wage=((999*1.5 )/35) if hr_w2hi & year>=1973 & year<=1985
replace hr_wage=((1999*1.5)/35) if hr_w2hi & year>=1986 & year<=1988
replace hr_wage=((1923*1.5)/35) if hr_w2hi & year>=1989 & year<=1997
replace hr_wage=((2884*1.5)/35) if hr_w2hi & year>=1998 & year<=2019






/* ###: Turn wages into real terms  */
replace hr_wage=hr_wage*gdp
label var hr_wage "Hourly wage for hourly employees & imputed hourly wage for full time employees, 2019$"


/************************************
*  Save as cleaned data
************************************/

label data "Cleaned `1' Morg Data"
compress

if (`1'>=73) save "/Users/yisroelcahn/Documents/JointlyDeterminedOutcomes/Data/Cleaned Data/morg_cleaned_19`1'", replace
if (`1'< 73) save "/Users/yisroelcahn/Documents/JointlyDeterminedOutcomes/Data/Cleaned Data/morg_cleaned_20`1'", replace

/*fold: }}} */

