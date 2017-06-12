/* 	Chad R. Bhatti
	02.13.2015
	metric_variable_selection.sas
*/

/*
We will use the phrase 'metric variable selection' to refer to the variable selection
methods for PROC REG that use standard linear regression metrics, that are mostly specific
to linear regression.  For example R-Squared, Adjusted R-Squared, and Mallow's Cp are
specific to linear regression and not defined for other linear models.  Metrics like
AIC and BIC are general metrics, when defined generally with respect to the likelihood 
function, that can be used for variable selection, but SAS does not allow them as options 
for PROC REG.  However, SAS does allow AIC and BIC to be computed as output statistics.

See the following web page for details on options for the model statement for PROC REG.

http://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_reg_sect013.htm

See the following web page for details on variable selection for PROC REG.

http://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_reg_sect030.htm

*/


*libname mydata	'/courses/d6fc9ae5ba27fe300/c_3505/SAS_Data/' access=readonly;
libname mydata 	'/scs/crb519/PREDICT_410/SAS_Data/' access=readonly;


/*
Regression Analysis By Example, 5th Edition ISBN 9780470905845 - p. 328-329
http://www1.aucegypt.edu/faculty/hadi/RABE5/#Download

Property Valuation:  The objective of scientific mass appraisal 
(or Automated Valuation Models) is to predict the sale price of a 
home based on selected physical attributes of the property. 

Y:  sale price of house in thousands of dollars
X1: taxes in thousands of dollars
X2: number of bathrooms
X3: lot size in thousands of square feet
X4: living space in thousands of square feet
X5: number of garage stalls
X6: number of rooms
X7: number of bedrooms
X8: age of home in years
X9: number of fireplaces 

*/


/*
proc contents data=mydata.building_prices; run; quit;
proc print data=mydata.building_prices(obs=5); run; quit;
*/

data temp;
	set mydata.building_prices;
run;


*******************************************************************************;
* Selection using the Rsquare method;
*******************************************************************************;
proc reg data=temp;
model y = x1-x9 / selection=rsquare start=1 stop=1;
run;

* Note that we have specified the START and STOP parameters to control the model
* size.  In this example we are searching for the simple linear regression model
* with the highest R-Squared value;

* Be sure to read this page to understand how the metric based variable selection
* methods work;
/*
http://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_reg_sect030.htm
*/


proc reg data=temp;
model y = x1-x9 / selection=rsquare start=2 stop=4;
run;
* Lots of output.  Let's use the BEST option;


proc reg data=temp;
model y = x1-x9 / selection=rsquare start=2 stop=4 best=2;
run;
* The BEST option allows us to increase the search space in an orderly fashion;


*******************************************************************************;
* Maximum R-Squared Improvement Selection;
*******************************************************************************;
proc reg data=temp;
model y = x1-x9 / selection=maxr;
run;


* How does MAXR differ from RSQUARE?;

* MAXR finds the best one variable model, then the best two variable model
* given the predictor from step 1 such that the second predictor is the predictor
* that increases the R-Squared value the most given the predictor from step 1,
* and so forth;
* This is an iterative or greedy method similar to forward variable selection;
* Use the same mindset that you would use in forward variable selection;


* Note that this variable selection method is not guaranteed to find the model
* with the largest R-Squared value for each size. (That would be SELECTION=RSQUARE.);



*******************************************************************************;
* Adjusted R-Squared Selection;
*******************************************************************************;
proc reg data=temp;
model y = x1-x9 / selection=adjrsq;
run;

* The metric based options spit out a lot of output;
* Always use the best option with a metric variable selection method;

proc reg data=temp;
model y = x1-x9 / selection=adjrsq best=10;
run;


*******************************************************************************;
* Mallow's Cp Selection;
*******************************************************************************;
proc reg data=temp;
model y = x1-x9 / selection=cp best=4;
run;


*******************************************************************************;
* Include Option for Variable Selection;
*******************************************************************************;
proc reg data=temp;
model y = x1-x3 x4-x9 / selection=maxr include=3;
run;

* Include the first three variables using the include option;
* Note that the forced inclusion variables are marked with a *;


*******************************************************************************;
* Outputting Cp, AIC, and BIC for model comparison;
*******************************************************************************;
* After we identify our candidate models using automated variable selection
* techniques, we should re-run PROC REG to get the final output that we want for
* our reports;

proc reg data=temp;
model y = x1-x5 / aic bic cp vif;
run;

* Notice that we can't get SAS to output the AIC, BIC, and CP statistics;
* We need to trick SAS to output what we want;
* Unfortunately SAS will only output these statistics in conjunction with
* some variable selection methods.  Here is how we trick SAS;


proc reg data=temp;
model y = x1-x5 / selection=rsquare start=5 stop=5 aic bic cp vif;
run;



*******************************************************************************;
*******************************************************************************;





