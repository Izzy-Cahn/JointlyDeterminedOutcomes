*fig 3
********************************************
global figures "/Users/yisroelcahn/Documents/GitHub/JointlyDeterminedOutcomes/Figures/"
use usdb, clear
destring FIPS, replace

drop if id==57
drop if id==4
drop if id==39
drop if id==46
drop if id==54
drop if id==55

rename FIPS stfips
merge 1:m stfips using "/Users/yisroelcahn/Downloads/s_11au16/mw_state_monthly.dta"
drop if _merge!=3


drop if STATE == "AK" | STATE == "HI"

spmap MonthlyStateAverage using uscoord if year==1979 & month==1 & id!=1, id(id) fcolor(Blues) legstyle(3) 
graph export "${figures}graph5.pdf", replace

spmap MonthlyStateAverage using uscoord if year==1999 & month==1 & id!=1, id(id) fcolor(Blues) legstyle(3) 
graph export "${figures}graph6.pdf", replace

spmap MonthlyStateAverage using uscoord if year==2019 & month==1 & id!=1, id(id) fcolor(Blues) legstyle(3) 
graph export "${figures}graph7.pdf", replace






