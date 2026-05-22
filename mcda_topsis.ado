*! version 1.0.0  22may2024
program define mcda_topsis, rclass
    version 16.0

    syntax [varlist(numeric default=none)] [using/] [if] [in] [, ///
        Weights(numlist) ///
        Direction(numlist) ///
        Domains(numlist) ///
        GENerate(string) ///
        Export_template(string) ///
        REPlace ///
    ]

    * --- Export Template Mode ---
    if "`export_template'" != "" {
        export_template `varlist', file("`export_template'") `replace'
        exit
    }

    * --- Data Preparation ---
    marksample touse

    tempname W_mat D_mat
    local criteria ""
    
    * --- Handle Excel Template Ingestion ---
    if "`using'" != "" {
        preserve
        qui import excel "`using'", firstrow clear
        
        * Validate columns: variable, weight, direction
        foreach col in variable weight direction {
            capture confirm variable `col'
            if _rc {
                di as error "Excel template must contain a '`col'' column."
                exit 198
            }
        }
        
        * Check for 'active' column if it exists
        capture confirm variable active
        if !_rc {
            qui keep if active == 1 | active == "1" | lower(active) == "yes"
        }
        
        * Get criteria and weights into locals before restoring
        local count = _N
        forvalues i = 1/`count' {
            local v_`i' = variable[`i']
            local w_`i' = weight[`i']
            local d_`i' = direction[`i']
            
            capture confirm variable domain
            if !_rc {
                local dom_`i' = domain[`i']
            }
            else {
                local dom_`i' ""
            }
        }
        
        restore
        
        local criteria_list ""
        local w_list ""
        local dir_list ""
        local dom_list ""
        local has_domains 0
        
        forvalues i = 1/`count' {
            local v `v_`i''
            capture confirm variable `v'
            if _rc {
                di as error "Variable '`v'' specified in Excel not found in dataset."
                exit 111
            }
            
            local criteria_list "`criteria_list' `v'"
            local w_list "`w_list' `w_`i''"
            local dir_list "`dir_list' `d_`i''"
            local dom_list "`dom_list' `dom_`i''"
            if "`dom_`i''" != "" local has_domains 1
        }
        
        local criteria "`criteria_list'"
        local weights "`w_list'"
        local direction "`dir_list'"
        if `has_domains' local domains "`dom_list'"
    }
    else {
        local criteria "`varlist'"
        if "`criteria'" == "" {
            di as error "Criteria variables must be specified."
            exit 198
        }
    }

    * --- Validation and Weight Processing ---
    local n_crit : word count `criteria'
    
    if "`weights'" == "" {
        * Default to equal weights
        forvalues i = 1/`n_crit' {
            local weights "`weights' 1"
        }
    }
    
    local n_w : word count `weights'
    local n_d : word count `direction'
    
    if `n_w' != `n_crit' && "`using'" == "" && "`domains'" == "" {
        di as error "Number of weights must match number of variables."
        exit 198
    }
    
    if `n_d' != `n_crit' && "`direction'" != "" {
        di as error "Number of directions must match number of variables."
        exit 198
    }
    
    if "`direction'" == "" {
        forvalues i = 1/`n_crit' {
            local direction "`direction' 1"
        }
    }

    * --- Domain Weight Splitting Logic ---
    if "`domains'" != "" {
        * If domains are provided, we need to adjust weights
        mata: split_domain_weights("`weights'", "`domains'", "`criteria'")
        local weights `r(weights)'
    }

    * --- Core TOPSIS Logic (Mata) ---
    tempvar score
    qui gen double `score' = .
    
    mata: do_topsis("`criteria'", "`weights'", "`direction'", "`touse'", "`score'")

    * --- Output Generation ---
    if "`generate'" != "" {
        local g1 : word 1 of `generate'
        local g2 : word 2 of `generate'
        
        if "`g1'" == "" local g1 "topsis_score"
        if "`g2'" == "" local g2 "topsis_rank"
        
        qui gen double `g1' = `score' if `touse'
        label variable `g1' "TOPSIS Relative Closeness Score"
        
        qui egen long `g2' = rank(-`score') if `touse', unique
        label variable `g2' "TOPSIS Rank"
        
        di as text "Generated variables: `g1', `g2'"
    }
    else {
        qui gen double topsis_score = `score' if `touse'
        label variable topsis_score "TOPSIS Relative Closeness Score"
        
        qui egen long topsis_rank = rank(-topsis_score) if `touse', unique
        label variable topsis_rank "TOPSIS Rank"
        
        di as text "Generated variables: topsis_score, topsis_rank"
    }

    * --- Display Summary ---
    di _n as text "TOPSIS Results Summary (Top 10)"
    gsort -`score'
    list `criteria' topsis_score topsis_rank in 1/10 if `touse'

end

* --- Helper Program: Export Template ---
program define export_template
    syntax [varlist(numeric)] , file(string) [replace]
    
    preserve
    if "`varlist'" == "" {
        unab varlist : _all
        local numeric_vars ""
        foreach v of local varlist {
            capture confirm numeric variable `v'
            if !_rc {
                local numeric_vars "`numeric_vars' `v'"
            }
        }
        local varlist "`numeric_vars'"
    }
    
    clear
    local n : word count `varlist'
    set obs `n'
    gen variable = ""
    gen weight = 1
    gen direction = 1
    gen domain = ""
    gen active = 1
    
    forvalues i = 1/`n' {
        replace variable = "`: word `i' of `varlist''" in `i'
    }
    
    export excel using "`file'", firstrow(variables) `replace'
    di as text "Template exported to `file'"
    restore
