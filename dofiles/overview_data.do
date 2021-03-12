** ########################################################################
** Droughts, insurance and conflict
** Overview Borena/Marsabit Data
** ########################################################################


*# Project 
// ILRI piloted in January 2010 a market-mediated index-based insurance product, designed to protect pastoralists from droughtrelated livestock mortality, in Marsabit district of northern Kenya.
// Goal: protect against the climate related risk that vulnerable rural smallholder farmers face.
// Index-insurance is based in the realization of an outcome that cannot be influenced by insurers of policy holders

*## Insurance
// A numerical indicator of the degree of greenness recorded by satelite "standardized Normalized Differenced Vegetation Index (NDVI)." It predicts area-average livestock mortality due to drought and calculate indemnity payouts.
// payments: if the predicted livestock mortality index exceeds a threshold of 15% (10% in 2015).
// IBlI is marketed and sold over two periods before the two rainy seasons ->  (August-September and January-February), one year coverage and two indemnity payouts, one after each dry season.

// M<arsabit has five index areas.  

*## Impacts
// IBLI could act as a productive safety net for households affected by livestock losses after drought years and help them effectively manage the resulting shock.
// may also provide households with incentives to invest in livestock by reducing the risk 
// purchase of an IBLI insurance contract may enhance financial deepening, making credit more available and catalyzing related market opportunities.
// unexpected market, environmental, and behavioral impacts

*## Data
// Oct-Nov 2009 -> Fisrt round (baseline). Survey Oct-Nov until 2015 (no data 2014)
// Sales period -> Jan-Feb  and Aug-Sep.
// Indemnity payouts -> in between.

// 16 sub-locations of the full 47 in Marsabit district at baseline survey time (2009). 8 were initially targeted by HSNP (cash transfer program).

// Self-selection: HH decides if buy or not IBLI -. used encouragement process. randomly assign two strategies to control for that. Differentiating *** between people who received but did not purchase or purchased it in relatively small amounts and those who purchased insurance though they did not receive encouragement ****.  

clear all
cd "/Users/mrfreerider/Documents/GitHub/droughts_and_conflict/data/original/ibli marsabit"


******************************************************************
*** Livelihood and income
******************************************************************

*# TLU (Tropical livestock units) **********
use "S6A Livestock Stock.dta", clear

recode s6q1 -77=.

global animal Camels Cattle Goats Sheep

// total number of animals by type
foreach a in $animal{
	bys hhid round animaltype: egen `a'=total(s6q1) if animaltype=="`a'":L_Animal_Type
} 

drop if gender==2
drop gender

// fill missing values
sort hhid round
foreach a in $animal{
	
	bys hhid round: replace `a'=`a'[_n-1]  if missing(`a')
	bys hhid round: replace `a'=`a'[_n+1]  if missing(`a')
	bys hhid round: replace `a'=`a'[_n+2]  if missing(`a')
}
drop if animaltype>1
drop LivestockID animaltype 

// Generate TLU
bys hhid round: gen tlu_total=Camels*1.4+Cattle*1+Goats*0.1+Sheep*0.1 //calulate TLU
label var tlu_total "TLU including owned/borrowed"
//save data
keep hhid round Camels Cattle Goats Sheep tlu_total
save "/Users/mrfreerider/Documents/GitHub/droughts_and_conflict/data/processed/livestock.dta", replace

*#  Livestock Accounting **********
use "S6B Livestock Accounting.dta", clear 

recode s6q11 -77=.

global animal Camels Cattle Goats Sheep

// total number of animals by type
sort hhid round animaltype5
foreach a in $animal{
	bys hhid round animaltype5: egen `a'=total(s6q11) if animaltype5=="`a'":animaltype5
} 

drop if gender>1

// fill missing values
sort hhid round
foreach a in $animal{
	bys hhid round: replace `a'=`a'[_n-1]  if missing(`a')
	bys hhid round: replace `a'=`a'[_n+1]  if missing(`a')
	bys hhid round: replace `a'=`a'[_n+2]  if missing(`a')
} 
drop if animaltype5>1
drop LivestockID animaltype5 gender3 comment

// Generate TLU of losses
bys hhid round: gen tlu_loss=Camels*1.4+Cattle*1+Goats*0.1+Sheep*0.1
label var tlu_loss "TLU losses"
//save data
keep hhid round tlu_loss
save "~/Documents/GitHub/droughts_and_conflict/data/processed/livestocklosses.dta", replace


*# Livestock Losses **********
use "S6C Livestock Losses.dta", clear

