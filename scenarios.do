cd "/Users/yitche/Library/CloudStorage/OneDrive-KarolinskaInstitutet/ec_phd/Researchers/yuliya_leontyeva/Study_compLLE/simulation/"

/*===================
== Survival models ==
=====================*/

// Using the same popmort file. No age standardisation 
use simdata, clear
stset stime, failure(died = 1)

// Generate attained age and attained calendar year
gen _age=int(min(99,age+_t))
gen _year=int(min(2022,year(year+_t*365.24)))		

// Merge popmortfile
merge m:1 _age sex _year using "popmort2022_se", keepusing(rate)
drop _age _year _merge
drop if age == .

// FPRSM model
stpm3 @ns(age, df(3)) trt, scale(lncumhazard) bhazard(rate) df(5) ///
						   tvc(@ns(age, df(3)) trt) dftvc(3)
range temptime 0 100 1201
gen t100 = 100

/*==============
// Scenario 1 //
===============*/
cap drop *sc1
/* No age standardisation involved*/
// Plot age distributions
twoway (histogram age if trt == 0, frequency color(red%70)) ///
	   (histogram age if trt == 1, frequency color(blue%70)), ///
        xscale(range(0 100)) xlab(0(20)100) ///
		yscale(range(0 250)) ylab(0(50)250) ///
        legend(order(1 "No treatment X=0"  2 "Treatment X=1")) ///
		title("Scenario 1: Non-standardization") ///
		xtitle("Age (years)") ///
		text(250 70 "Age distribution X=1 ~ Normal(60,10)", size(medlarge) justification(left)) ///
		text(230 70 "Age distribution X=0 ~ Normal(50,10)", size(medlarge) justification(left)) //

graph export "./output/agedist_sc1.png", replace

// Estimate LE, LE_expected
standsurv, at1(trt 1, atif(trt == 1)) ///
		   at2(trt 0, atif(trt == 0)) ///
		   timevar(t100) rmst ///
		   atvars(le1_sc1 le0_sc1) ///
		   expsurv(using("popmort2022_se.dta") ///
							 agediag(age) ///    
							 datediag(diagdate) ///
							 pmage(_age) ///       
							 pmyear(_year) ///
							 pmother(sex) ///      
							 pmrate(rate) ///      
							 pmmaxyear(2022) ///    
							 expsurvvar(leexp1_sc1 leexp0_sc1))

global le1_sc1: display %-9.1f le1_sc1
global le0_sc1: display %-9.1f le0_sc1
global leexp1_sc1: display %-9.1f leexp1_sc1
global leexp0_sc1: display %-9.1f leexp0_sc1
global lle1_sc1: display $leexp1_sc1 - $le1_sc1
global lle0_sc1: display $leexp0_sc1 - $le0_sc1

global diff_le_sc1: display %-9.1f $le1_sc1 - $le0_sc1
global diff_leexp_sc1: display %-9.1f $leexp1_sc1 - $leexp0_sc1
global diff_lle_sc1: display %-9.1f $diff_leexp_sc1 - $diff_le_sc1
		
// Estimate overall survival, expected survival
standsurv, timevar(temptime) ///
		   at1(trt 1, atif(trt == 1)) ///
		   at2(trt 0, atif(trt == 0)) ///
		   atvars(os1_sc1 os0_sc1) ///
		   expsurv(using("popmort2022_se.dta")  ///  popmort 
							 agediag(age)     ///  age at diagnosis
							 datediag(diagdate)	///  date at diagnosis
							 pmage(_age)        ///  age variable in popmort 
							 pmyear(_year)      ///  year variable in popmort file		
							 pmother(sex)       ///  other variables in popmort
							 pmrate(rate)       ///  rate varible in popmort
							 pmmaxyear(2022)    ///  maximum year in popmort
							 expsurvvar(exps1_sc1 exps0_sc1))
							 
