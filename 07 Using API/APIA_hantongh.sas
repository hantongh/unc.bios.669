*********************************************************************
*  Assignment:    APIA                                 
*                                                                    
*  Description:   First collection of SAS API practice
*
*  Name:          Hantong Hu
*
*  Date:          3/7/2019                                        
*------------------------------------------------------------------- 
*  Job name:      APIA_hantongh.sas   
*
*  Purpose:       Practicing using API to obtain data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         websites
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=APIA;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0308_APIA/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";


ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

ods noproctitle;

* 1. Using data pulled from https://worldcup.sfg.io/matches, compute statistics on 
attendance at each location used for the 2018 FIFA World’s Cup in Russia, where 
attendance and location are two pieces of data collected for each match (or game) 
and stored in the root data set;

filename results temp;

proc http
	url="%nrstr(https://worldcup.sfg.io/matches)"
	method='get'
	out=results;
run;

libname soccer json fileref=results;

data soccer;
	set soccer.root;
	attendance_num=input(attendance,best.);
run;

title '1. Statistics for attendance at each location in 2018 World Cup - Russia';
proc means data=soccer n mean std min max nonobs;
	var attendance_num;
	class location;
run;


* 2. Using the sunrise-sunset API, find the sunrise time (UTC), sunset time (UTC),
and day length for the location of your birth on the day that you were born;

%let location %nrstr(lat=31.16667&lng=121.46667);
%let birth %nrstr(date=1998-04-03);
%let website https://api.sunrise-sunset.org/json?&location.&&&birth.;

filename results temp;

proc http
	url="&website."
	method='get'
	out=results;
run;

libname sunrise json fileref=results;

title "2. Sunrise and sunset time and other statistics for Shanghai (&location.) on &birth.";
proc print data=sunrise.results;run;


* 3. Using data pulled from the open air quality API, compute mean ozone (o3) at 
9 AM, 2 PM, and 7 PM (three separate means) for the time span of March 1-6, 2019 in
Durham, NC;

filename results temp;
%let parameter=%nrstr(country=US&city=Durham&location=Durham Armory&limit=10000);


proc http
	url="https://api.openaq.org/v1/measurements/?&parameter."
	method='get'
	out=results;
run;

libname air json fileref=results
		map='/folders/myfolders/BIOS-669/Assignment/0308_APIA/measurements.user_meas.map';

proc sql;
	create table air as
		select parameter, value, local, substr(local,12,2) as Hour
			from air.meas
			where parameter='o3'
				and '03-01'<=substr(local,6,5)<='03-06' 
				and calculated hour in ('09','14','19');
quit;

title '3. Statistics for ozone value at Durham Armory (Durham, US)';
title2 'From Mar01-Mar06 (9AM, 2PM, 7PM)';
proc means data=air n mean std min max nonobs;
	var value;
	class hour;
run;
title;


* 4. Build a custom JSON map that will make a data set named books and pull
only book name, number of pages, and release time information from this API;

* Automap;
filename icefire1 temp;
proc http
	url="%nrstr(https://www.anapioficeandfire.com/api/books?page=1&pagesize=30)"
	method='get'
	out=icefire1;
run;

libname throne1 json fileref=icefire1
		automap=create;


* Custom map;
filename icefire2 temp;
proc http
	url="%nrstr(https://www.anapioficeandfire.com/api/books?page=1&pagesize=30)"
	method='get'
	out=icefire2;
run;

libname throne2 json fileref=icefire2
		map='/folders/myfolders/BIOS-669/Assignment/0308_APIA/iceandfire.books.map';

title '4. Book name, number of pages, and release time information from Ice and Fire';
proc print data=throne2.books; run;

ods pdf close;