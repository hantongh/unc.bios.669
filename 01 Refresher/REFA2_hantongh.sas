*********************************************************************
*  Assignment:    REFA                                         
*                                                                    
*  Description:   First collection of SAS refresher problems using 
*                 METS study data
*
*  Name:          Hantong Hu
*
*  Date:          1/15/2019                                        
*------------------------------------------------------------------- 
*  Job name:      REFA2_hantongh.sas   
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

%LET job=REFA2;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0116_REFA/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

data omra;
	set mets.omra_669;
run;

data med;
	set omra;
	where omra5a='Y';
	keep BID omra1;
	
	label BID='ID' omra1='Medication';
run;

title 'List of specially-allowed medication and patient ID';
title2 'Collected from baseline visit';

proc print data=med label noobs;
run;

title;

ODS pdf CLOSE;