// Overall survival and expected survival
tw (line os1_sc1 temptime, lcolor(blue%70) lwidth(0.7) sort) ///
   (line os0_sc1 temptime, lcolor(red%70) lwidth(0.7) sort) ///
   (line exps1_sc1 temptime, lcolor(blue%70) lpattern(dash) lwidth(0.7) sort) ///
   (line exps0_sc1 temptime, lcolor(red%70) lpattern(dash) lwidth(0.7) sort), ///
   xtitle("Time (years)") ytitle("Survival probability") ///
   title("Scenario 1: Without age standardization") ///
   legend(order(1 "Overall survival, X=1" 2 "Overall survival, X=0" 3 "Expected survival, , X=1" 4 "Expected survival, X=0")) ///
   xscale(r(0 100)) ///
       text(1 35 "LE{superscript:X=1} = $le1_sc1", place(e) justification(left) size(medlarge)) ///
	   text(.9 35 "LE{superscript:X=0} = $le0_sc1", place(e) justification(left) size(medlarge)) ///	 
	   text(.8 35 "{&Delta}LE = $diff_le_sc1", place(e) justification(left) size(medlarge)) ///
 	   text(1 55 "LE{superscript:*X=1} = $leexp1_sc1", place(e) justification(left) size(medlarge)) ///
	   text(.9 55 "LE{superscript:*X=0} = $leexp0_sc1", place(e) justification(left) size(medlarge)) ///
	   text(.8 55 "{&Delta}LE{superscript:*} = $diff_leexp_sc1", place(e) justification(left) size(medlarge)) ///
	   text(1 80 "LLE{superscript:X=1} = $lle1_sc1", place(e) justification(left) size(medlarge)) ///
	   text(.9 80 "LLE{superscript:X=0} = $lle0_sc1", place(e) justification(left) size(medlarge)) ///
	   text(.8 80 "{&Delta}LLE = $diff_lle_sc1", place(e) justification(left) size(medlarge))
graph export "./output/sc1.png", replace
	   

// Estimate relative survival
standsurv, timevar(temptime) ///
		   at1(trt 1, atif(trt == 1)) ///
		   at2(trt 0, atif(trt == 0)) ///
		   atvars(rs1_sc1 rs0_sc1)

tw (line rs1_sc1 rs0_sc1 temptime, sort)


/*==============
// Scenario 2 //
===============*/
cap drop *sc2
/* Standardize to age distribution in trt == 1*/
// Plot age distributions
twoway (histogram age if trt == 1, frequency color(blue%70)) ///
	   (histogram age if trt == 1, frequency color(red%70)), ///
        xscale(range(0 100)) xlab(0(20)100) ///
		yscale(range(0 250)) ylab(0(50)250) ///
        legend(order(2 "No treatment X=0"  1 "Treatment X=1")) ///
		title("Scenario 2: Age standardized to X=1") ///
		xtitle("Age (years)") ///
		text(250 65 "Age distribution X=1 ~ Normal(60,10)", size(medlarge) justification(left)) ///
		text(230 70 "Age distribution X=0 ~ Age distribution X=1", size(medlarge) justification(left)) //
graph export "./output/agedist_sc2.png", replace
		
/* Standardize to age distribution in trt == 1*/
// Estimate LE, LE_expected
standsurv, at1(trt 1, atif(trt == 1)) ///
		   at2(trt 0, atif(trt == 1)) ///
		   timevar(t100) rmst ///
		   atvars(le1_sc2 le0_sc2) ///
		   expsurv(using("popmort2022_se.dta") ///
							 agediag(age) ///    
							 datediag(diagdate) ///
							 pmage(_age) ///       
							 pmyear(_year) ///
							 pmother(sex) ///      
							 pmrate(rate) ///      
							 pmmaxyear(2022) ///    
							 expsurvvar(leexp1_sc2 leexp0_sc2))

gen lle1_sc2 = leexp1_sc2 - le1_sc2
gen lle0_sc2 = leexp0_sc2 - le0_sc2

global le1_sc2: display %-9.1f le1_sc2
global le0_sc2: display %-9.1f le0_sc2
global leexp1_sc2: display %-9.1f leexp1_sc2
global leexp0_sc2: display %-9.1f leexp0_sc2
global lle1_sc2: display $leexp1_sc2 - $le1_sc2
global lle0_sc2: display $leexp0_sc2 - $le0_sc2