// Count the number of events
bys hhid round: egen lossevents=count(lossevent)

// Loss events ocurred during the long dry season? 
// 1 if the loss events ocurred between june and september. 
gen losslds=1 if s6q20b>=6 & s6q20b<=9
replace losslds=0 if missing(losslds)

bys hhid round: egen loss_lds=total(losslds)
label var loss_lds "Losses during long dry season"

// Reason for  the loss events.
recode s6q22 -77=.

// Loss events due Starvation/Drought 
gen loss_starvdrought1=1 if s6q22==1
replace loss_starvdrought1=0 if missing(loss_starvdrought1)
bys hhid round: egen loss_starvdrought=total(loss_starvdrought1)
label var loss_lds "Losses due Starvation/Drought"

gen loss_starvdrought_lds1=1 if loss_starvdrought1==1 & s6q20b>=6 & s6q20b<=9
replace loss_starvdrought_lds1=0 if missing(loss_starvdrought_lds1)
bys hhid round: egen loss_starvdrought_lds=total(loss_starvdrought_lds1)

//Loss events due Raids, rustling, conflict  
gen loss_raid1=1 if s6q22==4
replace loss_raid1=0 if missing(loss_raid1)
bys hhid round: egen loss_raid=total(loss_raid1)
label var loss_raid "Losses due Raiding/Rusyling/Conflicts"

gen loss_raid_lds1=1 if loss_raid1==1 & s6q20b>=6 & s6q20b<=9
replace loss_raid_lds1=0 if missing(loss_raid_lds1)
bys hhid round: egen loss_raid_lds=total(loss_raid_lds1)


// Loss events at atelaites camps
recode s6q23 -77=.

gen loss_satelite1=1 if s6q23==2
replace loss_satelite1=0 if missing(loss_satelite1)
bys hhid round: egen loss_satelite=total(loss_satelite1)
label var loss_satelite "Losses at satelite camps"

gen loss_satelite_lds1=1 if loss_satelite1==1 & s6q20b>=6 & s6q20b<=9
replace loss_satelite_lds1=0 if missing(loss_satelite_lds1)
bys hhid round: egen loss_satelite_lds=total(loss_satelite_lds1)


drop if lossevent>1
keep hhid round lossevents loss_lds loss_starvdrought loss_starvdrought_lds  loss_raid loss_raid_lds loss_satelite loss_satelite_lds 
save "~/Documents/GitHub/droughts_and_conflict/data/processed/livestocklossesdetail.dta", replace

*# Milk production **********
use "S6H Milk Production.dta", clear

gen cont1=s6q56
recode cont1 -77=0 97=0 .=0
gen cont2=s6q56b
recode cont2 -77=0 97=0 .=0
gen cont3=s6q55*1000
recode cont3 -77=0 97=0 .=0

gen milk_cont= cont1 +cont2+cont3
label var milk_cont "milk container"
drop cont1 cont2 cont3

gen num_cont=s6q57
recode num_cont .=0 -77=. 

gen num_animal_lact=s6q54 
recode num_animal_lact .=0 -77=.

gen milk_prod1=(milk_cont*num_cont*num_animal_lact)/1000
label var milk_prod "Milk production liters per day"
recode milk_prod 0=.

gen selling_milk = s6q59
recode selling_milk -77=. 1=0 2=1

recode s6q62 -77=.
gen milk_sell1 = (s6q62*num_animal_lact)/1000

bys hhid round: egen milk_prod=total(milk_prod1)
bys hhid round: egen milk_sell=total(milk_sell1)
bys hhid round: egen self_cons=mean(selling_milk)
replace self_cons=0  if milk_prod==0 & milk_sell==0 & missing(self_cons)
replace self_cons=1 if self_cons>0 & self_cons<1 
keep if MilkID==1
keep hhid round milk_prod self_cons milk_sell

save "~/Documents/GitHub/droughts_and_conflict/data/processed/milk_production.dta", replace


*#  INCOME **********
// jun/sep:LONG Dry season; mar/may:Rainy season; jan/feb:SHORT dry season; oct/dec:rainy season
use "S8 Livelihood and Income.dta", clear
bys hhid round: egen inc_lds=sum(s8q5a)
bys hhid round: egen inc_lrs=sum(s8q5b)
bys hhid round: egen inc_sds=sum(s8q5c)
bys hhid round: egen inc_srs=sum(s8q5d)
gen inc_annual = inc_lds + inc_lrs + inc_sds + inc_srs

