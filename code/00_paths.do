
/*******************************************************************************
  Project:   Guinea Bissau - Chilcare and motherhood

  Title:          00_paths
  Author:         Sara Restrepo Tamayo
  Date:           May 2025
  Version:        Stata 18
  Resume:         Please put your path
  
*******************************************************************************/

clear all
set matsize 10000
set maxvar 12000


************************************************
**#                0. Key Macros               *
************************************************

*Folder globals

di "current user: `c(username)'"


if "`c(username)'" == "sararestrepotamayo"{
	global github_dofiles "/Users/sararestrepotamayo/Documents/GitHub/guinea_bissau/code"
	global path "/Users/sararestrepotamayo/Dropbox/Examples"
	global raw_data "$path/data/raw_data"
}