global diff_le_sc2: display %-9.1f $le1_sc2 - $le0_sc2
global diff_leexp_sc2: display %-9.1f $leexp1_sc2 - $leexp0_sc2
global diff_lle_sc2: display %-9.1f $diff_leexp_sc2 - $diff_le_sc2
		
// Estimate overall survival, expected survival
standsurv, timevar(temptime) ///
		   at1(trt 1, atif(trt == 1)) ///
		   at2(trt 0, atif(trt == 1)) ///
		   atvars(os1_sc2 os0_sc2) ///
		   expsurv(using("popmort2022_se.dta")  ///  popmort 
							 agediag(age)     ///  age at diagnosis
							 datediag(diagdate)	///  date at diagnosis
							 pmage(_age)        ///  age variable in popmort 
							 pmyear(_year)      ///  year variable in popmort file		
							 pmother(sex)       ///  other variables in popmort
							 pmrate(rate)       ///  rate varible in popmort
							 pmmaxyear(2022)    ///  maximum year in popmort
							 expsurvvar(exps1_sc2 exps0_sc2))
							 
// Overall survival and expected survival
tw (line os1_sc2 temptime, lcolor(blue%70) lwidth(0.7) sort) ///
   (line os0_sc2 temptime, lcolor(red%70) lwidth(0.7) sort) ///
   (line exps1_sc2 temptime, lcolor(blue%70) lwidth(0.7) lpattern(dash) sort) ///
   (line exps0_sc2 temptime, lcolor(red%70) lwidth(0.7) lpattern(shortdash) sort), ///
   xtitle("Time (years)") ytitle("Survival probability") ///
   title("Scenario 2: Age standardized to X=1") ///
   legend(order(1 "Overall survival, X=1" 2 "Overall survival, X=0" 3 "Expected survival, X=1" 4 "Expected survival, X=0")) ///
   xscale(r(0 100)) ///
       text(1 35 "LE{superscript:X=1} = $le1_sc2", place(e) justification(left) size(medlarge)) ///
	   text(.9 35 "LE{superscript:X=0} = $le0_sc2", place(e) justification(left) size(medlarge)) ///	 
	   text(.8 35 "{&Delta}LE = $diff_le_sc2", place(e) justification(left) size(medlarge)) ///
 	   text(1 55 "LE{superscript:*X=1} = $leexp1_sc2", place(e) justification(left) size(medlarge)) ///
	   text(.9 55 "LE{superscript:*X=0} = $leexp0_sc2", place(e) justification(left) size(medlarge)) ///
	   text(.8 55 "{&Delta}LE{superscript:*} = $diff_leexp_sc2", place(e) justification(left) size(medlarge)) ///
	   text(1 80 "LLE{superscript:X=1} = $lle1_sc2", place(e) justification(left) size(medlarge)) ///
	   text(.9 80 "LLE{superscript:X=0} = $lle0_sc2", place(e) justification(left) size(medlarge)) ///
	   text(.8 80 "{&Delta}LLE = $diff_lle_sc2", place(e) justification(left) size(medlarge))

graph export "./output/sc2.png", replace

// Estimate relative survival
standsurv, timevar(temptime) ///
		   at1(trt 1, atif(trt == 1)) ///
		   at2(trt 0, atif(trt == 1)) ///
		   atvars(rs1_sc2 rs0_sc2)

tw (line rs1_sc2 rs0_sc2 temptime, sort)

/*==============
// Scenario 3 //
===============*/
cap drop *sc3
/* Standardize to age distribution in trt == 0*/
// Plot age distributions
twoway (histogram age if trt == 0, frequency color(red%70)) ///
	   (histogram age if trt == 0, frequency color(blue%70)), ///
        xscale(range(0 100)) xlab(0(20)100) ///
		yscale(range(0 250)) ylab(0(50)250) ///
        legend(order(1 "No treatment X=0"  2 "Treatment X=1")) ///
		title("Scenario 3: Age standardized to X=0") ///
		xtitle("Age (years)") ///
		text(250 70 "Age distribution X=1 ~ Age distribution X=0", size(medlarge) justification(left)) ///
		text(230 65 "Age distribution X=0 ~ Normal(50,10)", size(medlarge) justification(left)) //
