// Loss in Life Expectancy Does Not Adjust Confounding
// Updated by 20240729 Enoch Chen

// Simulate two groups with hazard ratio = 1
// Both with sex 1, year 1990, survival times follow weibull(lambda 0.2, gamma 1)
// but with the following differences:
// Treatment 1: 1000 individuals age ~ rnormal(60, 10)
// Treatment 0: 1000 individuals age ~ rnormal(50, 10)

clear all

set seed 123456

* Create the first frame
frame create group1
frame group1 {
    set obs 1000
    generate age = min(max(floor(rnormal(60, 10)), 1), 99)
    generate sex = 1
    generate year = 1990
	generate diagdate = date("01/01/1999","MDY")
	generate trt = 1
	
	tempfile group1
    save `group1'
}

* Create the second frame
frame create group2
frame group2 {
    set obs 1000
    generate age = min(max(floor(rnormal(50, 10)), 1), 99)
    generate sex = 1
    generate year = 1990
	generate diagdate = date("01/01/1999","MDY")
	generate trt = 0

	tempfile group2
    save `group2'
}

* Save the combined dataset
clear 
use `group1', clear
append using `group2'

// Simulate survival time from a baseline Weibull distribution
// with an increasing hazard function with log hazard-ratio = 0
// That is, there is not difference between the hazard of these two groups,
// despite the difference of age distributions
survsim stime, distribution(weibull) lambdas(0.2) gammas(1) covariates(trt 0) 

generate died = 1
tempfile simdata
save simdata, replace