keep hhid round inc_lds  inc_lrs inc_sds inc_srs inc_annual
bys hhid round: gen dup= cond(_N==1,0,_n)
drop if dup > 1
drop dup
save "~/Documents/GitHub/droughts_and_conflict/data/processed/income.dta", replace


******************************************************************
** IBLI contracts
******************************************************************
use "S15B IBLI contracts.dta", clear

bys hhid round: egen ibli=count(contract_id)
recode s15q19_2 -77=.
bys hhid round: egen ibli_pay=total(s15q19_2)
recode s15q40 -77=. 98=. 1=1 2=0
bys hhid round: egen ibli_coupon=total(s15q40)
recode s15q22 -77=. 98=. 1=1 2=0
bys hhid round: egen ibli_coupon_use=total(s15q22)

recode s15q22a -77 98 =.
recode s15q22b -77 98 =.
recode s15q22c -77 98 =.
gen tlu_insured=s15q22a*1.4+s15q22b*1+s15q22c*0.1
bys hhid round: egen tlu_insur_tot=total(tlu_insured)

recode s15q39 -77=.
bys hhid round: egen index_area=mean(s15q39)
label value index_area L_Index_Area

keep if contract_id ==1
keep hhid round  ibli ibli_pay ibli_coupon ibli_coupon_use tlu_insured tlu_insur_tot index_area

save "~/Documents/GitHub/droughts_and_conflict/data/processed/ibli_contract.dta", replace 

******************************************************************
** Head & Household Characteristics
******************************************************************
*# Households Characteristics **********
use "S2 Household Rosters.dta", clear
sort hhid memberid round
merge m:m hhid memberid round  using "S3 Education.dta"

sort hhid memberid round
bys hhid: egen members=max(memberid) // number of members
label var members "Number of members"

*#  Household head ID **********
gen role = s2q5
label value role L_Relationship_to_Head
sort hhid memberid round
bys hhid memberid: replace role=role[_n+1] if missing(role)
label var role "Role of the member"

*# Gender **********
gen gender = s2q2
label value gender L_Gender
sort hhid memberid round
bys hhid memberid: replace gender=gender[_n+1] if missing(gender)
recode gender -77=. 1=1 2=0
label var gender "1 if household head is male"

*# Age **********
gen age = s2q3
label var age "Age (years)"
sort hhid memberid round
bys hhid memberid: replace age=age[_n-1]+1 if missing(age)
recode age -98=. -77=. -75=.

*# Marital Status **********
gen mar_stat= s2q6
label value mar_stat L_Marital_Status
recode mar_stat -99=. -77=.
sort hhid memberid round
bys hhid memberid: replace mar_stat=mar_stat[_n-1] if mar_stat==.
label var mar_stat "Marital status"

gen married = 1 if mar_stat==2 // Married
replace married = 0 if missing(married)
label var married "1 if household head is married"

gen widowed = 1 if mar_stat==5 //Widowed
replace widowed = 0 if missing(widowed)
label var widowed "1 if household head is widow"

*# Number of partners when the head is a man **********
gen num_partners=s2q7 
recode num_partners -77=.
sort hhid memberid round
bys hhid memberid: replace num_partners=num_partners[_n-1] if missing(num_partners)
label var num_partners "Number of wives/partners if head is a married man"

bys hhid memberid: replace num_partners=1 if gender==0 & mar_stat>=2 & mar_stat<=3
bys hhid memberid: replace num_partners=0 if mar_stat>=3
bys hhid memberid: replace num_partners=0 if mar_stat==1

*# Write in english **********
gen write_eng=s3q1
label value write_eng yes_no
sort hhid memberid round
bys hhid memberid: replace write_eng=write_eng[_n-1] if missing(write_eng)
recode write_eng -77=. 1=1 2=0

*# Write in Kiswahili **********
gen write_kis=s3q14a
label value write_kis yes_no
sort hhid memberid round
bys hhid memberid: replace write_kis=write_kis[6] if missing(write_kis)
recode s3q14a -77=. 1=1 2=0

*# Has ever attendend School or any other type **********
sort hhid memberid round
gen atten_school=s3q2
label var atten_school "Has the member attended school or any other educational facilites"
label value atten_school yes_no
sort hhid memberid round
bys hhid memberid: replace atten_school=atten_school[_n-1] if missing(atten_school)
recode atten_school -77=. 1=1 2=0

*# Max. level Education any member **********
sort hhid memberid round
gen educ_years = s3q6

