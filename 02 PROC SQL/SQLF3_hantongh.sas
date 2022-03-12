*********************************************************************
*  Assignment:    SQLF                                     
*                                                                    
*  Description:   Sixth collection of SAS PROC SQL problems using 
*                 MET data
*
*  Name:          Hantong Hu
*
*  Date:          2/7/2019                                        
*------------------------------------------------------------------- 
*  Job name:      SQLF3_hantongh.sas   
*
*  Purpose:       PROC SQL practice problem by using the MET data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set uvfa_669, CGIA_669, AESA_669,
*					SAEA_669, VSFA_669, AUQA_669, LABA_669
*					BSFA_669, and SMFA_669
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=SQLF3;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0208_SQLF/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
options orientation=landscape;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

proc sql;
	title 'Unscheduled visits form filling status';
	select u.bid, u.visit, u.uvfa1A, u.uvfa1B, u.uvfa1C, u.uvfa1D,
			u.uvfa0b, c.form, ae.form, sa.form, v.form, 
			au.form, l.form, b.form, sm.form
		from mets.uvfa_669 as u
			left join
				mets.cgia_669 as c
				on u.bid=c.bid and u.visit=c.visit and u.uvfa0b=c.cgia0b
			left join
				mets.aesa_669 as ae
				on u.bid=ae.bid and u.visit=ae.visit and u.uvfa0b=ae.aesa0b
			left join
				mets.saea_669 as sa
				on u.bid=sa.bid and u.visit=sa.visit and u.uvfa0b=sa.saea0b
			left join
				mets.vsfa_669 as v
				on u.bid=v.bid and u.visit=v.visit and u.uvfa0b=v.vsfa0b
			left join
				mets.auqa_669 as au
				on u.bid=au.bid and u.visit=au.visit and u.uvfa0b=au.auqa0b
			left join
				mets.laba_669 as l
				on u.bid=l.bid and u.visit=l.visit and u.uvfa0b=l.laba0b
			left join
				mets.bsfa_669 as b
				on u.bid=b.bid and u.visit=b.visit and u.uvfa0b=b.bsfa0b
			left join
				mets.smfa_669 as sm
				on u.bid=sm.bid and u.visit=sm.visit and u.uvfa0b=sm.smfa0b;
	title;
quit;

ods pdf close;
