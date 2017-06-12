/*	Chad R. Bhatti
	03.25.2015
	waterfall_example.sas
*/


* Dr. Bhatti's Predict 410 data warehouse;
libname mydata	'/courses/d6fc9ae5ba27fe300/c_3505/SAS_Data/' access=readonly;


* List out the column names and data types for the data set;
proc contents data=mydata.ames_housing_data; run; quit;

* Print out the first 10 observations on the data set;
proc print data=mydata.ames_housing_data(obs=10); run; quit;


* Let's make up some drop conditions;
* Note that these are not intended to be realistic or meaningful drop conditions;
data temp;
	set mydata.ames_housing_data;
	format drop_condition $30.;
	if (street ne 'Pave') then drop_condition='01: Street not Paved';
	else if (YearBuilt < 1950) then drop_condition='02: Built Pre-1950';
	else if (TotalBsmtSF < 1) then drop_condition='03: No Basement';
	else if (GrLivArea < 800) then drop_condition='04: LT 800 SQFT';
	else drop_condition='05: Sample Population';
run;


proc freq data=temp;
tables drop_condition;
title 'Sample Waterfall';
run; quit;


