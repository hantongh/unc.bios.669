*********************************************************************
*  Assignment:    SQLE                                       
*                                                                    
*  Description:   Fifth collection of SAS PROC SQL problems using 
*                 airline data
*
*  Name:          Hantong Hu
*
*  Date:          2/5/2019                                        
*------------------------------------------------------------------- 
*  Job name:      SQLE3_hantongh.sas   
*
*  Purpose:       PROC SQL practice problem by using the airline data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         airline.payrollmaster
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=SQLE3;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0206_SQLE/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME airline "/folders/myfolders/BIOS-669/Data/Airline data and documentation for SQL assignments/airline";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

%macro emp_aboveavgsal(jobcode=);

	proc sql noprint;
		select mean(salary) into :avgsal_&jobcode.
			from airline.payrollmaster
			where jobcode="&jobcode.";
	quit;
	
	title "Employees (Job code: &jobcode.) having a salary above the average within this job";
	title2 "Average salary for &jobcode.: $ &&avgsal_&jobcode..";
	proc sql;
		select empid, jobcode, dateofhire, salary
			from airline.payrollmaster
			where jobcode="&jobcode."
			having salary>&&avgsal_&jobcode..;
	quit;

%mend;

%emp_aboveavgsal(jobcode=FA1);
%emp_aboveavgsal(jobcode=PT2);


ods pdf close;
