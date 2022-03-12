*********************************************************************
*  Assignment:    SQLA                                         
*                                                                    
*  Description:   First collection of SAS PROC SQL problems using 
*                 Airline data
*
*  Name:          Hantong Hu
*
*  Date:          1/21/2019                                        
*------------------------------------------------------------------- 
*  Job name:      SQLA1_hantongh.sas   
*
*  Purpose:       PROC SQL practice problem by using the Airline data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Airline data set AIRLINE.PAYROLLMASTER, 
*					AIRLINE.MARCHFLIGHTS, AIRLINE.STAFFMASTER
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=SQLA1;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0123_SQLA/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME airline "/folders/myfolders/BIOS-669/Data/Airline data and documentation for SQL assignments/airline";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;



proc sql;
	title 'a) Complete form of payrollmaster data set';
	select * from airline.payrollmaster;

	title 'b) Employee ID, gender, job code, and salary summary';
	select empid, gender, jobcode, salary from airline.payrollmaster;
	
	title 'c) Employee ID, gender, job code, salary, and tax summary';
	select empid, gender, jobcode, salary,
	       salary/3 as Tax
		from airline.payrollmaster;

	title 'd) Employee ID, gender, job code, salary, and tax summary';
	select empid, gender, jobcode, salary format=dollar11.2,
	       salary/3 as Tax format=dollar11.2
		from airline.payrollmaster;

	title 'e) Employee ID, job code, salary, and tax summary for male employees';
	select empid, gender, jobcode, salary format=dollar11.2,
	       salary/3 as Tax format=dollar11.2
		from airline.payrollmaster
		where gender='M';

	title 'f) Employee ID, salary, and tax summary for male flight attendants';
	select empid, gender, jobcode, salary format=dollar11.2,
	       salary/3 as Tax format=dollar11.2
		from airline.payrollmaster
		where gender='M' and substr(jobcode,1,2)='FA';
	
	title 'g) Employee ID, salary (descending order), and tax summary for male flight attendants';
	select empid, gender, jobcode, salary format=dollar11.2,
	       salary/3 as Tax format=dollar11.2
		from airline.payrollmaster
		where gender='M' and substr(jobcode,1,2)='FA'
		order by salary desc;
	
	title 'h) Summary of high-pay employees';
	create table high_pay as
		select empid, gender, jobcode, salary format=dollar11.2
			from airline.payrollmaster
			where salary>112000
			order by empid;
quit;

title 'h) Summary of high-pay employees';
proc print data=high_pay; run;
title;

ODS pdf CLOSE;