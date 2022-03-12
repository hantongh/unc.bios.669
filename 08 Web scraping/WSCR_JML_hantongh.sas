*********************************************************************
*  Assignment:    WSCR                                
*                                                                    
*  Description:   First collection of SAS Web scraping practice
*
*  Name:          Hantong Hu
*
*  Date:          3/19/2019                                        
*------------------------------------------------------------------- 
*  Job name:      WSCR_JML_hantongh.sas   
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

%LET job=WSCR_JML;
%LET onyen=hantongh;
%LET outdir=/folders/myfolders/BIOS-669/Assignment/0320_WSCR;
libname lib "/folders/myfolders/BIOS-669/Assignment/0320_WSCR";

OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";


ODS pdf FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

data player;
	set lib.player_per_game_table;
	
	retain totmember;
	length totmember $30;
	
	if rk='Rk' then delete;
	
	if tm='TOT' then totmember=player;
		else if player=totmember then delete;

	FG_percent=input(fg_,best.);
	AST_num=input(ast,best.);
	
	drop totmember FG_ AST;
run;

title 'Average field goal percentage and average assists per game by position';
proc means data=player (rename=(fg_percent=FG_ AST_num=AST));
	var FG_ AST;
	class POS;
run;

ods pdf close;