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
*  Job name:      REFB3_hantongh.sas   
*
*  Purpose:       Produce a display for evaluating whether treatment
*                 groups are fairly balanced across the METS sites.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set uvfa_669, CGIA_669, AESA_669,
*					SAEA_669, VSFA_669, AUQA_669, LABA_669
*					BSFA_669, and SMFA_669
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=REFB3;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0118_REFB/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

%let sets=UVFA CGIA AESA SAEA VSFA AUQA LABA BSFA SMFA;

option symbolgen mprint mlogic;
%macro setop;
    
    %let i=1;
    
    %do %until (%scan(&sets.,&i)= );
    
        %let ds=%scan(&sets.,&i);
        
        data &ds.;
            set mets.&ds._669;
            visitdate=&ds.0b;
        run;

        proc sort data=&ds.;
        	by bid visit visitdate;
        run;   
        
        %let i=%eval(&i + 1);
    
    %end;
    
%mend;

%setop;

data unsch;
	merge uvfa cgia aesa saea vsfa auqa laba bsfa smfa;
	by bid visit visitdate;
	
	if uvfa0b;
	
	cgia=1-missing(cgia0b);
	aesa=1-missing(aesa0b);
	saea=1-missing(saea0b);
	vsfa=1-missing(vsfa0b);
	auqa=1-missing(auqa0b);
	laba=1-missing(laba0b);
	bsfa=1-missing(bsfa0b);
	smfa=1-missing(smfa0b);
	
	label cgia='Clinical Global Impressions Form'
			aesa='Adverse Event/Side Effects Form'
			saea='Serious Adverse Event Report'
			vsfa='Vital Signs Follow Up Form'
			auqa='Alcohol Use Questionnaire'
			laba='Laboratory'
			bsfa='Biospecimen Shipping/Receiving Form'
			smfa='Study Medication Dispensing, Dosing, and Adherence Form';
	
	
	keep bid visit uvfa: cgia aesa saea vsfa auqa laba bsfa smfa;
	
run;

proc print data=unsch label;
	title 'Unscheduled visits form filling status';
run;

ODS pdf CLOSE;