{smcl}
{* *! version 1.1  20apr2023}{...} 
{vieweralsosee "plottabs" "help plottabs"}{...}
{vieweralsosee "plotmeans" "help plotmeans"}{...}
{vieweralsosee "plotshares" "help plotshares"}{...}
{vieweralsosee "plotbetas" "help plotbetas"}{...}
{vieweralsosee "twoway" "help twoway"}{...}
{viewerjumpto "Syntax" "plotbetas##syntax"}{...}
{viewerjumpto "Description" "plotbetas##description"}{...} 
{viewerjumpto "Examples" "plotbetas##examples"}{...}
{viewerjumpto "Contact" "plotbetas##contact"}{...}
{title:Title}

{phang}
{bf:plotbetas} {hline 2} Plot regression coefficients (post-estimation) 


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:plotb:etas} {it:{help varlist}} {ifin}
[, options]

{p 8 17 2}where {it:{help varlist}} defines the set of variables to be plotted.

{synoptset 20 tabbed}{...}
{synopthdr}
{p2line}
{syntab :Basic options}
{p2col:{cmdab:ov:er(}{it:{help varlist}})}an alternative way to specify the {it:{help varlist}}{p_end}
{p2col:{cmdab:gr:aph(}{it:graph_type})}specify the {it:{help twoway}} {it:graph_type} for coefficient estimates: {bf:line}(default)/{bf:bar}/{bf:connected}/{bf:scatter}/etc.{p_end}
{p2col:{cmdab:rgr:aph(}{it:rgraph_type})}specify the {it:{help twoway}} {it:rgraph_type} for confidence intervals: {bf:rarea}(default)/{bf:rbar}/{bf:rcap}/{bf:rspike}/etc.{p_end}
{p2col:{cmdab:ci(}{bf:#},{it:ci_options})}specify the confidence level for confidence intervals:  {bf:#} = 0...100, {bf:off} = suppress CIs. By default, {bf:#} is the confidence level used in the regression output.{p_end}
{p2col:}  {it:ci_options} denote {it:rgraph_type} customization options ({it:e.g.}, color and transparency){p_end}

{syntab :Memory/data management}
{p2col:{cmdab:fr:ame(}{it:frame_name})}specify the name of the {it:{help frame}} that stores the plot data ({bf:frame_pt} is the default {it:frame_name}){p_end}
{p2col:{cmdab:cl:ear}}clear all plot data stored in {it:frame_name}{p_end}
{p2col:{cmdab:rep:lace(}{it:#}{cmd:)}}replace data and/or options for plot # in {it:frame_name}{p_end}
{p2col:{cmdab:plot:only}}display the plots already stored in {it:frame_name}{p_end}

{syntab :Plot customization}
{p2col:{cmdab:com:mand}}print out the {it:{help twoway}} command used to display the chart (useful for finer customization){p_end}
{p2col:{cmdab:gl:obal}}apply the same customization options to all plots in {it:frame_name}{p_end}
{p2col:{cmdab:pln:ame(}{it:plot_name})}name the current plot (used in legends when displaying multiple plots at once){p_end}
{p2col:{cmdab:xsh:ift(}{it:real})}shift the plotted values along the x-axis{p_end}
{p2col:{cmdab:ysh:ift(}{it:real})}shift the plotted values along the y-axis{p_end}
{p2col:{cmdab:yz:ero}}a shorthand option for displaying zero on the y-axis (and scaling ylabels accordingly){p_end}
{p2col:{it:{help twoway_options}}}change titles, legends, axes, aspect ratio, etc.{p_end}
{p2col:{it:{help connect_options}}}change look of lines or connecting method{p_end}
{p2col:{it:{help scatter##marker_options:marker_options}}}change look of
       markers (color, size, etc.){p_end}
INCLUDE help gr_baropt

{syntab :Other options}
{p2col:{cmdab:nod:raw}}do not display the plotted values (useful when looping/overlaying many intermediate plots){p_end}
{p2col:{cmdab:tim:es(}{it:real})}multiply the plotted values by a constant (useful for normalizations){p_end}
{p2line}
{p2colreset}{...}
{p 4 6 2}
{it:{help varlist}} needs to be specified (one way or the other) to produce a new plot. It does not need to be specified when displaying plots that are already stored in the memory (using the option {cmdab:plot:only}).

{marker description}{...}
{title:Description}

{pstd}
{bf:plotbetas} is a post-estimation (!) command that visualizes regression coefficient estimates of {it:{help varlist}} along with their confidence intervals.
The {it:{help varlist}} can be either a list of multiple variables, or a single factorized variable (i.{it:{help varname}}).

{pstd}
{bf:plotbetas} avoids time-consuming memory operations performed by native graphing commands.
By leveraging the data {it:{help frame}} environment, it proves extremely fast in very large datasets.
 
{pstd}
{bf:plotbetas} can be called sequentially. The plotted data is stored in a dedicated data frame (see {it:Memory/data management options}), which allows users to create complex visualizations that combine multiple plots.
{bf:plotbetas} can be also combined with other commands in the plot suite ({it:{help plottabs}}, {it:{help plotmeans}}, and {it:{help plotshares}}).

{pstd}
{bf:Customization}: the coefficient plots can be customized by selecting the preferred {it:{help twoway}} {it:graph_type}, and adjusting it further using the {it:{help twoway_options}} and other options specific to the given {it:graph_type}. 
The confidence-interval plots can be customized by selecting the preferred {it:{help twoway}} {it:rgraph_type}, and adjusting it further using the {it:ci_options} suboption of {bf:ci}({bf:#},{it:ci_options}). See examples below.{p_end}

{pstd}
{bf:CURRENT LIMITATIONS}: Custom confidence levels for confidence intervals are currently restricted to OLS models (command {it:{help regress}}). However, you can work around this limitation by estimating your model with pre-specified 
confidence level (option {bf:level(#)}), and run the {bf:plotbetas} command without specifying the confidence level. See example below.{p_end}

{marker examples}{...}
{title:Examples}

    Basic use:

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}
{phang2}{cmd:. reg ttl_exp i.age}{p_end}
{phang2}{cmd:. plotbetas i.age}{p_end}

{phang2}{cmd:* produce a whisker plot instead:}{p_end}
{phang2}{cmd:. plotbetas i.age, clear graph(scatter) rgraph(rcap)}{p_end}

    {hline}
    Compare regression estimates for two groups:

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}

{phang2}{cmd:. reg ttl_exp i.age if union==0}{p_end}
{phang2}{cmd:. plotbetas i.age, graph(connect) plname(Non-union)}{p_end}

{phang2}{cmd:. reg ttl_exp i.age if union==1}{p_end}
{phang2}{cmd:. plotbetas i.age, graph(connect) plname(Union)}{p_end}

    {hline}
    Customize line color, CI color & CI transparency:

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}
{phang2}{cmd:. reg ttl_exp i.age}{p_end}
{phang2}{cmd:. plotbetas i.age, color(green) ci(, color(gold%35))}{p_end}

    {hline}
    Plot non-linear model coefficients with 99% CIs: 

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}
{phang2}{cmd:. logit collgrad i.age, level(99)}{p_end}
{phang2}{cmd:. plotbetas i.age}{p_end}

    {hline}
    Plot data management:

{phang2}{help plottabs##plot_data_management:See plottabs / Plot data management}{p_end}

{marker frames}{...}
{title:Frames}

{phang2}{help plottabs##frames:See plottabs / Frames}{p_end}

{marker contact}{...}
{title:Contact}

{phang2}Jan Kabátek, The University of Melbourne{p_end}
{phang2}j.kabatek@unimelb.edu.au{p_end} 
 
