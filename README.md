# MCDA Topsis command for Stata

## Aim
The goal of this toolkit is to provide Stata users with robust, user-friendly tools to perform Multi-Criteria Decision Analysis. These methods are essential for ranking or selecting alternatives when multiple, often conflicting, criteria must be considered.

## Methodology: TOPSIS
The primary command in this toolkit, `mcda_topsis`, implements the **Technique for Order of Preference by Similarity to Ideal Solution (TOPSIS)**. 

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
-   **Template-Driven Workflow**: Users can export a CSV/Excel template, fill in parameters, and run the analysis directly from the file.
-   **Flexible Directionality**: Easily specify "benefit" criteria (higher is better) vs "cost" criteria (lower is better).

## Syntax

```stata
mcda_topsis [varlist] [using filename] [if] [in] [, options]
```

### Options

#### Main
-   `weights(numlist)`: Specify the importance of each criterion.
-   `direction(numlist)`: Specify direction for each variable (1 for benefit, -1 for cost).
-   `domains(numlist)`: Specify domain IDs to split weights across groups of variables.

#### Output & Configuration
-   `generate(names)`: Specify names for the generated score and rank variables (default: `topsis_score`, `topsis_rank`).
-   `export_template(filename)`: Export a blank CSV or Excel template with the dataset's variables.
-   `replace`: Overwrite existing files when exporting.

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

### 3. Template Workflow (CSV)
```stata
mcda_topsis mpg price weight, export_template("criteria.csv") replace
* (Edit criteria.csv to set parameters)
mcda_topsis using "criteria.csv"
```

## Reporting Bugs
If you encounter any issues or bugs, please open an issue on the [GitHub repository](https://github.com/emawbgit/MCDA/issues). Please include your Stata version and a sample of your data.

## Author
Emanuele Clemente (With the help of Jules)

## License
MIT
