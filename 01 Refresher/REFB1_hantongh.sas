*********************************************************************
*  Assignment:    REFB                                         
*                                                                    
*  Description:   Second collection of SAS refresher problems using 
*                 METS study data
*
*  Name:          Hantong Hu
*
*  Date:          1/17/2019                                        
*------------------------------------------------------------------- 
*  Job name:      REFB1_hantongh.sas   
*
*  Purpose:       Produce a display for evaluating whether treatment
*                 groups are fairly balanced across the METS sites.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set dema_669 
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=REFB1;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0118_REFB/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;


proc format;
	value agecat
			low-34='Young'
			35-55='Middle-aged'
			56-high='Senior';
	value $sex
			'M'='Male'
			'F'='Female';
run;


data dema;
	set mets.dema_669;
	format dema1 agecat. dema2 sex.;
	keep bid dema1 dema2;
run;

proc sort data=dema;
	by dema1;
run;

title ' Joint age and gender breakdown of participants in the METS study';
title2 'Age groups: Young: <35; Middle-aged: 35-55; Senior: >56';
ods noproctitle;
ods startpage=no;
proc freq data=dema;
	tables dema2/nocum;
	by dema1;
run;
title;


ODS pdf CLOSE;