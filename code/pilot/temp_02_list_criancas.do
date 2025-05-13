
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

*All siblings

use "$intermediate_data/Agregados Familiares.dta", clear

keep name_jardim name_crianca cod_jardim agre_fam10 agre_fam11_* agre_fam12_* agre_fam12_1_* eligi08 eligi09

*Reshaping 1

	reshape long agre_fam11_ agre_fam12_ agre_fam12_1_ , i(name_crianca cod_jardim name_jardim agre_fam10 eligi08 eligi09) j(position)
	drop if agre_fam11_ == "" & agre_fam10 != 0
	
	replace agre_fam11_ = "" if agre_fam12_ > 8 & agre_fam12_ != . 
	replace agre_fam11_ = "" if agre_fam11_ == "_888"
	
	replace agre_fam12_ = . if agre_fam12_ > 8 & agre_fam12_ != .
	replace agre_fam12_ = . if agre_fam12_ == -888

	replace agre_fam12_1_ = . if agre_fam12_ > 8 & agre_fam12_ != .
	drop position
	bys cod_jardim name_crianca (agre_fam12_): gen position = _n
	keep if position == 1 | (position > 1 & agre_fam11_ != "")
	
	replace name_crianca = upper(name_crianca)
	replace agre_fam11_ = upper(agre_fam11_)
	drop position
	bys cod_jardim name_crianca: gen position = _n
	
*Reshaping 2

	reshape wide agre_fam11_ agre_fam12_ agre_fam12_1_, i(name_crianca cod_jardim name_jardim agre_fam10 eligi08 eligi09) j(position)
	
*Coding criancas
	bys cod_jardim (name_crianca): gen order = _n
	tostring order, replace
	
	gen cod_crianca = cod_jardim + "_" + order
	
	drop order
	
	order cod_jardim name_jardim name_crianca cod_crianca eligi08 eligi09 agre_fam10
	
	keep name_jardim name_crianca cod_jardim cod_crianca
	
	sort name_jardim name_crianca cod_jardim
	tempfile crianca_id
	save `crianca_id'
	
* Attending same childcare

use "$intermediate_data/Agregados Familiares.dta", clear

keep name_jardim name_crianca cod_jardim eligi08 eligi09 index_eligi10_* eligi10_*
	foreach var in eligi10_1 eligi10_2 eligi10_3 name_crianca{
		replace `var' = upper(`var')
	}

	merge 1:1 name_jardim name_crianca cod_jardim using `crianca_id', nogen
