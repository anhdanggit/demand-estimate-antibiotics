
*******************************************
*** MEDICAM DATA PROCESSING ***************

*** Author: Mai-Anh Dang
*** Date: 18/12/2017

*** Input: OpenMedic_PHMEV\OPEN_PHMEV_ANIMAL_14_16.dta

clear all       
capture log close 
set type double
set more off, permanently
set excelxlsxlargefile on

// Change the cd to the directory of project
cd "C:\Users\utilisateur\Google Drive\M2 EEE Project Antibiotics"

// Load input data 
use "OpenMedic_PHMEV\OPEN_PHMEV_ANIMAL_14_16.dta", clear

rename PRICE PRIXMOY

// If we want to turn to panel
encode ATC5, gen(molecule)
xtset molecule YEAR


********************************************************
*** 1 - OLS 						   
********************************************************

reg lMARKETSHARE PRIXMOY LAG_MG d_*
// reg lMARKETSHARE PRIXMOY l.LAG_MG d_*



********************************************************
*** 2 - 2SLS										   *
********************************************************
	
	
* 2.1 - Instrument PRIXMOY by (ATC3dummy x countATC5inATC3) 
**********************************************************

* Count of # of ATC5 in each ATC3
bysort ATC3: egen COUNTATC5 = nvals(ATC5)

* Count of total number of ATC5 except the ones of the ATC3 at stake for each obs
egen COUNTOTHERATC5 = nvals(ATC5)
replace COUNTOTHERATC5 = COUNTOTHERATC5 - COUNTATC5

* Interaction terms dummy ATC3 and number of ATC5 in it
levelsof ATC3
foreach level in `r(levels)'{
	gen d2_`level' = (ATC3 == "`level'")
	gen INTER_`level' = d2_`level' * COUNTATC5
	}
drop d2_*

* 2SLS
eststo:
ivreg2 lMARKETSHARE (PRIXMOY = INTER_*) LAG_MG
est store IV1
	
	
eststo:
ivreg2 lMARKETSHARE (PRIXMOY = COUNTOTHERATC5)
est store IV2
