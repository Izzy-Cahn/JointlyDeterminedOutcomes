*counterfactual accounting for selection 

**********preamble***************
*Change the folders
* The folder $data must contain the file "data.dta".
* the results will be saved in the folder $ results.
global data "/Users/yisroelcahn/Documents/GitHub/JointlyDeterminedOutcomes/Data/Selection Cleaned Data/"
global results "/Users/yisroelcahn/Documents/GitHub/JointlyDeterminedOutcomes/Results/Selection/"
set more off

use "${data}data.dta", clear



***functions for estimation

*Mata, logistic distribution
cap mata mata drop logisticcdf()
mata real colvector logisticcdf(real colvector x) return(1:/(1:+exp(-x)))

*Mata, birary regression
cap mata mata drop binary_reg()
mata colvector binary_reg(string scalar touse, real colvector yt, string scalar reg, string scalar weight, string scalar method,idx){
	/*store yt in idx */
	st_store(.,idx,touse,yt)
	if(method=="logit") stata("logit "+idx+" "+reg+" [pweight="+weight+"] if "+touse+"==1, asis iterate(100)",1)
	if(method=="probit") stata("probit "+idx+" "+reg+" [pweight="+weight+"] if "+touse+"==1, asis iterate(100)",1) 
	temp=st_matrix("e(b)")'
	return(temp)
}

*Mata, birary regression with selection
cap mata mata drop binary_reg_selection()
mata colvector binary_reg_selection(string scalar touse, real colvector yt, string scalar firstreg, string scalar secondreg, string scalar weight,idx){
	/*store yt in idx */
	st_store(.,idx,touse,yt)
	stata("heckprobit "+idx+" "+firstreg+" [pweight="+weight+"] if "+touse+"==1, select( lfp ="+secondreg+")  iterate(100)",1) 
	temp1=st_matrix("e(b)")'
	/* replace 114 with number of variables in firstreg+1*/
	temp1=temp1[1..114,1]
	return(temp1)
}

*Mata, fitted probability for bivariate normal 
cap mata mata drop binormal_prob()
mata colvector binormal_prob(real matrix x1, real matrix x2, real colvector coef){
	firstcoef= coef[1..rows(x1),1]
	secondcoef= coef[rows(x1)+1..rows(x2),1]
	athrho= coef[rows(x2)+1,1]
	rho=tanh(athrho)
	temp=binormal(x1*firstcoef,x2*secondcoef,rho)
	return(temp)
}


*Mata, fitted probability
cap mata mata drop fitted_prob()
mata colvector fitted_prob(real matrix xt, real colvector coef, string scalar method){
	if(method=="logit") temp=logisticcdf(xt*coef)
	if(method=="probit") temp=normal(xt*coef)
	return(temp)
}


*********************************

***for testing, delete
*group0="select10"
*group1="select20"
*method="logit"
*B="No"
*gender="men"
***

