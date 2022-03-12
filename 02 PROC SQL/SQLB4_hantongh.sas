*********************************************************************
*  Assignment:    SQLB                                         
*                                                                    
*  Description:   Second collection of SAS PROC SQL problems using 
*                 Airline data
*
*  Name:          Hantong Hu
*
*  Date:          1/25/2019                                        
*------------------------------------------------------------------- 
*  Job name:      SQLB4_hantongh.sas   
*
*  Purpose:       PROC SQL practice problem by using the Airline data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Airline data set METS.LABA
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=SQLB4;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0125_SQLB/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME airline "/folders/myfolders/BIOS-669/Data/Airline data and documentation for SQL assignments/airline";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

%macro outrange(analyte=, varname=, low_level=, high_level=);

title 'Lab test participant value outside reasonable range';
title2 "Analyte: &analyte.; Reasonable range: &low_level to &high_level";

proc sql;
	select bid,
			visit,
			&varname.,
			case
				when &varname.>&high_level. then 'High'
				when &varname.<&low_level. then 'Low'
				else 'Normal'
			end as Condition
		from mets.laba_669
		where calculated condition~='Normal' and missing(&varname.)=0;
quit;

%mend;

%outrange(analyte=Sodium, varname=laba11, low_level=130, high_level=150);
%outrange(analyte=Calcium, varname=laba15, low_level=8, high_level=10.5);
%outrange(analyte=Protein, varname=laba16, low_level=6, high_level=9);


ods pdf close;