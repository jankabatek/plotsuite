*! version 1.1 19Sep2022 
capture program drop plottwoway 
program define plottwoway, rclass
version 16 
syntax, FRame(string) [COMmand NODIAG YZero NODraw] 
	qui {
		** default colour palette
		local graph_syntax = ""
		local gr_counter = 0 
		
		** (1) STOCKTAKING *****************************************************
		** how many plots are stored eventually?
		local I = 0
		cap
		while _rc ==0 { 
			local I = `I' + 1 
			frame `frame': cap confirm var x_val`I'	
		}
		local I = `I'- 1
		
		 
		** (2) CUSTOMIZATION *******************************************
		** global two-way options:
		frame `frame'_cust: local tw_op  = cust_two[1]
		frame `frame'_cust: local oth_op = cust_oth[1]
	 
		** include zero on the y-axis (pt1) 
		if "`yzero'" != "" local maxval = 0
		 
		** produce the two-way graph from data stored in `frame', using the customization options stored in `frame'_cust
		forvalues j = 1/`I'{	
			local gr_counter = `gr_counter' + 1
			
			** options applicable to all plot types:
			frame `frame'_cust: local output = cust_out[`j']
			frame `frame'_cust: local graph  = cust_gra[`j']
			frame `frame'_cust: local gs_op  = cust_opt[`j']
  			
			** are we using a secondary axis?
			local 0 plotaux , `gs_op'
			_parse expand cmd yax : 0 , common(YAXis()) 
			if  "`yax_op'" == "yaxis(2)" local ytitle2 ytitle(`output',axis(2))
			else local ytitle1 ytitle(`output') 

			** include zero on the y-axis (pt2)
			if "`yzero'" != "" &  "`yax_op'" != "yaxis(2)"{
				frame `frame': qui sum y_val`j'
				if `maxval' < r(max) local maxval = r(max)
			}	
					
			** append graph syntax to the twoway command	
			local graph_syntax `graph_syntax' (`graph' y_val`j' x_val`j', pstyle(p`j') `gs_op')
			
			** CI options applicable to plotmeans & plotbetas:
			frame `frame'_cust: cap local rgraph= cust_rgr[`j']
			frame `frame'_cust: cap local ci_leg= cust_lci[`j'] 
			frame `frame'_cust: cap local ci_op = cust_oci[`j'] 
			
			** CI plotted if rgraph `j' is defined in `frame'_cust
			if "`rgraph'" !="" {
			
				** CI transparency & colors
				local 0 x), `ci_op'
				_parse expand cmd citr : 0 , common(CoLor()) 
				** is color(+transparency) defined? 
				tokenize `citr_op', parse("()")
				local ci_col `3'
				** if no, is color for the main chart defined?
				local 999 plotaux , `gs_op'
				if `"`gs_op'"' != "" _parse expand x col : 999 , common(CoLor())  
				if `"`ci_col'"' =="" & `"`col_op'"' != "" {
					tokenize `col_op', parse("(%)")	
					tokenize `3', parse("%")
					local ci_col `1' 
				}				

				** is transparency for rarea graphs defined?
				if "`rgraph'" == "rarea" {
					tokenize `citr_op', parse("%)")
					if "`3'"=="" local ci_col `ci_col'%15
					tokenize `col_op', parse(`"""')
					if "`2'" != "" local ci_col ""`ci_col'""
				} 
				
				** extract all other ci options and save it as `cioth_op'
				local 0 (`cmd_1'
				_parse expand cmd cioth : 0
				
				** CI line width for rarea graphs (default = none)
				if "`rgraph'" == "rarea" {
					local 0 plotaux , `ci_op' 
					if `"`ci_op'"' != "" _parse expand cmd lw : 0 , common(LWidth())
					if `"`lw_op'"' == "" local cioth_op `cioth_op' lwidth(none)								
				}
		
				** copy axis options to the CI
				local 0 plotaux , `gs_op' 
				if `"`gs_op'"' != "" _parse expand cmd ax : 0 , common(XAXis() YAXis())
			
				local gr_counter = `gr_counter' + 1
				
				** updated options for ci area graphs
				local r_op pstyle(p`j') `cioth_op'
				if `"`ci_col'"' != "" local r_op color(`ci_col') `r_op'
				
				** legends for ci area graphs
				if `"`ci_leg'"' != "" local r_op `r_op' legend(label(`gr_counter' "`ci_leg'"))
				
				** rgraph syntax
				local graph_syntax `graph_syntax' (`rgraph' LCI_val`j' UCI_val`j' x_val`j' , `r_op' `ax_op') 
				
			}
		}  
		
		** include zero on the y-axis (pt3) (add to the global two-way options)
		if "`yzero'" != "" {
			local exp = floor(log10(`maxval'/4))
			local ystep	= floor((`maxval'/4)/(10^`exp'))*(10^`exp')
			local ymax = `ystep'*5			
			local tw_op `tw_op' ysc(r(0 `ymax'))
			local 0  plotaux , `tw_op'
			if `"`tw_op'"' != "" _parse expand cmd yl : 0 , common(YLabel())
			if `"`yl_op'"' == "" local tw_op `tw_op' ylabel(0(`ystep')`ymax')  
		}	
		  
		** information for troubleshooting
		if "`nodiag'"=="" n di as text  						"  - output type:            "  "`output'" 	
		if "`nodiag'"=="" n di as text  						"  - graph type:             "  "`graph'"  	
		if "`nodiag'"=="" & `"`tw_op'"' != "" n di as text   	"  - twoway options:         " `"`tw_op'"'	
	    if "`nodiag'"=="" & `"`gs_op'"' != "" n di as text  	"  - graph-specific options: " `"`gs_op'"'	
				
		** default title of the y-axis (`output' type corresponding to the last plot)
		local 0  plotaux , `tw_op' 
		if `"`tw_op'"' != "" _parse expand cmd yt : 0 , common(YTitle(string)) 
		if `"`yt_op'"' == "" local tw_op `tw_op' `ytitle1' `ytitle2'
		
		** default title of the x-axis (label of x_val in the last plot) 
		if `"`tw_op'"' != "" _parse expand cmd xt : 0 , common(XTitle(string)) 
		if `"`xt_op'"' == "" {
			cap frame `frame':  local xlbl : variable label x_val`I'
			local tw_op `tw_op' xtitle("`xlbl'")
		}
		
		** white background for s2color scheme unless specified otherwise
		local 0 plotaux , `tw_op' 
		if `"`tw_op'"' != "" _parse expand cmd bg : 0 , common(SCHeme()) 
		local cscheme = c(scheme)
		if "`bg_op'"=="" &  "`cscheme'"=="s2color" {
			local 0 plotaux , `tw_op' 
			if `"`tw_op'"' != "" _parse expand cmd bg2 : 0 , common(graphregion())  
			if  "`bg2_op'"  == "" local tw_op `tw_op' graphregion(fcolor(white) lcolor(white))
		}
		
		if "`command'" != "" n di  as text  "  - twoway graph command:   " as res `"frame `frame': twoway `graph_syntax', `nodraw' `tw_op' `oth_op'"'	
		** run the twoway command (sourced from the `frame'): 
		frame `frame': cap twoway `graph_syntax', `nodraw' `tw_op' `oth_op'  
		if _rc !=0 {
			n di as err "Error: The plotted data were generated but some of the specified graphing options were inalid / not allowed."
			n di as err "Use the 'replace' option to replace yhe last plot or to correct the faulty graphing options. Use the 'clear' option to start again."
			frame `frame': twoway `graph_syntax', `nodraw' `tw_op' `oth_op'  
		}
		if "`command'" != "" return local cmd  frame `frame': twoway `graph_syntax', `nodraw' `tw_op' `oth_op' `nodraw'
	}		
end		 