*Simulation

global results "/Users/yisroelcahn/Documents/GitHub/JointlyDeterminedOutcomes/Results/"
global tables "/Users/yisroelcahn/Documents/GitHub/JointlyDeterminedOutcomes/Tables/"
global figures "/Users/yisroelcahn/Documents/GitHub/JointlyDeterminedOutcomes/Figures/"
set more off

**simple case
set obs 3000
set seed 12345

gen x0 = rnormal(10,3)
  
gen instrument0 = rnormal(2,12)

gen weight0 = 1

gen y0_1 = x0 + rnormal(0,4)
gen y0_2 = x0 + instrument0 + rnormal(0,4)


*note: y0_1~N(10,5)
*	   y0_2~N(12,13)

*group
gen all=1


***distribution regressions

*functions for estimation

*Mata, logistic distribution
cap mata mata drop logisticcdf()
mata real colvector logisticcdf(real colvector x) return(1:/(1:+exp(-x)))

*Mata, birary regression
cap mata mata drop binary_reg()
mata colvector binary_reg(string scalar touse, real colvector yt, string scalar reg, string scalar weight, string scalar method,idx){
	st_store(.,idx,touse,yt)
	if(method=="logit") stata("logit "+idx+" "+reg+" [pweight="+weight+"] if "+touse+"==1, asis iterate(100)",1)
	temp=st_matrix("e(b)")'
	return(temp)
}

*Mata, fitted probability
cap mata mata drop fitted_prob()
mata colvector fitted_prob(real matrix xt, real colvector coef, string scalar method){
	if(method=="logit") temp=logisticcdf(xt*coef)
	return(temp)
}


