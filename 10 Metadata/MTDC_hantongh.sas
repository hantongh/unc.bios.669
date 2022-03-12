*********************************************************************
*  Assignment:    MTDC                                  
*                                                                    
*  Description:   Third collection of exercises with SAS metadata
*
*  Name:          Hantong Hu
*
*  Date:          4/15/2019                                        
*------------------------------------------------------------------- 
*  Job name:      MTDC_hantongh.sas   
*
*  Purpose:       Metadata practice focusing on analyzing
*					observations by using the mets data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         mets.dema_669
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=MTDC;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0417_MTDC;

OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";
libname patients "/folders/myfolders/BIOS-669/Data/Patients data for SQL unit/patients";

options nosymbolgen nomprint nomlogic;
options orientation=landscape;
ods noproctitle;


%macro codebook(lib_name=,data_set_name=default); 

%let libname=%upcase(&lib_name.);

%macro setcodebook(lib=&libname.,ds=&data_set.);
%let fullds=%sysfunc(catx(.,&lib.,&ds.));


/* Check existence */
%if %sysfunc(exist(&fullds.))=0 %then %do;
%put Data set does not exist;
%return;
%end;

/* Part I: General properties of the whole data set */

/* General features: name, label, nvar, nobs */
data one;
	dsid=OPEN("&fullds.");
	NumObs=ATTRN(dsid,'NOBS');
	NumVars=ATTRN(dsid,'NVARS');
	DSLabel = ATTRC(dsid,'LABEL');
	DSLib = ATTRC(dsid,'LIB');
	DSMemName = ATTRC(dsid,'MEM');
	rc=CLOSE(dsid);
run;

title "General features of data set &ds.";
title2 "First 10 observations displayed";
proc report data=one;
	columns ('Location' dslib dsmemname) ('Purpose' dslabel) ('Property' numvars numobs);
	define dslib / display 'Library' center;
	define dsmemname / display 'Data set name' center;
	define dslabel / display ' ' style=[cellwidth=11 cm] center;
	define numvars / display 'Number of variables' center;
	define numobs / display 'Number of observations' center;
run;

ods startpage=off;
proc print data=&fullds.(obs=10); run; 
title;

/* Part II: General properties of variables within the data set */ 
ods startpage=on;
proc sql;
	create table two as
		select name as varname, label as varlab, propcase(type) as vartype, length as varlength, format as varfor
			from dictionary.columns
			where libname="&lib." and memname="&ds.";
quit;

title "General properties of variables of data set &ds.";
proc report data=two;
	columns varname varlab vartype varlength varfor;
	define varname / display 'Variable name' center;
	define varlab / display 'Variable label' style=[cellwidth=9 cm];
	define vartype / display 'Type (Numeric as Num and Character as Char)' center;
	define varlength / display 'Length' center;
	define varfor / display 'Format' center;
run;
title;