graph export "./output/agedist_sc3.png", replace
		
/* Standardize to age distribution in trt == 0*/
// Estimate LE, LE_expected
standsurv, at1(trt 1, atif(trt == 0)) ///
		   at2(trt 0, atif(trt == 0)) ///
		   timevar(t100) rmst ///
		   atvars(le1_sc3 le0_sc3) ///
		   expsurv(using("popmort2022_se.dta") ///
							 agediag(age) ///    
							 datediag(diagdate) ///
							 pmage(_age) ///       
							 pmyear(_year) ///
							 pmother(sex) ///      
							 pmrate(rate) ///      
							 pmmaxyear(2022) ///    
							 expsurvvar(leexp1_sc3 leexp0_sc3))

gen lle1_sc3 = leexp1_sc3 - le1_sc3
gen lle0_sc3 = leexp0_sc3 - le0_sc3

global le1_sc3: display %-9.1f le1_sc3
global le0_sc3: display %-9.1f le0_sc3
global leexp1_sc3: display %-9.1f leexp1_sc3
global leexp0_sc3: display %-9.1f leexp0_sc3
global lle1_sc3: display $leexp1_sc3 - $le1_sc3
global lle0_sc3: display $leexp0_sc3 - $le0_sc3

global diff_le_sc3: display %-9.1f $le1_sc3 - $le0_sc3
global diff_leexp_sc3: display %-9.1f $leexp1_sc3 - $leexp0_sc3
global diff_lle_sc3: display %-9.1f $diff_leexp_sc3 - $diff_le_sc3
		
// Estimate overall survival, expected survival
standsurv, timevar(temptime) ///
		   at1(trt 1, atif(trt == 1)) ///
		   at2(trt 0, atif(trt == 1)) ///
		   atvars(os1_sc3 os0_sc3) ///
		   expsurv(using("popmort2022_se.dta")  ///  popmort 
							 agediag(age)     ///  age at diagnosis
							 datediag(diagdate)	///  date at diagnosis
							 pmage(_age)        ///  age variable in popmort 
							 pmyear(_year)      ///  year variable in popmort file		
							 pmother(sex)       ///  other variables in popmort
							 pmrate(rate)       ///  rate varible in popmort
							 pmmaxyear(2022)    ///  maximum year in popmort
							 expsurvvar(exps1_sc3 exps0_sc3))
							 
// Overall survival and expected survival
tw (line os1_sc3 temptime, lcolor(blue%70) lwidth(0.7) sort) ///
   (line os0_sc3 temptime, lcolor(red%70) lwidth(0.7) sort) ///
   (line exps1_sc3 temptime, lcolor(blue%70) lwidth(0.7) lpattern(dash) sort) ///
   (line exps0_sc3 temptime, lcolor(red%70) lwidth(0.7) lpattern(shortdash) sort), ///
   xtitle("Time (years)") ytitle("Survival probability") ///
   title("Scenario 3: Age standardized to X=0") ///
   legend(order(1 "Overall survival, X=1" 2 "Overall survival, X=0" 3 "Expected survival, X=1" 4 "Expected survival, X=0")) ///
   xscale(r(0 100)) ///
       text(1 35 "LE{superscript:X=1} = $le1_sc3", place(e) justification(left) size(medlarge)) ///
	   text(.9 35 "LE{superscript:X=0} = $le0_sc3", place(e) justification(left) size(medlarge)) ///	 
	   text(.8 35 "{&Delta}LE = $diff_le_sc3", place(e) justification(left) size(medlarge)) ///
 	   text(1 55 "LE{superscript:*X=1} = $leexp1_sc3", place(e) justification(left) size(medlarge)) ///
	   text(.9 55 "LE{superscript:*X=0} = $leexp0_sc3", place(e) justification(left) size(medlarge)) ///
	   text(.8 55 "{&Delta}LE{superscript:*} = $diff_leexp_sc3", place(e) justification(left) size(medlarge)) ///
	   text(1 80 "LLE{superscript:X=1} = $lle1_sc3", place(e) justification(left) size(medlarge)) ///
	   text(.9 80 "LLE{superscript:X=0} = $lle0_sc3", place(e) justification(left) size(medlarge)) ///
	   text(.8 80 "{&Delta}LLE = $diff_lle_sc3", place(e) justification(left) size(medlarge))

