*********************************************************************
*  Assignment:    WSCR                                
*                                                                    
*  Description:   First collection of SAS Web scraping practice
*
*  Name:          Hantong Hu
*
*  Date:          3/19/2019                                        
*------------------------------------------------------------------- 
*  Job name:      WSCR_SAS_hantongh.sas   
*
*  Purpose:       Practicing using web scraping to obtain data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         websites
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=WSCR_SAS;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0320_WSCR;

OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";


ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;


filename marvel url "https://www.imdb.com/title/tt4154664/fullcredits";

data marvel(keep=name);
	length name $30;
	
	infile marvel length=len lrecl=80;
	input line $VARYING32767. len;
	
	if prxmatch('/alt=.*title=/', line) and ~prxmatch('/list image/', line) then do;
		name=scan(line,6,'"');
	output;
	end;
	
run;

filename marvel clear;

proc print data=marvel; run;


ods pdf close;
