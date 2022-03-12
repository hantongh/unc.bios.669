*********************************************************************
*  Assignment:    SIMB                                  
*                                                                    
*  Description:   Second collection of exercises with SAS simulation
*
*  Name:          Hantong Hu
*
*  Date:          4/23/2019                                        
*------------------------------------------------------------------- 
*  Job name:      SIMB_hantongh.sas   
*
*  Purpose:       SAS Simulation practice.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         N/A
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=SIMB;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0424_SIMB;

OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
ods noproctitle;

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

/* Part I – Monte Carlo simulations */

* 1. Use PROC IML or the DATA step and procedures to estimate 
the sampling distribution for the maximum of 10 uniform random variates, 
based on 1000 samples. Display summary statistics for the distribution.; 

%let n=10;
%let m=1000;

data SimUni;
	call streaminit(0423);
	
	do sampleid=1 to &m.;
		do i=1 to &n.;
			x=rand('UNIFORM');
			output;
		end;
	end;
run;

proc means data=simuni noprint;
	by sampleid;
	var x;
	output out=maxuni(drop=_freq_ _type_) max=Maximum;
run;

title 'Part I - 1. Sample distribution of Max generated from UNIFORM distribution';
proc means data=maxuni;
	var Maximum;
run;
ods startpage=off;
proc sgplot data=maxuni;
	histogram Maximum;
	density Maximum / type=kernel;
run;
ods startpage=on;

*  Do an analysis to show the probability that the maximum would be 
less than 0.8.;
data testmax;
	set maxuni;
	smallmax=(maximum<0.8);
run;

title 'Part I - 1.Probability of Maximum < 0.8';
title2 '0: >=0.8, 1: <0.8';
proc freq data=testmax;
	tables smallmax / nocum;
run;
title;


*2. When sampling an odd number of points from a normal distribution,
 it is known that the variance of the sample mean is about 64% of 
the variance of the sample median.;
%let n=31;
%let m=10000;

data SimNorm;
	call streaminit(0423);
	
	mu=0; std=1;
	
	do sampleid=1 to &m.;
		do i=1 to &n.;
			x=rand('NORMAL',mu,std);
			output;
		end;
	end;
run;

proc means data=simnorm noprint;
	by sampleid;
	var x;
	output out=medmeannorm(drop=_freq_ _type_) mean=Mean median=Median;
run;

title 'Part I - 2.Sample distribution of Mean and Median generated from NORMAL distribution';
proc means data=medmeannorm n var min max range;
	var mean median;
	output out=medmean var= / autoname;
run;
ods startpage=off;
proc sql;
	select mean_var/median_var label='Proportion of mean to median' from medmean;
run;
proc sgplot data=medmeannorm;
	histogram median/binwidth=0.05 transparency=0.5;
    histogram mean/binwidth=0.05 transparency=0.5;
	density median / type=kernel;
	density mean / type=kernel;
	xaxis label=' ';
run;
ods startpage=on;


* 3.  Do a graphical extension of I.1 above that would be
useful in determining the approximate N where the probability 
approaches 0 that the maximum of N uniform random variates, 
based on 1000 samples, is less than 0.8.;
%let m=1000;
proc iml;
	call randseed(0423);
	do n=1 to 30 by 2;
		x = J(&m.,n);
		call randgen(x,'UNIFORM');
		m = x[,<>];
		Mean = Mean(m);
		StdDev = STD(m);
		CALL QNTL(q,m,{0.05 0.95});
 /* compute proportion of statistics less than 0.8 */
 /* (works because (m < 0.8) is either 0 or 1) */
		Prob = mean(m<0.8);
 		both = N || Prob; * for our graph, need to save both N and Prob;
 		all = all // both; * stack results;
 	end;

	c = {"N" "Prob"};
	create forP from all[colname=c]; * write results to a data set;
	append from all;
	close forP;
quit;
title 'Part I - 3.Determine the approximate N where the probability approaches 0 that the maximum of
N uniform random variates, based on 1000 samples, is less than 0.8.';
title2 'N is approximately 29';
proc print data=forP noobs; run;
title;

/* Part II - Bootstrap simulation */
* Analyze original data set;
data versi;
	set sashelp.iris;
	where species='Versicolor';
run;

title 'Part II - Statistics of Original Data set';
proc means data=versi n mean std skewness;
	var petalwidth;
run;
ods startpage=off;
proc sgplot data=versi;
	histogram petalwidth;
run;
ods startpage=on;

* Select sample;
%let sample=5000;
proc surveyselect data=versi
					seed=0423
					out=width(rename=(replicate=SampleID))
					method=urs samprate=1
					reps=&sample outhits;
run;

proc means data=width noprint;
	by sampleid;
	var petalwidth;
	output out=outstats(drop=_type_ _freq_) skew=skewness std=std;
run;

* Analyze sample statistics;
TITLE 'Part II - Descriptive Statistics for Bootstrap Distribution';
proc means data=outstats;
	var skewness std;
run;
ods startpage=off;
proc sgplot data=OutStats;
	histogram Skewness/transparency=0.5 legendlabel='Skewness';
	histogram std/transparency=0.5 legendlabel='Standard Deviation';
run;
TITLE;
ods startpage=on;

ods pdf close;