graph export "./output/sc3.png", replace

// Estimate relative survival
standsurv, timevar(temptime) ///
		   at1(trt 1, atif(trt == 1)) ///
		   at2(trt 0, atif(trt == 1)) ///
		   atvars(rs1_sc3 rs0_sc3)

tw (line rs1_sc3 rs0_sc3 temptime, sort)


/*==============
// Scenario 4 //
===============*/
cap drop *sc4
/* Standardize to age distribution in the entire population (trt == 1 and trt == 0)*/
// Plot age distributions
twoway (histogram age , frequency color(red%50)) ///
	   (histogram age , frequency color(blue%50)), ///
        xscale(range(0 100)) xlab(0(20)100) ///
		yscale(range(0 250)) ylab(0(50)250) ///
        legend(order(1 "No treatment X=0"  2 "Treatment X=1")) ///
		title("Scenario 4: Age standardized to X=1 + X=0") ///
		xtitle("Age (years)") ///
		text(250 60 "Age distribution X=1 ~ Age distribution X=1 + X=0", size(medlarge) justification(left)) ///
		text(230 60 "Age distribution X=0 ~ Age distribution X=1 + X=0", size(medlarge) justification(left)) //
graph export "./output/agedist_sc4.png", replace
		
/* Standardize to age distribution*/
// Estimate LE, LE_expected
standsurv, at1(trt 1) ///
		   at2(trt 0) ///
		   timevar(t100) rmst ///
		   atvars(le1_sc4 le0_sc4) ///
		   expsurv(using("popmort2022_se.dta") ///
							 agediag(age) ///    
							 datediag(diagdate) ///
							 pmage(_age) ///       
							 pmyear(_year) ///
							 pmother(sex) ///      
							 pmrate(rate) ///      
							 pmmaxyear(2022) ///    
							 expsurvvar(leexp1_sc4 leexp0_sc4))

gen lle1_sc4 = leexp1_sc4 - le1_sc4
gen lle0_sc4 = leexp0_sc4 - le0_sc4

global le1_sc4: display %-9.1f le1_sc4
global le0_sc4: display %-9.1f le0_sc4
global leexp1_sc4: display %-9.1f leexp1_sc4
global leexp0_sc4: display %-9.1f leexp0_sc4
global lle1_sc4: display $leexp1_sc4 - $le1_sc4
global lle0_sc4: display $leexp0_sc4 - $le0_sc4

global diff_le_sc4: display %-9.1f $le1_sc4 - $le0_sc4
global diff_leexp_sc4: display %-9.1f $leexp1_sc4 - $leexp0_sc4
global diff_lle_sc4: display %-9.1f $diff_leexp_sc4 - $diff_le_sc4
		
// Estimate overall survival, expected survival
standsurv, timevar(temptime) ///
		   at1(trt 1, atif(trt == 1)) ///
		   at2(trt 0, atif(trt == 1)) ///
		   atvars(os1_sc4 os0_sc4) ///
		   expsurv(using("popmort2022_se.dta")  ///  popmort 
							 agediag(age)     ///  age at diagnosis
							 datediag(diagdate)	///  date at diagnosis
							 pmage(_age)        ///  age variable in popmort 
							 pmyear(_year)      ///  year variable in popmort file		
							 pmother(sex)       ///  other variables in popmort
							 pmrate(rate)       ///  rate varible in popmort
							 pmmaxyear(2022)    ///  maximum year in popmort
							 expsurvvar(exps1_sc4 exps0_sc4))
							 
