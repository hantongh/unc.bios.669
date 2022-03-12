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
*  Job name:      SQLE4_hantongh.sas   
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

%LET job=SQLE4;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0206_SQLE/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME airline "/folders/myfolders/BIOS-669/Data/Airline data and documentation for SQL assignments/airline";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;


proc sql;
	title 'Flights to Dallas (DFW) that were not delayed for two days in a row';
	select a.flightnumber,
			a.date as FirstDate,
			b.date as SecondDate,
			a.delay as FirstDelay,
			b.delay as SecondDelay
		from airline.flightdelays as a, airline.flightdelays as b
		where a.destination='DFW' and
				a.destination=b.destination and
				a.flightnumber=b.flightnumber and
				firstdate+1=seconddate and
				firstdelay<=0 and seconddelay<=0;
quit;
		

ods pdf close;
