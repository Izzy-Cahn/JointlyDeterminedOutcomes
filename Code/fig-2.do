*fig 2
global data "/Users/yisroelcahn/Documents/JointlyDeterminedOutcomes/Data/Cleaned Data/"
global tables "/Users/yisroelcahn/Documents/JointlyDeterminedOutcomes/Tables/"
global figures "/Users/yisroelcahn/Documents/JointlyDeterminedOutcomes/Figures/"
set more off


**pooled

*make excel variables 
putexcel (B1) = ("W1") using "${tables}fig2pooled.xlsx", modify
putexcel (C1) = ("W2") using "${tables}fig2pooled.xlsx", modify
putexcel (D1) = ("W3") using "${tables}fig2pooled.xlsx", modify
putexcel (E1) = ("W4") using "${tables}fig2pooled.xlsx", modify
putexcel (F1) = ("W5") using "${tables}fig2pooled.xlsx", modify
	
putexcel (G1) = ("H1") using "${tables}fig2pooled.xlsx", modify
putexcel (H1) = ("H2") using "${tables}fig2pooled.xlsx", modify
putexcel (I1) = ("H3") using "${tables}fig2pooled.xlsx", modify
putexcel (J1) = ("H4") using "${tables}fig2pooled.xlsx", modify
putexcel (K1) = ("H5") using "${tables}fig2pooled.xlsx", modify

putexcel (A1) = ("year") using "${tables}fig2pooled.xlsx", modify
	