// Overall survival and expected survival
tw (line os1_sc4 temptime, lcolor(blue%70) lwidth(0.7) sort) ///
   (line os0_sc4 temptime, lcolor(red%70) lwidth(0.7) sort) ///
   (line exps1_sc4 temptime, lcolor(blue%70) lwidth(0.7) lpattern(dash) sort) ///
   (line exps0_sc4 temptime, lcolor(red%70) lwidth(0.7) lpattern(shortdash) sort), ///
   xtitle("Time (years)") ytitle("Survival probability") ///
   title("Scenario 4: Age standardized to X=1 + X=0") ///
   legend(order(1 "Overall survival, X=1" 2 "Overall survival, X=0" 3 "Expected survival, X=1" 4 "Expected survival, X=0")) ///
   xscale(r(0 100)) ///
       text(1 35 "LE{superscript:X=1} = $le1_sc4", place(e) justification(left) size(medlarge)) ///
	   text(.9 35 "LE{superscript:X=0} = $le0_sc4", place(e) justification(left) size(medlarge)) ///	 
	   text(.8 35 "{&Delta}LE = $diff_le_sc4", place(e) justification(left) size(medlarge)) ///
 	   text(1 55 "LE{superscript:*X=1} = $leexp1_sc4", place(e) justification(left) size(medlarge)) ///
	   text(.9 55 "LE{superscript:*X=0} = $leexp0_sc4", place(e) justification(left) size(medlarge)) ///
	   text(.8 55 "{&Delta}LE{superscript:*} = $diff_leexp_sc4", place(e) justification(left) size(medlarge)) ///
	   text(1 80 "LLE{superscript:X=1} = $lle1_sc4", place(e) justification(left) size(medlarge)) ///
	   text(.9 80 "LLE{superscript:X=0} = $lle0_sc4", place(e) justification(left) size(medlarge)) ///
	   text(.8 80 "{&Delta}LLE = $diff_lle_sc4", place(e) justification(left) size(medlarge))
 
graph export "./output/sc4.png", replace
	   
// Estimate relative survival
standsurv, timevar(temptime) ///
		   at1(trt 1, atif(trt == 1)) ///
		   at2(trt 0, atif(trt == 1)) ///
		   atvars(rs1_sc4 rs0_sc4)

tw (line rs1_sc4 rs0_sc4 temptime, sort)

/*===========================================
Create an empty dataset to store the results
=============================================*/
clear
set obs 1

// Initialize variables
gen scenario = .
gen trt = 1
gen mean_le = .
gen mean_leexp= .
gen mean_lle= .
expand 2
replace trt = 0 in 2

// Scenario 1 to 4
forvalues i = 1/4 {
    preserve
    replace scenario = `i'
    
    // Assign values for treatment 1
    replace mean_le = ${le1_sc`i'} if trt == 1 & scenario == `i'
    replace mean_leexp = ${leexp1_sc`i'} if trt == 1 & scenario == `i'
    replace mean_lle = ${lle1_sc`i'} if trt == 1 & scenario == `i'

    // Assign values for treatment 0
    replace mean_le = ${le0_sc`i'} if trt == 0 & scenario == `i'
    replace mean_leexp = ${leexp0_sc`i'} if trt == 0 & scenario == `i'
    replace mean_lle = ${lle0_sc`i'} if trt == 0 & scenario == `i'

    tempfile sc`i'
    save `sc`i'', replace
    restore
}

forvalues i = 1/4 {
    append using `sc`i''
}

drop if scenario == .
sort scenario
by scenario: gen diff_le = round(mean_le - mean_le[_n+1], 0.1)
by scenario: gen diff_leexp = round(mean_leexp - mean_leexp[_n+1], 0.1)
by scenario: gen diff_lle = round(mean_lle - mean_lle[_n+1], 0.1)

// Add a variable to indicate standardization
gen agestd = ""
replace agestd = "Without standardization" if scenario == 1
replace agestd = "Treatment" if scenario == 2
replace agestd = "No treatment" if scenario == 3
replace agestd = "Treatment + No treatment" if scenario == 4

gen trtgrp = ""
replace trtgrp = "Treatment" if trt == 1
replace trtgrp = "No treatment" if trt == 0
drop trt
order scenario agestd trtgrp
save scenarios, replace
// End