replace educ_years=13
label var educ_years "Highest grade head has attained"
sort hhid  memberid round
bys hhid memberid: replace educ_years=educ_years[_n-1] if missing(educ_years)
replace educ_years=0 if atten_school==0
recode educ_years -77=.  97=. 23=. 15=13 16=14 17=15 19=14 20=13 21=14

bys hhid: egen max_educ_years=max(educ_years)
label var max_educ_years "Highest grade any member has attained"


*# Age when start school **********
gen educ_enrol = s3q5
label var educ_enrol "At what age did head first enroll in school"
sort hhid  memberid round
bys hhid memberid: replace educ_enrol=educ_enrol[_n-1] if missing(educ_enrol)
replace educ_enrol=0 if atten_school==0
recode educ_enrol -77=.  98=. 

keep hhid round memberid members gender age role num_partners mar_stat married widowed write_eng write_kis atten_school educ_years max_educ_years educ_enrol 

// standard = primary school (8 years = 8). Form = secondary school (4 years = 12). degree = university (4 years = 14)
// certificate (2 years = 14) diploma (higher voc/tech education 2 years = 13)

**********
keep if role ==1
duplicates report hhid round
duplicates list hhid round
duplicates tag  hhid round, gen(isdup) 

drop if isdup==1 & hhid==8029 & gender==0
drop if isdup==1 & hhid==9016 & gender==0 & age==45
drop if isdup==1 & hhid==12025 & gender==0
drop memberid isdup

save "~/Documents/GitHub/droughts_and_conflict/data/processed/hh_rosters.dta", replace

******************************************************************
** Combining data sets
******************************************************************
clear all
cd "/Users/mrfreerider/Documents/GitHub/droughts_and_conflict/data/original/ibli marsabit"

// HH identification information
use "S0A Household Identification Information.dta", clear
sort hhid round 
xtset hhid round 
bys hhid: replace panelnewhh = panelnewhh[3] if panelnewhh==.
bys hhid: replace hh_head_ethnic_group = hh_head_ethnic_group[1] if  hh_head_ethnic_group==.

global varkeep  hhid round TLU_class weight slocid panelnewhh hh_head_ethnic_group hh_head_clan_st district division location sublocation sublocation_16 sub_location_newhh  village village_newhh village_newhh_other householdmove2009 movetowhere sublocation_previous sublocation_confirmed moved_sublocation new_sublocation sublocation_other village_previous village_confirmed village_other moved_village new_village new_village_moved s1q6_old s1q6_old_other moved500m s2q15 s6q1a s6q1b s6q1c s6q1d s6q1e s6q1f s6q1g s6q19 lossaccountedyn s6q26 intakeaccountedyn s6q35 offaccountedyn s6q44 birthyn s6q48 slaughteryn s9q1 s9q2 s9q3 s9q4 s10q7 s10q8 s10q9 s10q10

keep $varkeep

gen move_subloc = .
replace move_subloc = householdmove2009 if round == 2 
replace move_subloc = moved_sublocation if round > 2 
label var move_subloc " Has your household moved to a new sublocation since October last year?"
recode move_subloc 1=1 2=0

gen subloc = slocid
replace subloc = sublocation_16 if round<=2
replace subloc = sublocation_16 if round==1
label value  subloc sublocID 


merge 1:1 hhid round using "S1 Household Information.dta"
bys hhid: replace s1q1=s1q1[1] if s1q1==.
bys hhid: replace s1q2=s1q2[1] if s1q2==.
bys hhid: replace s1q4a=s1q4a[1] if s1q4a==.
bys hhid: replace s1q4b=s1q4b[1] if s1q4b==.
replace s1q4b=0 if s1q4b==.

keep  $varkeep move_subloc subloc s1q1 s1q1b s1q2 s1q3 s1q4a s1q4b s1q6 s1q6b s1q8 s1q9 s1q9b


merge 1:1 hhid round using "S15A Groups, IBLI, HSNP.dta"

