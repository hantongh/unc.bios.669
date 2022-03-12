*********************************************************************
*  Assignment:    DCLA                                     
*                                                                    
*  Description:   First collection of SAS data cleaning problems using 
*                 Respiratory data
*
*  Name:          Hantong Hu
*
*  Date:          2/14/2019                                        
*------------------------------------------------------------------- 
*  Job name:      DCLA_CDF_hantongh.sas   
*
*  Purpose:       Data cleaning practice problem by using the Respiratory data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Respiratory data set cdf2018
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=DCLA_CDF;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0215_DCLA/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME resp "/folders/myfolders/BIOS-669/Data/Respiratory study data/resp2018";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

data cdf; set resp.cdf2018; run;

* 1. Check that variables include only valid values;
title 'Check values for data set CDF';
proc freq data=cdf;
	tables cdfa1 cdfa2 cdfa3/nopercent nocum missing;
run;
title;

title 'Missing values in data set CDF';
proc print data=cdf;
	where missing(cdfa3)=1;
run;
title;

* 2. Checking for and eliminating duplicate entries.;
proc sort data=cdf out=cdf_nodup dupout=cdf_dup nodupkey;
	by fakeid visit fseqno;
run;

* 3. Pull out Fakeid with last response withdraw;
proc sort data=cdf out=cdf_sorted;
	by fakeid cdfa1 cdfa2 cdfa3 fseqno;
run;

data withdraw;
	set cdf_sorted;
	by fakeid cdfa1 cdfa2 cdfa3 fseqno;
	if last.fakeid and cdfa2='W';
	keep fakeid;
run;
	

ods pdf close;