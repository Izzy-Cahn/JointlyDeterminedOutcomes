*The difference here is uhours==0 are not dropped
*and we need a labor market participation variable (LMP) using unemployed workers.

set more off
clear
graph drop _all
capture close log



clear
set mem 100m



forvalues i=79/99{
use "/Users/yisroelcahn/Documents/GitHub/JointlyDeterminedOutcomes/Data/Raw Data/morg`i'.dta", clear

   keep if age>=18 & age<=64
   
   if (year>=1973  & year<=1988) keep if (classer >= 1 & classer <= 2)
   if (year>=1989 & year<=1993) keep if (classer>=1 & classer<=4)
   if (year>=1994 & year<=2019) keep if (class94>=1 & class94<=5)  
   
   
   gen lfp=0
   if (year>=1973  & year<=1988) replace lfp=1 if (esr==1 | esr==2)
   if (year>=1973  & year<=1988) drop if (esr>3)
   if (year>=1989 & year<=1993) replace lfp=1 if (lfsr89==1 | lfsr89==2)
   if (year>=1989 & year<=1993) drop if (lfsr89>4)
   if (year>=1994 & year<=2019) replace lfp=1 if (lfsr94==1 | lfsr94==2)
   if (year>=1994 & year<=2019) drop if (lfsr94>4)
   
   gen married=1
   replace married=0 if marital>=4 
   
   
   gen byte black=race==2
   gen byte other=race>=3
   replace race=3 if race>=3


   gen byte female=sex==2
     

   if (year>=1973 & year<=1991) {
		rename gradeat grdhi
		rename gradecp grdcom
   }
   if (year>=1992 & year<=2019) {
		rename grade92 grdatn
   }
   

   if (year>=1973 & year<=1991) {
       rename grdhi _grdhi
	   gen educomp=_grdhi if grdcom==1 & _grdhi~=0
	   replace educomp=_grdhi-1 if grdcom==2 & _grdhi~=0
	   replace educomp=0 if _grdhi==0
   }

   if (year>=1973 & year<=1991) {
	   gen exp=max(min(age-educomp-6, age-16),0)
   }
   
     
   if (year>=1992 & year<=2019) {
		
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


		gen exp_unrounded=max(min(age-educomp-6, age-16),0)
		gen exp=round(exp_unrounded,1)
		drop exp_unrounded 
   }

   if (year>=1992 & year<=2019) assert exp!=.
   if (year>=1992 & year<=2019) summ exp
   
   
   if year>=1979 & year<=1993{
   drop uhours
   rename hourslw uhours
   }
   if year>=1994 & year<=2019{
   rename hourslw uhours
   }

   replace uhours=99 if uhours>=99 & uhours<.
   
   

gen byte ft=uhours>=35
replace ft=0 if uhours==.
label var ft "Hours >= 35 last week"


replace earnhre=earnhre/100


replace earnhre=. if earnhre<0
replace earnwke=. if earnwke<0
  
 
gen hr_wage = earnwke/uhours 

replace hr_wage=(earnwke*1.5)/uhours if earnwke==999 


replace hr_wage=earnhre if paidhre==1 & earnhre!=. & earnhre>0


gen hr_alloc=0
replace hr_alloc=1 if paidhre>0 & paidhre==1
replace hr_alloc=0 if hr_wage==.
label var hr_alloc "Flag for when both earning/hours flagged and payed by the hour flagged"


replace hr_wage=. if hr_wage<=0
replace hr_wage=0 if hr_wage==.
replace uhours=0 if uhours==.


   rename earnwt wgt
   replace wgt=wgt/12
   replace wgt=wgt/100 

   label variable wgt "earnings weight"
   *drop if wgt==.
   gen wgtrd=round(wgt,1)
   label variable wgtrd "earnings weight, rounded to nearest integer"


gen gdp=0


replace gdp=255.7/72.6	 if year==1979
replace gdp=255.7/82.4 	 if year==1980
replace gdp=255.7/90.9 	 if year==1981
replace gdp=255.7/96.5 	 if year==1982
replace gdp=255.7/99.6 	 if year==1983
replace gdp=255.7/103.9  if year==1984
replace gdp=255.7/107.6  if year==1985
replace gdp=255.7/109.6  if year==1986
replace gdp=255.7/113.6  if year==1987
replace gdp=255.7/118.3  if year==1988
replace gdp=255.7/124.0  if year==1989
replace gdp=255.7/130.7  if year==1990
replace gdp=255.7/136.2  if year==1991
replace gdp=255.7/140.3  if year==1992
replace gdp=255.7/144.5  if year==1993
replace gdp=255.7/148.2  if year==1994
replace gdp=255.7/152.4  if year==1995
replace gdp=255.7/156.9  if year==1996
replace gdp=255.7/160.5  if year==1997
replace gdp=255.7/163.0  if year==1998
replace gdp=255.7/166.6  if year==1999
replace gdp=255.7/172.2  if year==2000
replace gdp=255.7/177.1  if year==2001
replace gdp=255.7/179.9  if year==2002
replace gdp=255.7/184.0  if year==2003
replace gdp=255.7/188.9  if year==2004
replace gdp=255.7/195.3  if year==2005
replace gdp=255.7/201.6  if year==2006
replace gdp=255.7/207.3  if year==2007
replace gdp=255.7/215.3  if year==2008
replace gdp=255.7/214.5  if year==2009
replace gdp=255.7/218.1  if year==2010
replace gdp=255.7/224.9  if year==2011
replace gdp=255.7/229.6  if year==2012
replace gdp=255.7/233.0  if year==2013
replace gdp=255.7/236.7  if year==2014
replace gdp=255.7/237.0  if year==2015
replace gdp=255.7/240.0  if year==2016
replace gdp=255.7/245.1  if year==2017
replace gdp=255.7/251.1  if year==2018
replace gdp=255.7/255.7  if year==2019
assert gdp!=0                  

label variable gdp "GDP Personal Consumption Expenditure Deflator, 2019$"

gen byte hr_w2hi=0
replace hr_w2hi=1 if ((hr_wage)>((999*1.5 )/35)) & year>=1973 & year<=1985
replace hr_w2hi=1 if ((hr_wage)>((1999*1.5)/35)) & year>=1986 & year<=1988
replace hr_w2hi=1 if ((hr_wage)>((1923*1.5)/35)) & year>=1989 & year<=1997
replace hr_w2hi=1 if ((hr_wage)>((2884*1.5)/35)) & year>=1998 & year<=2019
replace hr_w2hi=0 if hr_wage==.
label var hr_w2hi "Equal to one if earning more than the current earnings top code times 1.5 divided by 35 hours/week"


replace hr_wage=((999*1.5 )/35) if hr_w2hi & year>=1973 & year<=1985
replace hr_wage=((1999*1.5)/35) if hr_w2hi & year>=1986 & year<=1988
replace hr_wage=((1923*1.5)/35) if hr_w2hi & year>=1989 & year<=1997
replace hr_wage=((2884*1.5)/35) if hr_w2hi & year>=1998 & year<=2019



replace hr_wage=hr_wage*gdp
label var hr_wage "Hourly wage for hourly employees & imputed hourly wage for full time employees, 2019$"


label data "Cleaned `i' Morg Data"
compress

if (`i'>=73) save "/Users/yisroelcahn/Documents/GitHub/JointlyDeterminedOutcomes/Data/Selection Cleaned Data/morg_cleaned_19`i'", replace
if (`i'< 73) save "/Users/yisroelcahn/Documents/GitHub/JointlyDeterminedOutcomes/Data/Selection Cleaned Data/morg_cleaned_20`i'", replace

 
}
