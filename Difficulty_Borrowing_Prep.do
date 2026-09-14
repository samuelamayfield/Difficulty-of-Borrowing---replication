clear all
set more off

global PROJDIR "/Users/samuelmayfield/Desktop/Research/EfD Borrowing"
cd "$PROJDIR"

capture log close
log using "Difficulty_Borrowing_Prep.log", replace text

* import wave 1

use "NUSP0001_w1_OUTPUT.dta", clear

* append wave 2

append using "NUSP0001_w2_OUTPUT.dta"

* generate country indicator variables

replace country = 1 if country_of_residence == 170
replace country = 2 if country_of_residence == 356
replace country = 3 if country_of_residence == 404
replace country = 4 if country_of_residence == 566
replace country = 5 if country_of_residence == 710
replace country = 7 if country_of_residence == 704
replace country = 8 if country_of_residence == 152
gen Colombia=1 if country==1
gen India=1 if country==2
gen Kenya=1 if country==3
gen Nigeria=1 if country==4
gen South_Africa=1 if country==5
gen Tanzania=1 if country==6
gen Vietnam=1 if country==7
gen Chile=1 if country==8
label define Country 1 "Colombia" 2 "India" 3 "Kenya" 4 "Nigeria" 5 "South Africa" 6 "Tanzania" 7 "Vietnam" 8 "Chile"
label values country Country

* sort by country

sort country caseid

* generate log age variable

gen lage = ln(age)

* generate education level variable

gen EducLevel=.
replace EducLevel=1 if education_cl==1 | education_co==1 | education_in==1 | education_ke < 4 | education_ng < 6 | education_vt==1 | education_tz < 4 | education_za == 1 
replace EducLevel=2 if education_cl==2 | education_co==2 | education_in==2 | education_ke==4 | education_ng==6 | education_vt==2 | education_tz==4 | education_za == 2
replace EducLevel=3 if education_cl==3 | education_co==3 | education_co==4
replace EducLevel=3 if education_co==5 | education_in==3 | education_in==4 | education_ke==5 | education_ke==6 | education_ng==6 | education_ng==7 | education_vt==3 | education_vt==4 | education_tz==5 | education_za == 3 | education_za == 4
replace EducLevel=4 if education_cl==4 | education_cl==5 | education_co==6 | education_in==5 | education_in==6 | education_ke==7 | education_ng==8 | education_vt==5 | education_tz==6 | education_za == 5
replace EducLevel=5 if education_cl==6 | education_co==7 | education_in==7 | education_ke==8 | education_ng==9 | education_vt==6 | education_za == 6
label var EducLevel "Education Level"
label define elevel 1 "less than high school" 2 "high school degree" 3 "some college" 4 "college degree" 5 "postgraduate degree"
label values EducLevel elevel

* convert currencies to USD
* exchange rates determined using historical rate table on www.xe.com

* Colombia 05feb2022 0.0002533235
replace D29 = D29*0.0002533235 if country == 1 & wave == 1
replace D30 = D30*0.0002533235 if country == 1 & wave == 1
* Columbia 26apr2023 0.0002201308
replace D29 = D29*0.0002201308 if country == 1 & wave == 2
replace D30 = D30*0.0002201308 if country == 1 & wave == 2
label define codi 1 "Less than $2" 2 "$2-$5" 3 "$6-$10" 4 "$11-$20" 5 "$21-$50" 6 "$51-$100" 7 "$101-$150" 8 "$151-$300" 9 "Above $300" 96 "Don't know" 97 "Refused to answer"
label values D6_CO codi
label define comi 1 "Less than $100" 2 "$101-$200" 3 "$201-$400" 4 "$401-$700" 5 "$701-$1000" 6 "$1001-$1500" 7 "$1501-$2000" 8 "$2001-$3000" 9 "Above $3000" 96 "Don't know" 97 "Refused to answer"
label values D7_CO comi

