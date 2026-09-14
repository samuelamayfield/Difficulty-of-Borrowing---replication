*==============================================================================
* Difficulty_Borrowing_Analysis.do
*
* Project : The Difficulty of Borrowing Question: An Assessment of Its
*           Usefulness in Six Major Global South Countries
*
* Author  : Samuel Mayfield
* Date    : 2026-09-14

version 17
clear all
set more off

*------------------------------------------------------------------------------
* SETUP
*------------------------------------------------------------------------------
global PROJDIR "/Users/samuelmayfield/Desktop/Research/EfD Borrowing"
cd "$PROJDIR"

foreach pkg in estout asdoc {
    capture which `pkg'
    if _rc ssc install `pkg', replace
}

capture log close
log using "Difficulty_Borrowing_Analysis.log", replace text

*==============================================================================
* DATA PREPARATION
*==============================================================================

use "EfD_W1-W2.dta", clear

* Tanzania (Wave 1 only) and Chile (Wave 2 only) are not part of the analysis.
drop if country == 6 | country == 8
drop Tanzania Chile

* Question-order indicator. F100 == 0 means the US$100 question came first.
* The filter !(wave == 2 & F100 == 1) therefore keeps all of Wave 1 plus the Wave 2 respondents who saw US$100 first
gen F100 = .
replace F100 = 0 if Borr100_500_Order == "1,2"
replace F100 = 1 if Borr100_500_Order == "2,1"
label define ordr_lbl 0 "$100 First" 1 "$500 First", modify
label values F100 ordr_lbl

gen byte consistent = (Borr100 >= Borr500) if wave == 2
label var consistent "Borrow difficulty logically consistent (D8 >= D8b)"

* Monthly income bracket, 1-9.
* Don't know (96) and refused (97) are assigned bracket 3.
gen Income = .
replace Income = MonInc if MonInc != 96 & MonInc != 97
replace Income = 3 if MonInc == 96 | MonInc == 97
label define inc 1 "50" 2 "$150" 3 "$300" 4 "$550" 5 "$850" ///
                 6 "$1250" 7 "$1750" 8 "$2500" 9 "$3000"
label values Income inc

gen lIncome = ln(Income)

* Demographic binaries
label define ynlab 0 "No" 1 "Yes"

gen byte Own = (OwnRent == 1)
label var Own "Household owns dwelling"
label values Own ynlab

gen byte Employed = inlist(EmplStatus, 1, 2)
label var Employed "Formal Employed"
label define empl 1 "Firm+Gov" 0 "Other"
label values Employed empl

gen byte Married = inlist(MarStatus, 2)
label var Married "Married"
label values Married ynlab

gen byte Female = (gender == 2)
label var Female "Female"
label define fml 1 "Female" 0 "Male"
label values Female fml

gen byte BigCity = (Urban == 1)
label var BigCity "Big City"
label values BigCity ynlab

gen byte MidAge = inlist(age_5cat, 3, 4)
label var MidAge "Age 35-55"
label values MidAge ynlab

* Household durables.
* AirCon and Solar come from D10_21 / D10_25, asked in Wave 2 only, so those two are Wave-2 estimates while TV, Fan, Micr and Car pool both waves.
gen byte AirCon = (D10_21 == 1) if wave == 2
gen byte Solar  = (D10_25 == 1) if wave == 2
gen byte Car    = (CarTruVan == 1 | D10_27 == 1 | D10_28 == 1)

recode TV   (2 = 0)
recode Fan  (2 = 0)
recode Micr (2 = 0)

label define yn 0 "No" 1 "Yes"
foreach v in AirCon Solar Car TV Fan Micr {
    label values `v' yn
}
label var AirCon "Air Conditioning"
label var Solar  "Solar Panels"
label var Car    "Car"
label var TV     "TV"
label var Fan    "Fan"
label var Micr   "Microwave"

* Country ordering used in the order-effect output
gen country_plot = .
replace country_plot = 1 if Colombia     == 1
replace country_plot = 2 if India        == 1
replace country_plot = 3 if Kenya        == 1
replace country_plot = 4 if Nigeria      == 1
replace country_plot = 5 if Vietnam      == 1
replace country_plot = 6 if South_Africa == 1
label define c_lbl 1 "Colombia" 2 "India" 3 "Kenya" ///
                   4 "Nigeria" 5 "Vietnam" 6 "South Africa"
label values country_plot c_lbl


*==============================================================================
* TABLE S1.  Sample demographic statistics
*==============================================================================

tabstat Income if !inlist(MonInc, 96, 97), by(wave) stats(median)

capture confirm variable IncomeUSD
if _rc {
    display as error "IncomeUSD not found. Re-run EfD_W1-W2_Prep.do, which builds it."
    exit 111
}

gen byte S1_female    = (gender == 2)      if inlist(gender, 1, 2)
gen byte S1_college   = (EducLevel >= 4)   if !missing(EducLevel)
gen byte S1_homeowner = (OwnRent == 1)     if inrange(OwnRent, 1, 3)
gen byte S1_retired   = (EmplStatus == 5)  if inrange(EmplStatus, 1, 7)
forvalues u = 1/5 {
    gen byte S1_urban`u' = (Urban == `u')  if inrange(Urban, 1, 5)
}
label var S1_female    "Female"
label var S1_college   "College"
label var S1_homeowner "Homeowner"
label var S1_retired   "Retired"
label var S1_urban1    "Live in big city"
label var S1_urban2    "Live in small city"
label var S1_urban3    "Live in suburb"
label var S1_urban4    "Live in small town"
label var S1_urban5    "Live in rural area"
label var IncomeUSD    "Household income (US$/month)"

