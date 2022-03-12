*********************************************************************
*  Assignment:    RPTD                                     
*                                                                    
*  Description:   Fourth collection of SAS proc report problems using 
*                 MET data
*
*  Name:          Hantong Hu
*
*  Date:          4/2/2019                                        
*------------------------------------------------------------------- 
*  Job name:      RPTD_hantongh.sas   
*
*  Purpose:       PROC REPORT practice problem by using the MET data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MET data set omra_669
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=RPTD;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0403_RPTD;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";

options missing='';

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

* Prepare data set;
data medication;
	set mets.omra_669;
	keep bid WtLiabMed;
	
	where omra5a='Y' and omra4='06';
	
	WtLiabMed=scan(omra1,1);
run;
proc sort data=medication nodupkey; by bid wtliabmed; run;


DATA lookup;
	LENGTH med $15 class $4 ;
	INPUT med class ;
CARDS;
CLOZAPINE HIGH
ZYPREXA HIGH
RISPERIDONE HIGH
SEROQUEL HIGH
INVEGA HIGH
CLOZARIL HIGH
OLANZAPINE HIGH
RISPERDAL HIGH
ZIPREXA HIGH
LARI HIGH
QUETIAPINE HIGH
RISPERDONE HIGH
RISPERIDAL HIGH
RISPERIDOL HIGH
SERAQUEL HIGH
ABILIFY LOW
GEODON LOW
ARIPIPRAZOLE LOW
HALOPERIDOL LOW
PROLIXIN LOW
ZIPRASIDONE LOW
GEODONE LOW
HALDOL LOW
PERPHENAZINE LOW
FLUPHENAZINE LOW
THIOTRIXENE LOW
TRILAFON LOW
TRILOFAN LOW
;

PROC SQL;
    CREATE TABLE medication_hl AS
        SELECT m.bid,m.WtLiabMed,t.class
            FROM medication AS m
            	left join
                 lookup AS t
                 on m.WtLiabMed=t.med
            group by bid
            order by bid;
QUIT;

data medication_revised;
	set medication_hl;
	keep bid class;
	
	if missing(class)=1 then delete;
run;

proc sort data=medication_revised;
	by bid class;
run;
proc sort data=medication_revised nodupkey; by bid;run;

/*proc freq data=medication_revised; table class; run;*/

data med_merge;
	merge medication_revised mets.dr_669(keep=bid trt);
	by bid;
	
	if missing(class)=1 then class='HIGH';
run;


* Calculate p-value;
proc freq data = med_merge noprint;
	table class * trt / chisq;
	output out = pvalue pchi;
run;

data _null_;
	set pvalue;
	CALL SYMPUT('pvalue',PUT(p_pchi,6.4));
run;

* Calculate report statistics (code from RPTB);
data med;
	set med_merge;
	output;
	trt='Z';
	output;
run;

TITLE 'Basic counts and percents';
proc freq data=med noprint;
	where trt in ('A','B');
	tables trt*class / outpct out=hlcnt missing;
	tables trt / out=trtcnt;
run;

proc freq data=med noprint;
	where trt='Z';
	tables trt*class / outpct out=hltotcnt missing;
	tables trt / out=totcnt;
run;

data cnt; set hlcnt hltotcnt; run;

*** store treatment group counts in macro variables for later display;
*** in column headings;
data _NULL_;
	set trtcnt;
	if trt='A' THEN CALL SYMPUT('metformin',PUT(count,2.));
	if trt='B' THEN CALL SYMPUT('placebo',PUT(count,2.));
	
	set totcnt;
	if trt='Z' THEN CALL SYMPUT('total',PUT(count,3.));
	%put &metformin &placebo &total;
run;


*** create N (%) character values requested in table shell;
*** (simplify data set BEFORE transposing);
data hlpct;
	set hlcnt (keep=trt class count pct_row) hltotcnt (keep=trt class count pct_row);
	length cp $10;
	cp=strip(put(count,3.)) || ' (' || strip(put(pct_row,4.1)) || ')';
	
	keep trt class cp;
run;

proc sort data=hlpct; by class; run;

*** basic transposition by race or gender to get active & placebo values;
*** on same record per table shell;
proc transpose data=hlpct out=hltrn prefix=trt;
	by class;
	id trt;
	var cp;
run;

data hltrn;
	set hltrn;
	drop _name_;
	if class='HIGH' then pvalue=&pvalue.;
	
	if class='HIGH' then comments='Participants on higher weight liability antipsychotic meds';
	if class='LOW' then comments='Participants on lower weight liability antipsychotic meds';
run;

* PROC REPORT;

title 'Table 8.1: METS Weight Liability by Treatment Group';
footnote1 '*Chi-square statistic comparing metformin and placebo groups';
footnote2 'Participants taking both higher and lower weight liability meds are included in the higher group.';
proc report data=hltrn nowd;
	columns comments trtz trta trtb pvalue;
	define comments / display " " STYLE=[cellwidth=4.0cm];
	define trtz / display "Total N(%) n=&total." center;
	define trta / display "Metformin N(%) n=&metformin." center;
	define trtb / display "Placebo N(%) n=&placebo." center;
	define pvalue / display "P-value*" center;
run;

ods pdf close;

