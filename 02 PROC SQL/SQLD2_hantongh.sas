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
*  Job name:      SQLD2_hantongh.sas   
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

%LET job=SQLD2;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0201_SQLD/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME airline "/folders/myfolders/BIOS-669/Data/Airline data and documentation for SQL assignments/airline";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;


proc sql;
	title 'a) Maximum delay experienced for each flight number';
	select flightnumber, max(delay) as MaxDelay
		from airline.flightdelays
		group by flightnumber
		order by maxdelay desc;
	title;
	
	title 'b) Maximum delay experienced by each of the destinations';
	select destination, max(delay) as MaxDelay
		from airline.flightdelays
		group by destination
		order by maxdelay desc;
	title;
	
	title 'c) Average delay experienced by each of the destinations';
	select destination, mean(delay) as MeanDelay
		from airline.flightdelays
		group by destination
		order by meandelay desc;
	title;
	
	title 'd) Average delay experienced for all flights';
	select mean(delay) as MeanDelay
		from airline.flightdelays;
	title;

	title 'e) Destinations having average delay greater than the overall average delay for all flights';
	select destination, mean(delay) as MeanDelay
		from airline.flightdelays
		group by destination
		having calculated meandelay> 
			(select mean(delay)
			from airline.flightdelays)
		order by meandelay desc;
	title;
quit;



ods pdf close;