local s1prop S1_female S1_college S1_homeowner S1_retired ///
             S1_urban1 S1_urban2 S1_urban3 S1_urban4 S1_urban5

display _n "=== Table S1: age and income, by country (both waves) ==="
tabstat age IncomeUSD, by(country) stats(mean p50 n) format(%9.0f) columns(statistics)
display _n "=== Table S1: age and income, all six countries ==="
tabstat age IncomeUSD,             stats(mean p50 n) format(%9.0f) columns(statistics)

display _n "=== Table S1: proportions, by country (both waves) ==="
tabstat `s1prop', by(country) stats(mean) format(%9.2f) columns(variables)
display _n "=== Table S1: proportions, all six countries ==="
tabstat `s1prop',             stats(mean) format(%9.2f) columns(variables)

display _n "=== Table S1: income non-response, by country ==="
gen byte S1_incmiss = inlist(MonInc, 96, 97)
label var S1_incmiss "Income not reported"
tabstat S1_incmiss, by(country) stats(mean n) format(%9.3f)

drop S1_female S1_college S1_homeowner S1_retired S1_urban1-S1_urban5 S1_incmiss


*==============================================================================
* TABLE S2 SUPPORT
*==============================================================================

display _n "=== Table S2: age distribution by country (both waves) ==="
tabulate country age_5cat, row nofreq
display _n "=== Table S2: gender distribution by country (both waves) ==="
tabulate country gender, row nofreq


*==============================================================================
* DETERMINANTS OF BORROWING DIFFICULTY  (Table S4)
*==============================================================================

eststo clear

asdoc regress Borr100 i.country i.gender if wave == 1, ///
    nest save(Determinants.doc) replace dec(3) label
eststo mA

asdoc regress Borr100 i.country i.country#i.gender if wave == 1, nest append dec(3)
eststo mB

asdoc regress Borr100 i.country i.Urban if wave == 1, nest append dec(3)
eststo mC

asdoc regress Borr100 i.country i.country#i.Urban if wave == 1, nest append dec(3)
eststo mD

esttab mA mB mC mD using "Determinants.rtf", replace ///
    cells("b(fmt(3)) t(fmt(2))")                     ///
    collabels("Coef." "t-stat", pattern(1 1))        ///
    label                                            ///
    stats(N r2, fmt(%9.0g %9.3f) labels("Obs." "R2")) ///
    title("Determinants of borrowing difficulty (Borr100)")


*==============================================================================
* LIFE SATISFACTION  (Table S8)
*==============================================================================

ologit LifeSat Borr100 if !(wave == 2 & F100 == 1), or vce(robust)

ologit LifeSat Borr100 i.country if !(wave == 2 & F100 == 1), vce(cluster country)

ologit LifeSat Borr100 Income i.country if !(wave == 2 & F100 == 1), vce(cluster country)


*==============================================================================
* ASSET PREDICTORS  (Tables S5, S6, S7)
*==============================================================================

asdoc reg Income  AirCon if !(wave == 2 & F100 == 1), ///
    nest save(AssetPredictors.doc) replace dec(3) label
asdoc reg Borr100 AirCon if !(wave == 2 & F100 == 1), nest append dec(3)
asdoc reg Borr500 AirCon if !(wave == 2 & F100 == 1), nest append dec(3)