* India 04feb2022 0.0133972711
replace D29 = D29*0.0133972711 if country == 2 & wave == 1
replace D30 = D30*0.0133972711 if country == 2 & wave == 1
* India 26apr2023 0.0122315689
replace D29 = D29*0.0122315689 if country == 2 & wave == 2
replace D30 = D30*0.0122315689 if country == 2 & wave == 2
label define indi 1 "Less than $2" 2 "$2-$5" 3 "$6-$10" 4 "$11-$20" 5 "$21-$50" 6 "$51-$100" 7 "$101-$150" 8 "$151-$300" 9 "Above $300" 96 "Don't know" 97 "Refused to answer"
label values D6_IN indi
label define inmi 1 "Less than $100" 2 "$101-$200" 3 "$201-$400" 4 "$401-$700" 5 "$701-$1000" 6 "$1001-$1500" 7 "$1501-$2000" 8 "$2001-$3000" 9 "Above $3000" 96 "Don't know" 97 "Refused to answer"
label values D7_IN inmi

* Kenya 04feb2022 0.0087996391
replace D29 = D29*0.0087996391 if country == 3 & wave == 1
replace D30 = D30*0.0087996391 if country == 3 & wave == 1
* Kenya 26apr2023 0.0073641000
replace D29 = D29*0.0073641000 if country == 3 & wave == 2
replace D30 = D30*0.0073641000 if country == 3 & wave == 2
label define kedi 1 "Less than $2" 2 "$2-$5" 3 "$6-$10" 4 "$11-$20" 5 "$21-$50" 6 "$51-$100" 7 "$101-$150" 8 "$151-$300" 9 "Above $300" 96 "Don't know" 97 "Refused to answer"
label values D6_KE kedi
label define kemi 1 "Less than $100" 2 "$101-$200" 3 "$201-$400" 4 "$401-$700" 5 "$701-$1000" 6 "$1001-$1500" 7 "$1501-$2000" 8 "$2001-$3000" 9 "Above $3000" 96 "Don't know" 97 "Refused to answer"
label values D7_KE kemi

* Nigeria 04feb2022 0.0024029550
replace D29 = D29*0.0024029550 if country == 4 & wave == 1
replace D30 = D30*0.0024029550 if country == 4 & wave == 1
* Nigeria 26apr2023 0.0021711528
replace D29 = D29*0.0021711528 if country == 4 & wave == 2
replace D30 = D30*0.0021711528 if country == 4 & wave == 2
label define ngdi 1 "Less than $2" 2 "$2-$5" 3 "$6-$10" 4 "$11-$20" 5 "$21-$50" 6 "$51-$100" 7 "$101-$150" 8 "$151-$300" 9 "Above $300" 96 "Don't know" 97 "Refused to answer"
label values D6_NG ngdi
label define ngmi 1 "Less than $100" 2 "$101-$200" 3 "$201-$400" 4 "$401-$700" 5 "$701-$1000" 6 "$1001-$1500" 7 "$1501-$2000" 8 "$2001-$3000" 9 "Above $3000" 96 "Don't know" 97 "Refused to answer"
label values D7_NG ngmi

* South Africa 23feb2022 0.0662342839
replace D29 = D29*0.0662342839 if country == 5 & wave == 1
replace D30 = D30*0.0662342839 if country == 5 & wave == 1
* South Africa 26apr2023 0.0544122516
replace D29 = D29*0.0544122516 if country == 5 & wave == 2
replace D30 = D30*0.0544122516 if country == 5 & wave == 2
label define zadi 1 "Less than $2" 2 "$2-$5" 3 "$6-$10" 4 "$11-$20" 5 "$21-$50" 6 "$51-$100" 7 "$101-$150" 8 "$151-$300" 9 "Above $300" 96 "Don't know" 97 "Refused to answer"
label values D6_ZA zadi
label define zami 1 "Less than $100" 2 "$101-$200" 3 "$201-$400" 4 "$401-$700" 5 "$701-$1000" 6 "$1001-$1500" 7 "$1501-$2000" 8 "$2001-$3000" 9 "Above $3000" 96 "Don't know" 97 "Refused to answer"
label values D7_ZA zami

* Tanzania 26feb2022 0.0004322252
replace D29 = D29*0.0004322252 if country == 6 & wave == 1
replace D30 = D30*0.0004322252 if country == 6 & wave == 1
label define tzdi 1 "Less than $2" 2 "$2-$5" 3 "$6-$10" 4 "$11-$20" 5 "$21-$50" 6 "$51-$100" 7 "$101-$150" 8 "$151-$300" 9 "Above $300" 96 "Don't know" 97 "Refused to answer"
label values D6_TZ tzdi
label define tzmi 1 "Less than $100" 2 "$101-$200" 3 "$201-$400" 4 "$401-$700" 5 "$701-$1000" 6 "$1001-$1500" 7 "$1501-$2000" 8 "$2001-$3000" 9 "Above $3000" 96 "Don't know" 97 "Refused to answer"
label values D7_TZ tzmi

