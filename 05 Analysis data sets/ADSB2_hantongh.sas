*********************************************************************
*  Assignment:    ADSB                                  
*                                                                    
*  Description:   Second collection of SAS Analysis data set using CHD data
*
*  Name:          Hantong Hu
*
*  Date:          2/26/2019                                        
*------------------------------------------------------------------- 
*  Job name:      ADSB2_hantongh.sas   
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

%LET job=ADSB2;
%LET onyen=hantongh;
%LET outdir=C:\Users\hantongh\Desktop\SASUniversityEdition\myfolders\BIOS-669\Assignment\0227_ADSB\Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME chd "C:\Users\hantongh\Desktop\SASUniversityEdition\myfolders\BIOS-669\Data\CHD data\CHD";

%include 'C:\Users\hantongh\Desktop\SASUniversityEdition\myfolders\BIOS-669\Assignment\0227_ADSB\Exclude_data_using_conditions_for_669.sas';
%Exclude_data_using_conditions (_DATA_IN=chd.chd_combine,
                                  _DATA_OUT=included2,
                                  _USE_PRIMARY_EXCLUSIONS=Yes /*Are you going to use primary exclusions? Answer no or Yes*/,
                                  _PRIMARY_EXCLUSIONS=race^in ('B','W') ~ ^((Gender='M' and 600<TotCal<4200)|(Gender='F' and 500<TotCal<3600)),
                                  _SECONDARY_EXCLUSIONS= missing(BMI) ~ missing(DietMg) ~ missing(SerumMg),
                                  _NUMBER=1/*User defined word or number of the model which will appear in the name of rtf file, e.g. 1*/, 
                                  _PREDICTORS=race gender age BMI prevalentCHD /*List of ALL variables (including categorical, countable and continuous) to be included in table 2 separated by blanks*/, 
                                  _CATEGORICAL=race gender prevalentCHD /*List of the categorical variables to be included in table 2*/, 
                                  _COUNTABLE=_no_countable_predictors/*List of variables for which we estimate median to be included in table 2*/,
                                  _RQ=exclusions/*Characters to be included in the name of output RTF file, e.g. exclusions*/,
                                  _FOOTNOTE=%str(&sysdate, &systime -- produced by macro Exclude_data_using_conditions) /*Footnote*/,
                                  _ID=ID /*ID variable*/,
                                   _odsdir=&outdir,
                                  _COUNT=/*List of conditions for which we calculate counts, for example outcomes separated by ~*/,
                                  _TITLE1=Exclude_data_using_conditions Macro/*Title which appears in the rtf file*/)