drop _merge s15q3 s15q4 s15q10 s15q11 s15q11b s15q8 s15q9 s15q9b s15q15 s15q15a s15q15b s15q15c s15q15d s15q15e s15q15f s15q15g s15q15h s15q15i s15q15j s15q15j2 s15q15k s15q15l s15q15m s15q15n s15q15o s15q15p s15q15q s15q15r s15q15s s15q15t s15q15u s15q16 s15q18c1 s15q18e2 s15q19a s15q19a2 s15q19b s15q19b2 s15q19c s15q19c2 s15q25 s15q26 s15q27 s15q28 s15q29 s15q30 s15q31 s15q31b s15q41 s15q42 s15q43 s15q48 s15q49 s15q50 s15q51 s15q52 s15q48a6 s15q53 s15q48d1 s15q48d2 s15q48d3 s15q48d4 s15q48d5 s15q48d98 s15q48a1 s15q48a2 s15q48a3 s15q48a4 s15q48a5 s15q44 s15q47a s15q47b s15q47c s15q52_i_a s15q52_i_b s15q52_i_c s15q52_u_a s15q52_u_b s15q52_u_c s15q53_u_a s15q53_u_b s15q53_u_c s15q49_r3 s15q48_r3 s15q50_r3 s15q57a s15q57b s15q57c s15q57d s15q57e s15q57f s15q57g s15q58a s15q58a1 s15q58a2 s15q58a3 s15q58a4 s15q58a5 s15q58a6 s15q58a7 s15q58a8 s15q58b s15q58c

merge 1:1 hhid round using "S14A Saving, Lending, Borrowing.dta"
drop _merge s14q2b s14q2a s14q4a s14q4b s14q5 s14q6 s14q6b s14q7 s14q8 s14q9 s14q10 s14q11 s14q52 s14q52b s14q24 s14q25 s14q28 s14q53 s14q54 s14q83 s14q55 s14q56 s14q56b  s14q57 s14q57b s14q73 s14q71 s14q72 s14q18a s14q18a2 s14q18b s14q19a s14q19a2 s14q19b s14q20a s14q20a2 s14q20b s14q21a s14q21a2 s14q21b s14q6_r1 s14q6b_r1 s14q9_r1 s14q9b_r1 s14q10_r1 s14q10b_r1 s14q11_r1  s14q13 s14q13b s14q14 s14q16 s14q16b s14q17 s14q58_r23 s14q58a_r23 s14q58b_r23 s14q58a s14q58 s14q59 s14q59b s14q59c

merge 1:1 hhid round using "S15E Game and Discount Coupon.dta"
drop _merge

merge 1:1 hhid round  using "~/Documents/GitHub/droughts_and_conflict/data/processed/income.dta"
drop _merge

merge 1:1 hhid round  using "~/Documents/GitHub/droughts_and_conflict/data/processed/livestock.dta"
drop _merge

merge 1:1 hhid round  using "~/Documents/GitHub/droughts_and_conflict/data/processed/livestocklosses.dta"
drop _merge

merge 1:1 hhid round  using "~/Documents/GitHub/droughts_and_conflict/data/processed/livestocklossesdetail.dta"
drop _merge

merge 1:1 hhid round  using "~/Documents/GitHub/droughts_and_conflict/data/processed/milk_production.dta"
drop _merge

merge 1:m hhid round using "~/Documents/GitHub/droughts_and_conflict/data/processed/hh_rosters.dta"
drop _merge

merge m:1 hhid round  using "~/Documents/GitHub/droughts_and_conflict/data/processed/ibli_contract.dta"
sort hhid round