* Vietnam 05feb2022 0.0000440745
replace D29 = D29*0.0000440745 if country == 7 & wave == 1
replace D30 = D30*0.0000440745 if country == 7 & wave == 1
* Vietnam 26apr2023 0.0000428522
replace D29 = D29*0.0000428522 if country == 7 & wave == 2
replace D30 = D30*0.0000428522 if country == 7 & wave == 2
label define vtdi 1 "Less than $2" 2 "$2-$5" 3 "$6-$10" 4 "$11-$20" 5 "$21-$50" 6 "$51-$100" 7 "$101-$150" 8 "$151-$300" 9 "Above $300" 96 "Don't know" 97 "Refused to answer"
label values D6_VT vtdi
label define vtmi 1 "Less than $100" 2 "$101-$200" 3 "$201-$400" 4 "$401-$700" 5 "$701-$1000" 6 "$1001-$1500" 7 "$1501-$2000" 8 "$2001-$3000" 9 "Above $3000" 96 "Don't know" 97 "Refused to answer"
label values D7_VT vtmi

* Chile 26apr2023 0.0012451273
* BUGFIX 2026-08: these two lines previously read "if country == 7 & wave == 2".
* Country 7 is Vietnam; Chile is country 8. As written, Vietnam's wave-2 rent and
* house value were converted twice (by the Vietnam rate and again by the Chile
* rate), while Chile's were never converted and remained in pesos.
replace D29 = D29*0.0012451273 if country == 8 & wave == 2
replace D30 = D30*0.0012451273 if country == 8 & wave == 2
label define cldi 1 "Less than $2" 2 "$2-$5" 3 "$6-$10" 4 "$11-$20" 5 "$21-$50" 6 "$51-$100" 7 "$101-$150" 8 "$151-$300" 9 "Above $300" 96 "Don't know" 97 "Refused to answer"
label values D6_CL cldi
label define clmi 1 "Less than $100" 2 "$101-$200" 3 "$201-$400" 4 "$401-$700" 5 "$701-$1000" 6 "$1001-$1500" 7 "$1501-$2000" 8 "$2001-$3000" 9 "Above $3000" 96 "Don't know" 97 "Refused to answer"
label values D7_CL clmi

* generate daily income bracket for all

gen DaiInc = .
foreach x of varlist D6_CO D6_IN D6_KE D6_NG D6_ZA D6_TZ D6_VT D6_CL {
	replace DaiInc = `x' if `x' !=.
}
label define aldi 1 "Less than $2" 2 "$2-$5" 3 "$6-$10" 4 "$11-$20" 5 "$21-$50" 6 "$51-$100" 7 "$101-$150" 8 "$151-$300" 9 "Above $300" 96 "Don't know" 97 "Refused to answer"
label values DaiInc aldi

* generate monthly income bracket for all

gen MonInc = .
* BUGFIX 2026-08: the last variable in this list previously read D6_CL, which is
* Chile's DAILY income bracket. Chile's MonInc was therefore identical to its
* DaiInc rather than to its monthly bracket. Corrected to D7_CL.
foreach x of varlist D7_CO D7_IN D7_KE D7_NG D7_ZA D7_TZ D7_VT D7_CL {
	replace MonInc = `x' if `x' !=.
}
label define almi 1 "Less than $100" 2 "$101-$200" 3 "$201-$400" 4 "$401-$700" 5 "$701-$1000" 6 "$1001-$1500" 7 "$1501-$2000" 8 "$2001-$3000" 9 "Above $3000" 96 "Don't know" 97 "Refused to answer"
label values MonInc almi

* generate log monthly income variable

gen lMonInc = ln(MonInc)

