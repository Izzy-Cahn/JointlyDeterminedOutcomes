*confience bands for selection model

global tables "/Users/yisroelcahn/Documents/GitHub/JointlyDeterminedOutcomes/Tables/"
global figures "/Users/yisroelcahn/Documents/GitHub/JointlyDeterminedOutcomes/Figures/"
set more off


*Need to run again for 89-84 and 06-12 (i.e. replacing all the 89-92's with 89-84 or 06-12) 

***confidence bands
*get diff
mata fh=fopen("${results}89-92/diff","r")
mata diff=fgetmatrix(fh)
mata fclose(fh)

*get pcdf's (i.e. grid of y values used)
mata fh=fopen("${results}89-92/phours","r")
mata pcdf1=fgetmatrix(fh)
mata fclose(fh)
mata fh=fopen("${results}89-92/pwages","r")
mata pcdf2=fgetmatrix(fh)
mata fclose(fh)

*put into excel
mata st_matrix("diff", diff)
mata st_matrix("pcdf1", pcdf1)
mata st_matrix("pcdf2", pcdf2)

putexcel (B2) = matrix(diff) using "${tables}men89-92.xlsx", modify
putexcel (A2) = matrix(pcdf2) using "${tables}men89-92.xlsx", modify
putexcel (B1) = matrix(pcdf1') using "${tables}men89-92.xlsx", modify



*get bootstraps
forvalues i=1/30{
	mata fh=fopen("${results}89-92/boot`i'","r")
	mata boot`i'=fgetmatrix(fh)
	mata fclose(fh)
}


*get an estimate for s^2(y_1,y_2)
mata ssquaredhat=J(9,9,0)

forvalues i=1/9{
	forvalues j=1/9{
		mata temp=J(1,30,0) 
		forvalues k=1/30{
			mata temp[1,`k']= (boot`k'[`i',`j']-diff[`i',`j'])^2
		}
		mata ssquaredhat[`i',`j']=mean(temp')
	}
}

*get critical values
mata criticalvalue=J(9,9,0)

mata c75=J(9,9,0)
mata c25=J(9,9,0)

forvalues i=1/9{
	forvalues j=1/9{
		mata temp=J(1,30,0) 
		forvalues k=1/30{
			mata temp[1,`k']= abs(boot`k'[`i',`j']-diff[`i',`j'])/sqrt(ssquaredhat[`i',`j'])
		}
		mata criticalvalue[`i',`j']= mm_quantile(temp',1,.95)
		mata c75[`i',`j']= mm_quantile(temp',1,.975)
		mata c25[`i',`j']= mm_quantile(temp',1,.025)
	}
}

*Sanity Check: c75-c25 should be a matrix of roughly 2's if T ratio approximately normal 
mata c75-c25

*upper and lower bands
mata ub=J(9,9,0)
mata lb=J(9,9,0)

forvalues i=1/9{
	forvalues j=1/9{
		mata ub[`i',`j']= diff[`i',`j']+criticalvalue[`i',`j']*sqrt(ssquaredhat[`i',`j'])
		mata lb[`i',`j']= diff[`i',`j']-criticalvalue[`i',`j']*sqrt(ssquaredhat[`i',`j'])
	}
}


*stars
mata stars = (ub :<0 :& lb :<0) :| (ub :>0 :& lb :>0)
mata stars


*************************
*********Women***********
*************************
*get diff
mata fh=fopen("${results}w89-92/wdiff","r")
mata wdiff=fgetmatrix(fh)
mata fclose(fh)

*get pcdf's
mata fh=fopen("${results}w89-92/phours","r")
mata pcdf1=fgetmatrix(fh)
mata fclose(fh)
mata fh=fopen("${results}w89-92/pwages","r")
mata pcdf2=fgetmatrix(fh)
mata fclose(fh)

*put into excel
mata st_matrix("wdiff", wdiff)
mata st_matrix("pcdf1", pcdf1)
mata st_matrix("pcdf2", pcdf2)

putexcel (B2) = matrix(wdiff) using "${tables}women89-92.xlsx", modify
putexcel (A2) = matrix(pcdf2) using "${tables}women89-92.xlsx", modify
putexcel (B1) = matrix(pcdf1') using "${tables}women89-92.xlsx", modify



*get bootstraps
forvalues i=1/30{
	mata fh=fopen("${results}w89-92/w_boot`i'","r")
	mata w_boot`i'=fgetmatrix(fh)
	mata fclose(fh)
}


*get an estimate for s^2(y_1,y_2)
mata ssquaredhat=J(9,9,0)

forvalues i=1/9{
	forvalues j=1/9{
		mata temp=J(1,30,0) 
		forvalues k=1/30{
			mata temp[1,`k']= (w_boot`k'[`i',`j']-wdiff[`i',`j'])^2
		}
		mata ssquaredhat[`i',`j']=mean(temp')
	}
}

*get critical values
mata criticalvalue=J(9,9,0)

mata c75=J(9,9,0)
mata c25=J(9,9,0)

forvalues i=1/9{
	forvalues j=1/9{
		mata temp=J(1,30,0) 
		forvalues k=1/30{
			mata temp[1,`k']= abs(w_boot`k'[`i',`j']-wdiff[`i',`j'])/sqrt(ssquaredhat[`i',`j'])
		}
		mata criticalvalue[`i',`j']= mm_quantile(temp',1,.95)
		mata c75[`i',`j']= mm_quantile(temp',1,.975)
		mata c25[`i',`j']= mm_quantile(temp',1,.025)
	}
}

*Sanity Check: c75-c25 should be a matrix of roughly 2's if T ratio approximately normal 
mata c75-c25

*upper and lower bands
mata ub=J(9,9,0)
mata lb=J(9,9,0)

forvalues i=1/9{
	forvalues j=1/9{
		mata ub[`i',`j']= wdiff[`i',`j']+criticalvalue[`i',`j']*sqrt(ssquaredhat[`i',`j'])
		mata lb[`i',`j']= wdiff[`i',`j']-criticalvalue[`i',`j']*sqrt(ssquaredhat[`i',`j'])
	}
}


*stars
mata stars = (ub :<0 :& lb :<0) :| (ub :>0 :& lb :>0)
mata stars



