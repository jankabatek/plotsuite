{smcl}
{* *! version 1.1  21sep2022}{...} 
{vieweralsosee "plottabs" "help plottabs"}{...}
{vieweralsosee "plotmeans" "help plotmeans"}{...}
{vieweralsosee "plotshares" "help plotshares"}{...}
{vieweralsosee "plotbetas" "help plotbetas"}{...}
{vieweralsosee "twoway" "help twoway"}{...}
{viewerjumpto "Syntax" "plottabs##syntax"}{...}
{viewerjumpto "Description" "plottabs##description"}{...} 
{viewerjumpto "Examples" "plottabs##examples"}{...}
{viewerjumpto "Frames" "plottabs##frames"}{...}
{viewerjumpto "Contact" "plottabs##contact"}{...}
{title:Title}

{phang}
{bf:plottabs} {hline 2} Plot conditional frequencies or shares (a visual analog of {it:{help tabulate oneway}}) 


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:plott:abs} {it:{help varname}} {ifin}
[{it:{help plottabs##weight:weight}}]
[, options]

{p 8 17 2}where {it:{help varname}} is the conditioning variable. 

{synoptset 20 tabbed}{...}
{synopthdr}
{p2line}
{syntab :Basic options}
{p2col:{cmdab:ov:er(}{it:{help varname}})}an alternative way to specify the conditioning variable{p_end}
{p2col:{cmdab:out:put(}{it:output_type})}specify the {it:output_type} to be plotted:  {cmdab:fre:quency}(default)/{cmdab:sha:re}/{cmdab:cum:ulative}{p_end}
{p2col:{cmdab:gr:aph(}{it:graph_type})}specify the {it:{help twoway}} {it:graph_type}:  {bf:line}(default)/{bf:bar}/{bf:connected}/{bf:scatter}/etc.{p_end}

{syntab :Memory/data management}
{p2col:{cmdab:fr:ame(}{it:frame_name})}specify the name of the {it:{help frame}} that stores the plot data ({bf:frame_pt} is the default){p_end}
{p2col:{cmdab:cl:ear}}clear all plot data stored in {it:frame_name}{p_end}
{p2col:{cmdab:rep:lace(}{it:#}{cmd:)}}replace data and/or options for plot # in {it:frame_name}{p_end}
{p2col:{cmdab:plot:only}}display the plots already stored in the {it:frame_name}{p_end}

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
{it:{help varname}} needs to be specified (one way or the other) to produce a new plot. It does not need to be specified when displaying plots that are already stored in the memory (using the option {cmdab:plot:only})..{p_end}
{marker weight}{...}
{p 4 6 2}
{opt fweight}s, {opt aweight}s, and {opt iweight}s are allowed;
see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{bf:plottabs} is a command that visualizes conditional frequencies and shares (i.e., the output of {it:{help tabulate oneway}} commands). 

{pstd}
By default, {bf:plottabs} produces frequencies of observations conditional on the unique values of {it:{help varname}}.
Setting the {it:output_type} to {cmdab:sha:re} produces relative shares, and {cmdab:cum:ulative} produces cumulative shares instead.  

{pstd}
{bf:plottabs} avoids time-consuming memory operations performed by native graphing commands. By leveraging the data {it:{help frame}} environment, it proves extremely fast in large datasets (up to {bf:300-times faster} than native commands).
 
{pstd}
{bf:plottabs} can be called sequentially. The plotted data is stored in a dedicated data frame (see {it:Memory/data management options}), which allows users to create complex visualizations that combine multiple conditional plots. 
{bf:plottabs} can be also combined with other commands from the {bf:plot suite} ({it:{help plotmeans}}, {it:{help plotbetas}}, and {it:{help plotshares}}).

{pstd}
{bf:Customization}: you can select your preferred {it:{help twoway}} {it:graph_type}, graph {it:{help scheme}}, and adjust it further using the {it:{help twoway_options}} and other options specific to the given {it:graph_type}.

{marker examples}{...}
{title:Examples}

    Basic use:

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. plottabs mpg, graph(bar)}{p_end}

    {hline}
    Compare cumulative shares of two groups:
 
{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. plottabs mpg if foreign == 0, output(cumulative) connect(stairstep) plname(Domestic)}{p_end}
{phang2}{cmd:. plottabs mpg if foreign == 1, output(cumulative) connect(stairstep) plname(Foreign)}{p_end}

    {hline}
    Combine two {it:output_types} in a graph with a custom {it:{help scheme}}:
 
{phang2}{cmd:. ssc install schemepack}{p_end}
{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. plottabs mpg, graph(bar)}{p_end}
{phang2}{cmd:. plottabs mpg, output(cumulative) connect(stairstep) legend(off) scheme(gg_tableau) yaxis(2)}{p_end}

    {hline}
    Combine multiple graphs from the {bf:plot suite}:

{phang2}{help plotmeans##plot_multi_graph:See plotmeans / Combine multiple graphs from the plot suite}{p_end}

{marker plot_data_management}{...}
    {hline}
    Plot data management:
	
{phang2}* generate two plots but suppress their display:{p_end}
{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. plottabs mpg if foreign == 0, nodraw plname(Domestic)}{p_end}
{phang2}{cmd:. plottabs mpg if foreign == 1, nodraw plname(Foreign)}{p_end}
	
{phang2}* display the two plots:{p_end}
{phang2}{cmd:. plottabs, plotonly}{p_end}

{phang2}* replace the second plot by another one:{p_end}
{phang2}{cmd:. plottabs mpg if headroom>3, replace(2)}{p_end}

{phang2}* adjust the customization options of the second plot:{p_end}
{phang2}{cmd:. plottabs, plotonly replace(2) color(pink) plname("Headroom > 3")}{p_end}

{phang2}* do the last two steps with one command:{p_end}
{phang2}{cmd:. plottabs mpg if headroom>3, rep(2) col(pink) pln("Headroom > 3")}{p_end}

{phang2}* clear the plot data from memory and create a new plot:{p_end}
{phang2}{cmd:. plottabs mpg, clear graph(bar)}{p_end}

{phang2}* create a separate plot (stored in a separate frame):{p_end}
{phang2}{cmd:. plottabs turn, graph(bar) frame(frame_hr)}{p_end}

{phang2}* name and display each of the two plots (stored in separate frames):{p_end}
{phang2}{cmd:. plottabs, plotonly name(fig1)}{p_end}
{phang2}{cmd:. plottabs, plotonly name(fig2) frame(frame_hr)}{p_end}

{marker frames}{...}
{title:Frames}

{pstd}
Plotted data are stored in a dedicated {it:{help frame}}. The default name of this frame is {it:frame_pt}, but other names can be specified using the option {cmdab:fr:ame(}{it:frame_name}).
To access the plotted data, switch to the respective frame:

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. plottabs mpg if foreign==0, out(cum) connect(stairstep) pln(Domestic)}{p_end}
{phang2}{cmd:. plottabs mpg if foreign==1, out(cum) connect(stairstep) pln(Foreign) scheme(economist)}{p_end}

{phang2}{cmd:. frame change frame_pt}{p_end}
{phang2}{cmd:. browse}{p_end}

{pstd}
The customization options are stored in a separate frame ({it:frame_name}_cust):

{phang2}{cmd:. frame change frame_pt_cust}{p_end}
{phang2}{cmd:. describe}{p_end}
{phang2}{cmd:. browse}{p_end}

{pstd}
To switch back to the default frame and plot more data:

{phang2}{cmd:. frame change default}{p_end}

{pstd}
Note that, once specified, the custom {it:frame_name} needs to be repeated every time you want to add data to the {it:frame_name}.
If no {it:frame_name} is specified, {bf:plottabs} will add the data to the default frame ({it:frame_pt}) instead.

{phang2}{cmd:. plottabs mpg if rep78 == 3, graph(bar) pln(rep78=3) frame(fr_2)}{p_end}
{phang2}{cmd:. plottabs mpg if rep78 == 4, graph(bar) pln(rep78=4)}{p_end}
{phang2}{cmd:. plottabs mpg if rep78 == 5, graph(bar) pln(rep78=5) frame(fr_2)}{p_end}

{marker contact}{...}
{title:Contact}

{phang2}Jan Kabátek, The University of Melbourne{p_end}
{phang2}j.kabatek@unimelb.edu.au{p_end} 
 