*Generate COVID-19 Knowledge Scale Variable
*sort by country so can use the "by country:" prefix
sort country
*
*Create KnowScale Variable
*Set to zero for all respondents
gen KnowScale=0
*Now increment up by 1 for correct answer and down by - 1 for incorrect answers on Q22 series
*Virus not mutating [incorrect]
replace KnowScale=KnowScale - 1 if Q22_1==1
replace KnowScale=KnowScale + 1 if Q22_1==2
*No more likely to die [incorrect]
replace KnowScale=KnowScale - 1 if Q22_2==1
replace KnowScale=KnowScale + 1 if Q22_2==2
*First infected in China [correct]
replace KnowScale=KnowScale + 1 if Q22_3==1
replace KnowScale=KnowScale - 1 if Q22_3==2
*Young immune [incorrect]
replace KnowScale=KnowScale - 1 if Q22_4==1
replace KnowScale=KnowScale + 1 if Q22_4==2
*Asymptomatic can infect [correct]
replace KnowScale=KnowScale + 1 if Q22_5==1
replace KnowScale=KnowScale - 1 if Q22_5==2
*Social distancing reduces transmission [correct]
replace KnowScale=KnowScale + 1 if Q22_6==1
replace KnowScale=KnowScale - 1 if Q22_6==2
*Facemasks do not help [incorrect]
replace KnowScale=KnowScale - 1 if Q22_7==1
replace KnowScale=KnowScale + 1 if Q22_7==2
*Avoiding crowds reduces transmission [correct]
replace KnowScale=KnowScale + 1 if Q22_8==1
replace KnowScale=KnowScale - 1 if Q22_8==2
*Outdoors safer [correct]
replace KnowScale=KnowScale + 1 if Q22_9==1
replace KnowScale=KnowScale - 1 if Q22_9==2
*Vaccines safe
replace KnowScale=KnowScale + 1 if Q22_10==1
replace KnowScale=KnowScale - 1 if Q22_10==2
*
* tab KnowScale   // diagnostic only; commented out 2026-08 so that this file
*                 // produces data and nothing else
*
*Note that variable has a substantial number of negative values
*Create a recentered version where all values are positive
gen KScale11=KnowScale + 11
*Create log version
gen LogKScale11=log(KScale11)
*
* The three exploratory estimations below were run while the COVID knowledge
* scale was being developed. They are not used anywhere in the paper and are
* commented out 2026-08 so that this file performs data preparation only.
* Note also that the first mlogit specified i.country twice.
*
* by country: summarize KnowScale
* mlogit Q34 i.country LogKScale11
* mlogit Q34 LogKScale11 age i.gender