cap mata mata drop counterfactual()
mata numeric matrix counterfactual(real colvector ys, string scalar B){
 

reg="x0"
wei="weight0"
dep="y0_1"
y0=st_data(.,dep,"all")
z0=st_data(.,reg,"all")
/* add constant */
z0=(z0,J(rows(z0),1,1))
w0=st_data(.,wei,"all")
ys=mm_quantile(y0,w0,(1..99)/100)'
nys=rows(ys)
temp=st_addvar("byte", idx=st_tempname())


coef1=J(cols(z0),nys,0)
i=1
while(i<=nys){
if (i>1 & ys[i]==ys[max(1\(i-1))]) coef1[.,i]=coef1[.,i-1]
else coef1[.,i]=binary_reg("all", y0:<=ys[i], reg, wei, "logit", idx)
i=i+1
}


pred=J(0,1,0)
i=1
while(i<=nys){
if (i>1 & ys[i]==ys[max(1\(i-1))]) pred=pred\pred[i-1]
else{
temp=fitted_prob(z0 ,coef1[.,i],"logit")
pred=pred\mean(temp, w0)
}
i=i+1
}


Fwage=pred
qdrwage=mm_quantile(ys,pred-(0\pred[1..(rows(pred)-1)]),((1..99)/100)/max(pred))'

/*****for y0_2 */
reg="x0 instrument0"
wei="weight0"
dep="y0_2"
y0=st_data(.,dep,"all")
z0=st_data(.,reg,"all")
/*add constant */
z0=(z0,J(rows(z0),1,1))
w0=st_data(.,wei,"all")
ys=mm_quantile(y0,w0,(1..99)/100)'
nys=rows(ys)
temp=st_addvar("byte", idx=st_tempname())


coef1=J(cols(z0),nys,0)
i=1
while(i<=nys){
if (i>1 & ys[i]==ys[max(1\(i-1))]) coef1[.,i]=coef1[.,i-1]
else coef1[.,i]=binary_reg("all", y0:<=ys[i], reg, wei, "logit", idx)
i=i+1
}


pred2=J(0,1,0)
i=1
while(i<=nys){
if (i>1 & ys[i]==ys[max(1\(i-1))]) pred2=pred2\pred2[i-1]
else{
temp=fitted_prob(z0 ,coef1[.,i],"logit")
pred2=pred2\mean(temp, w0)
}
i=i+1
}

Fhour=pred2
qdrhour=mm_quantile(ys,pred2-(0\pred2[1..(rows(pred2)-1)]),((1..99)/100)/max(pred2))'

/*save matrices */
st_matrix("qdrhour", qdrhour)
st_matrix("qdrwage", qdrwage)


/*make joint though empirical copula */
y0_1=st_data(.,"y0_1")
y0_2=st_data(.,"y0_2")
weight0=st_data(.,"weight0")
wages=y0_1
hours=y0_2
weights=wieght0

nwages=rows(wages)
nhours=rows(hours)

if (B=="Yes"){
	fh=fopen("${results}sim_boot/qwages","r")
	qwages=fgetmatrix(fh)
	fclose(fh)
	fh=fopen("${results}sim_boot/qhours","r")
	qhours=fgetmatrix(fh)
	fclose(fh)
	fh=fopen("${results}sim_boot/pwages","r")
	pwages=fgetmatrix(fh)
	fclose(fh)
	fh=fopen("${results}sim_boot/phours","r")
	phours=fgetmatrix(fh)
	fclose(fh)
}
else{
	qwages=mm_quantile(y0_1,weight0,(1..99)/100)'
	qhours=mm_quantile(y0_2,weight0,(1..99)/100)'
	pwages= mm_quantile(wages,weight0,(.1,.2,.3,.4,.5,.6,.7,.8,.9))'
	phours= mm_quantile(hours,weight0,(.1,.2,.3,.4,.5,.6,.7,.8,.9))'
	fh=fopen("${results}sim_boot/qwages","a")
	fputmatrix(fh,qwages)
	fclose(fh)
	fh=fopen("${results}sim_boot/qhours","a")
	fputmatrix(fh,qhours)
	fclose(fh)
	fh=fopen("${results}sim_boot/pwages","a")
	fputmatrix(fh,pwages)
	fclose(fh)
	fh=fopen("${results}sim_boot/phours","a")
	fputmatrix(fh,phours)
	fclose(fh)
}


nqwages=rows(qwages)
nqhours=rows(qhours)


utilda = J(nwages,2,0) 

utilda[.,1]=mm_ecdf(wages,weight0)
utilda[.,2]=mm_ecdf(hours,weight0)



copula=J(nqwages, nqhours,0)
/*make u1 and u2 vectors 0 to 1 */
u1= J(nqwages,1,0)
u2= J(nqwages,1,0)
i=1
temp=(nqwages+1)^(-1)
while(i<=nqwages){
	u1[i,1]=temp
	u2[i,1]=temp
	temp=temp + (nqwages+1)^(-1)
	i=i+1
}


i=1
while(i<=nqwages){
	j=1
	while(j<=nqhours){
		copula[i,j]= mean(((utilda[.,1]:<=u1[i,1]) :+ (utilda[.,2]:<=u2[j,1])):>=2)	
		j=j+1
	}
	i=i+1
}


Joint=J(nqwages, nqhours,0)


j=1
while(j<=nqwages){
	k=1
	while(k<=nqhours){
		temp_j=round(mm_relrank(qwages,1, qdrwage[j,1])*100)
		temp_k=round(mm_relrank(qhours,1, qdrhour[k,1])*100)
		if (temp_j==0){
			temp_j=1
		}
		if (temp_k==0){
			temp_k=1
		}
		if (temp_j==nqwages+1){
			temp_j=nqwages
		}
		if (temp_k==nqhours+1){
			temp_k=nqhours
		}
		Joint[j,k]=copula[temp_j,temp_k] 
		k=k+1
	}
	j=j+1
}



pJoint=J(9,9,0)


j=1
while(j<=9){
	k=1
	while(k<=9){
		pJoint[j,k]=Joint[round(j*nqwages*.1),round(k*nqwages*.1)]
		k=k+1
	}
j=j+1	
}
	


cdf = J(nqwages,nqhours,0)



j=1
while(j<=nqwages){
	k=1
	while(k<=nqhours){
		cdf[j,k]= mean(((y0_1:<=qwages[j,1]) :+ (y0_2:<=qhours[k,1])):>=2)
		k=k+1
	}
	j=j+1
}



pcdf=J(9,9,0)

j=1
while(j<=9){
	k=1
	while(k<=9){
		pcdf[j,k]=cdf[round(j*nqwages*.1),round(k*nqwages*.1)]
		k=k+1
	}
	j=j+1
}


diff=pcdf-pJoint

return(diff)
}

