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
*  Job name:      SQLF2_hantongh.sas   
*
*  Purpose:       PROC SQL practice problem by using the MET data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MET data set dr_669, ieca_669, rdma_669
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=SQLF2;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0208_SQLF/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

proc sql;
	title ' METS participants having less than 3 days or more than 14 days 
		between screening and baseline visit';
	select s.bid, d.psite, s.ieca0b, r.rdma0b,
			r.rdma0b-s.ieca0b as Period label='Observation Period'
		from mets.dr_669 as d, mets.ieca_669 as s, mets.rdma_669 as r
		where s.bid=d.bid=r.bid and (r.rdma0b-s.ieca0b<3 or r.rdma0b-s.ieca0b>14);
    title;
quit;


ods pdf close;