foreach x of varlist Solar Car TV Fan Micr {
    asdoc reg Income  `x' if !(wave == 2 & F100 == 1), ///
        nest save(AssetPredictors.doc) reset dec(3) label
    asdoc reg Borr100 `x' if !(wave == 2 & F100 == 1), nest dec(3)
    asdoc reg Borr500 `x' if !(wave == 2 & F100 == 1), nest dec(3)
}

* ---- consolidated table -----------------------------
eststo clear
foreach dv in Income Borr100 Borr500 {
    local all_assets
    foreach a in AirCon Solar Car TV Fan Micr {
        local all_assets `all_assets' `a'
        quietly reg `dv' `a' if !(wave == 2 & F100 == 1)
        eststo `dv'_`a'
    }
    quietly reg `dv' `all_assets' if !(wave == 2 & F100 == 1)
    eststo `dv'_all
}

esttab Income_* Borr100_* Borr500_* using "AssetPredictors.rtf", replace ///
    cells(b(star fmt(3)) se(par fmt(3)))                                 ///
    keep(AirCon Solar Car TV Fan Micr)                                   ///
    starlevels(* 0.10 ** 0.05 *** 0.01)                                  ///
    stats(N r2, labels("Observations" "R-squared"))                      ///
    noobs nonumbers label                                                ///
    mtitles("Income" "Borr100" "Borr500")                                ///
    title("Asset predictors of financial outcomes")

* ---- (Tables S5, S6, S7) ----------------------------
eststo clear
local assets AirCon Solar Car TV Fan Micr

foreach a in `assets' {
    quietly reg Income  `a' if !(wave == 2 & F100 == 1)
    eststo Inc_`a'
    quietly reg Borr100 `a' if !(wave == 2 & F100 == 1)
    eststo B100_`a'
    quietly reg Borr500 `a' if !(wave == 2 & F100 == 1)
    eststo B500_`a'
}

esttab Inc_* using "Table_Income.rtf", replace          ///
    cells(b(star fmt(3)) se(par fmt(3))) keep(`assets') ///
    title("Table S5. Asset predictors of income")       ///
    stats(N r2, labels("Observations" "R-squared"))     ///
    starlevels(* 0.10 ** 0.05 *** 0.01) label noobs nonumbers

esttab B100_* using "Table_Borr100.rtf", replace        ///
    cells(b(star fmt(3)) se(par fmt(3))) keep(`assets') ///
    title("Table S6. Asset predictors of difficulty of borrowing US$100") ///
    stats(N r2, labels("Observations" "R-squared"))     ///
    starlevels(* 0.10 ** 0.05 *** 0.01) label noobs nonumbers

esttab B500_* using "Table_Borr500.rtf", replace        ///
    cells(b(star fmt(3)) se(par fmt(3))) keep(`assets') ///
    title("Table S7. Asset predictors of difficulty of borrowing US$500") ///
    stats(N r2, labels("Observations" "R-squared"))     ///
    starlevels(* 0.10 ** 0.05 *** 0.01) label noobs nonumbers


*==============================================================================
* US$100 AGAINST US$500  (Tables S9 to S13)
*==============================================================================

asdoc tab Borr100 Borr500, col chi2 save(BorrowingOrder.doc) replace dec(3) label

asdoc reg Borr100  Borr500,                        append dec(3)
asdoc reg Borr100  Borr500 F100,                   append dec(3)
asdoc reg LifeSat  Borr100 Borr500 if F100 == 0,   append dec(3)
asdoc reg LifeSat  Borr100 Borr500 if F100 == 1,   append dec(3)
asdoc reg EndsMeet Borr100 Borr500 if F100 == 0,   append dec(3)
asdoc reg EndsMeet Borr100 Borr500 if F100 == 1,   append dec(3)
asdoc reg LifeSat  EndsMeet        if wave == 2,   append dec(3)
asdoc reg LifeSat  EndsMeet Borr100 Borr500 if wave == 2, append dec(3)
asdoc reg LifeSat  i.F100#c.EndsMeet i.F100#c.Borr100 i.F100#c.Borr500, append dec(3)


*==============================================================================
* SIGNIFICANCE TESTS
*==============================================================================

display _n "=== wave-over-wave difference, by country (p < .05 in all six) ==="
levelsof country, local(cntry)
foreach c of local cntry {
    display _n "---- country `c' ----"
    tabulate Borr100 wave if country == `c' & !(wave == 2 & F100 == 1), chi2 column
}

display _n "=== question-order effect, US$100 ==="
tabulate Borr100 F100 if consistent == 1, col chi2

display _n "=== question-order effect, US$500 ==="
tabulate Borr500 F100 if consistent == 1, col chi2

display _n "=== first-stage F, income on borrowing difficulty, by country ==="
foreach x of varlist Colombia-Vietnam {
    display _n "---- `x' ----"
    reg Income i.Borr100 if `x' == 1 & wave == 1
}

log close