*Rename & Label Variables
rename Q1_4_order Q1_4_Order
rename Q1 LifeSat
rename Q2 EndsMeet
rename Q4 EndsMeetPre
*Labeling Q5 & Q6
label var Q5_3most_1 "Attn: Newspapers"
label var Q5_3most_2 "Attn: Television"
label var Q5_3most_3 "Attn: Radio"
label var Q5_3most_4 "Attn: Social Media"
label var Q5_3most_5 "Attn: Other Internet Sites"
label var Q5_3most_6 "Attn: Family Members"
label var Q5_3most_7 "Attn: Friends & Neighbors"
label var Q5_3most_9 "Attn: Doctors & Healthcare Workers"
label var Q5_3most_10 "Attn: Religious Leaders"
label var Q5_3most_11 "Attn: NGOs"
label var Q5_3most_12 "Attn: National Government"
label var Q5_3most_13 "Attn: Local Government"
label var Q5_3least_1 "Attn: Newspapers"
label var Q5_3least_2 "Attn: Television"
label var Q5_3least_3 "Attn: Radio"
label var Q5_3least_4 "Attn: Social Media"
label var Q5_3least_5 "Attn: Other Internet Sites"
label var Q5_3least_6 "Attn: Family Members"
label var Q5_3least_7 "Attn: Friends & Neighbors"
label var Q5_3least_9 "Attn: Doctors & Healthcare Workers"
label var Q5_3least_10 "Attn: Religious Leaders"
label var Q5_3least_11 "Attn: NGOs"
label var Q5_3least_12 "Attn: National Government"
label var Q5_3least_13 "Attn: Local Government"
label var Q6_3most_1 "Trust: Newspapers"
label var Q6_3most_2 "Trust: Television"
label var Q6_3most_3 "Trust: Radio"
label var Q6_3most_4 "Trust: Social Media"
label var Q6_3most_5 "Trust: Other Internet Sites"
label var Q6_3most_11 "Trust: Family Members"
label var Q6_3most_12 "Trust: Friends & Neighbors"
label var Q6_3most_13 "Trust: Doctors & Healthcare Workers"
label var Q6_3most_9 "Trust: Religious Leaders"
label var Q6_3most_10 "Trust: NGOs"
label var Q6_3most_14 "Trust: National Government"
label var Q6_3most_15 "Trust: Local Government"
label var Q6_3least_1 "Trust: Newspapers"
label var Q6_3least_2 "Trust: Television"
label var Q6_3least_3 "Trust: Radio"
label var Q6_3least_4 "Trust: Social Media"
label var Q6_3least_5 "Trust: Other Internet Sites"
label var Q6_3least_11 "Trust: Family Members"
label var Q6_3least_12 "Trust: Friends & Neighbors"
label var Q6_3least_13 "Trust: Doctors & Healthcare Workers"
label var Q6_3least_9 "Trust: Religious Leaders"
label var Q6_3least_10 "Trust: NGOs"
label var Q6_3least_14 "Trust: National Government"
label var Q6_3least_15 "Trust: Local Government"
*
*Financial aid received since COVID-19 pandemic began in March 2020
rename Q7a_1 Sup_Unemp
rename Q7a_2 Sup_Food
rename Q7a_3 Sup_Tax
rename Q7a_4 Sup_WatSub
rename Q7a_5 Sup_WatDef
rename Q7a_6 Sup_ElecSub
rename Q7a_7 Sup_ElecDef
rename Q7a_8 Sup_RentSub
rename Q7a_9 Sup_Health
rename Q7a_10 Sup_EducFin
rename Q7a_11 Sup_ExFamFin
rename Q7a_12 Sup_BusFin
rename Q7a_13 Sup_LoanDef
rename Q7a_14 Sup_RentDef
rename Q7a_15 Sup_MortDef
rename Q7a_16 Sup_NoFin
*Actions taken in response to the COVID-19 pandemic
rename Q7c_1 Red_Cont
rename Q7c_2 Inc_Wash
rename Q7c_3 Red_Reli
rename Q7c_4 Red_Shop
rename Q7c_5 Red_Rest
rename Q7c_6 Red_Nat
rename Q7c_7 Red_Exer
rename Q7c_8 Red_PubTrns
rename Q7c_9 Red_ComWork
rename Q7c_10 Red_ColFuel
rename Q7c_11 Red_ColWat
rename Q7c_12 MaskUse
rename Q7c_13 TracApp
rename Q7c_21 NoAct
lab var Red_Cont "COVID Action: Reduced Contact"
lab var Inc_Wash "COVID Action: Increased Handwashing"
lab var Red_Reli "COVID Action: Reduced Religious Attendance"
lab var Red_Shop "COVID Action: Reduced Shopping"
lab var Red_Rest "COVID Action: Reduced Restaurant Visits"
lab var Red_Nat "COVID Action: Reduced Time Outdoors"
lab var Red_Exer "COVID Action: Reduced Exercise"
lab var Red_PubTrns "COVID Action: Reduced Public Transportation"
lab var Red_ComWork "COVID Action: Reduced Work Visits"
lab var Red_ColFuel "COVID Action: Reduced Time Collecting Fuel"
lab var Red_ColWat "COVID Action: Reduced Time Collecting Water"
lab var MaskUse "COVID Action: Facemask Use Outside Home"
lab var TracApp "COVID Action: Installed Tracing App"
lab var NoAct "COVID Action: None Taken"
*Goods and services use delta since COVID-19 pandemic began
rename Q8_1 Use_Elec
rename Q8_2 Use_TradFuel
rename Q8_3 Use_ModFuel
rename Q8_4 Use_CommServ
rename Q8_5 Use_PubTrans
rename Q8_6 Use_Wat
rename Q8_7 Use_Food
rename Q8_8 Use_Health
*Quality delta since COVID-19 pandemic began
rename Q11_1 AirInd
rename Q11_2 AirOut
rename Q11_3 DrinkWat
rename Q11_4 PubLit
rename Q11_5 TrafCon
*COVID-19 risk and illness questions
rename Q12 HH_Num
rename Q12a HH_Sch
rename Q12b HH_Min
rename Q12c HH_Eld
rename Q13 COV19Risk
rename Q13C_1 BloodPres
rename Q13C_2 LungDis
rename Q13C_3 HeartDis
rename Q13C_4 KidneyDis
rename Q13C_5 Diab
rename Q13C_6 ImmComp
rename Q13C_9 OthDis
rename Q14_1 ThouCOV19
rename Q14_2 TestCOV19
rename Q14_3 TPosCOV19
rename Q14_4 SickCOV19
rename Q14_5 HospCOV19
rename Q14_6 DiedCOV19
rename Q15 NHHSickCOV19
rename Q16 PersSickCOV19
rename Q17 PersTestCOV19
rename Q18 PersTPosCOV19
rename Q19 EaseTestCOV19
*Agreement with COVID-19 statements
rename Q22_1 COV19StopMut
rename Q22_2 FluEqCOV19
rename Q22_3 FirstChina
rename Q22_4 YoAdImm
rename Q22_5 NoSympInf
rename Q22_6 TwoMetRed
rename Q22_7 MasksNotRed
rename Q22_8 AvdCrwRedInf
rename Q22_9 RedInfOut
rename Q22_10 VacSafe
*Label Q23
label var Q23a_1 "Malaria"
label var Q23b_1 "Malaria"
label var Q23c_1 "Malaria"
label var Q23a_2 "HIV/AIDS"
label var Q23b_2 "HIV/AIDS"
label var Q23c_2 "HIV/AIDS"
label var Q23a_3 "Water borne diseases"
label var Q23b_3 "Water borne diseases"
label var Q23c_3 "Water borne diseases"
label var Q23a_4 "Respritory diseases"
label var Q23b_4 "Respritory diseases"
label var Q23c_4 "Respritory diseases"
label var Q23a_5 "Alcoholism and drug use"
label var Q23b_5 "Alcoholism and drug use"
label var Q23c_5 "Alcoholism and drug use"
label var Q23a_6 "Tuberculosis"
label var Q23b_6 "Tuberculosis"
label var Q23c_6 "Tuberculosis"
label var Q23a_7 "COVID-19"
label var Q23b_7 "COVID-19"
label var Q23c_7 "COVID-19"
*Label Q25
label var Q25_3most_1 "Being able to get non-COVID medical care"
label var Q25_3most_2 "Being able to pay rent or mortgage"
label var Q25_3most_3 "Having enough money for medical care/insurance"
label var Q25_3most_4 "Having enough money for school fees"
label var Q25_3most_5 "Having enough money for fuel"
label var Q25_3most_6 "Having enough clean water"
label var Q25_3most_7 "Children falling behind in their education"
label var Q25_3most_8 "Unable to work because children are not in school"
label var Q25_3most_9 "Being able to travel"
label var Q25_3most_10 "Not having enough food to eat every day"
label var Q25_3least_1 "Being able to get non-COVID medical care"
label var Q25_3least_2 "Being able to pay rent or mortgage"
label var Q25_3least_3 "Having enough money for medical care/insurance"
label var Q25_3least_4 "Having enough money for school fees"
label var Q25_3least_5 "Having enough money for fuel"
label var Q25_3least_6 "Having enough clean water"
label var Q25_3least_7 "Children falling behind in their education"
label var Q25_3least_8 "Unable to work because children are not in school"
label var Q25_3least_9 "Being able to travel"
label var Q25_3least_10 "Not having enough food to eat every day"
*The following gauge preference for government action, regulation, and enforcement
rename Q26 OutbreakPref
rename Q27 MaskPref
rename Q27a COV19Lockdown
rename Q28 LockdownPref
rename Q29 VacTravelPref
*Over next 12 months, what do you think the chances are that you will become infected with COVID-19
rename Q30v1 InfWordsNum
rename Q30v2 InfWords
rename Q30v3 InfNum
rename Q31v1 HosWordsNum
rename Q31v2 HosWords
rename Q31v3 HosNum
*Prediction of when COVID-19 pandemic will end in respondents country and globaly
rename Q32 COV19End
*Respondents vaccine situation
rename Q34 VacStatus
*Assign individuals who recieved one or more booster shots to same indicator value
replace VacStatus = 0 if VacStatus == 7 | VacStatus == 6
label define vacstatus 0 "I am fully vaccinated and have received one or more booster injections" 1 "I am fully vaccinated (two doses for some vaccines and one for others)" 2 "I am partially vaccinated having gotten the first of a two shot vaccine" 3 "I want to get vaccinated as soon as possible" 4 "I want to wait to see other people’s experience before I get vaccinated" 5 "I don’t want to get vaccinated"
label values VacStatus vacstatus
rename Q35 VacType
rename Q36 VacAva1
rename Q36b VacAva2
rename Q36c VacAva3
*Label Q37
label var Q37_3most_1 "Increasing employment"
label var Q37_3most_2 "Addressing climate change"
label var Q37_3most_3 "Getting COVID-19 under control"
label var Q37_3most_4 "Decreasing poverty"
label var Q37_3most_5 "Decreasing political corruption"
label var Q37_3most_6 "Decreasing crime"
label var Q37_3most_7 "Improving access to food supplies"
label var Q37_3most_8 "Improving healthcare services"
label var Q37_3most_9 "Improving public transport"
label var Q37_3most_10 "Improving access to credit"
label var Q37_3most_11 "Improving education"
label var Q37_3most_12 "Improving access to water and sanitation"
label var Q37_3most_13 "Improving access to electricity"
label var Q37_3least_1 "Increasing employment"
label var Q37_3least_2 "Addressing climate change"
label var Q37_3least_3 "Getting COVID-19 under control"
label var Q37_3least_4 "Decreasing poverty"
label var Q37_3least_5 "Decreasing political corruption"
label var Q37_3least_6 "Decreasing crime"
label var Q37_3least_7 "Improving access to food supplies"
label var Q37_3least_8 "Improving healthcare services"
label var Q37_3least_9 "Improving public transport"
label var Q37_3least_10 "Improving access to credit"
label var Q37_3least_11 "Improving education"
label var Q37_3least_12 "Improving access to water and sanitation"
label var Q37_3least_13 "Improving access to electricity"
*What should the respondents country budget prioritize, indicate three highest and three lowest
*Respondents perspective about various issues
rename Q39_1 ClivCOV19
rename Q39_2 CliChngPri
rename Q39_3 EcnRcvPri
*Label Q40-Q42
label var Q40_1 "National Lottery"
label var Q40_2 "Let market set price"
label var Q40_3 "Government officials decide"
label var Q40_4 "Independent panel of scientists"
label var Q40_5 "High risk group"
label var Q40_6 "High transmission groups"
label var Q40_7 "High infection groups"
label var Q41_1 "National Lottery"
label var Q41_2 "Let market set price"
label var Q41_3 "Government officials decide"
label var Q41_4 "Independent panel of scientists"
label var Q41_5 "High risk group"
label var Q41_6 "High transmission groups"
label var Q41_7 "High infection groups"
label var Q42_1 "National Lottery"
label var Q42_2 "Let market set price"
label var Q42_3 "Government officials decide"
label var Q42_4 "Independent panel of scientists"
label var Q42_5 "High risk group"
label var Q42_6 "High transmission groups"
label var Q42_7 "High infection groups"
*Household Questions
rename D1_urban Urban
rename D2 MarStatus
rename D3 DaysWorked
rename D4 EmplStatus
rename D6_CO DaiInc_CO
rename D6_IN DaiInc_IN
rename D6_KE DaiInc_KE
rename D6_NG DaiInc_NG
rename D6_TZ DaiInc_TZ
rename D6_ZA DaiInc_ZA
rename D6_VT DaiInc_VT
rename D7_CO MonInc_CO
rename D7_IN MonInc_IN
rename D7_KE MonInc_KE
rename D7_NG MonInc_NG
rename D7_VT MonInc_VT
rename D7_TZ MonInc_TZ
rename D7_ZA MonInc_ZA
rename D7_change IncChg
rename m_D8_inner_module_rnd Borr100_500_Order
rename D8 Borr100
rename D8b Borr500
rename D9 PreBorr100
rename D10_1 Refri
rename D10_2 Fan
rename D10_3 TV
rename D10_4 Micr
rename D10_5 TradStove
rename D10_6 GasStove
rename D10_7 SolarCook
rename D10_8 PipWat
rename D10_9 ShaPipWat
rename D10_10 PriGrdWat
rename D10_11 InHWatTrt
rename D10_12 SewCon
rename D10_13 PriElecCon
rename D10_14 ShaElecCon
rename D10_15 GenElec
rename D10_16 IntCon
rename D10_17 MobPhone
rename D10_18 CarTruVan
rename D10_19 Mbike
rename D10_20 Bicycle
rename D14 PriWatSou
rename D15 ElecMet
rename D18 PriFuel
rename D18_t PriFuelOth
rename D19 SecStove
rename D20 SecStoveFuel
rename D20_t SecFuelOth
rename D22_1 HHIncExp
rename D22_4 HHDebtExp
rename D22_5 JobLossExp
rename D22_7 OutAirPoll
rename D23 TrblPun
rename D24 LeaDec
rename D25 QuesCust
rename D26 OwnRent
rename D27 MultSingStor
rename D28 HouOwn
rename D29 MonRent
rename D30 HouVal
rename D36 PolIdeal

