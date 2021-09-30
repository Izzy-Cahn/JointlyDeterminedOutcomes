# Replication File for: "Estimating Jointly Determined Outcomes: HowMinimum Wage Affects Wages and Hours Worked"

## Data Cleaning 

1.	Download raw CPS data from https://data.nber.org/morg/annual/
2.	Get CPI from https://www.minneapolisfed.org/about-us/monetary-policy/inflation-calculator/consumer-price-index-1913-
3.	Obtain minimum wage by state data from Vaghul and Zipprer (2016), which is available at https://github.com/benzipperer/historicalminwage/releases.
4.	Run clean_morg_microdata.do forvalues i=79/99 and then forvalues i=00/19. This program is a modified version of the clearner used by Autor et. al (2006).


## Descriptive Statistics 

1.	Run fig-1.do to get minimum wage over time figure, percent of workers below minimum wage over time figure, and minimum wage changes in each state figures. 
2.	Run fig-2.do to get wages and hours worked over time figures.

## Simulation 

## Counterfactual Joint Distributions

## Fixed Effects Model

## Other Robustness Checks

## Selection 

