# Replication File for: "Estimating Jointly Determined Outcomes: HowMinimum Wage Affects Wages and Hours Worked"

## Data Cleaning 

1.	Download raw CPS data from https://data.nber.org/morg/annual/
2.	Get CPI from https://www.minneapolisfed.org/about-us/monetary-policy/inflation-calculator/consumer-price-index-1913-
3.	Obtain minimum wage by state data from Vaghul and Zipprer (2016), which is available at https://github.com/benzipperer/historicalminwage/releases.
4.	Run clean_morg_microdata.do forvalues i=79/99 and then forvalues i=00/19. This program is a modified version of the clearner used by Autor et. al (2006).


## Descriptive Statistics 

1.	Run fig-1.do to get minimum wage over time figure, percent of workers below minimum wage over time figure, and minimum wage changes in each state figures. 
2.	Run fig-2.do to get wages and hours worked over time figures.
3.	Run MWmap.do to get minimum wage maps of the US. 

## Simulation 

1. Run Simulation.do to get tables and figures in Appendix A.1 Simulation. 

## Counterfactual Joint Distributions

1. Run Data_Preparation.do to obtain data.dta used for estimating the counterfactual joint distribution of hours and wages in 1992 had it the minimum wage compostion of 1989.
2. Run counterfactual.do
3. Run confidencebands.do
4. Repeat steps 1-3 with the years 1984 and 1989, and the years 2006 and 2012 for those counterfacutual distribution effects. 

## Robustness Checks

1.

## Selection 

1.
