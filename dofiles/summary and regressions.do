** ########################################################################
** Droughts, insurance and conflict
** Summary and regressions
** ########################################################################

clear all

cd "/Users/mrfreerider/Documents/GitHub/droughts_and_conflict"

use "data/processed/merge_data_marsabit.dta", clear





******************************************************************
** Summary statistics
******************************************************************

preserve
keep if round==1
eststo clear
estpost sum members gender age married widow num_partners ethnic2 ethnic3 ethnic6 atten_school max_educ_years educ_enrol inc_pc tlu_total  milk_prod self_cons saving saving_amount cash_transf cash_transf_amount ndvi_zyd ndvi_zldsd
esttab  using "/Users/mrfreerider/Documents/GitHub/droughts_and_conflict/tables/summary_hh_baseline.tex", replace cells("mean(label(Mean) fmt(a3)) sd(label(Std. Dev.) fmt(a3) par) min(label(Min)) max(label(Max))") nomtitles nonumber nostar booktabs noobs coeflabels(members "Household size" gender "Male head" age "Age of head" married "Married head" widow "Widowed head" num_partners "Number of partners" ethnic2 "Ethnic group Borana" ethnic3 "Ethnic group = Rendille " ethnic6 "Ethnic group Gabra" atten_school "Has head attended school" max_educ_years "Maximum years of education" educ_enrol "Age when head enrolled in school" inc_pc "Income per capita per day (KSh)" tlu_total "TLU" milk_prod "Milk production per day (liters)" self_cons "Milk for self-consumption" saving "Have any cash savings" saving_amount "Savings (KSh)" cash_transf "Beneficiary of cash transfer" cash_transf_amount "Amount transfer (KSh)" ndvi_zyd "NDVI z-score per year" ndvi_zldsd "NDVI z-score per long-dry season")
restore 


******************************************************************
** Baseline differences per round by 1 if received coupon ever
******************************************************************

** Receive a discount coupon (IBLI contract section)

// January 2010
gen disc2=discount_jan_2010
replace disc2=1 if discount_jan_2010>0 & round==2
// January & August 2011
gen disc3a=discount_jan_2011
gen disc3b=discount_aug_2011
replace disc3a=1 if discount_jan_2011>0 & round==3
replace disc3b=1 if discount_aug_2011>0 & round==3
gen disc3=disc3a+disc3b
recode disc3 2=1
drop disc3a disc3b
// August 2012
gen disc4=discount_aug_2012
replace disc4=1 if discount_aug_2012>0 & round==4
//  January & August 2013
gen disc5a=discount_jan_2013
gen disc5b=discount_aug_2013
replace disc5a=1 if discount_jan_2013>0 & round==5
replace disc5b=1 if discount_aug_2013>0 & round==5
gen disc5=disc5a+disc5b
recode disc5 2=1
drop disc5a disc5b

