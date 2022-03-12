*********************************************************************
*  Assignment:    RPTB                                  
*                                                                    
*  Description:   Second collection of SAS PROC REPORT using car2011 data
*
*  Name:          Hantong Hu
*
*  Date:          3/26/2019                                        
*------------------------------------------------------------------- 
*  Job name:      RPTB_hantongh.sas   
*
*  Purpose:       Creating a report - focusing on analyzing
*					observations by using the METS data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=RPTB;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0327_RPTB;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME lib "/folders/myfolders/BIOS-669/Data/METS/METSdata";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

data mhxa; set lib.mhxa_669; run;
data mhxa_trt;
	merge mhxa lib.dr_669(keep=bid trt);
	by bid;
	
	keep bid trt mhxa25-mhxa32;
	output;
	trt='Z';
	output;
run;

%macro npct(test=,name=);
*** compute basic counts and percents required by table shell;
TITLE 'Basic counts and percents';
proc freq data=mhxa_trt noprint;
	where trt in ('A','B');
	tables trt*&test / outpct out=&test.cnt missing;
	tables trt / out=trtcnt;
run;

proc freq data=mhxa_trt noprint;
	where trt='Z';
	tables trt*&test / outpct out=&test.totcnt missing;
	tables trt / out=totcnt;
run;

data cnt; set trtcnt totcnt; run;

*** store treatment group counts in macro variables for later display;
*** in column headings;
data _NULL_;
	set cnt;
	if trt='A' THEN CALL SYMPUT('metformin',PUT(count,2.));
	if trt='B' THEN CALL SYMPUT('placebo',PUT(count,2.));
	if trt='Z' THEN CALL SYMPUT('total',PUT(count,3.));
	%put &metformin &placebo &total;
run;


*** create N (%) character values requested in table shell;
*** (simplify data set BEFORE transposing);
data &test.pct;
	set &test.cnt (keep=trt &test count pct_row) &test.totcnt (keep=trt &test count pct_row);
	length cp $10;
	where &test.='A';
	cp=put(count,2.) || ' (' || strip(put(pct_row,4.1)) || ')';
run;

*** basic transposition by race or gender to get active & placebo values;
*** on same record per table shell;
proc transpose data=&test.pct(keep=trt &test. cp) out=&test.trn prefix=trt;
	id trt;
	var cp;
run;

data &test.trn; set &test.trn; exam="&name."; drop _name_; run;

%mend;

%npct(test=mhxa25,name=Abnormal General Appearance/Skin);
%npct(test=mhxa26,name=Abnormal HEENT);
%npct(test=mhxa27,name=Abnormal Cardiovascular);
%npct(test=mhxa28,name=Abnormal Chest);
%npct(test=mhxa29,name=Abnormal Abdominal);
%npct(test=mhxa30,name=Abnormal Extremities/Joints);
%npct(test=mhxa31,name=Abnormal Neurological);
%npct(test=mhxa32,name=Abnormal Physical Exam Other);


data for_report;
	set mhxa25trn mhxa26trn mhxa27trn mhxa28trn mhxa29trn mhxa30trn mhxa31trn mhxa32trn;
run;

proc sort data=for_report; by descending trtz; run;


title 'Table 2.2: METS Baseline Physical Exam - Systematic Inquiry';
footnote 'Participants could have experienced more than one medical disorder.';
proc report data=for_report nowd;
	columns exam trtz trta trtb;
	define exam / display 'N (%)' STYLE(HEADER)=[JUST=RIGHT] ;
	define trtz / display "Total N=&total." center;
	define trta / display "Total N=&metformin." center;
	define trtb / display "Total N=&placebo." center;
run;



ods pdf close;