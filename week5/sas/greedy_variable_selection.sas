/* 	Chad R. Bhatti
	02.06.2015
	greedy_variable_selection.sas
*/

/*
We will use the term 'greedy variable selection' to refer to the 'traditional' statistical methods
of variable selection - forward, backward, and stepwise variable selection.

Do we know what 'greedy' means?  Search 'greedy algorithm'.  In general we are talking about an
algorithm that makes a 'local' decision to reach a 'global'decision.  In our case these algorithms
consider one variable at a time (a local decision) to reach an 'optimal' or 'best' model (a global
decision).

Forward, backward, and stepwise variable selection algorithms are general enough to be implemented
in any type of generalized linear model.  However, the decision criterion for these algorithms will
be different depending on the type of linear model (e.g. linear regression versus logistic regression) 
and the software implementation.  For example SAS implements these algorithms using a nested F-test
while R implements these algorithms using the AIC criterion (see stepAIC() for R details).

In this example we want to learn and understand how SAS implements these methods with PROC REG.
Note that SAS has a different (but analogous) implementation of these methods for PROC LOGISTIC.

See the following web page for details on options for the model statement for PROC REG.

http://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_reg_sect013.htm

*/


libname mydata	'/courses/d6fc9ae5ba27fe300/c_3505/SAS_Data/' access=readonly;


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
proc print data=mydata.building_prices; run; quit;
*/


data temp;
	set mydata.building_prices;
run;



* The three most common selection methods are forward, backward, and stepwise;

/*
The key to using these methods correctly is to understand the default settings
for the two algorithm parameters SLENTRY and SLSTAY.  The SAS default values
for these two parameters do not make much sense.
*/


*******************************************************************************;
* Selection using the forward method;
*******************************************************************************;
proc reg data=temp;
model y = x1-x9 / selection=forward slentry=0.5;
run;

* Note that if we name our variables x1 through xN, then SAS will allow us to 
* use a short-hand notation for referencing all of our variables;
* If we do not use this type of naming convention, then we would have to type
* each variable into the model statement by its name;  


* Default value for SLENTRY is 0.50.  This is the p-value of the F statistic;
* Having a default SLENTRY value of 0.5 makes very little sense;
* Note that forward selection is will fit "larger" models due to the default 
* entry criteria;
* You will need to set this parameter value to a more reasonable value like 0.1;


proc reg data=temp;
model y = x1-x9 / selection=forward slentry=0.15;
run;


*******************************************************************************;
* Selection using the backward method;
*******************************************************************************;
proc reg data=temp;
model y = x1-x9 / selection=backward slstay=0.1;
run;

* Default value for SLSTAY is 0.10.  This is the p-value of the F statistic;
* This is a reasonable value for SLSTAY;

proc reg data=temp;
model y = x1-x9 / selection=backward slstay=0.11;
run;


*******************************************************************************;
* Selection using the stepwise method;
*******************************************************************************;
* Stepwise variable selection is a contentious topic in the statistical community;
* It is perfectly fine to use stepwise variable selection as a heuristic technique
* for computational exploratory data analysis;

proc reg data=temp;
model y = x1-x9 / selection=stepwise slentry=0.15 slstay=0.15;
run;

* Default values are 0.15 for both slentry and slstay;
* These are reasonable values for SLENTRY and SLSTAY, but they are completely
* different from the corresponding default values for forward and backward
* selection.  There is no logical reason for SAS to have all of these values 
* set so differently.  You may wish to set these both to 0.1;


proc reg data=temp;
model y = x1-x9 / selection=stepwise slentry=0.4 slstay=0.4;
run;



*******************************************************************************;
* Include Option for Variable Selection;
*******************************************************************************;
* At times we might want to ensure that we have included a particular set of 
* variables into the model, and then search over the remaining variables to try
* to further improve the model.  We can do that in SAS using the include option;

proc reg data=temp;
model y = x1-x9 / selection=backward slstay=0.1 include=3;
run;
* Include the first three variables listed in the model statement using 
* the include option;


* Here is a more explicit representation of what we are doing with the include option;
* Here we will include x1-x3 and search x4-x9;
proc reg data=temp;
model y = x1-x3 x4-x9 / selection=backward slstay=0.1 include=3;
run;



*******************************************************************************;
*******************************************************************************;

