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
*  Job name:      SQLE1_hantongh.sas   
*
*  Purpose:       PROC SQL practice problem by using the airline data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         airline.internationalflights
*
*  Output:        None (macro variable)
*                                                                    
********************************************************************;

%LET job=SQLE1;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0206_SQLE/Output;

OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME airline "/folders/myfolders/BIOS-669/Data/Airline data and documentation for SQL assignments/airline";

proc sql noprint;
	select distinct destination into :n_destination separated by ' '
		from airline.internationalflights;
	
	%put destination=&n_destination;
quit;





