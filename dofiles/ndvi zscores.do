** ########################################################################
** NDVI data per division and sublocation
** NDVI (z-scores)
** ########################################################################

clear all

cd "~/Documents/GitHub/droughts_and_conflict/data/processed/"

import delimited "ndvi.csv", encoding(UTF-8) 

** Pixel ID
gen i_pix=_n 


reshape long ndvi_kenya_merge, i(i_pix) j(t)

** NDVI value range (-1 to 1)
gen ndvi=ndvi_kenya_merge/100000000

** Year ID
gen year=1 if t<=11
replace year=2 if t>11 & t<=23
replace year=3 if t>23 & t<=35
replace year=4 if t>35 & t<=47
replace year=5 if t>47 & t<=59
replace year=6 if t>59 & t<=71
replace year=7 if t>71 & t<=83
replace year=8 if t>83 & t<=95
replace year=9 if t>95 & t<=107
replace year=10 if t>107 & t<=119
replace year=11 if t>119 & t<=131
replace year=12 if t>131 & t<=143
replace year=13 if t>143 & t<=155
replace year=14 if t>155 & t<=167
replace year=15 if t>167 & t<=177

** Month ID
sort  i_pix t
bys i_pix year : gen month=_n
replace month=month+1 if year==1 

** NDVI mean and SD per pixel per month before 2009
sort  i_pix t
bys i_pix month: egen mean_pm=mean(ndvi) if year<10
bys i_pix month: egen sd_pm=sd(ndvi) if year<10

** Filling missing values after 2009
xtset i_pix t

sort  i_pix month year
bys i_pix month: replace mean_pm=mean_pm[_n-1] if missing(mean_pm) 

sort  i_pix month year
bys i_pix month: replace sd_pm=sd_pm[_n-1] if missing(sd_pm) 


** NDVI z-score monthly (round) and (long-dry season)

gen ndvi_zm=(ndvi-mean_pm)/sd_pm // Z-score monthly

bys i_pix year: egen ndvi_zy=mean(ndvi_zm) // By round

bys i_pix year: egen ndvi_zlds=mean(ndvi_zm) if month>=6 & month<=9 // By long-dry season




** Variable: Division ID
rename id division

** Save data set
save "ndvi_divisions.dta", replace


** Save data set with selected variables
use "ndvi_divisions.dta", clear

sort  i_pix t

bys division year: egen ndvi_zyd=mean(ndvi_zy)

bys division year: egen ndvi_zldsd=mean(ndvi_zlds)

bys division: egen ndvi_py25=pctile(ndvi_zyd), p(25) 
bys division: egen ndvi_plds25=pctile(ndvi_zldsd), p(25) 

// 1 if ndvi z-score is below the 25th percentile
gen  droughtyd = (ndvi_zyd < ndvi_py25)

gen  droughtldsd = (ndvi_zldsd<ndvi_plds25)

keep if month == 9
keep if year >= 10
bys division year: gen dup= cond(_N==1,0,_n)
drop if dup > 1
drop dup

gen round = year-9

keep division round ndvi_zyd ndvi_zldsd droughtyd droughtldsd

save "ndvi_division_zscores.dta", replace


******************************************************************************
** NDVI by Sublocations
******************************************************************************

** Sublocations Names

import delimited "/Users/mrfreerider/Documents/GitHub/droughts_and_conflict/data/processed/sublocations.csv", encoding(UTF-8) clear


rename v1 id
rename v2 division
rename v3 location
rename v4 sublocation
drop if id==.

encode division, gen(div)
encode location, gen(loc)
encode sublocation, gen(sub)

drop division location sublocation

rename div division
rename loc location
rename sub sublocations


sort division location sublocation
gen subloc=.
replace subloc=1 if sublocations==5
replace subloc=2 if sublocations==7
replace subloc=3 if sublocations==53
replace subloc=4 if sublocations==4
replace subloc=5 if sublocations==9
replace subloc=6 if sublocations==23
replace subloc=7 if sublocations==57
replace subloc=8 if sublocations==25
replace subloc=9 if sublocations==26
replace subloc=10 if sublocations==26
replace subloc=11 if sublocations==34
replace subloc=12 if sublocations==18
replace subloc=13 if sublocations==36
replace subloc=14 if sublocations==35
replace subloc=15 if sublocations==45
replace subloc=16 if sublocations==56

save "~/Documents/GitHub/droughts_and_conflict/data/processed/sublocationn_names.dta", replace

** NDVI by Sublocations

clear all
import delimited "/Users/mrfreerider/Documents/GitHub/droughts_and_conflict/data/processed/ndvi_sublocations.csv", encoding(UTF-8) 

gen i_pix=_n
reshape long crop, i(i_pix) j(t)

tostring t, replace
gen year = substr(t,1,4)
gen month = substr(t,5,6)
destring year, replace
destring month, replace
drop t
gen t=ym(year, month)
format t %tm

gen ndvi=crop/1000000000

xtset i_pix t
//  NDVI Mean and SD per pixel per month before 2009
sort  i_pix t
bys i_pix month: egen mean_pm=mean(ndvi) if year<2009
bys i_pix month: egen sd_pm=sd(ndvi) if year<2009

// Fill missing values after 2009
sort  i_pix month year
bys i_pix month: replace mean_pm=mean_pm[_n-1] if missing(mean_pm) 
sort  i_pix month year
bys i_pix month: replace sd_pm=sd_pm[_n-1] if missing(sd_pm) 

// NDVI z-score monthly
gen ndvi_zm=(ndvi-mean_pm)/sd_pm

bys i_pix year: egen ndvi_zy=mean(ndvi_zm) // year

bys i_pix year: egen ndvi_zld=mean(ndvi_zm) if month>=6 & month<=9 // long dry 

// By sublocations 
rename id sublocation
sort  i_pix t
bys sublocation year: egen ndvi_zyd=mean(ndvi_zy)
bys sublocation year: egen ndvi_zldd=mean(ndvi_zld)

// Duplicates
keep if month == 9
keep if year >= 2009
bys sublocation year: gen dup= cond(_N==1,0,_n)
drop if dup > 1
drop dup

gen round = year-2008

keep sublocation round ndvi_zyd ndvi_zldd
gen subloc = sublocation
save "/Users/mrfreerider/Documents/GitHub/droughts_and_conflict/data/processed/ndvi_sublocations.dta", replace

merge m:m subloc using "~/Documents/GitHub/droughts_and_conflict/data/processed/sublocationn_names.dta"

drop _merge

drop sublocation
rename sublocations sublocation

save "/Users/mrfreerider/Documents/GitHub/droughts_and_conflict/data/processed/ndvi_sublocations_zscores.dta", replace




