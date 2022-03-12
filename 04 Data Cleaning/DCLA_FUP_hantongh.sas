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
*  Job name:      DCLA_FUP_hantongh.sas   
*
*  Purpose:       Data cleaning practice problem by using the Respiratory data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Respiratory data set fup2018
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=DCLA_FUP;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0215_DCLA/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME resp "/folders/myfolders/BIOS-669/Data/Respiratory study data/resp2018";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;


data fup; set resp.fup2018; run;

* 1. Dupicate record;
proc sort data=fup out=fup_nodup dupout=dupset nodupkey;
	by fakeid visit fseqno;
run;

* 2. Invalid or missing value;
proc freq data=fup;
	tables fupa1/missing nocum nopercent;
run;

title 'Missing value for follow-up';
proc print data=fup(keep=fakeid fupa1) label; where missing(fupa1)=1;run;
title;

data record;
	set fup;
	where fupa1='Y';
run;

* Check weight;
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

title 'Missing weight value';
proc print data=fup(keep=fakeid fupa2 fupa3a fupa3b) label;
	where fupa2='Y' and missing(fupa3A)+missing(fupa3b)>0;
run;
title;

data weight;
	set record(rename=(fupa3a=weight fupa3b=unit));
	where fupa2='Y' and missing(weight)+missing(unit)=0;
	keep fakeid fupa2 weight unit;
run;

title 'Extraordinary weight (4 std away)';
%extra(measure=weight,unit=K);
ods startpage=off;
%extra(measure=weight,unit=P);
ods startpage=on;

* Check FEV1 and FVC;
proc sql;
	title 'Missing FEV1 and FVC value';
	select count(*)
		from record
		where fupa4='Y' and 
			missing(fupa4b)+missing(fupa4b1)+missing(fupa4c)+missing(fupa4c1)
			+missing(fupa4d)+missing(fupa4d1)+missing(fupa4e)+missing(fupa4e1)>0;
	title;
	
	title 'Invalid FEV1 and FVC value';
	select *
		from record
		where fupa4='Y' and 
			missing(fupa4b)+missing(fupa4b1)+missing(fupa4c)+missing(fupa4c1)
			+missing(fupa4d)+missing(fupa4d1)+missing(fupa4e)+missing(fupa4e1)=0
			and (fupa4b<0 or fupa4c<0 or fupa4d<0 or fupa4e<0);
	title;	
quit;








ods pdf close;
