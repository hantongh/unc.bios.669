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
*  Job name:      SQLA2_hantongh.sas   
*
*  Purpose:       PROC SQL practice problem by using the Airline data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Airline data set AIRLINE.MARCHFLIGHTS 
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=SQLA2;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0123_SQLA/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME airline "/folders/myfolders/BIOS-669/Data/Airline data and documentation for SQL assignments/airline";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

proc sql;
	title 'Passenger filling status of March flights';
	select date, flightnumber, boarded, transferred, nonrevenue,
	       sum(boarded,transferred,nonrevenue) as TotalPassenger,
	       passengercapacity,
	       calculated totalpassenger/passengercapacity as PctFull format=percent9.2
		from airline.marchflights;
quit;



ODS pdf CLOSE;