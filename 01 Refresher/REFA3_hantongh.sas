*********************************************************************
*  Assignment:    REFA                                         
*                                                                    
*  Description:   First collection of SAS refresher problems using 
*                 METS study data
*
*  Name:          Hantong Hu
*
*  Date:          1/15/2019                                        
*------------------------------------------------------------------- 
*  Job name:      REFA3_hantongh.sas   
*
*  Purpose:       Produce a display for evaluating whether treatment
*                 groups are fairly balanced across the METS sites.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set ieca_669, rdma_669
*
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=REFA3;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0116_REFA/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

proc sort data=mets.ieca_669 out=ieca; by BID; run;
proc sort data=mets.rdma_669 out=rdma; by BID; run;
proc sort data=mets.dr_669 out=dr; by BID; run;

data date_raw;
	merge dr(keep=bid psite)
			ieca(keep=bid ieca0b)
			rdma(keep=bid rdma0b);
	by bid;
	
	period=rdma0b-ieca0b;
	
run;

data date;
	set date_raw;
	where period<3 or period>14;
	
	label bid='ID' psite='Clinic site' ieca0b='Screening date'
			rdma0b='Randomization date' period='Observation period';
run;

title ' METS participants having less than 3 days or more than 14 days 
between screening and baseline visit';
proc print data=date label noobs;
run;

ODS pdf CLOSE;

