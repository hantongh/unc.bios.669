*********************************************************************
*  Assignment:    REGX                                  
*                                                                    
*  Description:   First collection of SAS regular expression practice
*
*  Name:          Hantong Hu
*
*  Date:          3/5/2019                                        
*------------------------------------------------------------------- 
*  Job name:      REGX_hantongh.sas   
*
*  Purpose:       Practicing regular expression to find patterns in
*					the omra1 variable of the METS omra_669 data set.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         omra_669
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=REGX;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0306_REGX/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";


ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

%macro regex(set=,reg=);

%LET exercise=%substr(&set.,4);
data &set.;
	set mets.omra_669;
	retain testRegEx;
	
	if _N_=1 then do;
		testRegEx=prxparse("/&reg./");
		
		if missing(testRegEx) then do;
			putlog 'ERROR regex is malformed';
			stop;
		end;
	end;
	
	if prxmatch(testRegEx, strip(omra1));
run;

title "&exercise.. OMRA1 matches &reg.";
%if &exercise=14 %then %do;
	title2 'Find all medication names that consist of words with more than 12 characters';
%end;

proc print data=&set.;
	var omra1;
run;

%mend;


* 1. Find all occurrences of ASPIRIN. ;
%let reg1=ASPIRIN;
%regex(set=reg1,reg=&reg1.);

* 2. Find all occurrences of ASPIRIN or its misspelling ASPRIN. ;
%let reg2=ASP\w*RIN;
%regex(set=reg2,reg=&reg2.);

* 3. Find all occurrences of ASPIRIN or its misspelling ASPRIN that include some kind of dosage
information as indicated by one or more digits in the medication value.;
%let reg3=ASP\w*RIN.*\d;
%regex(set=reg3,reg=&reg3.);

* 4. Find all occurrences of ROSAREM or ROZEREM.;
%let reg4=RO\w*REM;
%regex(set=reg4,reg=&reg4.);

* 5. Find all occurrences of SYNTHROID or SYNTHYROID.;
%let reg5=SYNTH\w*ROID;
%regex(set=reg5,reg=&reg5.);

* 6. Find all spellings of TRAZADONE (TRAZADONE, TRAZIDONE, TRAZODONE).;
%let reg6=TRAZ\w?DONE;
%regex(set=reg6,reg=&reg6.);

* 7. Find all medication names starting with ASPIRIN.;
%let reg7=^ASPIRIN;
%regex(set=reg7,reg=&reg7.);

* 8. Find all medication values that contain a % sign.;
%let reg8=\%;
%regex(set=reg8,reg=&reg8.);

* 9. Find all medication values that include dosage information in MG.;
%let reg9=\d*.*MG;
%regex(set=reg9,reg=&reg9.);

* 10. Find all medication values ending with one or more digits.;
%let reg10=\d$;
%regex(set=reg10,reg=&reg10.);

* 11. Find all medication values that contain PRO but not at 
the very beginning of the value.;
%let reg11=^[\w|\W].*PRO;
%regex(set=reg11,reg=&reg11.);

* 12. Find all medication names that contain three or fewer characters.;
%let reg12=%NRSTR(^\w{1,3}$);
%regex(set=reg12,reg=&reg12.);

* 13. Find all medication names that consist of four or more words
 (where a word is a sequence of characters separated from other sequences
 by spaces – it’s OK if a word is composed only of digits).;
%let reg13=^[\w\W]*\s[\w\W]*\s[\w\W]*\s[\w\W]*;
%regex(set=reg13,reg=&reg13.);

* 14. Suggest another interesting pattern to find in the med name values, 
and provide a solution.;
%let reg14=%NRSTR(\w{13,});
%regex(set=reg14,reg=&reg14.);


ods pdf close;