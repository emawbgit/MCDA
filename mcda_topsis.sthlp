{smcl}
{* *! version 1.1.0  22may2024}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "mcda_topsis##syntax"}{...}
{viewerjumpto "Description" "mcda_topsis##description"}{...}
{viewerjumpto "Options" "mcda_topsis##options"}{...}
{viewerjumpto "Installation" "mcda_topsis##installation"}{...}
{viewerjumpto "Examples" "mcda_topsis##examples"}{...}
{title:Title}

{phang}
{bf:mcda_topsis} {hline 2} Multi-Criteria Decision Analysis using TOPSIS method


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:mcda_topsis} {varlist} {ifin} [{cmd:,} {it:options}]


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt w:eights(numlist)}}specify weights for each variable{p_end}
{synopt:{opt d:irection(numlist)}}specify direction for each variable (1 for benefit, -1 for cost){p_end}
{synopt:{opt dom:ains(numlist)}}specify domain IDs for variables to split weights across domains{p_end}
{synopt:{opt gen:erate(names)}}specify names for the generated score and rank variables; default is {it:topsis_score} and {it:topsis_rank}{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:mcda_topsis} implements the Technique for Order of Preference by Similarity to Ideal Solution (TOPSIS). 
It ranks alternatives (observations) based on their geometric distance from the positive ideal solution (PIS) 
and the negative ideal solution (NIS).

{pstd}
The command uses Min-Max normalization to bring all criteria to a 0-1 scale. Benefit criteria (direction 1) 
are normalized as (x - min) / (max - min), while cost criteria (direction -1) are normalized as (max - x) / (max - min).


{marker options}{...}
{title:Options}

{phang}
{opt weights(numlist)} specifies the importance of each criterion. If {opt domains()} is not used, the number 
of weights must match the number of variables. If {opt domains()} is used, the weight provided for the first 
occurrence of a domain is divided equally among all variables in that domain.

{phang}
{opt direction(numlist)} specifies whether a variable is a "benefit" (1) or a "cost" (-1). Higher values in 
benefit variables contribute positively to the score.

{phang}
{opt generate(score_var rank_var)} allows the user to name the output variables.


{marker installation}{...}
{title:Installation}

{pstd}
To install via GitHub:

{phang2}{cmd:. net install github, from("https://haghish.github.io/github/")}{p_end}
{phang2}{cmd:. github install emawbgit/MCDA}{p_end}

{pstd}
To install via net install:

{phang2}{cmd:. net install mcda_topsis, from("https://raw.githubusercontent.com/emawbgit/MCDA/main/")}{p_end}


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto, clear}{p_end}

{pstd}Basic TOPSIS ranking{p_end}
{phang2}{cmd:. mcda_topsis mpg price weight, weights(0.4 0.3 0.3) direction(1 -1 -1)}{p_end}

{pstd}Using domains (splitting a 0.5 weight between mpg and gear_ratio){p_end}
{phang2}{cmd:. mcda_topsis mpg gear_ratio price, weights(0.5 0.5 0.5) domains(1 1 2)}{p_end}


{title:Author}
{pstd}Jules (MCDA Toolkit Development)

{title:License}
{pstd}MIT License
