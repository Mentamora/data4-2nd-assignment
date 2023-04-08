import delimited "C:\Users\Mora_Menta\Downloads\P_Data_Extract_From_World_Development_Indicators (3)\4927655d-5d87-4c9f-925d-3ef06028a388_Data.csv", varnames(1) stringcols(3 4) numericcols(1 5 6 7)
describe
browse
#renaming variables
rename populationtotalsppoptotl population

rename gdppercapitapppconstant2017inter gdppercap

rename co2emissionsktenatmco2ekt co2emissions

drop timecode

#dropping missing observations
drop if missing(gdppercap)

drop if missing(co2emissions)

drop if missing(population)

sort countryname time

#generating logs of CO2 emission and GDP

gen co2percap = co2emissions/population
lab var co2percap "CO2 emission per capita (kt)"

gen lngdppercap = ln(gdppercap)
lab var lngdppercap "Ln GDP per capita"

gen lnco2percap = ln(co2percap)
lab var lnco2percap "Ln CO2 emission per capita (kt)"

egen panelid = group(countryname)
xtset panelid time

#running regressions

#cross-section ols for 2005
reg lnco2percap lngdppercap if time == 2005, robust

#cross-section ols for 2015
reg lnco2percap lngdppercap if time == 2015, robust

#diff-in-diff models
gen difflnco2 = d.lnco2percap
gen difflngdp = d.lngdppercap

#diff-in-diff, no lags
reg difflnco2 difflngdp, cluster(countryname)

#diff-in-diff, 2-year lags
reg difflnco2 L(0/2).difflngdp, cluster(countryname)

#diff-in-diff, 6-year lags
reg difflnco2 L(0/6).difflngdp, cluster(countryname)

#FE model with time and country fixed effects
xtreg lnco2percap lngdppercap i.time, fe cluster(countryname)


save "C:\Users\Mora_Menta\Downloads\P_Data_Extract_From_World_Development_Indicators (3)\data4.dta", replace

