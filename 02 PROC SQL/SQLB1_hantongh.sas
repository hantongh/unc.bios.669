*********************************************************************
*  Assignment:    SQLB                                         
*                                                                    
*  Description:   Second collection of SAS PROC SQL problems using 
*                 Airline data
*
*  Name:          Hantong Hu
*
*  Date:          1/24/2019                                        
*------------------------------------------------------------------- 
*  Job name:      SQLB1_hantongh.sas   
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

%LET job=SQLB1;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0125_SQLB/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME airline "/folders/myfolders/BIOS-669/Data/Airline data and documentation for SQL assignments/airline";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

proc format;
	value $aircode
			'CPH'='Copenhagen'
			'DFW'='Dallas/Ft. Worth'
			'FRA'= 'Frankfurt'
			'LAX'= 'Los Angeles'
			'LGA'= 'New York'
			'LHR'= 'London'
			'ORD'= 'Chicago'
			'CDG'= 'Paris'
			'WAS'= 'Washington'
			'YYZ'= 'Toronto'
			' '='Not Specified'
			other='Other';
run;

proc sql;
	title 'a) Average passenger filling status for each destination of March flights';
	select destination format=$aircode.,
	       mean((boarded+transferred+nonrevenue)/passengercapacity) as AveragePct format=percent9.2
		from airline.marchflights
		group by destination
		order by averagepct desc;
	title;
		
	title 'b) Average passenger filling status less than 75%';
	select destination format=$aircode.,
	       mean((boarded+transferred+nonrevenue)/passengercapacity) as AveragePct format=percent9.2
		from airline.marchflights
		group by destination
		having AveragePct<0.75
		order by averagepct desc;
	title;
quit;


ods pdf close;