*********************************************************************
*  Assignment:    RPTC                                  
*                                                                    
*  Description:   Third collection of SAS PROC REPORT 
*				  Use a provided macro to produce a comparative METS report
*
*  Name:          Hantong Hu
*
*  Date:          3/28/2019                                        
*------------------------------------------------------------------- 
*  Job name:      RPTC_hantongh.sas   
*
*  Purpose:       Creating a comparative METS report
*				   by using a data set.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         make_rptc data set
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=RPTC;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0329_RPTC/;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME lib "/folders/myfolders/BIOS-669/Assignment/0329_RPTC";

%include "/folders/myfolders/BIOS-669/Assignment/0329_RPTC/Compare_baseline_669_ue.sas";

* Part 1;
%Compare_baseline_669 (_DATA_IN=lib.rptc   /*Name of the data set containing initial data - required*/,
                             _DATA_OUT=lib.rptc_pt1  /*data set to contain results - optional, omit parameter if not desired*/,
                             _NUMBER=1   /*User defined word or number of the model which will appear in the name of rtf file, e.g. 1*/, 
                             _GROUP=trt     /*by variable - required*/,
                             _PREDICTORS=race1 gender age bmi heartrate cholesterol /*List of variables to be included in a table separated by blanks - required*/, 
                             _CATEGORICAL=race1 gender /*List of ALL the categorical variables separated by blanks*/, 
                             _odsdir=&outdir,
                             _RQ=baseline_characteristics/*Characters to be included in the name of output RTF file, e.g. baseline_characteristics*/,
                             _FOOTNOTE=%str(&sysdate, &systime -- produced by macro Compare_baseline_669) /*Footnote*/,
                             _ID=BID      /*ID variable*/,
                             _COUNTABLE=age heartrate /*List of ALL the variables for which we estimate median and IQR*/,
                             _TITLE1=Compare_baseline_characteristics Macro/*Title which appears in the rtf file*/);
options nodate mprint pageno=1 mergenoby=warn MISSING=' ' validvarname=upcase;

* Part 2;
%let b=.; %let c=...; %let d=.......;

data display;
	set lib.rptc_pt1;
	length characteristic $200;
	
	if variable="AGE" then do;
		characteristic="{\i \ul Baseline Characteristics\line \line \ul0 \i0 &c Age (yr)}";
		order=1;
	end;
	
	if variable="BMI" then do;
		characteristic="{&c BMI (wt/ht\super 2}{)}{ (25\super th}{, 75\super th}{)}";
		order=2;
	end;

	if variable="GENDER" and label="Sex" then do;
		characteristic="&c Gender";
		order=3;
	end;
	if variable="GENDER" and label="- F" then do;
		characteristic="{&d \i Female}";
		order=4;
	end;
	if variable="GENDER" and label="- M" then do;
		characteristic="{&d \i Male}";
		order=5;
	end;

	if variable="RACE1" and label="" then do;
		characteristic="&c Race";
		order=6;
	end;
	if variable="RACE1" and label="- Black" then do;
		characteristic="{\i &d Black}";
		order=7;
	end;
	if variable="RACE1" and label="- White" then do;
		characteristic="{\i &d White}";
		order=8;
	end;
	if variable="RACE1" and label="- Other" then do;
		characteristic="{&d \i Other}";
		order=9;
	end;
	
	if variable="HEARTRATE" then do;
		characteristic="{&c Heart Rate (beats/min) (25\super th}{, 75\super th}{)}";
		order=10;
	end;

	if variable="CHOLESTEROL" then do;
		characteristic="&c Cholesterol (mg/dL)";
		order=11;
	end;

	if missing(order) then delete;
run;


ODS RTF FILE="&outdir./customised_table.RTF" style=journal bodytitle;
ods listing; title; footnote; ods listing close;

title1 J=center height=12pt font='ARIAL' bold "Final Results Publication";
title2 J=center height=11pt bold font='ARIAL' "{Table 1. Characteristics of the
Participants by Treatment Group}";
footnote1 J=left height=8.5pt font='ARIAL'
"{Note: Values expressed as N(%), mean ± standard deviation or median (25\super th}{,
75\super th }{percentiles)}" ; 
footnote2 J=left height=8.5pt font='ARIAL'
"P-value comparisons across treatment groups for categorical variables are based on
chi-square test of homogeneity; p-values for continuous variables are based on ANOVA 
or Kruskal-Wallis test for median" ;
Footnote3 J=left height=8.5pt font='ARIAL'" ";
Footnote4 J=right height=7pt font='ARIAL'
 "&sysdate, &systime -- Baseline Characteristics Macro";
 
%let st=style(column)=[just=center cellwidth=2.8 cm vjust=bottom font_size=8.5 pt]
 style(header)=[just=center font_size=8.5 pt];

proc report data=display nowd style=[cellpadding=6 font_size=8.5 pt rules=none];
	column order characteristic('Treatment Group' column_overall column_2 column_1 pvalue);
	define order / order noprint;
	define characteristic / display " " style=[just=left cellwidth=9.0 cm font_weight=bold font_size=8.5 pt];
	define column_2 / display "{Metformin\line (N=&count_2)}" &st ;
	define column_1 / display "{Placebo\line (N=&count_1)}" &st ;
	define column_overall / display "{Overall\line (N=&count_overall)}" &st;
	define pvalue / display "{p-value}" format=best4.2
		style(column)=[just=right cellwidth=2 cm vjust=bottom font_size=8.5 pt]
		style(header)=[just=right cellwidth=2 cm font_size=8.5 pt] ;
run;

ods rtf close; ods listing;

