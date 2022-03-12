*********************************************************************
*  Assignment:    SQLF                                     
*                                                                    
*  Description:   Sixth collection of SAS PROC SQL problems using 
*                 MET data
*
*  Name:          Hantong Hu
*
*  Date:          2/7/2019                                        
*------------------------------------------------------------------- 
*  Job name:      SQLF1_hantongh.sas   
*
*  Purpose:       PROC SQL practice problem by using the MET data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MET data set omra_669
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=SQLF1;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0208_SQLF/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

proc sql;
	title 'Patients taking medications that need special permission';
	select bid, omra1
		from mets.omra_669
		where omra1 in ('INSULIN','FUROSEMIDE','NIFEDIPINE','CIMETIDINE',
                 'AMILORIDE','DIGOXIN','MORPHINE','PROCAINAMIDE',
                 'QUINIDINE','QUININE','RANITIDINE','TRIAMTERENE',
                 'TRIMETHOPRIM','VANCOMYCIN')
                 and omra5a='Y';
     title;
quit;


ods pdf close;
