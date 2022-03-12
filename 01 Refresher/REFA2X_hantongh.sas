*********************************************************************
*  Assignment:    REFA                                         
*                                                                    
*  Description:   First collection of SAS refresher problems using 
*                 METS study data
*
*  Name:          Hantong Hu
*
*  Date:          1/16/2019                                        
*------------------------------------------------------------------- 
*  Job name:      REFA2X_hantongh.sas   
*
*  Purpose:       Produce a display for evaluating whether treatment
*                 groups are fairly balanced across the METS sites.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set omra_669
*
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=REFA2X;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0116_REFA/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

%macro med_list;

data omra;
	set mets.omra_669;
	label BID='ID' omra1='Medication';
run;

data v2;
	set omra;
	where omra5a='Y';
	keep BID omra1;
run;

title 'List of specially-allowed medication and patient ID';
title2 'Collected from Visit 2';
proc print data=v2 label noobs;
run;
title;

data v5;
	set omra;
	where omra5d='Y';
	keep BID omra1;
run;

title 'List of specially-allowed medication and patient ID';
title2 'Collected from Visit 5';
proc print data=v5 label noobs;
run;
title;

data v10;
	set omra;
	where omra5i='Y';
	keep BID omra1;
run;

title 'List of specially-allowed medication and patient ID';
title2 'Collected from Visit 10';
proc print data=v10 label noobs;
run;
title;

%mend;

%med_list;



ODS pdf CLOSE;
