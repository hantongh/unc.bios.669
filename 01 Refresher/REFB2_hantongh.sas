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
*  Job name:      REFB2_hantongh.sas   
*
*  Purpose:       Produce a display for evaluating whether treatment
*                 groups are fairly balanced across the METS sites.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set laba_669 
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=REFB2;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0118_REFB/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

data laba;
	set mets.laba_669;
run;

%let sodiumh=150;
%let sodiuml=130;
%let calciumh=10.5;
%let calciuml=8;
%let proteinh=9;
%let proteinl=6;
%let hdlh=25;
%let hdll=0;
%let ldlh=200;
%let ldll=0;

%macro out_range(analyte=,varname=);

	data laba_&analyte.;
		set laba;
	
		where missing(&varname.)=0;
		
		if &varname.>&&&analyte.h then condition='High';
		else if &varname.<&&&analyte.l then condition='Low';
		
		keep bid visit &varname condition;
		
		label bid='Personal ID'
				&varname.="&analyte."
				condition='Test condition (Low/High)';
	run;
	
	title 'Lab test participant value outside reasonable range';
	title2 "Analyte: &analyte.; Reasonable range: &&&analyte.l to &&&analyte.h";
	
	proc print data=laba_&analyte. label noobs;
		where condition~='';
	run;
	title;


%mend;

%out_range(analyte=Sodium,varname=laba11);
%out_range(analyte=Calcium,varname=laba15);
%out_range(analyte=Protein,varname=laba16);
%out_range(analyte=HDL,varname=laba5);
%out_range(analyte=LDL,varname=laba6);

ODS pdf CLOSE;