**********************************************


mata diff=counterfactual(ev=., "No")
mata fh=fopen("${results}sim_boot/diff","a")
mata fputmatrix(fh,diff)
mata fclose(fh)


**********************************************
***Bootstrap

*50 bootstrap samples (can change)
preserve
forvalues i=1/50{
	set seed `i'
	bsample 
	mata temp=counterfactual(ev=., "Yes")
	mata fh=fopen("${results}sim_boot/boot`i'","a")
	mata fputmatrix(fh,temp)
	mata fclose(fh)
	dis `i'
	restore, preserve
}



***confidence bands
*get bootstraps
forvalues i=1/50{
	mata fh=fopen("${results}sim_boot/boot`i'","r")
	mata boot`i'=fgetmatrix(fh)
	mata fclose(fh)
}


*get an estimate for s^2(y_1,y_2)
mata ssquaredhat=J(9,9,0)

forvalues i=1/9{
	forvalues j=1/9{
		mata temp=J(1,50,0) 
		forvalues k=1/50{
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
		mata temp=J(1,50,0) 
		forvalues k=1/50{
			mata temp[1,`k']= abs(boot`k'[`i',`j']-diff[`i',`j'])/sqrt(ssquaredhat[`i',`j'])
		}
		mata criticalvalue[`i',`j']= mm_quantile(temp',1,.95)
		mata c75[`i',`j']= mm_quantile(temp',1,.975)
		mata c25[`i',`j']= mm_quantile(temp',1,.025)
	}
}

*Sanity Check: c75-c25 should be a matrix of roughly 2's if T ratio approximately normal 
mata twos=c75-c25
mata twos

*upper and lower bands
mata ub=J(9,9,0)
mata lb=J(9,9,0)

forvalues i=1/9{
	forvalues j=1/9{
		mata ub[`i',`j']= diff[`i',`j']+criticalvalue[`i',`j']*sqrt(ssquaredhat[`i',`j'])
		mata lb[`i',`j']= diff[`i',`j']-criticalvalue[`i',`j']*sqrt(ssquaredhat[`i',`j'])
	}
}

mata stars = (ub :<0 :& lb :<0) :| (ub :>0 :& lb :>0)

mata stars




*get pcdf's (i.e. grid of y values used)
mata fh=fopen("${results}sim_boot/phours","r")
mata pcdf1=fgetmatrix(fh)
mata fclose(fh)
mata fh=fopen("${results}sim_boot/pwages","r")
mata pcdf2=fgetmatrix(fh)
mata fclose(fh)

*put into excel
mata st_matrix("diff", diff)
mata st_matrix("pcdf1", pcdf1)
mata st_matrix("pcdf2", pcdf2)

mata st_matrix("twos", twos)

putexcel (B2) = matrix(diff) using "${tables}sim.xlsx", modify
putexcel (A2) = matrix(pcdf2) using "${tables}sim.xlsx", modify
putexcel (B1) = matrix(pcdf1') using "${tables}sim.xlsx", modify

putexcel (B2) = matrix(twos) using "${tables}twos.xlsx", modify
putexcel (A2) = matrix(pcdf2) using "${tables}twos.xlsx", modify
putexcel (B1) = matrix(pcdf1') using "${tables}twos.xlsx", modify

****

svmat qdrwage
svmat qdrhour
hist qdrhour, normal 
graph export "${figures}sim1.pdf", replace
hist qdrwage, normal
graph export "${figures}sim1.pdf", replace




