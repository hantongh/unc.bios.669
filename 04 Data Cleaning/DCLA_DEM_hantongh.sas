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
*  Job name:      DCLA_DEM_hantongh.sas   
*
*  Purpose:       Data cleaning practice problem by using the Respiratory data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Respiratory data set dem2018
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=DCLA_DEM;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0215_DCLA/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME resp "/folders/myfolders/BIOS-669/Data/Respiratory study data/resp2018";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

data dem; set resp.dem2018; run;

* 1. Check that variables include only valid values;
title 'Check values for data set DEM';
proc freq data=dem;
	tables dema2 dema3 dema5 dema7 dema8 dema9 dema11a dema11b
			dema11c dema4a dema4b dema4c dema4e dema4f
			dema6b dema6d/nopercent nocum missing;
run;
proc print data=dem(keep=fakeid dema7);
	where dema7 not in ('','Y','R','N','U');
run;
title;

title 'Missing values in data set DEM';
proc print data=dem(keep=fakeid dema2) label; where missing(dema2)=1; run;
data dem_heightweightmiss;
	set dem;
	if missing(dema6a)=1 or missing(dema6b)=1
		or missing(dema6c)=1 or missing(dema6d)=1;
	keep fakeid dema6:;
run;
ods startpage=off;
proc print data=dem_heightweightmiss label; run;
title;
ods startpage=on;

* 2. Checking for and eliminating duplicate entries.;
title 'Duplicate record';
proc sql;
	select fakeid
		from dem
		group by fakeid
		having count(fakeid)>1;
quit;
title;

* 3. List of extraordinary values;
data weight;
	set dem(rename=(dema6a=weight dema6b=unit));
	where weight~=. and unit~='';
	keep fakeid weight unit age;
run;
data height;
	set dem(rename=(dema6c=height dema6b=unit));
	where height~=. and unit~='';
	keep fakeid height unit age;
run;

%macro extra(measure=,unit=);
proc means data=&measure. noprint;
	var &measure.;
	where unit="&unit.";
	output out=&measure.sum(drop=_type_ _freq_) mean=mean std=std;
run;

data combine;
	set &measure.;
	where unit="&unit.";
	if _N_=1 then set &measure.sum;
	if (&measure.<mean-4*std or &measure.>mean+4*std) then
	output;
	drop mean std;
run;

proc print data=combine; run;
%mend;

title 'Extraordinary weight and height (4 std away)';
%extra(measure=weight,unit=K);
ods startpage=off;
%extra(measure=weight,unit=P);
%extra(measure=height,unit=C);
%extra(measure=height,unit=I);
ods startpage=on;

ods pdf close;