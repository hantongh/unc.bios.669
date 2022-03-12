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
*  Job name:      REFA1_hantongh.sas   
*
*  Purpose:       Produce a display for evaluating whether treatment
*                 groups are fairly balanced across the METS sites.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set dr_669 
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=REFA1;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0116_REFA/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

data dr;
	set mets.dr_669;
run;

proc sort data=dr out=dr_sorted;
	by trt;
run;

title 'Number of METS treatment groups at each site';


ods noproctitle;
proc freq data=dr_sorted;
	tables psite*trt/nocol nopercent;
run;


ODS pdf CLOSE;

