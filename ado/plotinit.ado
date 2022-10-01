*! version 1.1 19Sep2022 
capture program drop plotinit 
program define plotinit, rclass
version 16 
syntax [varlist(fv)], FRAME(string)  [clear PLOTonly REPlace(integer -1)] 
	qui {	 
	
		** (1) FRAME INITIALIZATION ********************************************
		** find out current frame 
		frame pwf
		local frame_orig = r(currentframe)
		
		** define the stem word for frames used by plottab (frame_pt by default)
		if "`frame'" == ""  local frame frame_pt
		
		** ADD BETTER ERROR CODE
		if "`frame'" == "`frame_orig'" & "`plotonly'" == "" {
			n di as err "Error: please switch to a different data frame, `frame' is reserved for the plotted data [try: frame change default]"
			exit 104
		}
		
		** create the main output frame, and erase its data if `clear'
		cap frame create `frame'  
		if "`clear'" != "" frame `frame': clear 	
			
		** create a frame that stores the current plot only (`frame'_aux) 
		cap frame create `frame'_aux
		frame `frame'_aux: clear 	
		
		** create a frame that stores customized graphing options (`frame'_cust)
		cap frame create `frame'_cust
		if "`clear'" != "" frame `frame'_cust: clear 
				
		** (2) GATHER PRELIMINARY INFORMATION ********************************** 	
		** if only clearing the already-plotted data, skip everything below
		if "`clear'"!= "" & "`varlist'" =="" {
			n di as result `"  - clearing data from frame "`frame'""'
			exit
		}
		
		** check whether plotted variable(s) exist (nullifies _rc for the rest)
		if "`plotonly'" == "" cap di "placeholder"
		if "`plotonly'" != "" frame `frame': cap confirm var x_val1
		
		** how many graphs are stored already?
		local i = 0
		while _rc ==0 {
			local i = `i' + 1
			frame `frame': cap confirm var x_val`i'
			n di `i'
		}
		 
		** is the plot new or replacing one that is already stored?
		if `replace' != -1 { 
			frame `frame': cap confirm var x_val`replace'
			if _rc !=0 {
			   * may be some branching depending on the value of `rc'
			   n di "{err}Data for plot `i' not found!"
			   exit  
			}
			local i = `replace' 
		}
		
		** if replace is toggled, delete the data to be replaced
		if `replace' != -1 & "`plotonly'" == "" { 
			frame `frame': drop x_val`replace'
			frame `frame': drop y_val`replace'
			frame `frame': cap drop LCI_val`replace'
			frame `frame': cap drop UCI_val`replace'
		}
		
		** for the 1st plot generate the variable structure in `frame'_cust
		if `i'==1 & `replace' == -1 {  
			frame `frame'_cust: gen cust_out = "" 
			frame `frame'_cust: gen cust_gra = ""   
			frame `frame'_cust: gen cust_opt = ""    
			frame `frame'_cust: gen cust_two = ""
			frame `frame'_cust: gen cust_oth = ""
			frame `frame'_cust: gen cust_rgr = ""  
			frame `frame'_cust: gen cust_lci = ""
			frame `frame'_cust: gen cust_oci = ""
			frame `frame'_cust: label variable cust_out "Output type corresponding to _n-th plot"
			frame `frame'_cust: label variable cust_gra "Graph type corresponding to _n-th plot" 
			frame `frame'_cust: label variable cust_rgr "Graph type corresponding to the CIs of _n-th plot" 
			frame `frame'_cust: label variable cust_opt "Graphing options specific to _n-th plot"
			frame `frame'_cust: label variable cust_oth "Any other options specific to _n-th plot"
			frame `frame'_cust: label variable cust_lci "Legend for the CIs of _n-th plot"
			frame `frame'_cust: label variable cust_oci "Graphing options specific to the CIs of _n-th plot"
			frame `frame'_cust: label variable cust_two "Two-way options applicable to the overall graph " 	
		}
	}		
	return scalar i = `i'
end		

