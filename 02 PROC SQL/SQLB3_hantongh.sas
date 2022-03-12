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
*  Job name:      SQLB3_hantongh.sas   
*
*  Purpose:       PROC SQL practice problem by using the Airline data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Airline data set AIRLINE.FLIGHTDELAYS
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=SQLB3;
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
	title 'a) Summary of times delayed for each flight number';
	select flightnumber,
			destination format=$aircode.,
			count(*) as TimesDelayed
		from airline.flightdelays
		where delay>0
		group by flightnumber, destination
		order by flightnumber;
	title;
	
	create table averagedelay as
		select destination format=$aircode.,
				mean(delay) as AverageDelay format=8.2
			from airline.flightdelays
			group by destination;
quit;
 
title 'b) Average time delay for each destination';
proc print data=averagedelay noobs;run;
title;

proc means data=airline.flightdelays nway noprint;
	class destination;
	var delay;
	format destination $aircode.;
	output out=delay(drop=_type_ _freq_) mean=AverageDelay;
run;

title 'c) Average time delay for each destination';
title2 'Using PROC MEANS';
proc print data=delay noobs;run;
title;



ods pdf close;