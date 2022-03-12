*********************************************************************
*  Assignment:    ADSA                                  
*                                                                    
*  Description:   First collection of SAS Analysis data set and graphing
*					 using Respiratory data
*
*  Name:          Hantong Hu
*
*  Date:          2/20/2019                                        
*------------------------------------------------------------------- 
*  Job name:      ADSA_GRAPH_hantongh.sas   
*
*  Purpose:       Analysis data set and graphing problem by 
*					using the Respiratory data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Respiratory data set 
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=ADSA_GRAPH;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0222_ADSA/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME resp "/folders/myfolders/BIOS-669/Data/Respiratory study data/resp2018";
LIBNAME ADSA '/folders/myfolders/BIOS-669/Assignment/0222_ADSA';

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;
options orientation=landscape;

* Create format for graphing purpose;
proc format;
	value visitcat 1='Baseline'
					2='Follow-up Year 1'
					3='Follow-up Year 2'
					4='Follow-up Year 3'
					5='Follow-up Year 4'
					6='Follow-up Year 5';
	value $sexcat 'M'='Males'
					'F'='Females';
run;

* Graph 1: Side-by-side vertical box plots of BMI by gender;
data adsa1;
	set adsa.adsa;
run;

title 'Graph 1: BMI of Study Participants by Gender and Visit';
proc sgpanel data=adsa1;
	format sex $sexcat.
			visit visitcat.;
	panelby sex/novarname;
	vbox bmi/category=visit;
	
	rowaxis values=(0,25,50,75);
	colaxis display=(nolabel);
run;

* Graph 1A;
proc sql noprint;
	select count(fakeid) into :numfu3
		from adsa1
		where visit=4;
	
	select "'"||fakeid||"'" into :fu3list separated by ','
		from adsa1
		where visit=4;
quit;

data adsa1a;
	set adsa1;
	where fakeid in (&fu3list.) and visit<5;
	
	if sex='F' then sex_mod="Females (N=%trim(&numfu3.))";
	if sex='M' then sex_mod="Males (N=%trim(&numfu3.))";
run;

title 'Graph 1A: BMI of Study Participants by Gender and Visit';
title2 'Only Participants Through Visit 4 Who Completed All Four Visits';

proc sgpanel data=adsa1a;
	format visit visitcat.;
	panelby sex_mod/novarname;
	vbox bmi/category=visit;
	
	rowaxis values=(0,25,50,75);
	colaxis display=(nolabel);
run;


* Graph 2;
proc sql;
	create table adsa2 as
	select visit, basegold, mean(bmi) as meanbmi, count(bmi) as count
		from adsa1
		group by visit,basegold
		having calculated count>2;
quit;

title 'Graph 2: Mean BMI over Time by Baseline GOLD Status';
footnote 'Omitting GOLD groups with N < 3';
proc sgplot data=adsa2;
	format visit visitcat.;
	series x=visit y=meanbmi/ group=basegold markers;
	
	yaxis label='Mean BMI';
	xaxis display=(nolabel);
	keylegend / across=5 title='Baseline GOLD Status';
run;
title; footnote;

* Graph 2A;
proc sql;
	create table adsa2a as
	select visit, gold, mean(bmi) as meanbmi, count(bmi) as count
		from adsa1
		group by visit,gold
		having calculated count>2;
quit;

title 'Graph 2A: Mean BMI over Time by Visit-Specific GOLD Status';
footnote 'Omitting GOLD groups with N < 3';
proc sgplot data=adsa2a;
	format visit visitcat.;
	series x=visit y=meanbmi/ group=gold markers;
	
	yaxis label='Mean BMI';
	xaxis display=(nolabel);
	keylegend / across=5 title='Visit-Specific GOLD Status';
run;
title; footnote;

* Graph 2B;
proc sql;
	create table adsa2b as
	select visit, gold, mean(bmi) as meanbmi, count(bmi) as count
		from adsa1a
		group by visit,gold
		having calculated count>2;
quit;

title 'Graph 2B: Mean BMI over Time by Visit-Specific GOLD Status';
title2 'Only Participants Through Visit 4 Who Completed All Four Visits';
footnote 'Omitting GOLD groups with N < 3';
proc sgplot data=adsa2b;
	format visit visitcat.;
	series x=visit y=meanbmi/ group=gold markers;
	
	yaxis label='Mean BMI';
	xaxis display=(nolabel) integer;
	keylegend / across=5 title='Visit-Specific GOLD Status';
run;
title; footnote;

ods pdf close;