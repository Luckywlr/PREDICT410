/*	Chad R. Bhatti
	11.14.2015
	dog_mandible_01.sas
*/

/*
In this example we will look at clustering dogs based on a set of jaw measurements using
the hierarchical clustering algorithm provided by PROC CLUSTER.  The hierarchical clustering
algorithm creates a tree of cluster solutions so that we can easily recall any number of 
clusters using PROC TREE.

We will view this problem as a supervised learning problem or a classification problem 
where the objective is to create clusters in order to assign (or predict) the type of dog
based on its cluster membership.  We will look at the accuracy results for two different
sets (number) of clusters.
*/


libname mydata     '/scs/crb519/PREDICT_410/SAS_Data/' access=readonly;

proc contents data=mydata.dog_mandible_measurements; run; quit;

proc print data=mydata.dog_mandible_measurements; run; quit;


* list out class names and counts;
proc freq data=mydata.dog_mandible_measurements; 
tables group_name;
run; quit;
* note that we have 5 classes of dogs, 10 if we would count type of dog and gender;


* strip off class identifiers for clustering;
data measurements;
	set mydata.dog_mandible_measurements(keep= X:);
run;

proc print data=measurements; run; quit;


*********************************************************************************;
* Perform cluster analysis using PROC CLUSTER;
*********************************************************************************;
ods graphics on;
proc cluster data=measurements method=average outtree=tree1;
run; quit;
ods graphics off;


*********************************************************************************;
* Pull results for 5 clusters using PROC TREE;
*********************************************************************************;
ods graphics on;
proc tree data=tree1 ncl=5 out=_5_clusters;
copy X: ;
run; quit;
ods graphics off;

proc print data=_5_clusters; run; quit;

proc freq data=_5_clusters;
tables clusname;
run; quit;

proc sort data=_5_clusters; by X1-X9; run; quit;
proc sort data=mydata.dog_mandible_measurements out=class_labels; by X1-X9; run; quit;

data cluster_fit5;
	merge class_labels _5_clusters;
	by X1-X9;
run;

proc freq data=cluster_fit5;
tables clusname*group_name;
run; quit;


*********************************************************************************;
* Pull results for 10 clusters using PROC TREE;
* Note that with hierarchical clustering we do not need to refit the clustering
* algorithm.  All sets of clusters have already been fit.
*********************************************************************************;
ods graphics on;
proc tree data=tree1 ncl=10 out=_10_clusters;
copy X: ;
run; quit;
ods graphics off;

proc print data=_10_clusters; run; quit;

proc freq data=_10_clusters;
tables clusname;
run; quit;

proc sort data=_10_clusters; by X1-X9; run; quit;
proc sort data=mydata.dog_mandible_measurements out=class_labels; by X1-X9; run; quit;

data cluster_fit10;
	merge class_labels _10_clusters;
	by X1-X9;
run;

proc freq data=cluster_fit10;
tables clusname*group_name;
run; quit;


*********************************************************************************;
* Formalize the cluster fits and their accuracy;
*********************************************************************************;
data predict5;
	set cluster_fit5;
	format predicted_group $20.;
	
	if (clusname='CL10') then predicted_group='Golden Jackal';
	else if (clusname in ('CL12','CL8','OB58')) then predicted_group='Indian Wolves';
	else if (clusname='CL5') then predicted_group='Cuons';
	else predicted_group='Error';
	* Note that we are only predicting three of the five groups when using five clusters;
	* Note that the individual observations are essentially clustering outliers for the 
	given number of clusters.  They are far enough away from the other observations that
	they are given their own cluster;
	
	if (predicted_group=group_name) then correct_prediction=1;
	else correct_prediction=0;
run;

* Check predicted_group assignment for ERROR;
proc freq data=predict5; 
tables predicted_group;
run; quit;

proc means data=predict5 mean noprint;
var correct_prediction;
output out=prediction_accuracy5 
	sum(correct_prediction)=count_accurate
	mean(correct_prediction)=pct_accurate;
run; quit;

proc print data=prediction_accuracy5; run; quit;


data predict10;
	set cluster_fit10;
	format predicted_group $20.;
	
	if (clusname='CL10') then predicted_group='Golden Jackal';
	else if (clusname='CL11') then predicted_group='Prehistoric';
	else if (clusname in ('CL12','CL17','OB56','OB58','OB65')) then predicted_group='Indian Wolves';
	else if (clusname in ('CL13','CL14')) then predicted_group='Cuons';
	else if (clusname='CL15') then predicted_group='Modern';
	else predicted_group='Error';
	* Now we are predicting all five of the groups when using ten clusters;
	
	if (predicted_group=group_name) then correct_prediction=1;
	else correct_prediction=0;
run;

* Check predicted_group assignment for ERROR;
proc freq data=predict10; 
tables predicted_group;
run; quit;

proc means data=predict10 mean noprint;
var correct_prediction;
output out=prediction_accuracy10 
	sum(correct_prediction)=count_accurate
	mean(correct_prediction)=pct_accurate;
run; quit;

proc print data=prediction_accuracy10; run; quit;


* Prediction Accuracy for 5 Clusters = 0.63636;
* Prediction Accuracy for 10 Clusters = 0.74026;


*********************************************************************************;
* How can we improve this (supervised) cluster analysis?;
*********************************************************************************;
/*
(1) We did not standardize the attributes (or variable measurements).  When the
attributes are not standardized, then the clustering algorithm will focus on the
variables of largest magnitude.

(2) We did not reduce the dimension of our problem.  Cluster analysis works best
in lower dimensions.  Points get far apart quickly as the dimension of the 
attribute space grows.

*/










































 

