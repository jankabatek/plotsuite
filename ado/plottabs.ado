*! version 1.2 27Sep2022 
capture program drop plottabs
program define plottabs
	version 16
	
	** Plottabs-specific options defined here
	local pt_opts 		clear 				COMmand     		///
		FRame(string) 	GLobal 				GRaph(name)  		///
		PLOTonly   		PLName(string) 		REPlace(integer -1) ///
		OUTput(string) 	TIMes(real 1)  		XSHift(real 0)   	///
		YSHift(real 0)  YZero 				NODraw
	
	** All native twoway options specified here...
	local tw_opts 		  			        NAME(string) 		///
		SCHeme(passthru) COPYSCHeme 		noREFSCHeme 		/// 
		FXSIZe(passthru) FYSIZe(passthru)	PLAY(string asis)	/// 
		TItle(string)    SUBtitle(string) 	CAPtion(string)		///
		NOTE(string)     LEGend(string)							///
		T1title(string)  T2title(string) 	B1title(string)		///
		B2title(string)  L1title(string) 	L2title(string)		///
		R1title(string)  R2title(string)						///
		XLabels(string)  YLabels(string)  	TLabels(string)		///
		XTICks(string)   YTICks(string)   	TTICks(string)		///
		XMLabels(string) YMLabels(string) 	TMLabels(string)	///
		XMTicks(string)  YMTicks(string)  	TMTicks(string)		/// 
		XTitle(string)   YTitle(string)   	TTitle(string)		///
		XOptions(string) YOptions(string)						///
		XSIZe(passthru)  YSIZe(passthru)						///
		BY(string asis)  SAVing(string asis) GRAPHREGION(string)	
		
	syntax [varname(default=none max=1)] [if] [in], [over(varname)] [ `pt_opts' `tw_opts' * ] 		
	 
	** extract all twoway graphing options that are shared by all graph types 
	*  and store them in `tw_op' (declared by _parse)
	local 0 pt_aux_var `0' 									//   
	_parse expand cmd tw : 0 , common(`tw_opts')  
 
	** extract all the remaining (*) options (not included in pt_opts + my_opts + graph_opts) and 
	*  assume that these are all graph-specific options (e.g., lpattern, msymbol, etc.)
	*  TBD: _rc check whether these are actually graph-specific  options
	local gs_op `options' 	
	
	** deal with alternative varname declarations:
	if "`varlist'" != "" & "`over'" !="" n di as err "varname specified twice, using: `over'" 
	if "`varlist'" != "" & "`over'" =="" local over `varlist' 
	
	** define the default graph type to be plotted 
	if "`graph'" == "" local graph  line
	if "`output'"== "" local output frequency
	if "`frame'" == "" local frame  frame_pt 
 							 
	qui {
		** (1) FRAME INITIALIZATION (SAME FOR ALL PLOT COMMANDS) ***************
		
		** Done by the plotinit routine
		* if `clear': create the frame structure 
		* else: count the number of plots already in the frame structure
		plotinit `varlist', frame(`frame') `clear' `plotonly' replace(`replace')

		** the plot count is stored here:
		local i = r(i)
		
		** (3a) GENERATE PLOTTED DATA *******************************************
		if "`plotonly'" == ""  {	 	
			n di as result `i' " - tabulating values for a new graph" 
			
			** PT: tabulate command
			tab `over' `if' , matcell(plot_val`i') matrow(x_val`i')
			
			** PT: adjust the matcell data to conform with the chosen output type 
			local out = substr("`output'",1,3)  
			if "`out'"=="sha" {
				** conditional shares
				mat plot_val`i' =  plot_val`i'/r(N)
				local output Relative Share 
			}
			else if "`out'"=="cum" {
				** cumulative shares
				mat plot_val`i' =  plot_val`i'/r(N)
				local Nr = rowsof(plot_val`i')
				forvalues r = 2 / `Nr' { 	
					mat plot_val`i'[`r',1] = plot_val`i'[`r',1] + plot_val`i'[`r'-1,1]
				}			
				local output Cumulative Share	 
			}
			else { 
				if "`out'"!="fre" {
					n di as err "Unknown output type specified, reverting to frequencies"
				}
				local output Frequency
			} 
			
			** PT: multiply the cell values by a constant ?
			if "`times'" != "1"  mat plot_val`i' = plot_val`i' * `times'
		
			** for the 1st plot after `clear', store the data in frame_pt			
			frame `frame': svmat x_val`i' 
			frame `frame': svmat plot_val`i'
			
			** make the plot variable names more descriptive
			frame `frame': rename x_val`i'1    x_val`i'
			frame `frame': rename plot_val`i'1 y_val`i'

			** shift plotted values?	
			if "`xshift'" !=""  frame `frame':  replace x_val`i' = x_val`i' + `xshift'
			if "`yshift'" !=""  frame `frame':  replace y_val`i' = y_val`i' + `yshift'			 
	
		}		
		** (3b) DO NOTHING WHEN PLOTTING ALREADY STORED DATA *****************
		else {	 
			n di as result "X - plotting already stored graphs"				
		}
			
		** (3) FURTHER CUSTOMIZATION (if new plot or replace is triggered)****** 
				
		** save custom graph options for new or replaced graphs
		if "`plotonly'" == "" | `replace' != -1  {	
			
			** assign descriptive labels to auxiliary plot variables?
			** PT: specify the plot variable labels (EDIT)
			if "`plname'" == "" local plname "Plot `i'"
			frame `frame': label var y_val`i' "`plname'"	
			
			** x-labels do not work as before (used as titles) because x's are now plot-specific
			cap local xlbl : variable label `over'
			if _rc == 0 {
				if "`xlbl'" == "" local xlbl "Grouping variable"
				frame `frame': label var x_val`i' "`xlbl'"
			}
			
			** copy x-value labels
			local xvlbl : value label `over'
			if "`xvlbl'" != "" {
				tempfile auxlabfile
				cap label save `xvlbl' using `auxlabfile', replace 
				frame `frame': cap qui do `auxlabfile'
				frame `frame': label values x_val`i' `xvlbl'
			}
			 
			** save custom graph options for new or replaced graphs	
			if "`global'" == "" local in_i in `i'
			frame `frame'_cust: cap set obs `i' 
			frame `frame'_cust: replace cust_out = `"`output'"' `in_i'
			frame `frame'_cust: replace cust_gra = `"`graph'"'  `in_i'
			frame `frame'_cust: replace cust_opt = `"`gs_op'"'  `in_i'
			frame `frame'_cust: replace cust_two = `"`tw_op'"'   in 1
			frame `frame'_cust: replace cust_oth = `"`oth_op'"'  in 1 
		}
		else if `"`tw_op'"'!="" {
			frame `frame'_cust: replace cust_two = `"`tw_op'"'  in 1
		}
				
		** (4) TWO-WAY COMMAND *******************************************
		** create a twoway command syntax
		n plottwoway, frame(`frame') `command' `nodiag' `yzero' `nodraw'
	}
end