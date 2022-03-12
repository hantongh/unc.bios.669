*********************************************************************
*  Assignment:    MTDA                                  
*                                                                    
*  Description:   First collection of exercises with SAS metadata
*
*  Name:          Hantong Hu
*
*  Date:          4/4/2019                                        
*------------------------------------------------------------------- 
*  Job name:      MTDA_hantongh.sas   
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

%LET job=MTDA;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0405_MTDA;

options nosymbolgen nomprint nomlogic;
OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME lib "/folders/myfolders/BIOS-669/Data/Selected BIOS 511 data/bios511data";


ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

* Part 1: Write a macro that takes a data set name as a parameter and returns 
information about whether or not that data set exists. ;

%macro isExist(ds=);
	%if %sysfunc(exist(&ds))=1 %then %do;
		data _null_;
			dsid=OPEN("&ds.");
			NumObs=ATTRN(dsid,'NOBS');
			rc=CLOSE(dsid);
			call symputx("numobs",NumObs);
		run;
		%put "Data set &ds. exists, and has &numobs. observations.";
	%end;
	
	%else %do;
		%PUT "Data set &ds does not exist.";
	%end;
%mend;

%isExist(ds=lib.cars2011);
%isExist(ds=lib.cars2009);

* Part 2: Write a macro designed to take as an argument any numeric variable
in the CARS2011 data set. ;

%macro isNumVar(var=);
	data _null_;
		dsid=OPEN('lib.cars2011');
		type=VARTYPE(dsid,VARNUM(dsid,"&var."));
		CALL SYMPUTX('type',type);
		rc=close(dsid);
	run;
	
	%if &type.=C %then %do;
		%put "Variable &var. is a charater variable.";
	%end;
		
	%if &type.=N %then %do;
		proc sql noprint;
			select count(distinct &var.) into :numdist
				from lib.cars2011;
		quit;
		
		%if &numdist.<=6 %then %do;
			title "PROC FREQ Analysis for Variable &var.";
			proc freq data=lib.cars2011;
				tables &var. / missing;
			run;
		%end;
		%else %do;
			title "PROC MEANS Analysis for Variable &var.";
			proc means data=lib.cars2011;
				var &var.;
			run;
		%end;
	%end;
%mend;

ods noproctitle;
%isNumVar(var=model);
%isNumVar(var=basemsrp);
%isNumVar(var=reliability);


* Part 3: Write a macro that takes as an argument any variable in the CARS2011 
data set. The purpose of the macro is to write a sentence about this variable
 to the SAS log, using %PUT.;

%macro varTypeLabel(var=);
	data _null_;
		dsid=OPEN('lib.cars2011');
		type=VARTYPE(dsid,VARNUM(dsid,"&var."));
		car_label=varlabel(dsid,VARNUM(dsid,"&var."));
		CALL SYMPUTX('type',type);
		CALL SYMPUTX('carlabel',car_label);
		rc=close(dsid);
	run;
	
	%if &type.=C %then %do;
		%put "Character variable &var. is labeled &carlabel..";
	%end;
		
	%if &type.=N %then %do;
		%put "Numeric variable &var. is labeled &carlabel..";
	%end;
%mend;

%varTypeLabel(var=model);
%varTypeLabel(var=basemsrp);
%varTypeLabel(var=reliability);


* Part 4: Write a macro similar to the one for #3, but this time the goal is
to write the sentence not to the log but to the current output destination. ;

%macro varTypeLabelPut(var=);
	data _null_;
		dsid=OPEN('lib.cars2011');
		type=VARTYPE(dsid,VARNUM(dsid,"&var."));
		car_label=strip(varlabel(dsid,VARNUM(dsid,"&var.")));
		rc=close(dsid);
		
		if type='C' then do;
			FILE PRINT;
			put "Character variable &var. is labeled " car_label '.';
		end;
		
		if type='N' then do;
			FILE PRINT;
			put "Numeric variable &var. is labeled " car_label '.';
		end;
	run;
	
%mend;

%varTypeLabelPut(var=model);
%varTypeLabelPut(var=basemsrp);
%varTypeLabelPut(var=reliability);

ods pdf close;