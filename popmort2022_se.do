// Loss in Life Expectancy Does Not Adjust Confounding

// Data from http://www.mortality.org/
// Sweden, Death rates (period 1x1)
// Updated by 20240729 Enoch Chen

// Before this code was run all ages '110+' were replaces by '110' in order 
// for Stata to be able to recognize age as a numeric variable.

clear all
cd "/Users/yitche/Library/CloudStorage/OneDrive-KarolinskaInstitutet/ec_phd/Researchers/yuliya_leontyeva/Study_compLLE/simulation/"

infile _year _age female male total using "death_rates_sweden_from_HMD.txt" ///
if (_year > 1949 & _age <110 ), clear
drop if _year >= 2023
rename male rate1 
rename female rate2
rename total rate3
drop rate3 
reshape long rate, i(_year _age)
rename _j sex
gen prob=exp(-rate)

label data "Denish death rates from http://www.mortality.org/"
label variable rate "Death rate"
label variable prob "Survival probability"
label variable _year "Year of death"
label variable _age "Age"
label variable sex "Sex"

sort _year sex _age 

// Duplicates for 2023-2100
forvalues i = 2023/2100{
	expand 2 if _year == 2022, gen(dup)
	replace _year = `i' if dup == 1 & _year == 2022
	drop dup 
}
sort _year sex _age 

compress
label data "Death rates from HMD 1950-2022; 2023-2100 are duplicates from 2022"
save popmort2022_se, replace