global vars ibli ibli_pay ibli_coupon ibli_coupon_use tlu_insur_tot
foreach v in $vars{
	replace `v'=0 if _merge == 1
}
drop _merge



xtset hhid round

******************************************************************


******************************************************************
** Creating Variables
******************************************************************

// Household Income per capita per day
gen inc_pc=(inc_annual/members)/365  
label var inc_pc "Annual income per capita (KHS)"
// Ethnic Group
tab hh_head_ethnic_group, gen(ethnic)
//Savings
gen saving = s14q1
recode saving 1=1 2=0
gen saving_amount = s14q3
recode saving_amount -77=.

//beneficiarie from a cash transfer program
gen cash_transf = s15q12 
recode cash_transf -77=. 1=1 2=0

gen cash_transf_amount = s15q13
recode cash_transf_amount -77=.

// NDVI data 
xtset hhid round 
encode division, gen(division1)
sort hhid round 
bys hhid: replace division1=division1[_n-1] if missing(division1)
drop division
rename division1 division

replace division = 1 if subloc==1 & missing(division)
replace division = 1 if subloc==8 & missing(division)
replace division = 2 if subloc==2 & missing(division)
replace division = 2 if subloc==3 & missing(division)
replace division = 3 if subloc==11 & missing(division)
replace division = 3 if subloc==12 & missing(division)
replace division = 3 if subloc==13 & missing(division)
replace division = 3 if subloc==15 & missing(division)
replace division = 4 if subloc==9 & missing(division)
replace division = 4 if subloc==10 & missing(division)
replace division = 4 if subloc==14 & missing(division)
replace division = 4 if subloc==16 & missing(division)
replace division = 5 if subloc==4 & missing(division)
replace division = 5 if subloc==5 & missing(division)
replace division = 5 if subloc==6 & missing(division)
replace division = 5 if subloc==7 & missing(division)


merge m:m division round using "/Users/mrfreerider/Documents/GitHub/droughts_and_conflict/data/processed/ndvi_division_zscores.dta", force
drop _merge
drop if missing(hhid)
 
******************************************************************
** Save data set
******************************************************************

save "/Users/mrfreerider/Documents/GitHub/droughts_and_conflict/data/processed/merge_data_marsabit.dta", replace


tlu_total
inc_pc
s6q35 //losses

sort hhid round
xtset hhid round,

// Self-reported losses (Ddd you HH lose livestock last period)
recode s6q19 1=1 2=0

xtivreg  s6q19 (ibli_once = disc_once i.slocid##i.round cash_transf)  i.slocid##i.round cash_transf, first fe

xtprobit s6q19 ndvi_zyd ibli ibli_coupon i.round##i.subloc

xtreg tlu_loss ndvi_zyd ibli ibli_coupon i.round##i.subloc, fe vce(cluster slocid ) nonest

xtreg tlu_loss ndvi_zldd ibli ibli_coupon i.round##i.subloc, fe vce(cluster slocid ) nonest

xtpoisson lossevents ndvi_zyd ibli ibli_coupon i.round##i.division, fe 

xtpoisson loss_lds ndvi_zldd ibli ibli_coupon i.round##i.division, fe 

xtpoisson loss_starvdrought ndvi_zyd ibli ibli_coupon i.round##i.division, fe 

xtpoisson loss_starvdrought_lds ndvi_zldd ibli ibli_coupon i.round##i.division, fe

gen raid=1 if loss_raid>0
replace raid=0 if missing(raid)
xtprobit raid ndvi_zyd ibli ibli_coupon i.round##i.division

gen raidlds=1 if loss_raid_lds>0
replace raidlds=0 if missing(raidlds)
xtlogit raidlds ndvi_zldd  i.round##i.division, fe

xtpoisson loss_raid ndvi_zyd  ibli_once i.round##i.division, fe
xtpoisson loss_raid_lds ndvi_zldd ibli_once i.round##i.division, fe

xtpoisson loss_satelite ndvi_zyd ibli ibli_coupon i.round##i.division, fe
xtpoisson loss_satelite_lds ndvi_zlrd ibli ibli_coupon i.round##i.division, fe




areg s6q19 ndvi_zlrd, absorb(hhid) vce(cluster slocid)



areg inc_pc ndvi_zyd, absorb(hhid) 

areg tlu_total ndvi_zyd if tlu_total>0, absorb(hhid)  vce(cluster slocid)
areg tlu_total ndvi_zlrd, absorb(hhid) vce(cluster slocid)

** Did you purchase IBLI (current year)? // per round
preserve
gen s15q18cper=s15q18c*100
gen s15q18dper=s15q18d*100
collapse (mean) mean1=s15q18cper  (sd) sd1=s15q18cper (count) n1=s15q18cper (mean) mean2=s15q18dper  (sd) sd2=s15q18dper (count) n2=s15q18dper, by(round)

gen hivalue1 = mean1 + invttail(n1-1,0.025)*(sd1 / sqrt(n1))
gen lovalue1 = mean1 - invttail(n1-1,0.025)*(sd1 / sqrt(n1))
gen hivalue2 = mean2 + invttail(n2-1,0.025)*(sd2 / sqrt(n2))
gen lovalue2 = mean2 - invttail(n2-1,0.025)*(sd2 / sqrt(n2))

graph twoway (scatter mean1 round, color(navy)) (rcap hivalue1 lovalue1 round, color(navy)) (scatter mean2 round, color(maroon)) (rcap hivalue2 lovalue2 round, color(maroon)),  ytitle("Yes %") xtitle("Round") title(Purchased IBLI current year) note("Did you purchase livestock insurance (current year)?") name(purinsu_janfeb, replace) legend(order(1 "Mean Jan/Feb" 2 "95% CI Jan/Feb" 3 "Mean Aug/Sep" 4 "95% CI Aug/Sep") pos(6) cols(4))
//graph display purinsu_janfeb, xsize(8.0)
graph export "ibli_purchase.pdf", replace
restore

** Received a Coupon (current year)
recode s15q17a 1=1 2=0 -77=. 98=. // Did you receive a discount coupon that reduced the price of insurance in Jan/Feb (current year)?
recode s15q17c 1=1 2=0 -77=. 98=. // Did you receive a discount coupon that reduced the price of insurance in Aug/Sep (current year)?
 
gen coupon = 0 
replace coupon = 1 if discount_jan_2010 > 0
replace coupon = 2 if discount_jan_2011 > 0
replace coupon = discount_aug_2011
replace coupon = 1 if discount_aug_2012 > 0
replace coupon = 1 if discount_jan_2013 > 0
replace coupon = 1 if discount_aug_2013 > 0

preserve
gen s15q17aper=s15q17a*100
gen s15q17cper=s15q17c*100

collapse (mean) mean1=s15q17aper  (sd) sd1=s15q17aper (count) n1=s15q17aper (mean) mean2=s15q17cper  (sd) sd2=s15q17cper (count) n2=s15q17cper, by(round)

generate hivalue1 = mean1 + invttail(n1-1,0.025)*(sd1 / sqrt(n1))
generate lovalue1 = mean1 - invttail(n1-1,0.025)*(sd1 / sqrt(n1))
generate hivalue2 = mean2 + invttail(n2-1,0.025)*(sd2 / sqrt(n2))
generate lovalue2 = mean2 - invttail(n2-1,0.025)*(sd2 / sqrt(n2))


graph twoway (scatter mean1 round, color(navy)) (rcap hivalue1 lovalue1 round, color(navy)) (scatter mean2 round, color(maroon)) (rcap hivalue2 lovalue2 round, color(maroon)),  ytitle("Yes %") xtitle("Round") title(Received a coupon this year) note("Did you receive a discount coupon that reduced the price of insurance (current year)?") name(disco_janfeb, replace) legend(order(1 "Mean Jan/Feb" 2 "95% CI Jan/Feb" 3 "Mean Aug/Sep" 4 "95% CI Aug/Sep") pos(6) cols(4))
//graph display purinsu_janfeb, xsize(8.0)
graph export "coupon_received.pdf", replace
restore

//Percent received Jan/Feb(current year)
recode s15q17b 98=. 9=. // what percent of reduction di the cupon offer in Jan/Feb (current year)?
//Percent received Aug/Sep (current year)
recode s15q17d  98=. 9=. // what percent of reduction di the cupon offer in Jan/Feb (current year)?


recode s6q26 1=1 2=0

preserve
gen s6q26per=s6q26*100
collapse (mean) mean=s6q26per  (sd) sd=s6q26per (count) n=s6q26per, by(purch_twice round)
generate hivalue = mean + invttail(n-1,0.025)*(sd / sqrt(n))
generate lovalue = mean - invttail(n-1,0.025)*(sd / sqrt(n))

gen status_1 = purch_twice - 0.2
gen status_2 = purch_twice + 0.2

graph twoway (connected mean round if purch_twice==0, color(navy)) (rcap hivalue lovalue round if purch_twice==0, color(navy)) (connected mean round if purch_twice==1, color(maroon)) (rcap hivalue lovalue round if purch_twice==1, color(maroon)) (connected mean round if purch_twice==2,color(orange_red)) (rcap hivalue lovalue round if purch_twice==2, color(orange_red)),  ytitle("Yes %") xtitle("Round") title(Livestock purchases by IBLI) note(Did your household purchase or obtain livestock between Oct this year and Sep last year?) name(purchlive, replace)legend(order(1 "Mean Never" 3 "Mean Once" 5 "Mean Twice") pos(6) cols(3))
graph display purchlive, xsize(8.0)
graph export "livestok_purchases.pdf", replace
restore



hh_head_ethnic_group

s1q1// language
s1q3 // settlement?
s1q4a // number of years at the current location 
s1q4b // months
s1q6 // reasons casued moving migration
s15q5a s15q5b s15q5c s15q5d s15q5e s15q5f s15q5g s15q5h s15q5i // participation in groups
s15q12 s15q13 // beneficiarie cash transfer and amount received

// round 2 onward
s15q17a s15q17c s15q17b s15q17d // received a coupon & percent
s15q18c s15q18d // purchase and insurance/data/marsabit
s15q20b s15q20 s15q20a // received indemnity payout last march/october & houw much (previous year)
s15q21 s15q21b s15q21a s15q21c // received indemnity payout last march/october & houw much (current year)


 
preserve
keep if round == 1
global varint TLU_class s6q19 s6q26 s1q3



//Livestock losses
recode s6q19 1=1 2=0 // livestock losses

recode s15q18a 1=1 2=0 // Purchased insurance ever
recode s15q18c 1=1 2=0 -77=.  // Purchased Jan/Feb
recode s15q18d 1=1 2=0 -77=.  // Purchased Aug/Sep

gen purch_1=s15q18c
replace purch_1=0 if s15q18c==.
gen purch_2=s15q18d
replace purch_2=0 if s15q18d==.
gen purch_twice=purch_1+purch_2

preserve
gen s6q19per=s6q19*100
collapse (mean) mean=s6q19per  (sd) sd=s6q19per (count) n=s6q19per, by(purch_twice round)
label var mean "Mean"
generate hivalue = mean + invttail(n-1,0.025)*(sd / sqrt(n))
generate lovalue = mean - invttail(n-1,0.025)*(sd / sqrt(n))
label var hivalue "95% CI"
label var lovalue " "

graph twoway (connected mean round if purch_twice==0, color(navy)) (rcap hivalue lovalue round if purch_twice==0, color(navy)) (connected mean round if purch_twice==1, color(maroon)) (rcap hivalue lovalue round if purch_twice==1, color(maroon)) (connected mean round if purch_twice==2,color(orange_red)) (rcap hivalue lovalue round if purch_twice==2, color(orange_red)),  ytitle("Yes %") xtitle("Round") title(Livestock losses by IBLI) note(Did your household lose livestock due to mortality and other causes between Oct this year and Sep last year?) name(losslive, replace) legend(order(1 "Mean Never" 3 "Mean Once" 5 "Mean Twice") pos(6) cols(3))
//graph export "livestok_losses.pdf", replace
restore



** By etchnic group
replace hh_head_ethnic_group = . if hh_head_ethnic_group==97
preserve
gen s6q19per=s6q19*100
statsby , by(round hh_head_ethnic_group) clear: ci means s6q19 
list

ciplot s6q19 , by(round hh_head_ethnic_group) recast(bar) bfcolor(none ..) base(0)

Did your household lose livestock due to mortality and other causes between Oct this year and Sep last year
bys hh_head_ethnic_group round: egen liveloss_mean=mean(s6q19per)
gr bar liveloss_mean, over(round) over(hh_head_ethnic_group) name(losslive, replace) ytitle("Yes %")
graph display losslive, xsize(8.0)
graph export "livestok_losses_ethnic.pdf", replace
restore

preserve
gen s6q19per=s6q19*100
collapse (mean) mean=s6q19per  (sd) sd=s6q19per (count) n=s6q19per, by(  hh_head_ethnic_group round)
generate hivalue = mean + (1.96*sqrt(mean*(1-mean)/n))
generate lovalue = mean - (1.96*sqrt(mean*(1-mean)/n))

gen eth1 = hh_head_ethnic_group - 0.5
gen eth2 = hh_head_ethnic_group - 0.3
gen eth3 = hh_head_ethnic_group - 0.1
gen eth4 = hh_head_ethnic_group + 0.1
gen eth5 = hh_head_ethnic_group + 0.3
gen eth6 = hh_head_ethnic_group + 0.5

twoway (bar mean eth1, color(navy%70) barwidth(0.2)) ///
(bar mean eth2, color(maroon%70) barwidth(0.2)) (bar mean eth3, color(blue%70) barwidth(0.2))



//graph display losslive, xsize(8.0)
//graph export "livestok_losses_ethnic.pdf", replace
restore


xlabel(1 "Control" 2"Indirectly" 3 "Directly"))


|| (connected mean round if hh_head_ethnic_group==4, color(red)) (rcap hivalue lovalue round if hh_head_ethnic_group==4, color(red)) || (connected mean round if hh_head_ethnic_group==5) (rcap hivalue lovalue round if hh_head_ethnic_group==5, color(navy)) || (connected mean round if hh_head_ethnic_group==6) (rcap hivalue lovalue round if hh_head_ethnic_group==6, color(navy))










twoway (connected mean round if hh_head_ethnic_group==1) || (connected mean round if hh_head_ethnic_group==2) || (connected mean round if hh_head_ethnic_group==3) || (connected mean round if hh_head_ethnic_group==4) || (connected mean round if hh_head_ethnic_group==5) || (connected mean round if hh_head_ethnic_group==6) 
