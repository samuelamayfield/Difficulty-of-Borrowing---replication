*==============================================================================
* Difficulty_Borrowing_Figures.do
*
* Project : The Difficulty of Borrowing Question: An Assessment of Its
*           Usefulness in Six Major Global South Countries
*
* Author  : Samuel Mayfield
* Date    : 2026-09-14

version 17
clear all
set more off
set printcolor asis

*------------------------------------------------------------------------------
* SETUP
*------------------------------------------------------------------------------
global PROJDIR "/Users/samuelmayfield/Desktop/Research/EfD Borrowing"
cd "$PROJDIR"

foreach pkg in catplot coefplot grc1leg2 {
    capture which `pkg'
    if _rc ssc install `pkg', replace
}
capture which grc1leg
if _rc net install grc1leg, from("http://www.stata.com/users/vwiggins")

* ---------------------------------------------------------------------------
* usecolor 1 = colour, 0 = grayscale
* ---------------------------------------------------------------------------
local usecolor 1

if `usecolor' {
    set scheme s1color
    local sfx "color"

    * four-category fills: left empty so s1color's own sequence is used
    local fill4

    local p1 "navy"
    local p2 "cranberry"
    local fill2  bar(1, color(`p1')) bar(2, color(`p2'))
    local fillhh bar(1, color(`p1')) bar(2, color(`p2'))
}
else {
    set scheme s1mono
    local sfx "bw"

    local fill4 bar(1, fcolor(gs2)  lcolor(black) lwidth(vthin))      ///
                bar(2, fcolor(gs7)  lcolor(black) lwidth(vthin))      ///
                bar(3, fcolor(gs11) lcolor(black) lwidth(vthin))      ///
                bar(4, fcolor(gs15) lcolor(black) lwidth(vthin))

    local p1 "gs6"
    local p2 "gs12"
    local fill2  bar(1, fcolor(gs6)  lcolor(black) lwidth(vthin))     ///
                 bar(2, fcolor(gs12) lcolor(black) lwidth(vthin))
    local fillhh bar(1, fcolor(gs6)  lcolor(black) lwidth(vthin))     ///
                 bar(2, fcolor(gs12) lcolor(black) lwidth(vthin))
}

*==============================================================================
* DATA PREPARATION
*==============================================================================

use "Difficulty_Borrowing_Data.dta", clear

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
* FIGURE 1.  Borrowing difficulty US$100, across countries and between waves
*==============================================================================
catplot wave Borr100 if !(wave == 2 & F100 == 1),                    ///
    percent(country wave) asyvars by(country) recast(bar)            ///
    `fill2'                                                          ///
    var2opts(label(labsize(vsmall))                                  ///
             relabel(1 "Very difficult" 2 "Difficult"))              ///
    ytitle(Percent) xsize(11) ysize(7)

gr_edit .title.text = {"Borrowing Difficulty US$100 Across Countries and Between Waves"}
gr_edit .note.text = {}
graph save   "Fig1_TwoWaves_`sfx'.gph", replace
graph export "Fig1_TwoWaves_`sfx'.jpg", replace width(3000) quality(100)
graph export "Fig1_TwoWaves_`sfx'.png", replace width(2400)

*==============================================================================
* FIGURE 2.  Predicted household income by borrowing-difficulty category, Wave 1
*==============================================================================
foreach x of varlist Colombia-Vietnam {
    reg Income i.Borr100 if `x' == 1 & wave == 1
    margins Borr100, post
    estimates store `x'_100

    reg Income i.Borr100 if `x' == 1 & F100 == 0 & consistent == 1 & wave == 2
    margins Borr100, post
    estimates store `x'_w2_100

    reg Income i.Borr500 if `x' == 1 & F100 == 0 & consistent == 1 & wave == 2
    margins Borr500, post
    estimates store `x'_w2_500
}

coefplot Colombia_100,      bylabel(Colombia)       ///
    || India_100,           bylabel(India)          ///
    || Kenya_100,           bylabel(Kenya)          ///
    || Nigeria_100,         bylabel(Nigeria)        ///
    || South_Africa_100,    bylabel("South Africa") ///
    || Vietnam_100,         bylabel(Vietnam)        ///
    ||, vertical                                    ///
        ylabel(2 "$1800" 3 "$3600" 4 "$6600"        ///
               5 "$10200" 6 "$15000" 7 "$21000", angle(0) grid)  ///
        xlabel(1 "Very difficult" 2 "Difficult"     ///
               3 "Not too difficult" 4 "Easy", angle(45))
gr_edit .title.text = {"Predicted Household Income by Difficulty of Borrowing"}
gr_edit .note.text  = {"Note: Mean income at each borrowing-difficulty level with 95% confidence intervals (Wave 1)."}
graph save   "Fig2_PredictedIncome_`sfx'.gph", replace
graph export "Fig2_PredictedIncome_`sfx'.jpg", replace width(3000) quality(100)
graph export "Fig2_PredictedIncome_`sfx'.png", replace width(2400)

*==============================================================================
* FIGURE 3.  Demographic differences in difficulty of borrowing US$100
*==============================================================================
local panelvars  Female    Married  Own             Employed          BigCity    MidAge
local paneltitle `" "Gender" "Married" "Homeownership" "Formal Employed" "Big City" "Middle Aged" "'

foreach x of varlist Colombia-Vietnam {

    local c_name = subinstr("`x'", "_", " ", .)
    local k = 1

    foreach d of local panelvars {

        local ttl : word `k' of `paneltitle'
        local lsz = cond("`d'" == "Employed", "vsmall", "small")

        tab Borr100 `d' if !(wave == 2 & F100 == 1) & `x' == 1, chi2
        local chi3 : display %9.2f r(chi2)

        catplot Borr100 `d' if !(wave == 2 & F100 == 1) & `x' == 1,   ///
            asyvars percent(`d') stack recast(bar) `fill4'            ///
            ylabel(0(20)100, angle(horizontal) labsize(vsmall))       ///
            var2opts(label(labsize(`lsz')))                           ///
            title(" ", size(small))                                   ///
            ytitle("Percent of {bf:`ttl'}", size(vsmall))             ///
            note("chi2 = `chi3'", size(small))                        ///
            legend(rows(2) size(small)                                ///
                   label(1 "Very difficult or impossible")            ///
                   label(2 "Difficult")                               ///
                   label(3 "Not too difficult")                       ///
                   label(4 "Easy"))
        graph save "`x'_`d'_`sfx'.gph", replace
        local ++k
    }

    graph combine "`x'_Female_`sfx'.gph"   "`x'_Married_`sfx'.gph"    ///
                  "`x'_Own_`sfx'.gph"      "`x'_Employed_`sfx'.gph"   ///
                  "`x'_BigCity_`sfx'.gph"  "`x'_MidAge_`sfx'.gph",    ///
        rows(2) cols(3) imargin(small)                                ///
        title("`c_name' Demographics", size(medsmall))                ///
        graphregion(color(white)) name(blk_`x', replace)
    graph save "blk_`x'_`sfx'.gph", replace
}

grc1leg2 "blk_Colombia_`sfx'.gph"     "blk_India_`sfx'.gph"           ///
         "blk_Kenya_`sfx'.gph"        "blk_Nigeria_`sfx'.gph"         ///
         "blk_South_Africa_`sfx'.gph" "blk_Vietnam_`sfx'.gph",        ///
    labsize(small) rows(3) cols(2) imargin(medsmall)                  ///
    title("Demographic Differences in Difficulty of Borrowing US$100", size(small)) ///
    graphregion(color(white))

* force the portrait shape used in the manuscript
graph display, ysize(23) xsize(16)
graph save   "Fig3_Demographics_`sfx'.gph", replace
graph export "Fig3_Demographics_`sfx'.jpg", replace width(3000) quality(100)
graph export "Fig3_Demographics_`sfx'.png", replace width(2400)

*==============================================================================
* FIGURE 4.  Household durable ownership by borrowing difficulty
*==============================================================================

label define yn_rev 0 "Yes" 1 "No", replace

foreach v in TV Fan Micr Car AirCon Solar {
    capture drop `v'_rev
    gen byte `v'_rev = 1 - `v'
    label values `v'_rev yn_rev
    label var `v'_rev "`: var label `v''"
}

foreach x of varlist TV_rev Fan_rev Micr_rev Car_rev AirCon_rev Solar_rev {

    local orig = subinstr("`x'", "_rev", "", .)

    tab `orig' Borr100 if !(wave == 2 & F100 == 1), col chi2
    local chi2 : display %9.3f r(chi2)

    catplot `x' Borr100 if !(wave == 2 & F100 == 1),                  ///
        stack recast(bar) percent(Borr100) asyvars `fillhh'           ///
        ylabel(, angle(horizontal)) ytitle("Percent")                 ///
        var1opts(label(labsize(small)))                               ///
        var2opts(label(labsize(vsmall) angle(45))                     ///
                 relabel(1 "Very difficult" 2 "Difficult"             ///
                         3 "Not too difficult" 4 "Easy"))             ///
        title("`: var label `orig''") note("chi2 = `chi2'")
    graph save "`orig'_hh_`sfx'.gph", replace
}

grc1leg "TV_hh_`sfx'.gph"     "Fan_hh_`sfx'.gph"    "Micr_hh_`sfx'.gph"  ///
        "Car_hh_`sfx'.gph"    "AirCon_hh_`sfx'.gph" "Solar_hh_`sfx'.gph", ///
    cols(3) title(Household Holdings) ycommon                            ///
    note("Note: Air conditioning and solar panels are restricted to Wave 2 respondents.", size(small))
graph save   "Fig4_HouseholdHoldings_`sfx'.gph", replace
graph export "Fig4_HouseholdHoldings_`sfx'.jpg", replace width(3000) quality(100)
graph export "Fig4_HouseholdHoldings_`sfx'.png", replace width(2400)

*==============================================================================
* FIGURE 5.  US$100 / US$500 question-order effect by country
*==============================================================================
graph bar (mean) Borr100 Borr500 if wave == 2 & consistent == 1,      ///
    over(F100, label(angle(45) labsize(small)))                       ///
    over(country_plot, label(labsize(small)) gap(40))                 ///
    bar(1, color(`p1'))                                               ///
    bar(2, color(`p2'))                                               ///
    ytitle("Mean Response Value (1 to 4)", size(small))               ///
    ylabel(0(0.5)3, grid glpattern(dash) glcolor(gs13) angle(0) labsize(small)) ///
    title("Comparison of US$100 and US$500 Difficulty of Borrowing"   ///
          "by Country and Sequence Order", size(medium) span)         ///
    legend(order(1 "Mean $100 Borrowing Difficulty"                   ///
                 2 "Mean $500 Borrowing Difficulty")                  ///
           position(6) rows(1) size(small))                           ///
    note("*Borrowing Difficulty Category Endpoints: 1=Very Difficult, 4=Easy", size(vsmall)) ///
    graphregion(color(white)) plotregion(color(white))                ///
    xsize(13) ysize(7)
graph save   "Fig5_OrderEffect_`sfx'.gph", replace
graph export "Fig5_OrderEffect_`sfx'.jpg", replace width(3000) quality(100)
graph export "Fig5_OrderEffect_`sfx'.png", replace width(2400)

*==============================================================================
* FIGURE S1.  Predicted household income, Wave 2, US$100 and US$500
*==============================================================================
coefplot Colombia_w2_100,      bylabel(Colombia)       ///
    || India_w2_100,           bylabel(India)          ///
    || Kenya_w2_100,           bylabel(Kenya)          ///
    || Nigeria_w2_100,         bylabel(Nigeria)        ///
    || South_Africa_w2_100,    bylabel("South Africa") ///
    || Vietnam_w2_100,         bylabel(Vietnam)        ///
    ||, vertical                                       ///
        ylabel(2 "$1800" 3 "$3600" 4 "$6600"           ///
               5 "$10200" 6 "$15000" 7 "$21000", angle(0) grid) ///
        xlabel(1 "Very difficult" 2 "Difficult"        ///
               3 "Not too difficult" 4 "Easy", angle(45))
gr_edit .title.text = {"Borrowing Difficulty US$100"}
graph save "FigS1_panel100_`sfx'.gph", replace

coefplot Colombia_w2_500,      bylabel(Colombia)       ///
    || India_w2_500,           bylabel(India)          ///
    || Kenya_w2_500,           bylabel(Kenya)          ///
    || Nigeria_w2_500,         bylabel(Nigeria)        ///
    || South_Africa_w2_500,    bylabel("South Africa") ///
    || Vietnam_w2_500,         bylabel(Vietnam)        ///
    ||, vertical                                       ///
        ylabel(2 "$1800" 3 "$3600" 4 "$6600"           ///
               5 "$10200" 6 "$15000" 7 "$21000", angle(0) grid) ///
        xlabel(1 "Very difficult" 2 "Difficult"        ///
               3 "Not too difficult" 4 "Easy", angle(45))
gr_edit .title.text = {"Borrowing Difficulty US$500"}
graph save "FigS1_panel500_`sfx'.gph", replace

graph combine "FigS1_panel100_`sfx'.gph" "FigS1_panel500_`sfx'.gph",  ///
    title("Wave 2 Predicted Household Income")                        ///
    note("Note: Mean income at each borrowing-difficulty level with 95% confidence intervals. Wave 2 subsample asking the US$100 question before the US$500 question.") ///
    xsize(9)
graph save   "FigS1_PredictedIncome_W2_`sfx'.gph", replace
graph export "FigS1_PredictedIncome_W2_`sfx'.jpg", replace width(3000) quality(100)
graph export "FigS1_PredictedIncome_W2_`sfx'.png", replace width(2400)
