*********************************************************************
*  Assignment:    RPTA                                  
*                                                                    
*  Description:   First collection of SAS PROC REPORT using car2011 data
*
*  Name:          Hantong Hu
*
*  Date:          3/22/2019                                        
*------------------------------------------------------------------- 
*  Job name:      RPTA_hantongh.sas   
*
*  Purpose:       Creating a report - focusing on analyzing
*					observations by using the car2011 data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         car2011 data set
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=RPTA;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0322_RPTA;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME lib "/folders/myfolders/BIOS-669/Data/Selected BIOS 511 data/bios511data";


ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

data cars2011; set lib.cars2011; run;

* 1. Table 1 – Using aliases and a spanning header. For this report, use only cars 
from Ger, Jap, USA that have a non-missing baseMSRP value, which is what N should count.
 Note that the spanning header spans four columns, not three;

title 'Table 1.  Comparison of Car Characteristics across Various Countries';
proc report data=cars2011 nowd;
	columns country n ('Mean' basemsrp seating reliability satisfaction);
	define country / group 'Country of Origin';
	define n / 'N';
	define basemsrp/analysis mean format=dollar10.2 'Base Price' center;
	define seating /analysis mean format=3.1 'Number of Seats' center;
	define reliability /analysis mean format=3.1 'Reliability (lower is better)' center;
	define satisfaction/analysis mean format=3.1 'Satisfaction (lower is better)' center;
	where country in ('Germany','Japan','USA');
run;
title;

* 2. Table 2 – Using a COMPUTE block to create a new variable for display. 
 For this report, use only cars from Ger, Jap, USA that have both a non-missing CityMPG
 and a non-missing HwyMPG.  Be sure to skip a line between the two titles;

title1 'Table 2.  Average MPG of Cars from Different Countries';
title3 '(average MPG = average of city MPG and highway MPG)';
proc report data=cars2011 nowd;
	columns country citympg hwympg avgmpg;
	define country / group 'Country of Origin';
	define citympg / analysis mean noprint;
	define hwympg / analysis mean noprint;
	define avgmpg / computed 'Average MPG' format=4.1 center;
	
	compute avgmpg;
		avgmpg=(citympg.mean+hwympg.mean)/2;
	endcomp;
	
	where country in ('Germany','Japan','USA');
run;
title;


* 3. Table 3 – Two grouping variables with a break.  Note that only hatchbacks, 
SUVs, and sedans from the three countries shown should be used for this report.;

title 'Table 3.  Average MPG by Car Type and Country of Origin';
proc report data=cars2011 nowd;
	columns type country citympg hwympg;
	define type / group 'Type of Car';
	define country / group 'Country of Origin';
	define citympg / analysis mean 'City MPG' format=4.1;
	define hwympg / analysis mean 'Highway MPG' format=4.1;
	
	break after type / summarize STYLE=[BACKGROUNDCOLOR=ltgray];
	
	where country in ('Germany','Japan','USA') and type in ('Hatchback','SUV', 'Sedan');
run;
title;

* 4. Table 4 – A listing of all SUVs from Germany using spanning headers and 
STYLE options (including COMPUTE blocks used to specify STYLE options).  
Note that any 5’s in any of the three Quality columns should be bolded.  
(If you would really like to add one or two additional PROC and/or DATA steps 
to your program for this table in order to achieve a more elegant row shading
 solution, you can do so.);

data suvcount;
	set cars2011;
	by make country;
	
	where country='Germany' and type='SUV';
	retain count 0;
	
	if first.make then count=count+1;
run;
proc sql;
	create table cars as
	select c.*, s.count
		from cars2011 as c
			left join
			suvcount as s
			on c.make=s.make and c.model=s.model and c.type=s.type;
quit;


title 'Table 4.  German SUVs Available in the United States, 2011';
proc report data=cars nowd;
	columns count make model type ('MPG' citympg hwympg) ('Quality' reliability satisfaction ownercost5years);
	
	define count / display noprint; 
	define make / display 'Make';
	define model / display 'Model';
	define type / group noprint;
	define citympg / analysis mean 'City' format=4. center;
	define hwympg / analysis mean 'Highway' format=4. center;
	define reliability / display 'Reliability: 1=more, 5=less' center;
	define satisfaction / display 'Satisfaction: 1=more, 5=less' center;
	define ownercost5years / display 'Maintenance cost: 1=less, 5=more' center;
	
	compute count;
		if mod(count,2)=0 then do;
			CALL DEFINE(_row_,"STYLE","STYLE=[BACKGROUND=cxDDDDDD]");
		end;
	endcomp;
	compute reliability;
		if reliability=5 then do;
			call define(_col_,"STYLE","STYLE=[FONT_WEIGHT=Bold]");
 		end;
	endcomp;
	compute satisfaction;
		if satisfaction=5 then do;
			call define(_col_,"STYLE","STYLE=[FONT_WEIGHT=Bold]");
 		end;
	endcomp;
	compute ownercost5years;
		if ownercost5years=5 then do;
			call define(_col_,"STYLE","STYLE=[FONT_WEIGHT=Bold]");
 		end;
	endcomp;
	
	
	where country='Germany' and type='SUV';
run;


title;



ods pdf close;
