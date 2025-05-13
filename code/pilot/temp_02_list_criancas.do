
/*******************************************************************************
  Project:   Guinea Bissau - Chilcare and motherhood

  Title:          temp_02_list_criancas
  Author:         Sara Restrepo Tamayo
  Date:           May 2025
  Version:        Stata 18
  Resume:         We only want to keep the name of the selected crianca + siblings
*******************************************************************************/

************************************************
**#                 0. Key Macros              *
************************************************

*Folder globals

di "current user: `c(username)'"

if "`c(username)'" == "sararestrepotamayo"{
	global github_dofiles "/Users/sararestrepotamayo/Documents/GitHub/guinea_bissau/guinea_bissau/code"
}

do "$github_dofiles/00_paths.do" 

************************************************
**#                1. Creating list            *
************************************************

use "$intermediate_data/Agregados Familiares.dta", clear

keep name_jardim name_crianca cod_jardim agre_fam10 agre_fam11_* agre_fam12_* agre_fam12_1_*

*Reshaping 1

	reshape long agre_fam11_ agre_fam12_ agre_fam12_1_ , i(name_crianca cod_jardim name_jardim agre_fam10) j(position)
	drop if agre_fam11_ == ""
	drop if agre_fam12_ > 8
	drop if agre_fam12_ == -888
	replace name_crianca = upper(name_crianca)
	replace agre_fam11_ = upper(agre_fam11_)
	drop position
	bys cod_jardim name_crianca: gen position = _n
	
*Reshaping 2

	reshape wide agre_fam11_ agre_fam12_ agre_fam12_1_, i(name_crianca cod_jardim name_jardim agre_fam10) j(position)
	
*Coding criancas
	bys cod_jardim (name_crianca): gen order = _n
	tostring order, replace
	
	gen cod_crianca = cod_jardim + "_" + order
	
	drop order
	
	order cod_jardim name_jardim name_crianca cod_crianca agre_fam10 agre_fam11_1 agre_fam12_1 agre_fam12_1_1 agre_fam11_2 agre_fam12_2 agre_fam12_1_2 agre_fam11_3 agre_fam12_3 agre_fam12_1_3 
