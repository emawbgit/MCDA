{smcl}
{* *! version 1.4.0  23nov2026}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "mcda_topsis##syntax"}{...}
{viewerjumpto "Description" "mcda_topsis##description"}{...}
{viewerjumpto "Options" "mcda_topsis##options"}{...}
{viewerjumpto "Dialog box" "mcda_topsis##dialog"}{...}
{viewerjumpto "Installation" "mcda_topsis##installation"}{...}
{viewerjumpto "Examples" "mcda_topsis##examples"}{...}
{viewerjumpto "Stored results" "mcda_topsis##results"}{...}
{viewerjumpto "Author" "mcda_topsis##author"}{...}
{title:Title}

{phang}
{bf:mcda_topsis} {hline 2} Multi-Criteria Decision Analysis using TOPSIS method


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:mcda_topsis} {varlist} {ifin} [{cmd:,} {it:options}]

{pstd}Domains as groups (weights calculator):{p_end}

{p 8 17 2}
{cmd:mcda_topsis} {cmd:(}[{it:name}{cmd::}] {varlist}{cmd:)} [{cmd:(}[{it:name}{cmd::}] {varlist}{cmd:)} ...] {ifin}
[{cmd:,} {opt domainw:eights(numlist)} {it:options}]


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt w:eights(numlist)}}specify weights for each variable{p_end}
{synopt:{opt d:irection(numlist)}}specify direction for each variable (1 for benefit, -1 for cost){p_end}
{synopt:{opt dom:ains(numlist)}}domain ID of each variable{p_end}
{synopt:{opt domainw:eights(numlist)}}one weight per domain, split equally among its variables{p_end}
{synopt:{opt weightso:nly}}show the weights tables and stop, without scoring (weights calculator){p_end}
{synopt:{opt gen:erate(names)}}specify names for the generated score and rank variables; default is {it:topsis_score} and {it:topsis_rank}{p_end}
{synoptline}

{pstd}
Dialog box: type {cmd:db mcda_topsis} (see {help mcda_topsis##dialog:Dialog box}).


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

{pstd}
Each criterion may appear only once in {varlist}; a repeated variable (also through abbreviations) is an error.


{marker options}{...}
{title:Options}

{phang}
{opt weights(numlist)} specifies the importance of each criterion, one weight per variable in {varlist} order.
Weights must be non-negative and must sum to 1; a tolerance of 0.01 absorbs rounded inputs (for example,
weights typed with three decimals). Default is equal weights, 1/k for k criteria. With {opt domains()}, see below.

{phang}
{opt direction(numlist)} specifies whether a variable is a "benefit" (1) or a "cost" (-1). Higher values in 
benefit variables contribute positively to the score. Default is 1 for all variables.

{phang}
{opt domains(numlist)} assigns each variable to a domain, one domain ID per variable. Each domain weight is
divided equally among the variables of that domain, so a domain counts the same whatever its number of
indicators. A table of domain weight, number of indicators and weight per indicator is displayed and stored
in {cmd:r(domains)}. The domain weights come from {opt domainweights()}; if it is omitted, from the weight of
the first variable of each domain in {opt weights()}; if both are omitted, all domains get equal weight.

{phang}
{opt domainweights(numlist)} gives one weight per domain, in ascending order of domain ID; requires
{opt domains()} and cannot be combined with {opt weights()}. Domain weights must sum to 1 (tolerance 0.01).

{phang}
{opt generate(score_var rank_var)} allows the user to name the output variables.

{phang}
{opt weightsonly} computes and displays the weights (by domain and by criterion) and stops: no score or rank
is generated. Use it as a weights calculator before running the ranking; results are in {cmd:r(domains)}
and {cmd:r(criteria)}.


{marker groups}{...}
{title:Domains as groups}

{pstd}
Instead of typing a domain ID for every variable, list each domain's variables in parentheses, optionally
preceded by a name and a colon. The variables of the first group form domain 1, the second domain 2, and so on;
{opt domainweights()} then takes one weight per group, in the same order. Each domain weight is divided by the
number of variables in the group, so every indicator of a domain gets the same weight, as in a weights
calculator spreadsheet (domain weight / number of indicators). The weights table is labelled with the group
names. Groups and {opt domains()} cannot be combined.

{phang2}{cmd:. mcda_topsis (fuel: mpg gear_ratio) (cost: price weight), domainweights(.6 .4) direction(1 1 -1 -1)}{p_end}


{marker dialog}{...}
{title:Dialog box}

{pstd}
{cmd:db mcda_topsis} opens a point-and-click dialog. Each row holds one criterion: pick the variable
from the drop-down list, type its weight and tick {bf:Cost} when higher values should lower the score
(direction -1; unticked rows are benefits, direction 1). Empty rows are skipped, so rows 1 to 20 can be
filled in any number. To weight by domain, type a domain ID in each row's {bf:Domain} field and the weight
of each domain in the {bf:Domain 1} to {bf:Domain 8} fields on the {bf:Options} tab; row weights are then not
needed. {bf:Preview weights} shows the resulting weights tables in the Results window without running the
ranking, so you can adjust them as in a weights calculator. Each variable may be used once and the weights must sum to 1; these rules are checked
when you click {bf:OK} or {bf:Submit}, and a violation is shown in an error window (use {bf:Submit} to keep the
dialog open while fixing it). The {bf:Options} tab takes an {cmd:if} restriction, the domain weights and the names of the
generated variables. {bf:Submit} runs the command and keeps the dialog open; the copy button puts the
command on the clipboard so it can be pasted into a do-file.

{pstd}
To add the dialog to the {bf:User > Statistics} menu, put these lines in your {help profile} do-file:

{phang2}{cmd:. window menu append item "stUserStatistics" "MCDA: TOPSIS ranking" "db mcda_topsis"}{p_end}
{phang2}{cmd:. window menu refresh}{p_end}


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

{pstd}Domain weights (0.6 for domain 1 = mpg, gear_ratio; 0.4 for domain 2 = price, weight){p_end}
{phang2}{cmd:. mcda_topsis mpg gear_ratio price weight, domains(1 1 2 2) domainweights(0.6 0.4) direction(1 1 -1 -1)}{p_end}
{phang2}{cmd:. matlist r(domains)}{p_end}

{pstd}Same, with named groups; first preview the weights, then rank{p_end}
{phang2}{cmd:. mcda_topsis (fuel: mpg gear_ratio) (cost: price weight), domainweights(.6 .4) weightsonly}{p_end}
{phang2}{cmd:. mcda_topsis (fuel: mpg gear_ratio) (cost: price weight), domainweights(.6 .4) direction(1 1 -1 -1)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:mcda_topsis} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations ranked{p_end}
{synopt:{cmd:r(N_excluded)}}number of observations excluded because of missing criteria{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(domains)}}domain weight, number of indicators and weight per indicator, by domain (with domains){p_end}
{synopt:{cmd:r(criteria)}}weight of each criterion (with {opt weightsonly}){p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(weights)}}weights used (after any domain splitting){p_end}
{synopt:{cmd:r(direction)}}directions used{p_end}


{marker author}{...}
{title:Author}

{pstd}
Emanuele Clemente{break}
World Bank Group{break}
{browse "mailto:eclemente@worldbank.org":eclemente@worldbank.org}

{pstd}
Bug reports and suggestions: {browse "https://github.com/emawbgit/MCDA/issues":github.com/emawbgit/MCDA/issues}

{title:License}
{pstd}MIT License
