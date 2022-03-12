*********************************************************************
*  Assignment:    LUTA                                     
*                                                                    
*  Description:   First collection of SAS Look-up table problems using 
*                 MET data
*
*  Name:          Hantong Hu
*
*  Date:          2/12/2019                                        
*------------------------------------------------------------------- 
*  Job name:      LUTA_hantongh.sas   
*
*  Purpose:       Look-up table practice problem by using the MET data.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MET data set omra_669
*
*  Output:        PDF file
*                                                                    
********************************************************************;

%LET job=LUTA;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0213_LUTA/Output;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/BIOS-669/Data/METS/METSdata";

ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

data medication;
	set mets.omra_669;
	keep bid WtLiabMed;
	
	where omra5a='Y' and omra4='06';
	
	WtLiabMed=scan(omra1,1);
run;
proc sort data=medication nodup; by bid; run;


DATA lookup;
	LENGTH med $15 class $4 ;
	INPUT med class ;
CARDS;
CLOZAPINE HIGH
ZYPREXA HIGH
RISPERIDONE HIGH
SEROQUEL HIGH
INVEGA HIGH
CLOZARIL HIGH
OLANZAPINE HIGH
RISPERDAL HIGH
ZIPREXA HIGH
LARI HIGH
QUETIAPINE HIGH
RISPERDONE HIGH
RISPERIDAL HIGH
RISPERIDOL HIGH
SERAQUEL HIGH
ABILIFY LOW
GEODON LOW
ARIPIPRAZOLE LOW
HALOPERIDOL LOW
PROLIXIN LOW
ZIPRASIDONE LOW
GEODONE LOW
HALDOL LOW
PERPHENAZINE LOW
FLUPHENAZINE LOW
THIOTRIXENE LOW
TRILAFON LOW
TRILOFAN LOW
;


* Method 1: manually-created format with PUT;

proc format;
	value $medclass 'CLOZAPINE'='HIGH'
					'ZYPREXA'='HIGH'
					'RISPERIDONE'= 'HIGH'
					'SEROQUEL'='HIGH'
					'INVEGA'='HIGH'
					'CLOZARIL'='HIGH'
					'OLANZAPINE'='HIGH'
					'RISPERDAL'='HIGH'
					'ZIPREXA'='HIGH'
					'LARI'='HIGH'
					'QUETIAPINE'='HIGH'
					'RISPERDONE'='HIGH'
					'RISPERIDAL'='HIGH'
					'RISPERIDOL'='HIGH'
					'SERAQUEL'='HIGH'
					'ABILIFY'='LOW'
					'GEODON'='LOW'
					'ARIPIPRAZOLE'='LOW'
					'HALOPERIDOL'='LOW'
					'PROLIXIN'='LOW'
					'ZIPRASIDONE'='LOW'
					'GEODONE'='LOW'
					'HALDOL'='LOW'
					'PERPHENAZINE'='LOW'
					'FLUPHENAZINE'='LOW'
					'THIOTRIXENE'='LOW'
					'TRILAFON'='LOW'
					'TRILOFAN'='LOW'
					other=' ';
run;

data medication_m1;
	set medication;
	length class $5;
	class=put(WtLiabMed,$medclass.);
run;
	

* Method 2: Hash object;

data medication_m2;

    length class $5 med $30;

    IF _n_=1 THEN DO;
        DECLARE HASH medcat(DATASET:'work.lookup');
        medcat.DEFINEKEY('med');
        medcat.DEFINEDATA('class');
        medcat.DEFINEDONE();
        CALL MISSING(med,class);
    END;

    SET work.medication;

    rc=medcat.FIND(KEY:WtLiabMed);

    DROP rc med;
RUN;


* Method 3: SQL inner join;
PROC SQL;
    CREATE TABLE medication_m3 AS
        SELECT m.bid,m.WtLiabMed,t.class
            FROM medication AS m
            	left join
                 lookup AS t
                 on m.WtLiabMed=t.med
            group by bid
            order by bid;
QUIT;



* Examine data;

* Part a;
title 'a) A crosstab of classification * WtLiabMed ';
proc freq data=medication_m1;
	tables class*WtLiabMed/list missing;
run;
title;

* Part b;
title 'b) Check if three classification data produce the same result';
proc sort data=medication_m1; by bid WtLiabMed; run;
proc sort data=medication_m2; by bid WtLiabMed; run;
proc sort data=medication_m3; by bid WtLiabMed; run;
data combine;
	merge medication_m1(rename=(class=class1))
			medication_m2(rename=(class=class2))
			medication_m3(rename=(class=class3));
	by bid WtLiabMed;
run;

proc freq data=combine;
	tables class1*class2*class3/list missing;
run;
title;

* Part 3;
title 'c) A list of all BID/WtLiabMed combinations that were not classified as either HIGH or LOW';
proc print data=medication_m1;
	where missing(class)=1;
run;
title;

ods pdf close;
