*********************************************************************
*  Assignment:    ADSA                                  
*                                                                    
*  Description:   First collection of SAS Analysis data set and graphing
*					 using Respiratory data
*
*  Name:          Hantong Hu
*
*  Date:          2/19/2019                                        
*------------------------------------------------------------------- 
*  Job name:      ADSA_DATA_hantongh.sas   
*
*  Purpose:       Analysis data set and graphing problem by 
*					using the Respiratory data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         Respiratory data set 
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=ADSA_DATA;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0222_ADSA/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME resp "/folders/myfolders/BIOS-669/Data/Respiratory study data/resp2018";
LIBNAME ADSA '/folders/myfolders/BIOS-669/Assignment/0222_ADSA';

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

/* Create Data set ADSA */

* Observations in CDF with agreed fakeid;
proc sql noprint;
    select "'"||fakeid||"'" into :withdraw separated by ','
        from resp.cdf2018
        where CDFA2='W';
    %put &withdraw.;
        
	create table cdf_agree as
	select distinct(fakeid)
		from resp.cdf2018
		where fakeid ^in (&withdraw.);
quit;

* Sort out participants in DEM and CDF (agreed);
data dem_agree;
	merge cdf_agree(in=incdf)
			resp.dem2018(in=indem rename=(dema2=sex));
			
	by fakeid;
	if incdf and indem;
	
	* Data changed particular to this assignment;
	if fakeid='1575' then dema6b='K';
	if fakeid='0524' then dema6b='P';
	if fakeid='0260' then dema6d='I';
	if fakeid='0804' then dema6d='C';
	
	* Change units into standard ones;
	if dema6b='K' then weight=dema6a;
		else weight=dema6a/2.205;
	if dema6d='C' then height=dema6c/100;
		else height=dema6c/39.37;
		
	keep fakeid sex visit weight height;
run;

* Obtain list of participant ID;
proc sql noprint;
	select "'"||fakeid||"'" into :idlist separated by ','
		from dem_agree;
quit;

* Merge CLN with DEM_AGREE as baseline observation;
proc sql;
	create table baseline as
		select d.*, 
			c.clnb1e as fev1,
			c.clnb1d as fvc,
			c.clnb1e1 as fev1_percent
			from dem_agree as d
				left join
				resp.cln2018 as c
				 on d.fakeid=c.fakeid;
quit;

* Merge FUP with baseline;
data fup;
	set resp.fup2018;
	
	if fakeid ^in (&idlist.) then delete;
	
	* Data changed particular to this assignment;
	if fakeid='0467' and visit=2 then fupa3b='P';
	if fakeid='0648' and visit=3 then fupa3b='K';
	if fakeid='0799' and visit=2 then fupa3b='P';
	if fakeid='1194' and visit=6 then fupa3b='P';
	if fakeid='1742' and visit=2 then fupa3b='K';
	if fakeid='1779' and visit=2 then fupa3b='P';
	
	* Change weight units into standard;
	if fupa3b='K' then weight=fupa3a;
		else weight=fupa3a/2.205;
	
	fev1=fupa4e;
	fvc=fupa4d;
	fev1_percent=fupa4e1;
	
	keep fakeid visit weight fev1 fvc fev1_percent;
run;


data adsa;
	merge baseline fup;
	by fakeid visit;
	
	* retain sex and height from baseline;
	retain sextemp heighttemp;
	
	if first.fakeid then do;
		sextemp=sex;
		heighttemp=height;
	end;
	else do;
		sex=sextemp;
		height=heighttemp;
	end;
	
	* Define BMI;
	BMI=weight/(height*height);
	
	* Define baseGOLD and GOLD;
	length baseGOLD GOLD $10;
	if visit=1 then do;
		if fev1^=. and fvc^=. and fev1_percent^=. 
			and fev1/fvc<0.7 then do;
				if fev1_percent>=80 then baseGOLD='Stage I';
				else if fev1_percent>=50 and fev1_percent<80 then baseGOLD='Stage II';
				else if fev1_percent>=30 and fev1_percent<50 then baseGOLD='Stage III';
				else if fev1_percent<30 then baseGOLD='Stage IV';
			end;
		else baseGOLD='At Risk';
	end;
	
	retain basegoldtemp;
	if first.fakeid then do;
		basegoldtemp=basegold;
	end;
	else do;
		basegold=basegoldtemp;
	end;
	

	if fev1^=. and fvc^=. and fev1_percent^=. 
			and fev1/fvc<0.7 then do;
				if fev1_percent>=80 then GOLD='Stage I';
				else if fev1_percent>=50 and fev1_percent<80 then GOLD='Stage II';
				else if fev1_percent>=30 and fev1_percent<50 then GOLD='Stage III';
				else if fev1_percent<30 then GOLD='Stage IV';
			end;
		else GOLD='At Risk';

	drop sextemp heighttemp basegoldtemp;
run;

data adsa.adsa; set adsa; run;

/* Check work */
ods noproctitle;
title 'a. PROC CONTENTS on the data set';
proc contents data=adsa; run;

title 'b. PROC PRINT of the first 10 observations of the data set';
proc print data=adsa(obs=10); run;

title 'c. A PROC PRINT of 20 observations and appropriate variables to enable checking
of the BMI variable';
proc print data=adsa(obs=20); var fakeid visit weight height bmi; run;

title 'd. A solid check of the baseGOLD variable for visit=1 records only';
proc means data=adsa maxdec=2  N NMISS MEAN MIN MAX;
	class basegold/missing;
	where visit=1;
run;

title 'e. A solid check of the GOLD variable';
proc means data=adsa maxdec=2  N NMISS MEAN MIN MAX;
	class gold/missing;
run;

title 'f. One-way frequency tables with the MISSING option';
title2 'i. Gender';
proc freq data=adsa;
	tables sex/missing nocum;
run;

title2 'ii. Visit';
proc freq data=adsa;
	tables visit/missing nocum;
run;

title2 'iii. BaseGOLD';
proc freq data=adsa;
	tables basegold/missing nocum;
run;

title2 'iv. GOLD';
proc freq data=adsa;
	tables gold/missing nocum;
run;
title;

title 'g. Cross-tab of visit and the GOLD variable';
proc freq data=adsa;
	tables visit*gold/list missing nocum;
run;

title 'h. PROC MEANS on BMI';
proc means data=adsa maxdec=3 N NMISS MEAN MIN MAX;
	var bmi;
run;

ods pdf close;