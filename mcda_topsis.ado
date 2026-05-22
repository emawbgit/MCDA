*! version 1.1.0  22may2024
program define mcda_topsis, rclass
    version 16.0

    syntax varlist(numeric) [if] [in] [, ///
        Weights(numlist) ///
        Direction(numlist) ///
        Domains(numlist) ///
        GENerate(string) ///
    ]

    * --- Data Preparation ---
    marksample touse
    markout `touse' `varlist'
    
    qui count if `touse'
    if (r(N) == 0) {
        di as error "No observations remaining after handling missing values."
        exit 2000
    }

    local criteria "`varlist'"

    * --- Validation and Weight Processing ---
    local n_crit : word count `criteria'
    
    if ("`weights'" == "") {
        * Default to equal weights
        local weights ""
        forvalues i = 1/`n_crit' {
            local weights "`weights' 1"
        }
    }
    
    local n_w : word count `weights'
    local n_d : word count `direction'
    
    if (`n_w' != `n_crit') & ("`domains'" == "") {
        di as error "Number of weights (`n_w') does not match number of criteria (`n_crit')."
        exit 198
    }
    
    if (`n_d' != `n_crit') & ("`direction'" != "") {
        di as error "Number of directions (`n_d') does not match number of criteria (`n_crit')."
        exit 198
    }
    
    if ("`direction'" == "") {
        local direction ""
        forvalues i = 1/`n_crit' {
            local direction "`direction' 1"
        }
    }

    * --- Domain Weight Splitting Logic ---
    if ("`domains'" != "") {
        * If domains are provided, we need to adjust weights
        mata: split_domain_weights("`weights'", "`domains'", "`criteria'")
        local weights `r(weights)'
    }

    * --- Core TOPSIS Logic (Mata) ---
    tempvar score
    qui gen double `score' = .
    
    mata: do_topsis("`criteria'", "`weights'", "`direction'", "`touse'", "`score'")

    * --- Output Generation ---
    if ("`generate'" != "") {
        local g1 : word 1 of `generate'
        local g2 : word 2 of `generate'
        
        if ("`g1'" == "") local g1 "topsis_score"
        if ("`g2'" == "") local g2 "topsis_rank"
        
        capture drop `g1'
        qui gen double `g1' = `score' if `touse'
        label variable `g1' "TOPSIS Relative Closeness Score"
        
        capture drop `g2'
        qui egen long `g2' = rank(-`score') if `touse', unique
        label variable `g2' "TOPSIS Rank"
        
        di as text "Generated variables: `g1', `g2'"
    }
    else {
        capture drop topsis_score
        qui gen double topsis_score = `score' if `touse'
        label variable topsis_score "TOPSIS Relative Closeness Score"
        
        capture drop topsis_rank
        qui egen long topsis_rank = rank(-topsis_score) if `touse', unique
        label variable topsis_rank "TOPSIS Rank"
        
        di as text "Generated variables: topsis_score, topsis_rank"
    }

    * --- Display Summary ---
    di _n as text "TOPSIS Results Summary (Top 10)"
    preserve
    qui keep if `touse'
    gsort -`score'
    if ("`generate'" != "") {
        list `criteria' `g1' `g2' in 1/10
    }
    else {
        list `criteria' topsis_score topsis_rank in 1/10
    }
    restore

end

* --- Mata Functions ---
mata:
void split_domain_weights(string scalar w_str, string scalar d_str, string scalar c_str) {
    real rowvector w
    string rowvector doms, unique_doms
    real scalar i, j, p, count, dom_w
    real rowvector idx, final_w
    string scalar cur_dom
    
    w = strtoreal(tokens(w_str))
    doms = tokens(d_str)
    unique_doms = uniqrows(doms')'
    
    final_w = J(1, cols(doms), 0)
    
    for (i=1; i<=cols(unique_doms); i++) {
        cur_dom = unique_doms[i]
        
        idx = (doms :== cur_dom)
        count = sum(idx)
        
        p = selectindex(idx)[1]
        dom_w = w[p]
        
        for (j=1; j<=cols(doms); j++) {
            if (doms[j] == cur_dom) {
                final_w[j] = dom_w / count
            }
        }
    }
    
    st_rclear()
    st_global("r(weights)", invtokens(stroreal(final_w)))
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
