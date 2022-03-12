*********************************************************************
*  Assignment:    SQLC                                       
*                                                                    
*  Description:   Second collection of SAS PROC SQL problems using 
*                 Airline data
*
*  Name:          Hantong Hu
*
*  Date:          1/29/2019                                        
*------------------------------------------------------------------- 
*  Job name:      SQLC2_hantongh.sas   
*
*  Purpose:       PROC SQL practice problem by using the Airline data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Airline data set AIRLINE.FLIGHTSCHEDULE,
*					AIRLINE.STAFFMASTER
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=SQLC2;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0130_SQLC/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME airline "/folders/myfolders/BIOS-669/Data/Airline data and documentation for SQL assignments/airline";

ODS PDF FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

* a) Use PROC SQL to create an employee flight schedule data set 
	for flights in the first week of March;

proc sql;
	create table flights as
	select sch.flightnumber, sch.date,
			staff.firstname, staff.lastname, sch.empid,
			mar.departuretime, mar.destination
		from airline.staffmaster as staff,
				airline.flightschedule as sch,
				airline.marchflights as mar
		where sch.empid=staff.empid and 
				sch.flightnumber=mar.flightnumber and
				sch.date=mar.date and
				sch.destination=mar.destination
		order by sch.flightnumber, sch.date, staff.lastname, staff.firstname;
quit;

title 'a) Employee flight schedule for flights in the first week of March';
proc print data=flights (obs=10); run;
title;

* b) Produce the same data set as above but without PROC SQL;

proc sort data=airline.flightschedule out=schedule; by empid; run;
proc sort data=airline.staffmaster out=staff; by empid; run;

data sch_name;
	merge schedule(in=emp) staff(keep=empid firstname lastname);
	by empid;
	if emp;
run;

proc sort data=sch_name; by flightnumber date destination lastname firstname; run;
proc sort data=airline.marchflights out=march; by flightnumber date destination; run;

data fli_nosql;
	merge sch_name(in=sch) march(keep=flightnumber date destination departuretime);
	by flightnumber date destination;
	if sch;
run;

title 'b) Employee flight schedule for flights in the first week of March';
title2 'Not using PROC SQL';
proc print data=fli_nosql (obs=10); run;
title;


* c) Use PROC COMPARE to compare the output data set from (a) 
	with the output data set from (b). ;
	
proc compare base=flights compare=fli_nosql listall; run;

ODS PDF CLOSE;
