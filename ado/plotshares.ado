*! version 1.2 27Sep2022 
capture program drop plotshares
program define plotshares
	version 16
	
	** Plotshares-specific options defined here
	local pt_opts 		clear 				COMmand     		///
		FRame(string) 	GLobal 				GRaph(name)  		///
		INVert 		    OUTput(string)		NOStack 	PLOTonly 			///
		PLName(string)	REPlace(integer -1) TIMes(real 1) 		///
		YZero
	
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
	if "`varlist'" != "" & "`plotonly'" == ""  confirm var `over'
	if "`over'"    != "" & "`plotonly'" ==""   confirm var `varlist' 
	
	** define the default graph type to be plotted 
	if "`output'"== "" local output share
	if "`graph'" == "" local nogrop = 1
	if "`graph'" == "" local graph area
	if "`frame'" == "" local frame  frame_pt 

	** inverted categorical order?
	if "`invert'" != "invert" local inv_sw = 0
	if "`invert'" == "invert" local inv_sw = 1  
 							 
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
			
			** PS: tabulate command
			tab `over' `varlist' `if', matcell(cell_val) matrow(x_val) matcol(gr_val)  
			local ncol = r(c)

			** PS: adjust the matcell data to conform with the chosen output type 
			local out = substr("`output'",1,3)  
			if "`out'"=="fre" {
				if "`nostack'"=="" {
					mata: SHARES(0,`inv_sw',0)
					local output Stacked frequencies 
				}
				else{
					mata: SHARES(0,0,1)
					local output Relative Shares
					if `nogrop'==1 local graph line					
				}
			}
			else { 
				if "`out'"!="sha" {
					n di as err "Unknown output type specified, reverting to relative shares"
				}
				*local inv_sw = 1 - `inv_sw' //COULD BE COLLAPSED BELOW
				if "`nostack'"=="" {
					mata: SHARES(1,`inv_sw',0)
					local output Stacked shares 
				}
				else{
					mat MATVAL = cell_val
					local output Frequencies 
					if `nogrop'==1 local graph line				
				}
			} 
			
			** PS: multiply the cell values by a constant ?
			if "`times'" != "1"  mat plot_val`i' = plot_val`i' * `times'
		
			** PS: turn adjusted matrix into plot_vals
			frame `frame': svmat MATVAL, names(plot_val)
			
			** PS: make the plot variable names more descriptive (x_vals are repeated to conform with plottwoway structure)
			local imin = `i'
			forvalues c = 1/`ncol' {   
				if `c'>1 local i = `i' + 1
				frame `frame': svmat x_val, names(x_val`i') 
				frame `frame': rename x_val`i'1 x_val`i'
				frame `frame': rename plot_val`c' y_val`i'
			}	
			local imax = `i'
		}		
		** (3b) DO NOTHING WHEN PLOTTING ALREADY STORED DATA *****************
		else {	 
			n di as result "X - plotting already stored graphs"				
		}
			
		** (3) FURTHER CUSTOMIZATION (if new plot or replace is triggered)****** 
				
		** save custom graph options for new or replaced graphs
		if "`plotonly'" == "" | `replace' != -1  {	
			forvalues i = `imin'/`imax'	{
				** assign descriptive labels to auxiliary plot variables?
				** specify the plot variable labels (EDIT)
				*if "`plname'" == "" local plname "Share"
				
				** grnum assignment depends on invert
				if `inv_sw'==0 local grnum = gr_val[1,`i']
				else local grnum = gr_val[1,`imax'-(`i'-`imin')]
				
				** specify the category-labels 
				if "`vlab'" != "" {
					local lab`i' : label `vlab' `grnum'
					frame `frame': label var y_val`i' "`varlist'= `lab`i''"	
				} 
				else { 
					frame `frame': label var y_val`i' "`varlist'=`grnum'"	
				}
				
				** x-labels do not work as before (used as titles) because x's are now plot-specific
				local xlbl : variable label `over'
				if "`xlbl'" == "" local xlbl "Grouping variable"
				frame `frame': label var x_val`i' "`xlbl'"
				
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
			}
			frame `frame'_cust: replace cust_two = `"`tw_op'"'   in 1
			frame `frame'_cust: replace cust_oth = `"`oth_op'"'  in 1 
		}
		else if `"`tw_op'"'!="" {
			frame `frame'_cust: replace cust_two = `"`tw_op'"'  in 1
		}
				
		** (4) TWO-WAY COMMAND *******************************************
		** create a twoway command syntax
		n plottwoway, frame(`frame') `command' `nodiag' `yzero'
		
	}
end


cap mata: mata drop SHARES()
mata
function SHARES(share,inv,ns)
	{
		MATVAL_ORIG = st_matrix("cell_val")
		MATVAL 		= MATVAL_ORIG
		 
		/* inverse selection : first category comes on the top of the graph */
		if (ns ==0) {
			if (inv ==1) {
				for (j=1; j<=cols(MATVAL); j++) {
					jinv = cols(MATVAL) - (j-1)
					MATVAL[,j] = MATVAL_ORIG[,jinv]
				} 
			}
			
			/* relative shares */
			if (share ==1) {
				SUMVAL = rowsum(MATVAL)
				for (j=1; j<=cols(MATVAL); j++) {
					for (i=1; i<=rows(MATVAL); i++) {
						MATVAL[i,j] = MATVAL[i,j] / SUMVAL[i,1]
					}
				}
			}
			
			for (j=cols(MATVAL)-1; j>=1; j--) {
				for (i=1; i<=rows(MATVAL); i++) {
					MATVAL[i,j] = MATVAL[i,j] + MATVAL[i,(j+1)] 
				}
			}
		}
		else {
			for (i=1; i<=rows(MATVAL); i++) {
				MATVAL[i,] = MATVAL_ORIG[i,] / rowsum(MATVAL_ORIG[i,])
			}			
		}
		st_matrix("MATVAL",MATVAL)
	}
end 