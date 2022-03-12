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
*  Job name:      SQLA3_hantongh.sas   
*
*  Purpose:       PROC SQL practice problem by using the Airline data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Airline data set AIRLINE.STAFFMASTER
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=SQLA3;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0123_SQLA/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME airline "/folders/myfolders/BIOS-669/Data/Airline data and documentation for SQL assignments/airline";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

data STAFFMASTER; set airline.STAFFMASTER; run;

proc sql;
	title 'a) List of cities where employees live';
	select distinct city
		from airline.STAFFMASTER
		order by city;
	
	title 'b) Number of distinct last names of employees';
	select count(distinct lastname) as Counts
		from airline.STAFFMASTER;
	
	title 'c) Frequency of distinct last names of employees';
	select lastname, count(lastname) as Frequency
		from airline.STAFFMASTER
		group by lastname;
	
quit;



ODS pdf CLOSE;