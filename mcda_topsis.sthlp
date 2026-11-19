{smcl}
{* *! version 1.2.0  19nov2026}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "mcda_topsis##syntax"}{...}
{viewerjumpto "Description" "mcda_topsis##description"}{...}
{viewerjumpto "Options" "mcda_topsis##options"}{...}
{viewerjumpto "Installation" "mcda_topsis##installation"}{...}
{viewerjumpto "Examples" "mcda_topsis##examples"}{...}
{viewerjumpto "Stored results" "mcda_topsis##results"}{...}
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
Min-Max normalization is invariant to adding a constant to a criterion, so criteria with an arbitrary origin
(for example principal-component scores) can be used as they are.

{pstd}
Observations with a missing value in any criterion are excluded from the ranking; their score and rank are set
to missing and a note reports how many were excluded (see {cmd:r(N_excluded)}).

{pstd}
The rank variable assigns 1 to the highest score. Observations with tied scores share the same rank.


{marker options}{...}
{title:Options}

{phang}
{opt weights(numlist)} specifies the importance of each criterion. If {opt domains()} is not used, the number 
of weights must match the number of variables; this also holds when {opt domains()} is used, in which case the
weight provided for the first occurrence of a domain is divided equally among all variables in that domain.
Weights must be non-negative and at least one must be positive. Default is equal weights.

{phang}
{opt direction(numlist)} specifies whether a variable is a "benefit" (1) or a "cost" (-1). Higher values in 
benefit variables contribute positively to the score. Default is 1 for all variables.

{phang}
{opt domains(numlist)} assigns each variable to a domain; one domain ID per variable.

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


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:mcda_topsis} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations ranked{p_end}
{synopt:{cmd:r(N_excluded)}}number of observations excluded because of missing criteria{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(weights)}}weights used (after any domain splitting){p_end}
{synopt:{cmd:r(direction)}}directions used{p_end}


{title:Author}
{pstd}Emanuele Clemente

{title:License}
{pstd}MIT License
