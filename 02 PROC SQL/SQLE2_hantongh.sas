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
*  Job name:      SQLE2_hantongh.sas   
*
*  Purpose:       PROC SQL practice problem by using the airline data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         airline.FLIGHTDELAYS
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=SQLE2;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0206_SQLE/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME airline "/folders/myfolders/BIOS-669/Data/Airline data and documentation for SQL assignments/airline";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

proc sql noprint;
	select mean(delay) as MeanDelay into :meandelay
		from airline.flightdelays;
quit;
	
proc sql;
	title 'Destinations having average delay greater than the overall average delay for all flights';
	title2 "Overall average delay: &meandelay.";
	select destination, mean(delay) as MeanDelay
		from airline.flightdelays
		group by destination
		having calculated meandelay>&meandelay.
		order by meandelay desc;
	title;
quit;

ods pdf close;