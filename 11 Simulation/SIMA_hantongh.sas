*********************************************************************
*  Assignment:    SIMA                                  
*                                                                    
*  Description:   First collection of exercises with SAS simulation
*
*  Name:          Hantong Hu
*
*  Date:          4/18/2019                                        
*------------------------------------------------------------------- 
*  Job name:      SIMA_hantongh.sas   
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

%LET job=SIMA;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0419_SIMA;

OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
ods noproctitle;

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

/* Part I – Simulating univariate data */

* 1. Using a DATA step, produce a sample of 300 values
from the geometric distribution with a 1/4 probability of success. ;
%let n1=300;

data geometric(keep=x);
	call streaminit(0418);
	
	p=1/4;
	do i=1 to &n1.;
		x=rand('GEOMETRIC',p);
		output;
	end;
run;

title 'Check geometric sampling for reasonableness';
proc freq data=geometric;
	tables x/plots=freqplot;
run;
title;

* 2. Using a DATA step, generate 1000 records on each of which 
there are two simulated variables x and y. 
Variable x should be sampled from the normal distribution with 
mean 12 and standard deviation 4. 
Variable y should be sampled from the Bernoulli distribution with
 a 1/5 probability of success.;

%let n2=1000;

data normbern(keep=x y);
	call streaminit(0418);
	
	* Parameter for x;
	mu=12; sigma=4;
	
	* Parameter for y;
	p=1/5;
	
	do i=1 to &n2.;
		x=rand('NORMAL',mu,sigma);
		y=rand('BERNOULLI',p);
		output;
	end;
run;

title 'Check normal sample (mean=12, std=4) and bernoulli sample (p=0.2)';
proc means data=normbern;
	var x;
run;
ods startpage=off;
proc freq data=normbern;
	tables y;
run;
proc univariate data=normbern noprint;
	histogram x;
run;
proc sgplot data=normbern;
	vbar y;
run;
ods startpage=on;
title;

* 3. Using a DATA step, generate 300 integers uniformly distributed on or
 between 55 and 65.;

%let n3=300;

data uniform(keep=x);
	call streaminit(0418);
	
	a=55;
	b=65;
	
	do i=1 to &n3.;
		x=a+rand('UNIFORM')*(b-a);
		output;
	end;
run;

title 'Check uniform distribution between 55 and 65';
proc means data=uniform;
	var x;
run;
ods startpage=off;
proc sgplot data=uniform;
	histogram x;
run;
proc sgplot data=uniform ;
	scatter x=x y=x;
run;
ods startpage=on;
title;

* 4. Using PROC IML, produce a sample of 300 values from the geometric 
distribution with a 1/4 probability of success. Use a RANDSEED value that
 is the same as the STREAMINIT value you used in #1. ;
%let n4=300;

proc iml;
	call randseed(0418);
	
	geo=j(1,&n4.);
	p=1/4;
	
	call randgen(geo,'GEOMETRIC',p);
	/*print geo;
	reset print;*/
	
	cats=unique(geo);
	cats_c=char(cats,2);
	
	counts=j(ncol(cats),1,0);

	do i=1 to ncol(cats); * operate loop for each unique bin value;
		idx=loc(geo=cats[i]);
		counts[i]=NCOL(idx); * count number of cols returned by LOC;
	end;
	
	title 'Check geometric distribution of PROC IML and data step';
	print counts[ROWNAME=cats_c];
run;

ods startpage=off;
proc freq data=geometric;
	tables x;
run;
title;
ods startpage=on;

/* Part II – Simulating realistic data for a hypothetical study/clinical trial */

data baseline(keep=ID Visit BaseDate Gender Weight Age Smoke TRT)
		followup(keep=ID Visit Gender AE);
	call streaminit(0418);
	
	array aelist [4] $16 _temporary_ ('No AE','Flushing','Headache','Itching');
	
	mweightmu=187; mweightstd=30;
	fweightmu=165; fweightstd=30;
	
	smokep=1/8; trtp=0.5;
	
	startdate='01JAN2017'd;
	
	
	do ID=101 to 500;
	
		* Baseline data set;
		visit=1;
		
		BaseDate=startdate + int(RAND('UNIFORM')*90);

		age=int(20+(31-20)*rand('UNIFORM'));
		
		if rand('UNIFORM')>0.5 then do;
			gender='M';
			weight=rand('NORMAL',mweightmu,mweightstd);
			if rand('BERNOULLI',trtp)=1 then trt='C';
			else trt='P';
		end;
		else do;
			gender='F';
			weight=rand('NORMAL',fweightmu,fweightstd);
			if rand('BERNOULLI',trtp)=1 then trt='C';
			else trt='P';
		end;
		
		smoke=rand('BERNOULLI',smokep);
		
		format basedate mmddyy10. weight 8.2;
		
		output baseline;
		
		* Follow up data set;
		visit=2;
		
		if gender='M' then do;
			AE = aelist[RAND('TABLE',.6,.1,.15,.15)];
		end;
		else do;
			AE = aelist[RAND('TABLE',.7,.05,.2,.05)];
		end;
		
		output followup;

	end;
run;

title 'Check baseline data set';
title2 'ID Visit BaseDate Gender Weight Age Smoke TRT';
proc freq data=baseline;
	tables visit gender age smoke trt gender*trt/missing;
run;
ods startpage=off;
proc tabulate data=baseline;
	var basedate;
	table basedate, n nmiss (min max median)*f=mmddyy10. range;
run;
proc means data=baseline;
	class gender;
	var weight;
run;
title;
proc sgpanel data=baseline;
	panelby gender;
	histogram weight;
run;
ods startpage=on;

title 'Check follow-up data set';
title2 'ID Visit Gender AE';
proc freq data=followup;
	tables visit gender gender*ae/missing;
run;
title;

ods pdf close;