* Monthly household income in US dollars  (IncomeUSD)

matrix CO_lo = (0, 388000, 775001, 1550001, 2710001, 3880001, 5810001, 7750001, 11600001)
matrix CO_hi = (388000, 775000, 1550000, 2710000, 3880000, 5810000, 7750000, 11600000, .)
matrix IN_lo = (0, 7400, 14901, 29701, 52001, 74301, 111001, 149001, 223001)
matrix IN_hi = (7400, 14900, 29700, 52000, 74300, 111000, 149000, 223000, .)
matrix KE_lo = (0, 10900, 21801, 43701, 76401, 109001, 164001, 218001, 328001)
matrix KE_hi = (10900, 21800, 43700, 76400, 109000, 164000, 218000, 328000, .)
matrix NG_lo = (0, 41100, 82301, 165001, 288001, 411001, 617001, 823001, 1230001)
matrix NG_hi = (41100, 82300, 165000, 288000, 411000, 617000, 823000, 1230000, .)
matrix ZA_lo = (0, 1480, 2951, 5911, 10301, 14801, 22201, 29501, 44301)
matrix ZA_hi = (1480, 2950, 5910, 10300, 14800, 22200, 29500, 44300, .)
matrix VT_lo = (0, 2280000, 4560001, 9120001, 16000001, 22800001, 34200001, 45600001, 68400001)
matrix VT_hi = (2280000, 4560000, 9120000, 16000000, 22800000, 34200000, 45600000, 68400000, .)

