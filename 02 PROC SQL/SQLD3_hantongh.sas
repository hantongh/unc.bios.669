*********************************************************************
*  Assignment:    SQLD                                       
*                                                                    
*  Description:   Fourth collection of SAS PROC SQL problems using 
*                 Airline data
*
*  Name:          Hantong Hu
*
*  Date:          1/31/2019                                        
*------------------------------------------------------------------- 
*  Job name:      SQLD3_hantongh.sas   
*
*  Purpose:       PROC SQL practice problem by using the Airline data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Airline data set AIRLINE.STAFFMASTER
*					AIRLINE.FREQUENTFLYERS. 
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=SQLD3;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0201_SQLD/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME airline "/folders/myfolders/BIOS-669/Data/Airline data and documentation for SQL assignments/airline";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;


proc sql;
	title 'a) The number of employees who are also frequent flyers';
	select count(*) as Number
		from airline.staffmaster
		where firstname in 
				(select scan(name,2)
					from airline.frequentflyers)
			and lastname in	
				(select scan(name,1)
					from airline.frequentflyers);
	title;
	
	title 'b) Number of frequent flyer employees by member type';
	select membertype, count(*) as Number
		from airline.frequentflyers
		where name in 
				(select catx(', ',lastname, firstname)
					from airline.staffmaster)
		group by membertype;
	title;
quit;



ods pdf close;

