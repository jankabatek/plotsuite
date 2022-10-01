{smcl}
{* *! version 1.1  21sep2022}{...} 
{vieweralsosee "plottabs" "help plottabs"}{...}
{vieweralsosee "plotmeans" "help plotmeans"}{...}
{vieweralsosee "plotshares" "help plotshares"}{...}
{vieweralsosee "plotbetas" "help plotbetas"}{...}
{vieweralsosee "twoway" "help twoway"}{...}
{viewerjumpto "Syntax" "plotshares##syntax"}{...}
{viewerjumpto "Description" "plotshares##description"}{...} 
{viewerjumpto "Examples" "plotshares##examples"}{...}
{viewerjumpto "Contact" "plotshares##contact"}{...}
{title:Title}

{phang}
{bf:plotshares} {hline 2} Plot conditional shares (a visual analog of {it:{help tabulate twoway}})


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:plots:hares} {it:{help varname}} {ifin}
, over({it:{help groupvar}}) [options]

{p 8 8 2}where {it:{help varname}} is the (categorical) outcome variable and {it:{help groupvar}} is the conditioning variable 

{synoptset 20 tabbed}{...}
{synopthdr}
{p2line}
{syntab :Basic options}
{p2col:{cmdab:ov:er(}{it:{help groupvar}})}specify the conditioning variable{p_end}
{p2col:{cmdab:out:put(}{it:output_type})}specify the {it:output_type} to be plotted: {cmdab:sha:re}(default)/{cmdab:fre:quency}{p_end}
{p2col:{cmdab:gr:aph(}{it:graph_type})}specify the {it:{help twoway}} {it:graph_type}:  {bf:area}(default)/{bf:bar}/{bf:line}/etc.{p_end}
{p2col:{cmdab:inv:ert}}invert the order of stacked categories on the y-axis {it:frame_name}{p_end}
{p2col:{cmdab:nos:tack}}do not use stacked output presentation (i.e., each share/frequency category is measured from zero, and the default {it:graph_type} is set to {bf:line}){p_end}

{syntab :Memory/data management}
{p2col:{cmdab:fr:ame(}{it:frame_name})}specify the name of the {it:{help frame}} that stores the plot data ({bf:frame_pt} is the default {it:frame_name}){p_end}
{p2col:{cmdab:cl:ear}}clear all plot data stored in {it:frame_name}{p_end}
{p2col:{cmdab:rep:lace(}{it:#}{cmd:)}}replace data and/or options for plot # in {it:frame_name}{p_end}
{p2col:{cmdab:plot:only}}display the plots already stored in {it:frame_name}{p_end}

{syntab :Plot customization}
{p2col:{cmdab:com:mand}}print out the {it:{help twoway}} command used to display the chart (useful for finer customization){p_end}
{p2col:{cmdab:gl:obal}}apply the same customization options to all plots in {it:frame_name}{p_end}
{p2col:{cmdab:pln:ame(}{it:plot_name})}name the current plot (used in legends when displaying multiple plots at once){p_end}
{p2col:{cmdab:yz:ero}}a shorthand option for displaying zero on the y-axis (and scaling ylabels accordingly){p_end}
{p2col:{it:{help twoway_options}}}change titles, legends, axes, aspect ratio, etc.{p_end}
{p2col:{it:{help area_options}}}change look of area plots{p_end}
INCLUDE help gr_baropt

{syntab :Other options}
{p2col:{cmdab:nod:raw}}do not display the plotted values (useful when looping/overlaying many intermediate plots){p_end}
{p2col:{cmdab:tim:es(}{it:real})}multiply the plotted values by a constant{p_end}
{p2line}
{p2colreset}{...}
{p 4 6 2}
{it:{help varname}} and over({it:{help groupvar}}) need to be specified to produce a new plot. They do not need to be specified when displaying plots that are already stored in the memory (using the option {cmdab:plot:only}).


{marker description}{...}
{title:Description}

{pstd}
{bf:plotshares} is a command that visualizes conditional shares and frequencies of categorical variables ({it:i.e.}, the output of {it:{help tabulate twoway}} commands).

{pstd}
By default, {bf:plotshares} produces relative shares of {it:{help varname}} categories, conditional on the unique values of {it:{help groupvar}} (with the shares summing up to 1). 
Setting {it:output_type} to {cmdab:fre:quencies} produces frequencies of {it:{help varname}} instead. By default, {bf:plotshares} uses stacked presentation of the output categories. Option {cmdab:nos:tack} produces non-stacked shares/frequencies, instead.    

{pstd}
{bf:plotshares} avoids time-consuming memory operations performed by native graphing commands.
By leveraging the data {it:{help frame}} environment, it proves extremely fast in very large datasets.
 
{pstd}
{bf:plotshares} can be called sequentially. The plotted data is stored in a dedicated data frame (see {it:Memory/data management options}), which allows users to create complex visualizations that combine multiple conditional plots.
{bf:plotshares} can be also combined with other commands from the {bf:plot suite} ({it:{help plottabs}}, {it:{help plotbetas}}, and {it:{help plotmeans}}).

{pstd}
{bf:Customization:} conditional plots can be customized by selecting your preferred {it:{help twoway}} {it:graph_type}, and adjusting it further using the {it:{help twoway_options}} and other options specific to the given {it:graph_type}.

{pstd}
{bf:NOTE}: Some options (such as area/bar color adjustments) can only be adjusted outside the {bf:plotshares} environment. 
To change the area/bar colors, print out the {it:{help twoway}} command that displays the chart (use the option {cmdab:com:mand}),
add the custom colors to the respective sub-graph options, and parse the adjusted {it:{help twoway}} command directly. Direct {it:{help twoway}} parsing is as fast as {bf:plotshares}, {cmdab:plot:only}. 

{marker examples}{...}
{title:Examples}

    Basic use:

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}
{phang2}{cmd:}{it:* stacked shares:}{p_end}
{phang2}{cmd:. plotshares race, over(age)}{p_end}
{phang2}{cmd:}{it:* non-stacked shares (in a new graph):}{p_end}
{phang2}{cmd:. plotshares race, over(age) nostack clear}{p_end}

    {hline}
    Plot stacked frequencies instead:

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}
{phang2}{cmd:. plotshares race, over(age) output(frequency) graph(bar)}{p_end}

    {hline}
    Flip the ordering, use a custom scheme, and combine with a {it:{help plotmeans}} graph:
	
{phang2}{cmd:. ssc install schemepack}{p_end}
{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}
{phang2}{cmd:. plots race, over(age) invert}{p_end}
{phang2}{cmd:. plotm ttl_, over(age) graph(connect) plname(Yrs of Exp) scheme(white_ptol) color(red) yaxis(2) yzero}{p_end}

{marker frames}{...}
{title:Frames}

{pstd}
{help plottabs##frames:See plottabs / Frames}

{marker contact}{...}
{title:Contact}

{phang2}Jan Kabátek, The University of Melbourne{p_end}
{phang2}j.kabatek@unimelb.edu.au{p_end} 
 