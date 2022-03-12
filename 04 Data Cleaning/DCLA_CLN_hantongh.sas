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
*  Job name:      DCLA_CLN_hantongh.sas   
*
*  Purpose:       Data cleaning practice problem by using the Respiratory data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Respiratory data set cln2018
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=DCLA_CLN;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0215_DCLA/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME resp "/folders/myfolders/BIOS-669/Data/Respiratory study data/resp2018";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;


data cln; set resp.cln2018; run;

* 1. Check that variables include only valid values;
title 'Check values for data set CLN';
proc freq data=cln;
	tables CLNB1/nopercent nocum missing;
run;
title;

title 'Missing values in data set CLN';
data clnmiss;
	set cln;
	if clnb1='Y' and
		missing(clnb1b)+missing(clnb1b1)+missing(clnb1c)+missing(clnb1c1)+
		missing(clnb1d)+missing(clnb1d1)+missing(clnb1e)+missing(clnb1e1)>0 then
	output;
run;
proc print data=clnmiss;run;
title;

title 'Extraordinary FEV1 and FVC';
proc print data=cln;
	where clnb1b~=. and clnb1b<0 and clnb1c~=. and clnb1c<0 and
		clnb1d~=. and clnb1d<0 and clnb1e~=. and clnb1e<0;
run;
title;


* 2. Check for dupication;
proc sort data=cln out=clndup nodupkey;
	by fakeid;
run;

ods pdf close;