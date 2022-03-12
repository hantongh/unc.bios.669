*********************************************************************
*  Assignment:    MTDB                                  
*                                                                    
*  Description:   Second collection of exercises with SAS metadata
*
*  Name:          Hantong Hu
*
*  Date:          4/9/2019                                        
*------------------------------------------------------------------- 
*  Job name:      MTDB_hantongh.sas   
*
*  Purpose:       Metadata practice focusing on analyzing
*					observations by using the car2011 data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         car2011 data set
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=MTDB;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0410_MTDB;

options nosymbolgen nomprint nomlogic;
OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME lib "/folders/myfolders/BIOS-669/Data/Selected BIOS 511 data/bios511data";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

* 1. Use PROC SQL to create a single macro variable that contains 
a list of all the CARS2011 variables in alphabetical order, with the 
variable names separated by a blank space. 
Write the value of this variable to the SAS log with %PUT.;

proc sql noprint;
	select name into :alphalist separated by ' '
		from dictionary.columns
		where libname='LIB' and memname='CARS2011'
		order by name;
quit;

%put &alphalist.;

* 2. Using a query to the appropriate dictionary table, make a single macro 
variable that contains a list of all variables in CARS2011 whose name 
starts with C, M, or R. Then write a macro routine that will loop through
the variables in this list, doing the following in the loop: 
use a SQL query to determine how many unique values the current variable 
has (COUNT(DISTINCT var)) and write that number to a macro variable (INTO),
and then use %PUT to write a sentence about the variable and its number of
unique values to the SAS log.;

%macro distct;
	proc sql noprint;
		select name into :cmrlist separated by ' '
			from dictionary.columns
			where libname='LIB' and memname='CARS2011' and 
				substr(name,1,1) in ('C','M','R');
	quit;

	%if &sqlobs=0 %then %do;
		%put No such variable!;
	%end;

	%let i=1;
	%do %until (%scan(&cmrlist,&i)= );
		%let varname = %scan(&cmrlist,&i);
			
		proc sql noprint;
			select count(distinct &varname.) into :&varname.ct
				from lib.cars2011;
		quit;
			
		%let count=%sysfunc(strip(&&&varname.ct.));
		%put &varname. has &count. distinct values.;
		
		%let i = %eval(&i+1);
	%end;
%mend;	

%distct;


/* 3. Building on #2 of assignment MTDA, make a macro variable list of all 
numeric variables in CARS2011. Use a macro to loop through the list.

If the variable has 6 or fewer unique values, the macro should run PROC FREQ 
on the variable (be sure to use the MISSING function on the TABLES statement).

If the variable has more than 6 unique values, the macro should run PROC MEANS 
on it; */

%macro findnum;
	proc sql noprint;
		select name into :numlist separated by ' '
			from dictionary.columns
			where libname='LIB' and memname='CARS2011' and 
				type='num';
	quit;

	%if &sqlobs=0 %then %do;
		%put No such variable!;
	%end;

	title 'PROC FREQ analysis for variables with <=6 distinct values; PROC MEANS analysis for variables with >6 distinct values';
	title2 "Numeric variables for analysis: &numlist. ";
	%let i=1;
	%do %until (%scan(&numlist,&i)= );
		%let varname = %scan(&numlist,&i);
			
		proc sql noprint;
			select count(distinct &varname.) into :&varname.ct
				from lib.cars2011;
		quit;
			
		%let count=%sysfunc(strip(&&&varname.ct.));
		
		%if &count.<=6 %then %do;
			ods noproctitle;
			proc freq data=lib.cars2011;
				tables &varname./missing;
			run;
			ods startpage=off;
		%end;
		
		%if &count.>6 %then %do;
			ods noproctitle;
			proc means data=lib.cars2011;
				var &varname.;
			run;
			ods startpage=off;
		%end;
		
		%let i = %eval(&i+1);
	%end;
%mend;

%findnum;
ods startpage=on;
title;

/* 4. Using a query to the appropriate dictionary table, make a macro variable 
list of all date variables in METS data set BSFA_669. 
Use a macro to loop through the date variable list and, for each one, 
produce a small PROC TABULATE table that shows the minimum and maximum values 
for the date as well as the number of non-missing and missing values. 
If N date variables are found, your output should be N tables like this, with
the appropriate variable name, variable label, counts, and date values in 
place. */

%macro findlabel;
	proc sql noprint;
		select name into :datelist separated by ' '
			from dictionary.columns
			where libname='METS' and memname='BSFA_669' and type='num' 
			and (index(format,'DATE')>0 or index(format,'MMDDYY')>0);
	quit;

	%if &sqlobs=0 %then %do;
		%put No data sets!;
	%end;

	%let i=1;
	%do %until (%scan(&datelist,&i)= );
		%let varname = %scan(&datelist,&i);
			
		proc sql noprint;
			select label into :label
				from dictionary.columns
				where libname="METS" and memname='BSFA_669' and name="&varname.";
				
			create table report_raw as
				select n(&varname.) as N format=best.,
						nmiss(&varname.) as NMiss format=best.,
						min(&varname.) as Minimum format=date9.,
						max(&varname.) as Maximum format=date9.
				from mets.bsfa_669;
		quit;
		
		data forreport;
			set report_raw;
			&varname.="&label.";
		run;
		
		title "Statistics and label for variable &varname.";
		proc report data=forreport;
			columns &varname. n nmiss minimum maximum;
			define &varname. /display;
			define n/display;
			define nmiss/display;
			define minimum/display;
			define maximum/display;
		run;
		
		%let i = %eval(&i+1);
	%end;

%mend;

%findlabel;


ods pdf close;