forvalues i=1979/2019{
	use "${data}morg_cleaned_`i'.dta", clear

	keep hr_wage uhours wgtrd 
	
	xtile quart = hr_wage [fw=wgtrd], nq(5)
	
	display "`i'"
	
	*starting at 2 and incrementing by 1
	local k=`i'-1977
	
	putexcel (A`k') = (`i') using "${tables}fig2pooled.xlsx", modify
	
	tabstat  hr_wage [fw=wgtrd] , stat(mean) by(quart) save
	mat W1 = r(Stat1)
	mat W2 = r(Stat2)
	mat W3 = r(Stat3)
	mat W4 = r(Stat4)
	mat W5 = r(Stat5)
	
	putexcel (B`k') = (W1[1,1]) using "${tables}fig2pooled.xlsx", modify
	putexcel (C`k') = (W2[1,1]) using "${tables}fig2pooled.xlsx", modify
	putexcel (D`k') = (W3[1,1]) using "${tables}fig2pooled.xlsx", modify
	putexcel (E`k') = (W4[1,1]) using "${tables}fig2pooled.xlsx", modify
	putexcel (F`k') = (W5[1,1]) using "${tables}fig2pooled.xlsx", modify

	tabstat  uhours [fw=wgtrd] , stat(mean) by(quart) save
	mat H1 = r(Stat1)
	mat H2 = r(Stat2)
	mat H3 = r(Stat3)
	mat H4 = r(Stat4)
	mat H5 = r(Stat5)
	
	putexcel (G`k') = (H1[1,1]) using "${tables}fig2pooled.xlsx", modify
	putexcel (H`k') = (H2[1,1]) using "${tables}fig2pooled.xlsx", modify
	putexcel (I`k') = (H3[1,1]) using "${tables}fig2pooled.xlsx", modify
	putexcel (J`k') = (H4[1,1]) using "${tables}fig2pooled.xlsx", modify
	putexcel (K`k') = (H5[1,1]) using "${tables}fig2pooled.xlsx", modify

}


**men

*make excel variables 
putexcel (B1) = ("W1") using "${tables}fig2men.xlsx", modify
putexcel (C1) = ("W2") using "${tables}fig2men.xlsx", modify
putexcel (D1) = ("W3") using "${tables}fig2men.xlsx", modify
putexcel (E1) = ("W4") using "${tables}fig2men.xlsx", modify
putexcel (F1) = ("W5") using "${tables}fig2men.xlsx", modify
	
putexcel (G1) = ("H1") using "${tables}fig2men.xlsx", modify
putexcel (H1) = ("H2") using "${tables}fig2men.xlsx", modify
putexcel (I1) = ("H3") using "${tables}fig2men.xlsx", modify
putexcel (J1) = ("H4") using "${tables}fig2men.xlsx", modify
putexcel (K1) = ("H5") using "${tables}fig2men.xlsx", modify

forvalues i=1979/2019{
	use "${data}morg_cleaned_`i'.dta", clear
	
	keep if female==0

	keep hr_wage uhours wgtrd 
	
	xtile quart = hr_wage [fw=wgtrd], nq(5)
	
	display "`i'"
	
	*starting at 2 and incrementing by 1
	local k=`i'-1977
	
	putexcel (A`k') = (`i') using "${tables}fig2men.xlsx", modify
	
	tabstat  hr_wage [fw=wgtrd] , stat(mean) by(quart) save
	mat W1 = r(Stat1)
	mat W2 = r(Stat2)
	mat W3 = r(Stat3)
	mat W4 = r(Stat4)
	mat W5 = r(Stat5)
	
	putexcel (B`k') = (W1[1,1]) using "${tables}fig2men.xlsx", modify
	putexcel (C`k') = (W2[1,1]) using "${tables}fig2men.xlsx", modify
	putexcel (D`k') = (W3[1,1]) using "${tables}fig2men.xlsx", modify
	putexcel (E`k') = (W4[1,1]) using "${tables}fig2men.xlsx", modify
	putexcel (F`k') = (W5[1,1]) using "${tables}fig2men.xlsx", modify

	tabstat  uhours [fw=wgtrd] , stat(mean) by(quart) save
	mat H1 = r(Stat1)
	mat H2 = r(Stat2)
	mat H3 = r(Stat3)
	mat H4 = r(Stat4)
	mat H5 = r(Stat5)
	
	putexcel (G`k') = (H1[1,1]) using "${tables}fig2men.xlsx", modify
	putexcel (H`k') = (H2[1,1]) using "${tables}fig2men.xlsx", modify
	putexcel (I`k') = (H3[1,1]) using "${tables}fig2men.xlsx", modify
	putexcel (J`k') = (H4[1,1]) using "${tables}fig2men.xlsx", modify
	putexcel (K`k') = (H5[1,1]) using "${tables}fig2men.xlsx", modify

}

**women

*make excel variables 
putexcel (B1) = ("W1") using "${tables}fig2women.xlsx", modify
putexcel (C1) = ("W2") using "${tables}fig2women.xlsx", modify
putexcel (D1) = ("W3") using "${tables}fig2women.xlsx", modify
putexcel (E1) = ("W4") using "${tables}fig2women.xlsx", modify
putexcel (F1) = ("W5") using "${tables}fig2women.xlsx", modify
	
putexcel (G1) = ("H1") using "${tables}fig2women.xlsx", modify
putexcel (H1) = ("H2") using "${tables}fig2women.xlsx", modify
putexcel (I1) = ("H3") using "${tables}fig2women.xlsx", modify
putexcel (J1) = ("H4") using "${tables}fig2women.xlsx", modify
putexcel (K1) = ("H5") using "${tables}fig2women.xlsx", modify

forvalues i=1979/2019{
	use "${data}morg_cleaned_`i'.dta", clear
	
	keep if female==1
	
	keep hr_wage uhours wgtrd 
	
	xtile quart = hr_wage [fw=wgtrd], nq(5)
	
	display "`i'"
	
	*starting at 2 and incrementing by 1
	local k=`i'-1977
	
	putexcel (A`k') = (`i') using "${tables}fig2women.xlsx", modify
	
	tabstat  hr_wage [fw=wgtrd] , stat(mean) by(quart) save
	mat W1 = r(Stat1)
	mat W2 = r(Stat2)
	mat W3 = r(Stat3)
	mat W4 = r(Stat4)
	mat W5 = r(Stat5)
	
	putexcel (B`k') = (W1[1,1]) using "${tables}fig2women.xlsx", modify
	putexcel (C`k') = (W2[1,1]) using "${tables}fig2women.xlsx", modify
	putexcel (D`k') = (W3[1,1]) using "${tables}fig2women.xlsx", modify
	putexcel (E`k') = (W4[1,1]) using "${tables}fig2women.xlsx", modify
	putexcel (F`k') = (W5[1,1]) using "${tables}fig2women.xlsx", modify

	tabstat  uhours [fw=wgtrd] , stat(mean) by(quart) save
	mat H1 = r(Stat1)
	mat H2 = r(Stat2)
	mat H3 = r(Stat3)
	mat H4 = r(Stat4)
	mat H5 = r(Stat5)
	
	putexcel (G`k') = (H1[1,1]) using "${tables}fig2women.xlsx", modify
	putexcel (H`k') = (H2[1,1]) using "${tables}fig2women.xlsx", modify
	putexcel (I`k') = (H3[1,1]) using "${tables}fig2women.xlsx", modify
	putexcel (J`k') = (H4[1,1]) using "${tables}fig2women.xlsx", modify
	putexcel (K`k') = (H5[1,1]) using "${tables}fig2women.xlsx", modify

}


**Figures
*pooled
import excel "${tables}fig2pooled.xlsx", sheet("Sheet1") firstrow clear
label variable W1 "Avg Wage bottom 20%" 
label variable W2 "Avg Wage bottom 20%-40%" 
label variable W3 "Avg Wage bottom 40%-60%" 
label variable W4 "Avg Wage bottom 60%-80%" 
label variable W5 "Avg Wage top 20%"  
line  W1 W2 W3 W4 W5 year
graph export "${figures}graph3pooled.pdf", replace

label variable H1 "Avg Hours bottom 20%" 
label variable H2 "Avg Hours bottom 20%-40%" 
label variable H3 "Avg Hours bottom 40%-60%" 
label variable H4 "Avg Hours bottom 60%-80%" 
label variable H5 "Avg Hours top 20%" 
line H1 H2 H3 H4 H5 year
graph export "${figures}graph4pooled.pdf", replace

*men
import excel "${tables}fig2men.xlsx", sheet("Sheet1") firstrow clear
label variable W1 "Avg Wage bottom 20%" 
label variable W2 "Avg Wage bottom 20%-40%" 
label variable W3 "Avg Wage bottom 40%-60%" 
label variable W4 "Avg Wage bottom 60%-80%" 
label variable W5 "Avg Wage top 20%"  
line  W1 W2 W3 W4 W5 year
graph export "${figures}graph3men.pdf", replace

label variable H1 "Avg Hours bottom 20%" 
label variable H2 "Avg Hours bottom 20%-40%" 
label variable H3 "Avg Hours bottom 40%-60%" 
label variable H4 "Avg Hours bottom 60%-80%" 
label variable H5 "Avg Hours top 20%" 
line H1 H2 H3 H4 H5 year
graph export "${figures}graph4men.pdf", replace

*women
import excel "${tables}fig2women.xlsx", sheet("Sheet1") firstrow clear
label variable W1 "Avg Wage bottom 20%" 
label variable W2 "Avg Wage bottom 20%-40%" 
label variable W3 "Avg Wage bottom 40%-60%" 
label variable W4 "Avg Wage bottom 60%-80%" 
label variable W5 "Avg Wage top 20%"  
line  W1 W2 W3 W4 W5 year
graph export "${figures}graph3women.pdf", replace

label variable H1 "Avg Hours bottom 20%" 
label variable H2 "Avg Hours bottom 20%-40%" 
label variable H3 "Avg Hours bottom 40%-60%" 
label variable H4 "Avg Hours bottom 60%-80%" 
label variable H5 "Avg Hours top 20%" 
line H1 H2 H3 H4 H5 year
graph export "${figures}graph4women.pdf", replace