/* Part III: Specific variable properties */	
%macro findproperty;

	proc sql noprint;
		select name into :varlist separated by ' '
			from dictionary.columns
			where libname="&lib." and memname="&ds.";
	quit;

	%if &sqlobs=0 %then %do;
		%put No data sets!;
		%return;
	%end;

	%let i=1;
	%do %until (%scan(&varlist,&i)= );
		%let varname = %scan(&varlist,&i);
			
		proc sql noprint;
			select label,propcase(type),format into :varlabel trimmed, :vartype trimmed, :varfor trimmed
				from dictionary.columns
				where libname="&lib." and memname="&ds." and name="&varname.";
				
			select count(distinct &varname.),count(&varname.) into :distv trimmed, :nobs trimmed
				from &fullds.;
				
			create table var1 as
			select nmiss(&varname.) as Missing_value label='Number of missing values',
					count(distinct &varname.) as Distinct_value label='Number of distinct values'
				from &fullds.;
		quit;
		
		proc transpose data=var1 out=var1t; run;
		data var1t; set var1t; length value $30.; value=put(col1,8.); drop col1 _name_; run;
		data var2; length &varname. $40. value $30.; &varname.='Type'; value="&vartype."; run;
		data cat;
			length &varname. $40. value $30.;
			d1 = index("&varfor.",'DATE');
			d2 = index("&varfor.",'MMDDYY');
			
			if "&vartype."='Num' and (d1+d2>0) then do;
				&varname.='Category'; value="Date";
			end;
			if "&vartype."='Num' and &distv.>10 and &distv.<=&nobs. and (d1+d2=0) then do;
				&varname.='Category'; value="Continuous";
			end;
			if "&vartype."='Num' and &distv.<=10 and (d1+d2=0) then do;
				&varname.='Category'; value="Categorical";
			end;
			
			if "&vartype."='Char' and &distv.<=10 then do;
				&varname.='Category'; value="Categorical";
			end;
			if "&vartype."='Char' and &distv.>10 and &distv.<=&nobs. then do;
				&varname.='Category'; value="Unique";
			end;
			
			call symputx('cat',value);
			drop d1 d2;
		run;
		
		data forreport;
			set var2 var1t(rename=(_label_=&varname.)) cat;
			value=strip(value);
		run;
		
		title "Specific features for variable &varname.";
		proc report data=forreport;
			columns &varname. value;
			define &varname. /"Variable name: &varname." display;
			define value/display "&varlabel" style=[cellwidth=5cm];
		run;
		ods startpage=off;
		
		%let cate=%sysfunc(strip(&cat.));
		
		%if "&cate."="Date" %then %do;
			proc means data=&fullds. noprint;
				var &varname.;
				output out=var3(drop=_type_ _freq_) min=first max=last median=varmedian std=varstd;
			run;
			
			proc report data=var3;
				column first last varmedian varstd;
				define first / display 'Earliest date' center;
				define last / display 'Latest date' center;
				define varmedian / display 'Median date' center;
				define varstd / display 'Std in days' format=10.2 center;
			run;
		%end;
		
		%else %if "&cate."="Continuous" %then %do;
			proc means data=&fullds. noprint;
				var &varname.;
				output out=var3(drop=_type_ _freq_) min=min max=max mean=mean std=std;
			run;
	
			proc report data=var3;
				column min max mean std;
				define min / display 'Minimum' format=10.2 center;
				define max / display 'Maximum' format=10.2 center;
				define mean / display 'Mean' format=10.2 center;
				define std / display 'Std' format=10.2 center;
			run;
		%end;
		
		%else %if "&cate."="Unique" %then %do;
			data var3;
				length message $80.;
				message='Unique values for each variable';
			run;
			proc print data=var3 noobs; run;
		%end;
		
		%else %if "&cate."="Categorical" %then %do;
			proc freq data=&fullds.;
				tables &varname./missing nocum;
			run;
		%end;
		
		ods startpage=on;
		
		
		%let i = %eval(&i+1);
	%end;

%mend findproperty;

%findproperty;

%mend setcodebook;

%if "&data_set_name."="default" %then %do;

	ODS pdf FILE="&outdir/&job._&onyen._&libname..pdf" STYLE=JOURNAL;

	proc sql noprint;
		select distinct memname into :setlist separated by ' '
			from dictionary.columns
			where libname="&libname.";
	quit;

	%if &sqlobs=0 %then %do;
		%put No data sets in library &libname.!;
		%return;
	%end;

	%let j=1;
		%do %until (%scan(&setlist,&j)= );
			%let setname = %scan(&setlist,&j);
				%setcodebook(ds=&setname.);
			%let j = %eval(&j+1);
		%end;
	
	ods pdf close;
	
%end;

%else %DO;
	%let data_set=%upcase(&data_set_name.);
	ODS pdf FILE="&outdir/&job._&onyen._&libname._&data_set..pdf" STYLE=JOURNAL;
	%setcodebook;
	ods pdf close;
%end;


%mend codebook;

/* I somehow forgot to save different extensions into different programs, so this will just be a 
general macro that can produce either codebook for one designated data set or all data sets within one
library. I will include three pdfs showing these functions. */

/* Specify lib name and data set name to generate codebook for that data set
Output PDF name: MTDC_onyen_libname_datasetname. 
If data set doesn't exist and/or no variable in data set, message will be written to log.
*/

%codebook(lib_name=mets,data_set_name=dema_669);
%codebook(lib_name=mets,data_set_name=cgia_669);

/* Only specifying lib name to generate codebook for all data sets within that lib
Output PDF name: MTDC_onyen_libname. 
If data set doesn't exist and/or no variable in data set, message will be written to log.
*/

%codebook(lib_name=patients);


