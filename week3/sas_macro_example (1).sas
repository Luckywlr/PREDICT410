/*	Chad R. Bhatti
	01.19.2015
	sas_macro_example.sas
*/


* Dr. Bhatti's Predict 410 data warehouse;
libname mydata	'/courses/d6fc9ae5ba27fe300/c_3505/SAS_Data/' access=readonly;

proc contents data=mydata.ames_housing_data; run; quit;

****************************************************************************************************;
* Use DataDocumentation.txt to create predictor variables for your regression model;
* Note that the names have been streamlined on the data set;
* It would be smart to have a print out of the proc contents of the data set when 
* reading the data documentation;
*
****************************************************************************************************;
* Three reasons to use the SAS Macro Facility:
*	(1) To write parameterized script files for production
*	(2) To build compact subroutines for routine or frequent tasks
* 	(3) To perform looping in open code, i.e. the difference betweem do loops 
*		and %do loops;
*
****************************************************************************************************;


****************************************************************************************************;
* Let's begin by looking at a specific example;
****************************************************************************************************;

proc means data=mydata.ames_housing_data noprint;
var SalePrice;
output out=mean_summary;
run; quit;

proc print data=mean_summary; run; quit;

* I could write a SAS macro to reduce this code block into a single parameterized 
* SAS macro call;

* Initial macro: myMeans();
%macro myMeans(indata,outdata,myvar);
proc means data=&indata. noprint;
var &myvar.;
output out=&outdata.;
run; quit;
%mend;


* Notice the components of our SAS macro: %macro, %mend, &indata., &myvar., 
* and &outdata.;
* %macro is how you initialize the definition of the macro code and %mend (macro-end)
* is how you finalize the macro code;
* All macro variables need to be referenced by name with a preceeding & and a 
* trailing period;
* Read more about the SAS Macro Facility in The Little SAS Book;
* See Dr. Bhatti's personal web page for additional references for intermediate 
* and advanced SAS macro programming;

* Call myMeans();
* Note that I tend to wrap my arguments in the string function %str();
%myMeans(indata=%str(mydata.ames_housing_data),outdata=%str(SalePrice_Summary),myvar=%str(SalePrice));

proc print data=SalePrice_Summary; run; quit;


* Note the flexibility provided by the macro.  I can use this macro on any data set and summarize any variable;

%myMeans(indata=%str(mydata.ames_housing_data),outdata=%str(SalePrice_Summary),myvar=%str(GrLivArea));
%myMeans(indata=%str(mydata.ames_housing_data),outdata=%str(TotalBsmtSF_Summary),myvar=%str(TotalBsmtSF));
%myMeans(indata=%str(mydata.ames_housing_data),outdata=%str(YearBuilt_Summary),myvar=%str(YearBuilt));



****************************************************************************************************;
* Now let's make our example a bit more complicated;
****************************************************************************************************;
* Here we will modify our PROC MEANS statment to produce a set of quantiles (or percentiles);
* Note that if we want SAS to output these quantiles into our output data set, then we need to 
* include them in our OUTPUT statement with their output names;

%macro quantileMeans(indata,outdata,myvar);
proc means data=&indata. p1 p5 p25 p50 p75 p95 p99 noprint;
var &myvar.;
output out=&outdata. 
	p1(&myvar.)=p01 
	p5(&myvar.)=p05 
	p25(&myvar.)=p25 
	p50(&myvar.)=p50 
	p75(&myvar.)=p75 
	p95(&myvar.)=p95 
	p99(&myvar.)=p99 
;
run; quit;
%mend;

%quantileMeans(indata=%str(mydata.ames_housing_data),outdata=%str(SalePrice_Quantiles),myvar=%str(SalePrice));

proc print data=SalePrice_Quantiles; run; quit;


****************************************************************************************************;
* Now let's further parameterize our %quantileMeans() macro to increase its flexibility;
****************************************************************************************************;
* Here we are going to write a completely flexible macrotized PROC MEANS statement;

options mprint;
%macro qMeans(indata,outdata,myvar,mean_options,class_stm,output_stm);
proc means data=&indata. &mean_options.;
&class_stm.;
var &myvar.;
&output_stm.;
run; quit;
%mend;


* qMeans() call with no class statement;
%qMeans(indata=%str(mydata.ames_housing_data),
	outdata=%str(SalePrice_qMeans),
	myvar=%str(SalePrice),
	mean_options=%str(p1 p5 p25 p50 p75 p95 p99 noprint),
	class_stm=%str(),
	output_stm=%str(output out=&outdata. 
	p1(&myvar.)=p01 
	p5(&myvar.)=p05 
	p25(&myvar.)=p25 
	p50(&myvar.)=p50 
	p75(&myvar.)=p75 
	p95(&myvar.)=p95 
	p99(&myvar.)=p99 )
);

proc print data=SalePrice_qMeans; run; quit;


* qMeans() call with class statement SaleCondition;
%qMeans(indata=%str(mydata.ames_housing_data),
	outdata=%str(SalePrice_by_SaleCondition),
	myvar=%str(SalePrice),
	mean_options=%str(p1 p5 p25 p50 p75 p95 p99 noprint),
	class_stm=%str(class SaleCondition),
	output_stm=%str(output out=&outdata. 
	p1(&myvar.)=p01 
	p5(&myvar.)=p05 
	p25(&myvar.)=p25 
	p50(&myvar.)=p50 
	p75(&myvar.)=p75 
	p95(&myvar.)=p95 
	p99(&myvar.)=p99 )
);


proc print data=SalePrice_by_SaleCondition; run; quit;


****************************************************************************************************;
* Some Final Remarks;
****************************************************************************************************;
* The SAS Macro Facility does not define 'functions'.  Instead a SAS Macro is a piece of code
* that writes code, or generates code.  The SAS Macro Processor interprets the SAS Macro and generates
* the code to be interpreted by SAS.;
*
****************************************************************************************************;
* How can we use macros effectively?;
****************************************************************************************************;
* Typical uses include:
* (1) To parameterize statistical procedures (PROCs) in a subroutine format;
* (2) To parameterize statistical graphics in a subroutine format (PROC SGPLOT);
* (3) To parameterize data manipulations (SAS data steps) into an easy to use subroutine for someone
*	  who does not need to know all of the details of the data manipulation.
*
****************************************************************************************************;
****************************************************************************************************;
****************************************************************************************************;