*function that creates and saves the joint counterfactual distributions
cap mata mata drop counterfactual()
mata numeric matrix counterfactual(string scalar group0, string scalar group1, string scalar method, real colvector ys,string scalar B, string scalar gender)
{

/*define variables */

reg="minwage married union smsa partt nonwhite grade1to4 grade5to6 grade7to8 grade9 grade10 grade11 highschool somecollege college egrade1to4 egrade5to6 egrade7to8 egrade9 egrade10 egrade11 ehighschool esomecollege ecollege exper exper2 exper3 exper4 oc2-oc45 ind2-ind47"
reg1="married union smsa partt nonwhite grade1to4 grade5to6 grade7to8 grade9 grade10 grade11 highschool somecollege college egrade1to4 egrade5to6 egrade7to8 egrade9 egrade10 egrade11 ehighschool esomecollege ecollege exper exper2 exper3 exper4 oc2-oc45 ind2-ind47"

/*covairates for lfp */
reg2="ch05 married union smsa nonwhite grade5to6 grade7to8 grade9 grade10 grade11 highschool college egrade5to6 egrade7to8 egrade9 egrade10 egrade11 ehighschool ecollege exper exper2 exper3 exper4 oc2-oc45 ind2-ind47"

wei="eweight"
dep="wage"
y0=st_data(.,dep, group0)
y1=st_data(.,dep, group1)
z0=st_data(.,reg,group0)
/*add constant */
z0=(z0,J(rows(z0),1,1))
z1=st_data(.,reg, group1)
/*add constant */
z1=(z1,J(rows(z1),1,1))
w0=st_data(.,wei,group0)
w1=st_data(.,wei, group1)
/*stack y0 and y1 and get quantiles (this is just to make a grid of 1 to 99 y's for the distribution regression) */
ys=mm_quantile((y0\y1),(w0\w1),(1..99)/100)'
nys=rows(ys)
temp=st_addvar("byte", idx=st_tempname())

/***Steps for estimating counterfactual distribution
*1 estimate F_{c_1}(c) by empirical CDF
*2 estimate F_{m_0|c_0}(m|c) by logit regression (or probit)
*3 estimate F_{y_1|m_1,c_1}(y) by distirbution regression
*4 obtain counterfactual by summing over 1*d2*d3 (the summing should be over wave 1 characteristics)
*5 do this for hours with number of children in regressors as instrument
*6 use empirical copula to get joint distribution

***note that we will do steps 1 through 4 in the following way:
* estimate F_{m_0|c_0}(m|c) by logit regression
* estimate plug in c_1 in the above step and get \hat{P}_{m_0|c_0}(1|c_1)
* note that F_{(1|0,1)}=int_{C_1} int_{M_1} F_{y_1|m_1,c_1} d F_{m_0|c_0} (m|c) d F_{c_1}(c)
*                      = E[F_{y_1|m_1,c_1}]
*                      = F_{y_1|m_1,c_1}(1) * weight * P_{m_0|c_0}(1|c_1) + F_{y_1|m_1,c_1}(0) * weight * (1-P_{m_0|c_0}(1|c_1))
* so plug in estimates for F_{y_1|m_1,c_1}(y) and P_{m_0|c_0}(1|c_1)) in the line about to obtain the counterfactual 
*/


/****step 2 */

/* note: z0[.,1] is minwage, reg1 is all control variables except minwage */
temp=binary_reg(group0, z0[.,1], reg1, wei, method, idx)


/* jumping to part of step 4 (i.e. F_{m_0|c_0}(1|c_1)) */
mwdist=fitted_prob(z1[.,2..cols(z1)],temp,method) 



/* ***step 3 */

coef1=J(cols(z1),nys,0)
i=1
while(i<=nys){
		if (i>1 & ys[i]==ys[max(1\(i-1))]) coef1[.,i]=coef1[.,i-1]
		else coef1[.,i]=binary_reg_selection(group1, y1:<=ys[i], reg, reg2, wei, idx)
		i=i+1
	}


/****step 4 

*Note that F_{(1|0,1)}=int_{C_1} int_{M_1} F_{y_1|m_1,c_1} d F_{m_0|c_0} (m|c) d F_{c_1}(c)
*                     = E[F_{y_1|m_1,c_1}]
*                     = F_{y_1|m_1,c_1}(1) * w1 * F_{m_0|c_0}(1|c_1) + F_{y_1|m_1,c_1}(0) * w1 * (1-F_{m_0|c_0}(1|c_1))
*/

/*create a vector of length 2*length(z1) of zeros and ones */
z1c=z1\z1
z1c[1..rows(z1),1]=J(rows(z1),1,0)
z1c[(rows(z1)+1)..rows(z1c),1]=J(rows(z1),1,1)
/*make weighting vector of w1 * F_{m_0|c_0}(1|c_1) when y=1 and w1 * (1-F_{m_0|c_0}(1|c_1) when y=0 */
w1c=(w1:*(1:-mwdist))\(w1:*mwdist)

pred=J(0,1,0)
i=1
while(i<=nys){
	if (i>1 & ys[i]==ys[max(1\(i-1))]) pred=pred\pred[i-1]
	else{
		temp=fitted_prob(z1c,coef1[.,i], method)
		pred=pred\mean(temp,w1c)
	}
	i=i+1
}


qcounterwage=mm_quantile(ys,pred-(0\pred[1..(rows(pred)-1)]),((1..99)/100)/max(pred))'



/*****step 5 (marginal for hours) */

/*reg and reg1 include ch05 
*note that partt, esomecollege, somecollege, egrade1to4, and grade1to4 were ommited because of multicollinearity */
reg="minwage ch05 married union smsa nonwhite grade5to6 grade7to8 grade9 grade10 grade11 highschool college egrade5to6 egrade7to8 egrade9 egrade10 egrade11 ehighschool ecollege exper exper2 exper3 exper4 oc2-oc45 ind2-ind47"
reg1="ch05 married union smsa nonwhite grade5to6 grade7to8 grade9 grade10 grade11 highschool college egrade5to6 egrade7to8 egrade9 egrade10 egrade11 ehighschool ecollege exper exper2 exper3 exper4 oc2-oc45 ind2-ind47"
wei="eweight"
dep="uhours"
y0=st_data(.,dep, group0)
y1=st_data(.,dep,group1)
z0=st_data(.,reg, group0)
z0=(z0,J(rows(z0),1,1))
z1=st_data(.,reg,group1)
z1=(z1,J(rows(z1),1,1))
w0=st_data(.,wei, group0)
w1=st_data(.,wei,group1)
ys=mm_quantile((y0\y1),(w0\w1),(1..99)/100)'
nys=rows(ys)
temp=st_addvar("byte", idx=st_tempname())


temp=binary_reg(group0, z0[.,1], reg1, wei, method, idx)
mwdist=fitted_prob(z1[.,2..cols(z1)],temp,method)

coef1=J(cols(z1),nys,0)
i=1
while(i<=nys){
		if (i>1 & ys[i]==ys[max(1\(i-1))]) coef1[.,i]=coef1[.,i-1]
		else coef1[.,i]=binary_reg_selection(group1, y1:<=ys[i], reg, reg2, wei, idx)
		i=i+1
	}

	
z1c=z1\z1
z1c[1..rows(z1),1]=J(rows(z1),1,0)
z1c[(rows(z1)+1)..rows(z1c),1]=J(rows(z1),1,1)
w1c=(w1:*(1:-mwdist))\(w1:*mwdist)

predhours=J(0,1,0)
i=1
while(i<=nys){
	if (i>1 & ys[i]==ys[max(1\(i-1))]) predhours=predhours\predhours[i-1]
	else{
		temp=fitted_prob(z1c,coef1[.,i], method)
		predhours=predhours\mean(temp,w1c)
	}
	i=i+1
}


qcounterhours=mm_quantile(ys,predhours-(0\predhours[1..(rows(predhours)-1)]),((1..99)/100)/max(predhours))'


/******step 6
*(i) we have observations (Y_1^i,Y_2^i) of wages and hours for i=1,...n at t=1
*(ii) estiated CDFs of Y_1 and Y_2, \hat{F_1} and \hat{F_2} with empirical cdfs
*(iii) calculate sample of draws from uniform(0,1) with dependence structure: (\tilda{u_1}^i,\tilda{u_2}^i) = (\hat{F_1}(Y_1^i) , \hat{F_1}(Y_2^i))
*(iv) the empirical copula is: \hat{C}(u_1,u_2)= 1/n \sum_{i=1}^n 1{\tilda{u_1}^i<=u_1,\tilda{u_2}^i<=u_2}
*(v) finally, obtain the estimated the counterfactual joint distribution of Y_1 and Y_2 as \hat{Fcounterfactual}(Y_1,Y_2)= \hat{C}(\hat{F_1counterfactual}(Y_1),\hat{F_2counterfactual}(Y_2))
*/

/*(i) */
wei="eweight"

wages=st_data(.,"wage",group1)
hours=st_data(.,"uhours",group1)
weights=st_data(.,wei,group1)

nwages=rows(wages)
nhours=rows(hours)

/*************************
*big condition statement*
*************************
*make qwages, qhours, pwages, and phours and use the same ones for the bootstrap draws
*different qwages, qhours, pwages, and phours for men and women
*/

if (gender=="men"){
	if (B=="Yes"){
		fh=fopen("${results}89-92/qwages","r")
		qwages=fgetmatrix(fh)
		fclose(fh)
		fh=fopen("${results}89-92/qhours","r")
		qhours=fgetmatrix(fh)
		fclose(fh)
	}
	else{
		qwages=mm_quantile(wages,weights,(1..99)/100)'
		qhours=mm_quantile(hours,weights,(1..99)/100)'
		pwages= mm_quantile(wages,weights,(.1,.2,.3,.4,.5,.6,.7,.8,.9))'
		phours= mm_quantile(hours,weights,(.1,.2,.3,.4,.5,.6,.7,.8,.9))'
		fh=fopen("${results}89-92/qwages","a")
		fputmatrix(fh,qwages)
		fclose(fh)
		fh=fopen("${results}89-92/qhours","a")
		fputmatrix(fh,qhours)
		fclose(fh)
		fh=fopen("${results}89-92/pwages","a")
		fputmatrix(fh,pwages)
		fclose(fh)
		fh=fopen("${results}89-92/phours","a")
		fputmatrix(fh,phours)
		fclose(fh)
	}
}
if (gender=="women"){
	if (B=="Yes"){
		fh=fopen("${results}w89-92/qwages","r")
		qwages=fgetmatrix(fh)
		fclose(fh)
		fh=fopen("${results}w89-92/qhours","r")
		qhours=fgetmatrix(fh)
		fclose(fh)
	}
	else{
		qwages=mm_quantile(wages,weights,(1..99)/100)'
		qhours=mm_quantile(hours,weights,(1..99)/100)'
		pwages= mm_quantile(wages,weights,(.1,.2,.3,.4,.5,.6,.7,.8,.9))'
		phours= mm_quantile(hours,weights,(.1,.2,.3,.4,.5,.6,.7,.8,.9))'
		fh=fopen("${results}w89-92/qwages","a")
		fputmatrix(fh,qwages)
		fclose(fh)
		fh=fopen("${results}w89-92/qhours","a")
		fputmatrix(fh,qhours)
		fclose(fh)
		fh=fopen("${results}w89-92/pwages","a")
		fputmatrix(fh,pwages)
		fclose(fh)
		fh=fopen("${results}w89-92/phours","a")
		fputmatrix(fh,phours)
		fclose(fh)
	}
}

nqwages=rows(qwages)
nqhours=rows(qhours)


/*(ii) */
utilda = J(nwages,2,0) 

utilda[.,1]=mm_ecdf(wages,weights)
utilda[.,2]=mm_ecdf(hours,weights)



/*(iii) & (iv) */
copula=J(nqwages, nqhours,0)
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

/*(v) */
Joint=J(nqwages, nqhours,0)


j=1
while(j<=nqwages){
	k=1
	while(k<=nqhours){
		temp_j=round(mm_relrank(qwages,1, qcounterwage[j,1])*100)
		temp_k=round(mm_relrank(qhours,1, qcounterhours[k,1])*100)
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

/*rename pJoint */
pF101=pJoint



/*************Estimate CDF of observed distribution in post period */
F111=J(nqwages,nqhours,0)

/*ecdf of hours and wages in the post period */
j=1
while(j<=nqwages){
	k=1
	while(k<=nqhours){
		F111[j,k]= mean(((wages:<=qwages[j,1]) :+ (hours:<=qhours[k,1])):>=2)
		k=k+1
	}
	j=j+1
}



pF111=J(9,9,0)


j=1
while(j<=9){
	k=1
	while(k<=9){
		pF111[j,k]=F111[round(j*nqwages*.1),round(k*nqwages*.1)]
		k=k+1
	}
	j=j+1
}


diff=pF111-pF101

return(diff)
}


*************
*Estimation
*************
**Men
*logistic link function
mata 
diff=counterfactual("select10","select20","logit",ev=.,"N0","men")
/*change when using different years */
fh=fopen("${results}89-92/diff","a")
fputmatrix(fh,diff)
fclose(fh)

end

*Bootstrap (30 but can change)
preserve
forvalues i=1/30{
	global foo `i'
	set seed `i'
	bsample 
	mata temp=counterfactual("select10","select20","logit",ev=.,"Yes","men")
	mata fh=fopen("${results}89-92/boot`i'","a")
	mata fputmatrix(fh,temp)
	mata fclose(fh)
	
	dis `i'
	restore, preserve
}

**probit link function
*mata 
*counterfactual("select10","select20","probit",ev=.,"N0","men")
*end


***Women
**logistic link function

mata 
wdiff=counterfactual("select11","select21","logit",ev=.,"No","women")
fh=fopen("${results}w89-92/wdiff","a")
fputmatrix(fh,wdiff)
fclose(fh)
end

*Bootstrap (30 but can change)
preserve
forvalues i=1/30{
	global foo `i'
	set seed `i'
	bsample 
	mata temp=counterfactual("select11","select21","logit",ev=.,"Yes","women")
	mata fh=fopen("${results}w89-92/w_boot`i'","a")
	mata fputmatrix(fh,temp)
	mata fclose(fh)
	dis `i'
	restore, preserve
}




************NOTE**************
*to get matrix from file:
*fh=fopen("${results}F101","r")
*temp=fgetmatrix(fh)
*fclose(fh)
********END OF NOTE**********









