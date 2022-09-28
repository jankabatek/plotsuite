*! version 1.2 27Sep2022 
capture program drop plotbetas 
program define plotbetas
	version 16
	
	** Plotbetas-specific options defined here
	local pt_opts 		CIopt(string)       clear 				///
		COMmand     	FRame(string) 		GLobal 				///
		GRaph(name)  	NODIAG 				OUTput(string) 		///
		PLOTonly   		PLName(string) 							///
		RGRaph(name) 	REPlace(integer -1) TIMes(real 1)  		///
		XSHift(real 0)  YSHift(real 0)      YZero
	
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
				 		
	syntax [varlist(fv)] [if] [in], [ `pt_opts' `tw_opts' * ] 		
 	
	** extract all twoway graphing options that are shared by all graph types 
	*  and store them in `tw_op' (declared by _parse)
	local 0 pt_aux_var `0' 	 				   
	 
	_parse expand cmd tw : 0 , common(`tw_opts')  
  
	** extract all the remaining (*) options (not included in pt_opts + my_opts + graph_opts) and 
	*  assume that these are all graph-specific options (e.g., lpattern, msymbol, etc.)
	*  TBD: _rc check whether these are actually graph-specific  options
	local gs_op `options' 	
	 	
	** check if `varlist' is a factorized variable, or a list of non-factorized variables
	if "`plotonly'" == "" {
		cap _fv_check_depvar `varlist'
		if _rc != 0 {
		    local factor = 1
			tokenize `varlist', parse(".#")
			local fv_name `3'
		    fvexpand `varlist'
			local varlist = r(varlist)
		}		
		else local factor = 0
	} 
	
	** extract all CI options from the composite `ciopt' string: 
	tokenize "`ciopt'", parse(",")
	cap confirm number `1'
	if _rc != 0  & "`1'"!="off" local ciopt 95 `ciopt'
	_parse expand cmd off : ciopt , common(off)
	if "`off_op'" == "off" | "`1'" == "off" local noci noci
	else{
		tokenize "`cmd_1'", parse(",")
		local ci = `1'
		local ci_op `3' 
	}

	** define defaults: 
	if "`graph'" == "" local graph = "line"
	if "`rgraph'"== "" local rgraph = "rarea"
	if "`frame'" == "" local frame frame_pt 		 
	qui {
		** (1) FRAME INITIALIZATION (SAME FOR ALL PLOT COMMANDS) ***************
		
		** Done by the plotinit routine
		* if `clear': create the frame structure 
		* else: count the number of plots already in the frame structure
		plotinit `varlist', frame(`frame') `clear' `plotonly' replace(`replace')
		
		** the plot count is stored here:
		local i = r(i)
		
		** (2a) GENERATE PLOTTED DATA *******************************************
		
		if "`plotonly'" == ""  {	 	
			if "`nodiag'"=="" n di as result `i' " - calculating values for a new plot" 
 		
			** PB: min max and number of columns
			if "`constraint'" =="" { 
				qui sum `varlist'
				local min = r(min)
				local max = r(max)
			}
			else {
				tokenize "`constraint'"
				local min = `1'
				local max = `2'
			}
			
			local cols = 4
			if "`noci'" !="" local cols  = 2 
			
			** PB: define matrix of results
			mat PL = J(1,`cols',.)
			 
			** PB: populate the matrix of results
			local ii = 0
			qui foreach var in `varlist' {
				if `factor'==1 {
					** determine the value of the factorized variable:
					local pos = 1 // strpos("`var'","i") + 1
					local length = strpos("`var'",".") - `pos'
					local ii =  real(substr("`var'",`pos',`length')) 
					** deal with ibn's
					if `ii'==. {
						local pos_suffix = `pos' + `length' - 2
						if substr("`var'",`pos_suffix',2) == "bn" local ii =  real(substr("`var'",`pos',`length'-2))
					}					
				}
				else{
					** or just start from 1 (for non-factorized variables):
				    local ii = `ii' + 1
					local xlab `xlab' `ii' "`var'"
				}		
				cap qui di _b[`var']
				if _rc ==0 { 
					if "`noci'" =="" {
						** get degrees of freedom & inverse t-stat for confidence level `ci'
						local df = e(df_r)
						local invt = invt(`df',0.`ci')
						** derive the CI for the given coefficient
						local LC = _b[`var'] - `invt'*_se[`var']
						local UC = _b[`var'] + `invt'*_se[`var']
						mat PL = [PL \ `ii' , _b[`var'], `LC', `UC' ]
					}
					else { 
						mat PL = [PL \ `ii' , _b[`var']]
					}
				} 
			}  
			mat PL = PL[2...,1...]
			
			**PB: turn the matrix into variables
			frame `frame': svmat PL, names(plot_val`i')
			
			**PB: optionally, adjust the plot variables
			qui{
				if "`xshift'"   !=""  frame `frame':  replace plot_val`i'1 = plot_val`i'1 + `xshift'
				frame `frame': rename plot_val`i'1 x_val`i'
				if "`dropzero'" !=""  frame `frame':  for var plot_val`i'*:  replace X = . if X ==0	 
				if "`times'" 	!="1" frame `frame':  for var plot_val`i'*:  replace X = X * `times'
				if "`yshift'"   !=""  frame `frame':  for var plot_val`i'*:  replace X = X + `yshift'			 
			}
			
			** PB: rename the plot variables
			frame `frame': rename plot_val`i'2 y_val`i'
			if "`noci'" ==""{
				frame `frame': rename plot_val`i'3 LCI_val`i'
				frame `frame': rename plot_val`i'4 UCI_val`i'
			}
			
			** add value labels for non-factorized varlist
			local 0 plotaux , `gs_op' 
			if `"`gs_op'"' != "" _parse expand cmd xl : 0 , common(xlabel())
			if `factor'!=1 & `"`xl_op'"'=="" local gs_op `gs_op' xlabel(`xlab')
		}		
		** (2b) SKIP DATA GENERATION WHEN PLOTTING ALREADY STORED DATA *********
		else {	 
			n di as result "X - plotting already stored graphs"				
		}
		 
		** (3) FURTHER CUSTOMIZATION (if new plot or replace is triggered)******
		** labels, legends and saving
		if "`plotonly'" == "" | `replace' != -1  {		
		
			** assign descriptive labels to auxiliary plot variables?
			if "`plname'" != "" local plname `plname',
			if "`plname'" == "" local plname " "
			frame `frame': label var x_val`i' "Regressors"
			frame `frame': label var y_val`i' "`plname' Estimates"
			frame `frame': cap label var LCI_val`i' "`plname' `ci'% CI, LB"
			frame `frame': cap label var UCI_val`i' "`plname' `ci'% CI, UB"
			
			local output "Coefficient Estimates"
			local ci_lab  "`plname' `ci'% CIs"
			
			** copy x-value labels for factorized vars
			if `factor'==1 {
				cap local xvlbl : value label `fv_name'
				if "`xvlbl'" != "" {
				    tempfile auxlabfile
				    cap label save `xvlbl' using `auxlabfile', replace 
					frame `frame': cap qui do `auxlabfile'
					frame `frame': label values x_val`i' `xvlbl'
				}
			}
			
			** save custom graph options for new or replaced graphs	
			if "`global'" == "" local in_i in `i'
			frame `frame'_cust: cap set obs `i' 
			frame `frame'_cust: replace cust_out = `"`output'"' `in_i'
			frame `frame'_cust: replace cust_gra = `"`graph'"'  `in_i'
			frame `frame'_cust: replace cust_opt = `"`gs_op'"'  `in_i' 
			frame `frame'_cust: replace cust_two = `"`tw_op'"'   in 1
			frame `frame'_cust: replace cust_oth = `"`oth_op'"'  in 1 
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