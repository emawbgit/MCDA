*! version 1.4.0  23nov2026
*! Emanuele Clemente, World Bank Group, eclemente@worldbank.org
program define mcda_topsis, rclass
    version 16.0

    * Domains as parenthesised groups, optionally named: (hazard: a b c) (d e) ...
    * The group a variable sits in becomes its domain ID, so no IDs need typing
    local k 0
    while substr(strtrim(`"`0'"'), 1, 1) == "(" {
        gettoken grp 0 : 0, match(paren)
        local ++k
        local dname `k'
        if strpos(`"`grp'"', ":") {
            gettoken dname grp : grp, parse(":")
            gettoken colon grp : grp, parse(":")
            local dname = strtoname(strtrim(`"`dname'"'))
        }
        unab grp : `grp'
        local grouped `grouped' `grp'
        local domnames `domnames' `dname'
        foreach v of local grp {
            local domids `domids' `k'
        }
    }
    if (`k' > 0) local 0 `"`grouped' `0'"'

    syntax varlist(numeric) [if] [in] [, ///
        Weights(numlist) ///
        Direction(numlist integer) ///
        DOMains(numlist) /// "d" abbreviates direction() only
        DOMAINWeights(numlist) /// one weight per domain, ascending domain ID
        GENerate(string) ///
        WEIGHTSOnly /// show the weights tables and stop: a weights calculator
        FROMDIALOG /// undocumented: set by mcda_topsis.dlg so errors also pop up
    ]

    if ("`domids'" != "") {
        if ("`domains'" != "") {
            _mcda_err 198 "Give domains either as (groups) or with domains(), not both." `fromdialog'
        }
        local domains `domids'
    }
    else local domnames

    * --- Validation of criteria ---
    local dups : list dups varlist
    if ("`dups'" != "") {
        _mcda_err 198 "Each criterion may be entered only once; repeated: `: list uniq dups'." `fromdialog'
    }

    * --- Data Preparation ---
    * Rows with any missing criterion are excluded; count them so the user is told
    marksample touse, novarlist
    qui count if `touse'
    local n_all = r(N)
    markout `touse' `varlist'
    qui count if `touse'
    local n_used = r(N)
    if (`n_used' == 0) {
        _mcda_err 2000 "No observations remaining after handling missing values." `fromdialog'
    }
    local n_excl = `n_all' - `n_used'
    if (`n_excl' > 0) {
        di as text "note: `n_excl' observation(s) excluded because of missing values in the criteria;" ///
            " their score and rank are missing."
    }

    local criteria "`varlist'"

    * --- Validation and Weight Processing ---
    local n_crit : word count `criteria'

    if ("`domainweights'" != "") {
        if ("`domains'" == "") {
            _mcda_err 198 "domainweights() requires domains()." `fromdialog'
        }
        if ("`weights'" != "") {
            _mcda_err 198 "Specify either weights() or domainweights(), not both." `fromdialog'
        }
        local u_dom : list uniq domains
        local n_udom : list sizeof u_dom
        local n_dw : word count `domainweights'
        if (`n_dw' != `n_udom') {
            _mcda_err 198 "domainweights() needs one weight per domain: `n_udom' domains, `n_dw' weights." `fromdialog'
        }
        foreach x of local domainweights {
            if (`x' < 0) {
                _mcda_err 198 "Domain weights must be non-negative." `fromdialog'
            }
        }
    }
    else if ("`weights'" == "" & "`domains'" != "") {
        * Default with domains: equal domain weights summing to 1
        local u_dom : list uniq domains
        local n_udom : list sizeof u_dom
        forvalues i = 1/`n_udom' {
            local domainweights "`domainweights' `=1/`n_udom''"
        }
    }
    else if ("`weights'" == "") {
        * Default to equal weights summing to 1
        forvalues i = 1/`n_crit' {
            local weights "`weights' `=1/`n_crit''"
        }
    }

    if ("`direction'" == "") {
        local direction ""
        forvalues i = 1/`n_crit' {
            local direction "`direction' 1"
        }
    }

    local n_w : word count `weights'
    local n_d : word count `direction'
    local n_dom : word count `domains'

    * One weight per criterion also with domains(): the first weight of each domain is split
    if ("`domainweights'" == "" & `n_w' != `n_crit') {
        _mcda_err 198 "Number of weights (`n_w') does not match number of criteria (`n_crit')." `fromdialog'
    }
    if (`n_d' != `n_crit') {
        _mcda_err 198 "Number of directions (`n_d') does not match number of criteria (`n_crit')." `fromdialog'
    }
    if ("`domains'" != "" & `n_dom' != `n_crit') {
        _mcda_err 198 "Number of domain IDs (`n_dom') does not match number of criteria (`n_crit')." `fromdialog'
    }
    foreach x of local weights {
        if (`x' < 0) {
            _mcda_err 198 "Weights must be non-negative." `fromdialog'
        }
    }
    foreach x of local direction {
        if !inlist(`x', 1, -1) {
            _mcda_err 198 "Directions must be 1 (benefit) or -1 (cost)." `fromdialog'
        }
    }

    * --- Domain Weight Splitting Logic ---
    * Each domain weight is split equally among its criteria (as in a weights calculator)
    tempname domtab
    if ("`domains'" != "") {
        mata: split_domain_weights("`weights'", "`domainweights'", "`domains'", "`domnames'")
        local weights `r(weights)'
        matrix `domtab' = r(domtab)
        di _n as text "Weights by domain"
        matlist `domtab', rowtitle(Domain) format(%9.4g) lines(rowtotal)
    }

    * Weights (after domain splitting) must sum to 1; 0.01 tolerance absorbs rounded inputs
    local w_sum = 0
    foreach x of local weights {
        local w_sum = `w_sum' + `x'
    }
    if (abs(`w_sum' - 1) > 0.01) {
        _mcda_err 198 "Weights must sum to 1 (tolerance 0.01); they sum to `: di %6.4f `w_sum''." `fromdialog'
    }

    if ("`weightsonly'" != "") {
        tempname wcrit
        matrix `wcrit' = J(`n_crit', 1, .)
        forvalues i = 1/`n_crit' {
            matrix `wcrit'[`i', 1] = `: word `i' of `weights''
        }
        matrix rownames `wcrit' = `criteria'
        matrix colnames `wcrit' = Weight
        di _n as text "Weights by criterion"
        matlist `wcrit', rowtitle(Criterion) format(%9.4g)
        return scalar N = `n_used'
        return scalar N_excluded = `n_excl'
        return local weights "`weights'"
        return local direction "`direction'"
        return matrix criteria = `wcrit'
        if ("`domains'" != "") return matrix domains = `domtab'
        exit
    }

    * --- Core TOPSIS Logic (Mata) ---
    tempvar score
    qui gen double `score' = .

    mata: do_topsis("`criteria'", "`weights'", "`direction'", "`touse'", "`score'")

    * --- Output Generation ---
    local g1 : word 1 of `generate'
    local g2 : word 2 of `generate'
    if ("`g1'" == "") local g1 "topsis_score"
    if ("`g2'" == "") local g2 "topsis_rank"

    capture drop `g1'
    qui gen double `g1' = `score' if `touse'
    label variable `g1' "TOPSIS Relative Closeness Score"

    * Rank 1 = highest score; tied scores share the same (lowest) rank
    capture drop `g2'
    qui egen long `g2' = rank(`score') if `touse', field
    label variable `g2' "TOPSIS Rank"

    di as text "Generated variables: `g1', `g2'"

    * --- Display Summary ---
    di _n as text "TOPSIS Results Summary (Top 10)"
    preserve
    qui keep if `touse'
    gsort -`score'
    list `criteria' `g1' `g2' in 1/`=min(10, _N)'
    restore

    return scalar N = `n_used'
    return scalar N_excluded = `n_excl'
    return local weights "`weights'"
    return local direction "`direction'"
    if ("`domains'" != "") return matrix domains = `domtab'
end

* Error helper: message in the Results window and, from the dialog, in a pop-up box
program define _mcda_err
    args rc msg fromdialog
    di as error `"`msg'"'
    if ("`fromdialog'" != "") capture window stopbox stop `"`msg'"'
    exit `rc'
end

* --- Mata Functions ---
mata:
// Splits each domain weight equally among its criteria. Domain weights come from
// domainweights() (one per domain, ascending ID) or, if empty, from the weight of
// each domain's first criterion in weights(). Posts r(weights) and r(domtab).
void split_domain_weights(string scalar w_str, string scalar dw_str, string scalar d_str, string scalar names_str) {
    real rowvector d, u, w, dw, n, idx, final_w
    real scalar i
    string colvector rlab

    d = strtoreal(tokens(d_str))
    u = uniqrows(d')'                         // numeric order: 2 before 10
    if (dw_str != "") dw = strtoreal(tokens(dw_str))
    else {
        w = strtoreal(tokens(w_str))
        dw = J(1, cols(u), .)
    }
    n = J(1, cols(u), 0)
    final_w = J(1, cols(d), 0)
    rlab = J(cols(u) + 1, 1, "Total")

    for (i=1; i<=cols(u); i++) {
        idx = selectindex(d :== u[i])
        n[i] = cols(idx)
        if (dw_str == "") dw[i] = w[idx[1]]
        final_w[idx] = J(1, n[i], dw[i] / n[i])
        rlab[i] = (names_str != "" ? tokens(names_str)[i] : strofreal(u[i]))
    }

    st_rclear()
    st_global("r(weights)", invtokens(strofreal(final_w, "%21.0g")))
    st_matrix("r(domtab)", ((dw', n', (dw :/ n)') \ (sum(dw), sum(n), sum(dw))))
    st_matrixrowstripe("r(domtab)", (J(rows(rlab), 1, ""), rlab))
    st_matrixcolstripe("r(domtab)", (J(3, 1, ""), ("Domain_weight" \ "N_indicators" \ "Weight_per_indicator")))
}

void do_topsis(string scalar varlist, string scalar weight_str, string scalar dir_str, string scalar touse, string scalar scorevar) {
    real matrix X, Y
    real rowvector w, directions, max_x, min_x, pis, nis
    real colvector d_plus, d_minus, score
    real scalar i, j, range

    X = st_data(., varlist, touse)
    w = strtoreal(tokens(weight_str))
    directions = strtoreal(tokens(dir_str))

    // Normalize (Min-Max)
    max_x = colmax(X)
    min_x = colmin(X)

    Y = J(rows(X), cols(X), .)
    for (j=1; j<=cols(X); j++) {
        range = max_x[j] - min_x[j]
        if (range == 0) {
            Y[., j] = J(rows(X), 1, 0)
        }
        else {
            if (directions[j] == 1) {
                Y[., j] = (X[., j] :- min_x[j]) / range
            }
            else {
                Y[., j] = (max_x[j] :- X[., j]) / range
            }
        }
    }

    // Weighting
    Y = Y * diag(w)

    // Ideal Solutions
    pis = colmax(Y)
    nis = colmin(Y)

    // Distances
    d_plus = sqrt(rowsum((Y :- pis):^2))
    d_minus = sqrt(rowsum((Y :- nis):^2))

    // Relative Closeness
    score = d_minus :/ (d_plus + d_minus)

    // Fix cases where denominator is zero
    for (i=1; i<=rows(score); i++) {
        if ( (d_plus[i] + d_minus[i]) == 0 ) score[i] = 0
    }

    st_store(., scorevar, touse, score)
}
end
