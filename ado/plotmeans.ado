*! version 1.2 27Sep2022 
capture program drop plotmeans 
program define plotmeans
	version 16
	
	** Plotmeans-specific options defined here
	local pt_opts 		CIopt(string) 		clear 				///
		COMmand			FRame(string) 		GLobal 				///
		GRaph(name)  	 				    NODiag 				///
		PLOTonly   		PLName(string) 		REPlace(integer -1) ///
		RGRaph(name) 	OUTput(string) 		TIMes(real 1)  		///
		XSHift(real 0)  YSHift(real 0) 		YZero
	
	** All native twoway options specified here...
	local tw_opts 		 noDRAW 			NAME(string) 		///
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
		
	syntax [varname(default=none max=1)] [if] [in] [fw aw iw], [over(varname)] [ `pt_opts' `tw_opts' * ] 		
 	
	** extract all twoway graphing options that are shared by all graph types 
	*  and store them in `tw_op' (declared by _parse)
	local 0 pt_aux_var `0' 									//   
	_parse expand cmd tw : 0 , common(`tw_opts')  
  
	** extract all the remaining (*) options (not included in pt_opts + my_opts + graph_opts) and 
	*  assume that these are all graph-specific options (e.g., lpattern, msymbol, etc.)
	*  TBD: _rc check whether these are actually graph-specific  options
	local gs_op `options' 	
	
	** extract all CI options from the composite `ciopt' string: 
	tokenize "`ciopt'", parse(",")
	cap confirm number `1'
	if _rc != 0 & "`1'"!="off" local ciopt 95 `ciopt'
	_parse expand cmd off : ciopt , common(off)
	if "`off_op'" == "off" | "`1'" == "off" local noci noci
	else{
		tokenize "`cmd_1'", parse(",")
		local ci = `1'
		local ci_op `3' 
	} 
	
	** deal with alternative varname declarations:
	if "`varlist'" != "" & "`plotonly'" == ""  confirm var `over'
	if "`over'"    != "" & "`plotonly'" ==""   confirm var `varlist'
	
	** define the default graph type to be plotted 
	if "`graph'" == "" local graph = "line"
	if "`rgraph'"== "" local rgraph = "rarea"
	if "`frame'" == "" local frame frame_pt
	
	** weights
	local weight "[`weight'`exp']"
 							 						 
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
			if "`nodiag'"=="" n di as result `i' " - calculating values for a new plot" 
 		
			** get the plotted categories (xval) 
			tab `over' `if' `in', matrow(x_val)
			
			** PLOTMEANS works with factorized `over' variable -> check whether it is factorizable		
				** first check whether it consist of integer/whole numbers only
				local intcheck = 1
				cap confirm byte variable `over'
				if _rc != 0 {
					cap confirm int variable `over'
					if _rc != 0 { 					
						cap confirm long variable `over'
						if _rc != 0 { 
							local intcheck = 0						
						}
					}
				}
				** if `over' is string or float, create a temporary grouping variable 
				if `intcheck' == 0{
					if "`nodiag'"=="" n di as text "  - note:" as err " Variable `over' either contains non-integer values or it is not compressed to the optimal storage type (to correct this, run: compress `over'). Note that non-integer conditioning variables require more computing time & memory."	
					tempvar overtemp
					cap which ftools
					if _rc == 0 {
						fegen `overtemp' = group(`over')
					}
					else { 
						di as err "To optimize speed, install the ftools package [ssc install ftools]" 
						egen `overtemp' = group(`over')		
					}
					local factor_ov overtemp 
				}
				** if `over' contains whole numbers only, check whether its minimum is below zero 
				else{
					mata: st_numscalar("min_xv",min(st_matrix("x_val")))
					** if yes, create a temporary variable containing `over' values shifted to positive integers
					if min_xv < 0 {
						tempvar overtemp
						gen `overtemp' = `over' - min_xv 
						local factor overtemp 
					}
					else{
						local factor_ov over   
					}
				}
				
			** get the plotted means (by OLS with factorzized `over' variable `factor_ov')  
			reg `varlist' ibn.``factor_ov'' `if' `in' `weight' , nocons 
						
			mat RES = r(table)
			mat plot_val`i' = RES[1,1...]' 
			
			fvexpand ibn.``factor_ov''
			local fvarlist = r(varlist)
			
			** PB: populate the matrix of results
			local cols = 3
			if "`noci'" !="" local cols  = 1 
			
			** PB: define matrix of results
			mat PL = J(1,`cols',.)
			
			local ii = 0
			qui foreach var in `fvarlist' {    
				cap qui di _b[`var']
				if _rc ==0 { 
					if "`noci'" =="" {
						** get degrees of freedom & inverse t-stat for confidence level `ci'
						local df = e(df_r)
						local invt = invt(`df',`ci'/100)
						** derive the CI for the given coefficient
						local LC = _b[`var'] - `invt'*_se[`var']
						local UC = _b[`var'] + `invt'*_se[`var']
						mat PL = [PL \ _b[`var'], `LC', `UC' ]
					}
					else { 
						mat PL = [PL \ _b[`var']]
					}
				} 
			}   
			mat PL = PL[2...,1...]

			** PM: multiply the cell values by a constant ?
			if "`times'" != "1"  mat PL = PL * `times'
			  
			** PM: turn the PL matrix into plot variables
			frame `frame': svmat PL, names(plot_val`i')  
			frame `frame': svmat x_val, names(x_val`i')  	
			
			** PM: rename the plot variables
			frame `frame': rename x_val`i'1 x_val`i'
			frame `frame': rename plot_val`i'1 y_val`i'
			if "`noci'" ==""{
				frame `frame': cap rename plot_val`i'2 LCI_val`i'
				frame `frame': cap rename plot_val`i'3 UCI_val`i'
			} 					

			** shift plotted values?	
			if "`xshift'" !=""  frame `frame':  replace x_val`i' = x_val`i' + `xshift'
			if "`yshift'" !="" {
				frame `frame':  replace y_val`i'   = y_val`i'   + `yshift'
				frame `frame':  cap replace LCI_val`i' = LCI_val`i' + `yshift'
				frame `frame':  cap replace UCI_val`i' = UCI_val`i' + `yshift'
			}	
		}		
		** (3b) DO NOTHING WHEN PLOTTING ALREADY STORED DATA *****************
		else {	 
			if "`nodiag'"=="" n di as result "X - plotting already stored graphs"				
		}
		
		** (5) FURTHER CUSTOMIZATION *******************************************	 		
		** labels, legends and saving
		if "`plotonly'" == "" | `replace' != -1  {	
		
			** assign descriptive labels to auxiliary plot variables?
			local xlbl : variable label `over'
			if "`xlbl'"== "" local xlbl `over'
			if "`plname'" != "" local plname `plname'
			if "`plname'" == "" local plname "Plot `i'"
			frame `frame': label var x_val`i' "`xlbl'"
			frame `frame': label var y_val`i' "`plname', Estimates"
			frame `frame': cap label var LCI_val`i' "`plname' `ci'% CI, LB"
			frame `frame': cap label var UCI_val`i' "`plname' `ci'% CI, UB"
			
			** copy x-value labels
			local xvlbl : value label `over'
			if "`xvlbl'" != "" {
				tempfile auxlabfile
				cap label save `xvlbl' using `auxlabfile', replace 
				frame `frame': cap qui do `auxlabfile'
				frame `frame': label values x_val`i' `xvlbl'
			}
						
			local output "Conditional Means"	
			local ci_lab  "`plname', `ci'% CIs"

			** save custom graph options for new or replaced graphs	
			if "`global'" == "" local in_i in `i'
			frame `frame'_cust: cap set obs `i' 
			frame `frame'_cust: replace cust_out = `"`output'"' `in_i'
			frame `frame'_cust: replace cust_gra = `"`graph'"' `in_i'
			frame `frame'_cust: replace cust_opt = `"`gs_op'"' `in_i'
			frame `frame'_cust: replace cust_two = `"`tw_op'"'  in 1
			frame `frame'_cust: replace cust_oth = `"`oth_op'"' in 1 
			if "`noci'" ==""{			
				frame `frame'_cust: replace cust_rgr = `"`rgraph'"' `in_i' 
				frame `frame'_cust: replace cust_lci = `"`ci_lab'"' `in_i'
				frame `frame'_cust: replace cust_oci = `"`ci_op'"'  `in_i'
			}
		}
		else if `"`tw_op'"'!="" {
			frame `frame'_cust: replace cust_two = `"`tw_op'"'  in 1
		}

		** (4) TWO-WAY COMMAND *******************************************
		** create a twoway command syntax  
		n plottwoway, frame(`frame') `command' `nodiag' `yzero'
	}
end