end

* --- Mata Functions ---
mata:
void split_domain_weights(string scalar w_str, string scalar d_str, string scalar c_str) {
    real rowvector w, d_counts
    string rowvector doms, unique_doms
    
    w = strtoreal(tokens(w_str))
    doms = tokens(d_str)
    unique_doms = uniqrows(doms')'
    
    real rowvector final_w
    final_w = J(1, cols(doms), 0)
    
    for (i=1; i<=cols(unique_doms); i++) {
        string scalar cur_dom
        cur_dom = unique_doms[i]
        
        real rowvector idx
        idx = (doms :== cur_dom)
        
        real scalar count
        count = sum(idx)
        
        * Find the weight assigned to this domain 
        * (Taking the weight from the first occurrence in the input)
        real scalar dom_w
        pointer scalar p
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
    real matrix X, W, Y
    real rowvector w, directions, max_x, min_x
    real colvector d_plus, d_minus, score
    
    X = st_data(., varlist, touse)
    w = strtoreal(tokens(weight_str))
    directions = strtoreal(tokens(dir_str))
    
    * Normalize (Min-Max)
    max_x = colmax(X)
    min_x = colmin(X)
    
    Y = J(rows(X), cols(X), .)
    for (j=1; j<=cols(X); j++) {
        real scalar range
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
    
    * Weighting
    Y = Y * diag(w)
    
    * Ideal Solutions
    * Since we already adjusted for direction in normalization (cost becomes benefit),
    * the PIS is now always the max of the normalized matrix and NIS is min.
    real rowvector pis, nis
    pis = colmax(Y)
    nis = colmin(Y)
    
    * Distances
    d_plus = sqrt(rowsum((Y :- pis):^2))
    d_minus = sqrt(rowsum((Y :- nis):^2))
    
    * Relative Closeness
    score = d_minus :/ (d_plus + d_minus)
    
    * Fix cases where denominator is zero (all distances zero)
    for (i=1; i<=rows(score); i++) {
        if ( (d_plus[i] + d_minus[i]) == 0 ) score[i] = 0
    }
    
    st_store(., scorevar, touse, score)
}
end
