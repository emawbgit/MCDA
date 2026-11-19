# MCDA Toolkit for Stata

This repository contains Stata commands for Multi-Criteria Decision Analysis (MCDA). 

## Aim
The goal of this toolkit is to provide Stata users with robust, user-friendly tools to perform Multi-Criteria Decision Analysis. These methods are essential for ranking or selecting alternatives when multiple, often conflicting, criteria must be considered.

## Methodology: TOPSIS
The primary command in this toolkit, `mcda_topsis`, implements the **Technique for Order of Preference by Similarity to Ideal Solution (TOPSIS)** (Hwang and Yoon, 1981). 

TOPSIS ranks alternatives based on their geometric distance from both the Positive Ideal Solution (PIS) and the Negative Ideal Solution (NIS). The chosen alternative should have the shortest distance from the PIS and the farthest distance from the NIS.

### Core Logic:
1.  **Normalization**: Criteria are normalized to a 0-1 scale using Min-Max normalization.
2.  **Weighting**: User-defined weights are applied to the normalized criteria to reflect relative importance.
3.  **Ideal Solutions**: The algorithm identifies the PIS (best values for all criteria) and the NIS (worst values).
4.  **Distance Calculation**: The Euclidean distance of each alternative from both PIS and NIS is calculated.
5.  **Relative Closeness**: A final score (0 to 1) is generated based on the relative closeness to the ideal solution.

## Installation

You can install the latest version of the MCDA Toolkit directly from this GitHub repository using Stata's `net install` command:

```stata
net install mcda_topsis, from("https://raw.githubusercontent.com/emawbgit/MCDA/main/") replace
```

## Description

The `mcda_topsis` command processes a set of numeric variables and outputs rankings based on the TOPSIS algorithm. 

### Key Features:
-   **Min-Max Normalization**: Automatically standardizes criteria to a 0-1 scale.
-   **Domain Weighting**: Allows weights to be assigned to groups of variables (domains), which are then automatically split among members.
-   **Flexible Directionality**: Easily specify "benefit" criteria (higher is better) vs "cost" criteria (lower is better).
-   **Missing values**: observations with a missing criterion are excluded and reported (`r(N_excluded)`), never ranked silently.
-   **Ties**: rank 1 is the highest score; tied scores share the same rank.
-   **Input rules**: each criterion may be entered only once; weights (after domain splitting) must sum to 1, with a 0.01 tolerance for rounding.

## Dialog box
Type `db mcda_topsis` for a point-and-click dialog:
-   **Criteria tabs** (up to 20 criteria): one row per criterion, with a variable drop-down, a weight field and a **Cost** tick box (ticked = direction -1). Empty rows are skipped.
-   **Options tab**: `if` restriction, domain IDs, names of the generated variables.
-   **OK / Submit / Copy**: rule violations (repeated variable, weights not summing to 1) open an error window; **Submit** keeps the dialog open while you fix them; **Copy** puts the command on the clipboard for your do-file.

To add it to the **User > Statistics** menu, put this in your `profile.do`:

```stata
window menu append item "stUserStatistics" "MCDA: TOPSIS ranking" "db mcda_topsis"
window menu refresh
```

## Syntax

```stata
mcda_topsis varlist [if] [in] [, options]
```

### Options

#### Main
-   `weights(numlist)`: one weight per criterion; non-negative and summing to 1 (±0.01). Default: 1/k each.
-   `direction(numlist)`: one direction per criterion, 1 for benefit (higher raises the score), -1 for cost. Default: 1.
-   `domains(numlist)`: one domain ID per criterion; the weight of a domain's first variable is the domain weight and is split equally within the domain. Domain weights must sum to 1.

#### Output
-   `generate(names)`: Specify names for the generated score and rank variables (default: `topsis_score`, `topsis_rank`).

## Examples

### 1. Basic Ranking
```stata
sysuse auto, clear
mcda_topsis mpg price weight, weights(0.4 0.3 0.3) direction(1 -1 -1)
```

### 2. Domain-Based Weighting
In this example, a weight of 0.5 is assigned to Domain 1 (containing `mpg` and `gear_ratio`) and split between them.
```stata
mcda_topsis mpg gear_ratio price, weights(0.5 0.5 0.5) domains(1 1 2)
```

## Stored results
`r(N)`, `r(N_excluded)`, `r(weights)` (after domain splitting), `r(direction)`.

## Version history
-   **1.3.1** (2026-11-19): `domains()` now abbreviates to `dom()` (`d()` means `direction()` only, as documented); author and contact details; documentation tidy-up.
-   **1.3.0** (2026-11-19): `db mcda_topsis` dialog box; each criterion only once; weights must sum to 1 (±0.01; default 1/k); dialog shows rule violations in an error window.
-   **1.2.0** (2026-11-19): report observations excluded for missing criteria; validate weights, directions and domain IDs (one per criterion); tied scores share a rank instead of being broken arbitrarily; summary table no longer fails with fewer than 10 observations; stored results.
-   **1.1.0** (2024-05-22): domain weighting.

## Reporting Bugs or Desiderata
If you encounter any issues or bugs, please open an issue on the [GitHub repository](https://github.com/emawbgit/MCDA/issues). Please include your Stata version and a sample of your data.

## Author
Emanuele Clemente, University of Bari "Aldo Moro" ([eclemente@worldbank.org](mailto:eclemente@worldbank.org))

## License
MIT
