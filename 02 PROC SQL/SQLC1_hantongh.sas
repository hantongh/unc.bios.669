*********************************************************************
*  Assignment:    SQLC                                       
*                                                                    
*  Description:   Third collection of SAS PROC SQL problems using 
*                 Airline data
*
*  Name:          Hantong Hu
*
*  Date:          1/29/2019                                        
*------------------------------------------------------------------- 
*  Job name:      SQLC1_hantongh.sas   
*
*  Purpose:       PROC SQL practice problem by using the Airline data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Airline data set AIRLINE.STAFFMASTER, 
*					AIRLINE.PAYROLLMASTER
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=SQLC1;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0130_SQLC/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME airline "/folders/myfolders/BIOS-669/Data/Airline data and documentation for SQL assignments/airline";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

proc sql;
	title 'Employees with employment anniversaries in February';
	title2 'Ordered by lastname';
	select s.firstname, s.lastname
		from airline.staffmaster as s, airline.payrollmaster as p
		where s.empid=p.empid and month(p.dateofhire)=2
		order by s.lastname;
quit;







ods pdf close;