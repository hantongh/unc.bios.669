*********************************************************************
*  Assignment:    ADSB                                  
*                                                                    
*  Description:   Second collection of SAS Analysis data set using CHD data
*
*  Name:          Hantong Hu
*
*  Date:          2/26/2019                                        
*------------------------------------------------------------------- 
*  Job name:      ADSB1_hantongh.sas   
*
*  Purpose:       Creating an analysis data set - focusing on excluded
*					observations by using the CHD data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         CHD data sets
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=ADSB1;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0227_ADSB/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME chd "/folders/myfolders/BIOS-669/Data/CHD data/CHD";


ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

* 1. Use the medications_wide data set to create variables indicating diuretic use and use of lipid
lowering medications;

data med_diur_lipid;
	set chd.medications_wide;

	array code(17) drugcode1-drugcode17;
	
	do i=1 to 17;
		if '370000'<=code(i)<='380000' then do;
			Diuretic=1;
			continue;
		end;
		
		if code(i) in ('390000', '391000', '240600') then do;
			LipidLowerMed=1;
			continue;
		end;
	end;
	
	if diuretic=. then diuretic=0;
	if lipidlowermed=. then lipidlowermed=0;
	
	keep ID Diuretic LipidLowerMed;
run;

data chd.med_diur_lipid; set med_diur_lipid; run;

title '1. One-way frequency tables for Diuretic and LipidLowerMed';
proc freq data=med_diur_lipid;
	tables diuretic / missing;
run;
ods startpage=off;
proc freq data=med_diur_lipid;
	tables lipidlowermed / missing;
run;
ods startpage=on;


* 2. Combine the core, nutrition, measurements, and new meds data sets;
proc sql;
	create table combine(drop=mid) as
		select c.*, n.magnesium as DietMg,
				m.*, med.diuretic, med.lipidlowermed
			from chd.core as c
					left join
				chd.nutrition as n
					on n.id=c.id
					left join
				chd.measurements(rename=(magnesium=SerumMg id=mid)) as m
					on m.mid=c.id
					left join
				med_diur_lipid as med
					on med.id=c.id;
quit;

data chd_combine;
	set combine;
	if diuretic=. then diuretic=0;
	if lipidlowermed=. then lipidlowermed=0;
run;

data chd.chd_combine; set chd_combine; run;

title '2. PROC CONTENTS on combined data set produced by step 2';
proc contents data=chd_combine; run;
title '2.  One-way frequency tables for Diuretic and LipidLowerMed (step 2)';
proc freq data=chd_combine;
	tables diuretic / missing;
run;
ods startpage=off;
proc freq data=chd_combine;
	tables lipidlowermed / missing;
run;
ods startpage=on;

*3. Subset the data set made in step 2 to obtain the observations 
to be used for manuscript;
data manuscript;
	set chd_combine;
	
	if race in ('B','W');
	if (gender='F' and 500<totcal<3600) or (gender='M' and 600<totcal<4200);
	if missing(bmi)=0 and missing(serummg)=0 and missing(dietmg)=0;
run;

data chd.manuscript; set manuscript; run;

title '3. PROC CONTENTS on the step 3 data set';
proc contents data=manuscript; run;

title '3. One-way frequency tables of Race and Gender';
proc freq data=manuscript;
	tables race / missing;
run;
ods startpage=off;
proc freq data=manuscript;
	tables gender / missing;
run;
ods startpage=on;

title '3. PROC MEANS on variables TotCal, BMI, and the two
magnesium variables DietMg and SerumMg';
proc means data=manuscript n nmiss mean min max;
	var totcal;
run;
ods startpage=off;
proc means data=manuscript n nmiss mean min max;
	var bmi;
run;
proc means data=manuscript n nmiss mean min max;
	var dietmg;
run;
proc means data=manuscript n nmiss mean min max;
	var serummg;
run;
ods startpage=on;


*5. Optionally, derive Diuretic and LipidLowerMed using medications_long 
data set;
data long_diur_lipid;
	set chd.medications_long;
	by id;
	
	retain Diuretic LipidLowerMed;
	if first.id then do;
		diuretic=0;
		lipidlowermed=0;
	end;
	
	if '370000'<=drugcode<='380000' then Diuretic=1;
	if drugcode in ('390000', '391000', '240600') then LipidLowerMed=1;
	
	if last.id then output;
	
	keep id Diuretic LipidLowerMed;
run;

title '5. One-way frequency tables for Diuretic and LipidLowerMed';
proc freq data=med_diur_lipid;
	tables diuretic / missing;
run;
ods startpage=off;
proc freq data=med_diur_lipid;
	tables lipidlowermed / missing;
run;
ods startpage=on;

title '5. Proc Compare of data set in step 1 and 5';
proc compare base=med_diur_lipid compare=long_diur_lipid;
run;


ods pdf close;