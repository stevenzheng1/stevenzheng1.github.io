


/* IMPORTANT:
	Step 1) Use the Bloomberg excel sheet to get the most recent forecasts
	Step 2) Need to change link below to most recent Excel sheet --> most recent Monday will be the date
	Step 3) Double check the current dot plot numbers by
			Go to https://www.federalreserve.gov/monetarypolicy/fomccalendars.htm
			Click on "PDF Projection Materials" for most recent FOMC meeting
			The median for the federal funds rate can be found on Page 2 (need to round to 0.125, 0.375, 0.625, 0.875 because midpoint) 
*/


*INSERT DATE
local last_monday "06192023"


import excel "../Bloomberg inputs/Bloomberg_`last_monday'.xlsx", clear cellrange(A8:C25)
drop B
drop if C == "Final Value"
destring C, replace

//ssc install jsonio
jsonio out, what(data) filenm(test.json)


sysuse auto, clear
jsonio out in 73/74, what(record)





*Generate the data such that we can use it for the dot plot
generate x_axis = year(date("`c(current_date)'","DMY",2000)) - 1.5 if _n == 1
replace x_axis = x_axis[_n-1] + 0.5 if _n >= 2 & _n < 12

*Current level of federal funds rate
generate current_level = C[12] if _n == 2

*Dot plot
generate 	dot_plot = C[5] if _n == 4
replace 	dot_plot = C[6] if _n == 6
replace 	dot_plot = C[7] if _n == 8
replace 	dot_plot = C[8] if _n == 10

*Market forecast
generate 	market = C[13] if _n == 4
replace 	market = C[14] if _n == 6
replace 	market = C[15] if _n == 8

keep x_axis current_level dot_plot market
drop if missing(x_axis)


**********************
* Initial Dot plot
**********************

grstyle init
grstyle set plain
//grstyle set color Set1
//grstyle set symbol
//grstyle set lpattern

*Labels for the legend
label var dot_plot 		"Fed forecast"
label var market		"Market forecast"
label var current_level "Current Fed funds rate"

twoway scatter dot_plot market current_level x_axis, color(blue red black) msymbol(Oh Oh Oh) ///
	ytitle("") xtitle("") ///
	ylabels(0(0.5)6, angle(0))  ///
	yline(0 1 2 3 4 5 6, lcolor(black) lwidth(vthin)) ///
	yline(0.25 0.5 0.75 1.25 1.5 1.75 2.25 2.5 2.75 3.25 3.5 3.75 4.25 4.5 4.75 5.25 5.5 5.75, lcolor(black) lwidth(vthin) lpattern(dot)) ///
	xlabels(2022 "Fed funds rate" 2023(1)2025 2026 "Longer run", labsize(medium) notick)  ///
	xline(2025.5, lcolor(black) lpattern(dash)) ///
	xline(2022.5, lcolor(black) lpattern(dash)) ///
	yscale(lcolor(white) lstyle(none)) ///
	xscale(lstyle(none)) ///
	legend(row(1) position(12) order(3 1 2)) ///
	 graphregion(margin(0 2 0 0)) plotregion(margin(0 0 0 0)) xsize(1.8) ysize(1)
graph export "`last_monday'/dotplot_start.png", replace



	
**********************
* Create scenarios for updated Dot plot
**********************
	//No market forecast 

local long_list 	"00 25 50 75"
local med_list 		"00 25 50"
local short_list 	"00 25"


*Loop through all different combinations
foreach current of local long_list {
	
	foreach year1 of local med_list {
		
		foreach year2 of local med_list {
			
			foreach lr of local short_list {
				preserve 
						//local current "00" 
						//local year1 "00"
						//local year2 "50"
						//local lr "50"
				
				
						*Generate the new level of the fed funds rate
							generate new_current_level = current_level + real("`current'")/100

						*Generate the new dot plot forecasts
							generate new_dot_plot =  dot_plot
							
							*Adjust the 1-year forecast
							replace new_dot_plot = new_dot_plot + real("`year1'")/100 if _n == 4
							
							*Adjust the 2-year and 3-year forecast forecast
							replace new_dot_plot = new_dot_plot + real("`year2'")/100 if _n == 6 | _n == 8
							
							*Adjust the long-run forecast
							replace new_dot_plot = new_dot_plot + real("`lr'")/100 if _n == 10					
			
							label var new_dot_plot 		"Fed forecast (new)"
							label var dot_plot			"Fed forecast (old)"	
							label var new_current_level "Fed funds rate (new)"
							label var current_level 	"Fed funds rate (old)"	
								
							twoway scatter  new_dot_plot dot_plot new_current_level current_level   x_axis, color(blue blue black black) msymbol(Oh + Oh +)  ///
								ytitle("") xtitle("") ///
								ylabels(0(0.5)7, angle(0))  ///
								yline(0 1 2 3 4 5 6 7, lcolor(black) lwidth(vthin)) ///
								yline(0.25 0.5 0.75 1.25 1.5 1.75 2.25 2.5 2.75 3.25 3.5 3.75 4.25 4.5 4.75 5.25 5.5 5.75 6.25 6.5 6.75, lcolor(black) lwidth(vthin) lpattern(dot)) ///
								xlabels(2022 "Fed funds rate" 2023(1)2025 2026 "Longer run", labsize(medium) notick)  ///
								xline(2025.5, lcolor(black) lpattern(dash)) ///
								xline(2022.5, lcolor(black) lpattern(dash)) ///
								yscale(lcolor(white) lstyle(none)) ///
								xscale(lstyle(none)) ///
								legend(row(3) position(12) order(3 1 4 2)) ///
								graphregion(margin(0 2 0 0)) plotregion(margin(0 0 0 0)) xsize(1.8) ysize(1)	
								graph export "`last_monday'/dotplot_`current'_`year1'_`year2'_`lr'.png", replace									
				restore		
			}			
		}		
	}	
}	

	

	
	
	