** Differences in means (1 IF RECEIVE A DISCOUNT ONCE) per round
eststo clear
forvalues i=2/5{
	estpost ttest members gender age married widow num_partners ethnic2 ethnic3 ethnic6 atten_school max_educ_years educ_enrol inc_pc tlu_total  milk_prod self_cons saving saving_amount ndvi_zyd ndvi_zldsd  , by(disc`i') unequal
	eststo round`i'
}

esttab round2 round3 round4 round5 using "/Users/mrfreerider/Documents/GitHub/droughts_and_conflict/tables/balance_coupon_round.tex", replace cells("b(label(Diff) fmt(a3) star) se(label(Std. Dev.) fmt(a3) par)") nonumber nostar booktabs noobs coeflabels(members "Household size" gender "Male head" age "Age of head" married "Married head" widow "Widowed head" num_partners "Number of partners" ethnic2 "Ethnic group Borana" ethnic3 "Ethnic group = Rendille " ethnic6 "Ethnic group Gabra" atten_school "Has head attended school" max_educ_years "Maximum years of education" educ_enrol "Age when head enrolled in school" inc_pc "Income per capita per day (KSh)" tlu_total "TLU" milk_prod "Milk production per day (liters)" self_cons "Milk for self-consumption" saving "Have any cash savings" saving_amount "Savings (KSh)" cash_transf "Beneficiary of cash transfer" cash_transf_amount "Amount transfer (KSh)" ndvi_zyd "NDVI z-score per year" ndvi_zldsd "NDVI z-score per long-dry season") mtitle("Round 2" "Round 3" "Round 4" "Round 5")
	
	
** Received a coupon? (self-reported)
// 1 if received a coupon in January
gen  disc_1 = s15q17a
recode disc_1 -77 98=. 1=1 2=0
replace disc_1 = 0 if missing(disc_1)
// 1 if received a coupon in August
gen disc_2 = s15q17c
recode disc_2 -77 98=. 1=1 2=0
replace disc_2 = 0 if missing(disc_2)
// 1 if recieved a coupon once per round
gen disc_once= disc_1+disc_2 
recode disc_once 2=1
drop disc_1 disc_2

******************************************************************
** Baseline differences by IBLI purchase per round
******************************************************************

** Purchased IBLI (IBLI contract section)
gen ibli_once = 0
label var ibli_once "Purchased IBLI once"
replace ibli_once = 1 if ibli > 0

** Differences in means by purchased IBLI once per round
eststo clear
forvalues i=2/6{
	preserve
	keep if round==`i'
	estpost ttest members gender age married widow num_partners ethnic2 ethnic3 ethnic6 atten_school max_educ_years educ_enrol inc_pc tlu_total  milk_prod self_cons saving saving_amount ndvi_zyd ndvi_zldsd, by(ibli_once) unequal
	eststo round`i'
	restore
}

esttab round2 round3 round4 round5 round6 using "~/Documents/GitHub/droughts_and_conflict/tables/balance_ibli_round.tex", replace cells("b(label(Diff) fmt(a3) star) se(label(Std. Dev.) fmt(a3) par)") nonumber nostar booktabs noobs coeflabels(members "Household size" gender "Male head" age "Age of head" married "Married head" widow "Widowed head" num_partners "Number of partners" ethnic2 "Ethnic group Borana" ethnic3 "Ethnic group = Rendille " ethnic6 "Ethnic group Gabra" atten_school "Has head attended school" max_educ_years "Maximum years of education" educ_enrol "Age when head enrolled in school" inc_pc "Income per capita per day (KSh)" tlu_total "TLU" milk_prod "Milk production per day (liters)" self_cons "Milk for self-consumption" saving "Have any cash savings" saving_amount "Savings (KSh)" cash_transf "Beneficiary of cash transfer" cash_transf_amount "Amount transfer (KSh)" ndvi_zyd "NDVI z-score per year" ndvi_zldsd "NDVI z-score per long-dry season") mtitle("Round 2" "Round 3" "Round 4" "Round 5")

** Purchased IBLI? (self-reported)
// January current year
gen ibli1 = s15q18c
recode ibli1 -77 98=. 1=1 2=0
replace ibli1=0 if missing(ibli1)
// August current year
gen ibli2 = s15q18d
recode ibli2 -77 98=. 1=1 2=0
replace ibli2=0 if missing(ibli2)

gen ibli_self= ibli1+ibli2 
recode ibli_self 2=1
drop ibli1 ibli2


******************************************************************
** Regressions Loss Events on NDVI
******************************************************************

** NDVI and Drougths on # of losses events 
eststo reglossevents1: xtpoisson lossevents ndvi_zyd  i.round, fe robust
eststo reglossevents2: xtpoisson lossevents droughtyd  i.round, fe robust

eststo reglossevents3: xtpoisson lossevents ndvi_zyd i.ibli i.round, fe robust
eststo reglossevents4: xtpoisson lossevents droughtyd i.ibli i.round, fe robust

eststo reglossevents5: xtpoisson loss_lds ndvi_zldsd i.ibli i.round, fe robust
eststo reglossevents6: xtpoisson loss_lds droughtldsd i.ibli i.round, fe robust

esttab reglossevents1 reglossevents3 reglossevents2 reglossevents4 reglossevents5 reglossevents6 using "~/Documents/GitHub/droughts_and_conflict/tables/reg_lossevents.tex", replace keep(ndvi_zyd ndvi_zldsd droughtyd droughtldsd *.ibli) order(ndvi_zyd ndvi_zldsd droughtyd droughtldsd *.ibli) nobaselevels stat(N N_g chi2)


xtreg tlu_loss ndvi_zyd i.round##i.division, fe vce(cluster division)
xtreg tlu_loss droughtyd i.round##i.division, fe vce(cluster division)




gen raid=1 if loss_raid>0
replace raid=0 if missing(raid)

eststo A: xtlogit raid ndvi_zyd , fe 
eststo C: xtlogit raid ndvi_zyd i.ibli, fe
eststo C: xtlogit raid ndvi_zyd i.round##i.subloc, fe


eststo B: xtlogit raid droughtyd , fe 


eststo D: xtlogit raid droughtyd i.ibli, fe 

esttab A B C D, keep(ndvi_zyd droughtyd *.ibli) stat(N_g)

xtreg raid ndvi_zyd i.ibli i.subloc, fe 

xtlogit raid ndvi_zyd i.ibli i.round, fe 
xtlogit raid droughtyd i.ibli i.round, fe 

xtlogit raid c.ndvi_zyd##i.ibli  i.round##i.division, fe 
xtlogit raid i.droughtyd##i.ibli i.round##i.division, fe




gen raidlds=1 if loss_raid_lds>0
replace raidlds=0 if missing(raidlds)

xtlogit raidlds ndvi_zldsd i.ibli , fe 

xtlogit raidlds droughtldsd i.ibli  , fe 

xtlogit raidlds ndvi_zldsd i.ibli i.round, fe 
xtlogit raidlds droughtldsd i.ibli i.round, fe 


xtlogit raidlds c.ndvi_zldsd##i.ibli c.ndvi_zldsd##cash_transf i.round##i.division, fe 



// Raids Vs NDVI

preserve
gen raidper=raid*100
collapse (mean) mean1=raidper  (sd) sd1=raidper (count) n1=raidper (mean) mean2=ndvi_zyd  (sd) sd2=ndvi_zyd (count) n2=ndvi_zyd, by(round)

twoway connected mean1 round, color(navy) ytitle("Percentage") || connected mean2 round, color(maroon) yaxis(2) ytitle("NDVI", axis(2))  xtitle("Round") legend(order(1 "HH with livestock losses due to raids/conflict" 2 "NDVI" ) pos(6) cols(2)) title("Raids and NDVI")


graph display , xsize(8.0)
graph export "~/Documents/GitHub/droughts_and_conflict/images/raids_ndvi.pdf", replace
restore


preserve
gen raidper=raidlds*100
collapse (mean) mean1=raidper  (sd) sd1=raidper (count) n1=raidper (mean) mean2=ndvi_zyd  (sd) sd2=ndvi_zyd (count) n2=ndvi_zyd, by(round)

twoway connected mean1 round, color(navy) ytitle("Percentage") || connected mean2 round, color(maroon) yaxis(2) ytitle("NDVI", axis(2))  xtitle("Round") legend(order(1 "HH with livestock losses due to raids/conflict" 2 "NDVI" ) pos(6) cols(2)) title("Raids and NDVI in long-dry season")

graph display , xsize(8.0)
graph export "~/Documents/GitHub/droughts_and_conflict/images/raids_ndvi_lds.pdf", replace
restore


// Settlement
preserve
gen partper=part_set*100
gen raidper=raid*100
collapse (mean) mean1=partper  (sd) sd1=partper (count) n1=partper (mean) mean2=raidper  (sd) sd2=raidper (count) n2=raidper (mean) mean3=ndvi_zyd  (sd) sd3=ndvi_zyd (count) n3=ndvi_zyd, by(round)

twoway connected mean1 round, ytitle("Percentage") || connected mean2 round || connected mean3 round, yaxis(2) ytitle("NDVI", axis(2))  xtitle("Round") legend(order(1 "Partially settlement" 2 "Raids" 3 "NDVI" ) pos(6) cols(3)) title("Raids, Migration and NDVI")

graph display , xsize(8.0)
graph export "/Users/mrfreerider/Documents/GitHub/droughts_and_conflict/images/raids_ndvi.pdf", replace
restore




** Migrations and conflict
gen full_set= (s1q3==1)
gen part_set= (s1q3==2)

preserve
gen fullper=full_set*100
gen partper=part_set*100
collapse (mean) mean1=fullper  (sd) sd1=fullper (count) n1=fullper (mean) mean2=partper  (sd) sd2=partper (count) n2=partper, by(round)

gen hivalue1 = mean1 + invttail(n1-1,0.025)*(sd1 / sqrt(n1))
gen lovalue1 = mean1 - invttail(n1-1,0.025)*(sd1 / sqrt(n1))
gen hivalue2 = mean2 + invttail(n2-1,0.025)*(sd2 / sqrt(n2))
gen lovalue2 = mean2 - invttail(n2-1,0.025)*(sd2 / sqrt(n2))

graph twoway (connected mean1 round, color(navy)) (rcap hivalue1 lovalue1 round, color(navy)) (connected mean2 round, color(maroon)) (rcap hivalue2 lovalue2 round, color(maroon)),  ytitle("Yes %") xtitle("Round") title(Settlement) note(" ") name(settlement, replace) legend(order(1 "Full settlement" 2 "95% CI Jan/Feb" 3 "Partial settlement" 4 "95% CI Aug/Sep") pos(6) cols(2))
//graph display settlement, xsize(8.0)
graph export "/Users/mrfreerider/Documents/GitHub/droughts_and_conflict/images/settlement.pdf", replace
restore


