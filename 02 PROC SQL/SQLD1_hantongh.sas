*********************************************************************
*  Assignment:    SQLD                                       
*                                                                    
*  Description:   Fourth collection of SAS PROC SQL problems using 
*                 Patient data
*
*  Name:          Hantong Hu
*
*  Date:          1/31/2019                                        
*------------------------------------------------------------------- 
*  Job name:      SQLD1_hantongh.sas   
*
*  Purpose:       PROC SQL practice problem by using the Patient data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Patient data set PATIENT.PATIENTS, 
*					PATIENT.ADMITS
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=SQLD1;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0201_SQLD/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME patient "/folders/myfolders/BIOS-669/Data/Patients data for SQL unit/patients";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

proc sql;
	title 'All hospital admissions for females';
	select pt_id, admdate, primdx
		from patient.admits
		where pt_id in
			(select id
				from patient.patients
				where sex=2);
	title;
quit;
				















ods pdf close;