gen double IncomeLocal = .
label var IncomeLocal "Monthly household income, bracket midpoint, local currency"

foreach cc in CO IN KE NG ZA VT {
    forvalues b = 1/9 {
        local L  = `cc'_lo[1,`b']
        local H  = `cc'_hi[1,`b']
        local w8 = `cc'_hi[1,8] - `cc'_lo[1,8]
        if `b' < 9  local val = (`L' + `H')/2
        else        local val = `L' + `w8'
        replace IncomeLocal = `val' if MonInc_`cc' == `b'
    }
}

gen double IncomeUSD = .
label var IncomeUSD "Monthly household income, US$, bracket midpoint at wave FX rate"

* Colombia
replace IncomeUSD = IncomeLocal*0.0002533235 if country==1 & wave==1
replace IncomeUSD = IncomeLocal*0.0002201308 if country==1 & wave==2
* India
replace IncomeUSD = IncomeLocal*0.0133972711 if country==2 & wave==1
replace IncomeUSD = IncomeLocal*0.0122315689 if country==2 & wave==2
* Kenya
replace IncomeUSD = IncomeLocal*0.0087996391 if country==3 & wave==1
replace IncomeUSD = IncomeLocal*0.0073641000 if country==3 & wave==2
* Nigeria
replace IncomeUSD = IncomeLocal*0.0024029550 if country==4 & wave==1
replace IncomeUSD = IncomeLocal*0.0021711528 if country==4 & wave==2
* South Africa
replace IncomeUSD = IncomeLocal*0.0662342839 if country==5 & wave==1
replace IncomeUSD = IncomeLocal*0.0544122516 if country==5 & wave==2
* Tanzania (Wave 1 only)
replace IncomeUSD = IncomeLocal*0.0004322252 if country==6 & wave==1
* Vietnam
replace IncomeUSD = IncomeLocal*0.0000440745 if country==7 & wave==1
replace IncomeUSD = IncomeLocal*0.0000428522 if country==7 & wave==2

* Table S1 income rows: both waves pooled, six analysis countries
tabstat IncomeUSD if !inlist(country,6,8), by(country) stats(mean p50 n) format(%9.0f)
tabstat IncomeUSD if !inlist(country,6,8), stats(mean p50 n) format(%9.0f)

*------------------------------------------------------------------------------
* Save
*------------------------------------------------------------------------------

label data "Difficulty of Borrowing study: YouGov Waves 1 and 2, prepared file"
compress
save "Difficulty_Borrowing_Data.dta", replace

* Record what was produced, so the log is self-documenting
count
tabulate country wave

log close


