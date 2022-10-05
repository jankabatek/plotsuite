{smcl}
{* *! version 1.1  21sep2022}{...} 
{vieweralsosee "plottabs" "help plottabs"}{...}
{vieweralsosee "plotmeans" "help plotmeans"}{...}
{vieweralsosee "plotshares" "help plotshares"}{...}
{vieweralsosee "plotbetas" "help plotbetas"}{...}
{vieweralsosee "twoway" "help twoway"}{...}
{viewerjumpto "Syntax" "plotmeans##syntax"}{...}
{viewerjumpto "Description" "plotmeans##description"}{...} 
{viewerjumpto "Examples" "plotmeans##examples"}{...}
{viewerjumpto "Contact" "plotmeans##contact"}{...}
{title:Title}

{phang}
{bf:plotmeans} {hline 2} Plot conditional means (a visual analog of {help mean:mean y, over(x)})


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:plotm:eans} {it:{help varname}} {ifin}
[{it:{help plotmeans##weight:weight}}]
, over({it:{help groupvar}}) [options]

{p 8 17 2}where {it:{help varname}} is the outcome and {it:{help groupvar}} is the conditioning variable 

{synoptset 20 tabbed}{...}
{synopthdr}
{p2line}
{syntab :Basic options}
{p2col:{cmdab:ov:er(}{it:{help groupvar}})}specify the conditioning variable{p_end}
{p2col:{cmdab:gr:aph(}{it:graph_type})}specify the {it:{help twoway}} {it:graph_type} for mean values:  {bf:line}(default)/{bf:bar}/{bf:connected}/{bf:scatter}/etc.{p_end}
{p2col:{cmdab:rgr:aph(}{it:rgraph_type})}specify the {it:{help twoway}} {it:rgraph_type} for confidence intervals:  {bf:rarea}(default)/{bf:rbar}/{bf:rcap}/{bf:rspike}/etc.{p_end}
{p2col:{cmdab:ci(}{bf:#},{it:ci_options})}specify the confidence level for confidence intervals:  {bf:#} = 0...100, {bf:95} = default, {bf:off} = suppress CIs{p_end}
{p2col:}  {it:ci_options} denote {it:rgraph_type} customization options ({it:e.g.}, color and transparency){p_end}

{syntab :Memory/data management}
{p2col:{cmdab:fr:ame(}{it:frame_name})}specify the name of the {it:{help frame}} that stores the plot data ({bf:frame_pt} is the default){p_end}
{p2col:{cmdab:cl:ear}}clear all plot data stored in {it:frame_name}{p_end}
{p2col:{cmdab:rep:lace(}{it:#}{cmd:)}}replace data and/or options for plot # in {it:frame_name}{p_end}
{p2col:{cmdab:plot:only}}display the plots already stored in {it:frame_name}{p_end}

{syntab :Plot customization}
{p2col:{cmdab:com:mand}}print out the {it:{help twoway}} command used to display the chart (useful for finer customization){p_end}
{p2col:{cmdab:gl:obal}}apply the same customization options to all plots in {it:frame_name}{p_end}
{p2col:{cmdab:pln:ame(}{it:plot_name})}name the current plot (used in legends when displaying multiple plots at once){p_end}
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
{it:{help varname}} and over({it:{help groupvar}}) need to be specified to produce a new plot. They do not need to be specified when displaying plots that are already stored in the memory (using the option {cmdab:plot:only}).{p_end}
{marker weight}{...}
{p 4 6 2}
{opt aweight}s, {opt fweight}s, {opt iweight}s, and {opt pweight}s, are allowed;
see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{bf:plotmeans} is a command that visualizes conditional sample means of {it:{help varname}} over {it:{help groupvar}} ({it:i.e.}, the output of {it:{help mean}} {it:{help varname}}, over({it:{help groupvar}})).
By default, it also visualizes the corresponding confidence intervals . 

{pstd}
{bf:plotmeans} avoids the time-consuming memory operations performed by native graphing commands.
By leveraging the data {it:{help frame}} environment, it proves extremely fast in very large datasets.
Furthermore, because {bf:plotmeans} employs a factorized OLS model, it also outperforms the original {it:{help mean}} command. 
Note that the routine is least memory-intensive when {it:{help groupvar}} is integer (non-integer {it:{help groupvar}} variables are allowed, but the routine has to create an auxiliary integer {it:{help tempvar}} for factorization).
 
{pstd}
{bf:plotmeans} can be called sequentially. The plotted data is stored in a dedicated data frame (see {it:Memory/data management} options).
This allows users to create complex visualizations that combine multiple conditional plots.
{bf:plotmeans} can be also combined with other commands from the {bf:plot suite} ({it:{help plottabs}}, {it:{help plotbetas}}, and {it:{help plotshares}}).

{pstd}
{bf:Customization}: the conditional-mean plots can be customized by selecting the preferred {it:{help twoway}} {it:graph_type}, and adjusting it further using the {it:{help twoway_options}} and other options specific to the given {it:graph_type}.
The confidence-interval plots can be customized by selecting the preferred {it:{help twoway}} {it:rgraph_type}, and adjusting it further using the {it:ci_options} suboption of {bf:ci}({bf:#},{it:ci_options}). See examples below.{p_end}

{marker examples}{...}
{title:Examples}

    Basic use:

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}
{phang2}{cmd:. plotmeans ttl_exp, over(age)}{p_end}

{phang2}{cmd:* produce a whisker plot instead:}{p_end}
{phang2}{cmd:. plotmeans ttl_exp, over(age) graph(scatter) rgraph(rcap) clear}{p_end}

    {hline}
    Compare conditional means for two groups:

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}
{phang2}{cmd:. plotmeans ttl_exp if union==0, over(age) graph(connect) plname(Non-union)}{p_end}
{phang2}{cmd:. plotmeans ttl_exp if union==1, over(age) graph(connect) plname(Union)}{p_end}

{marker plot_multi_graph}{...}
    {hline}
    Combine multiple graphs from the {bf:plot suite}:

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}
{phang2}{cmd:. plottabs, over(age) graph(bar) plname(Frequencies) color(green%15) }{p_end}
{phang2}{cmd:. plotmeans ttl_exp, over(age) graph(connect) plname(Yrs of Exp) yaxis(2)}{p_end}

    {hline}
    Customize line color, CI color & CI transparency:

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}
{phang2}{cmd:. plotmeans ttl_exp, over(age) color(green) ci(, color(gold%35))}{p_end}

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
 