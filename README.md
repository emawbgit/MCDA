# MCDA Toolkit for Stata

This repository contains Stata commands for Multi-Criteria Decision Analysis (MCDA).

## Aim
The goal of this toolkit is to provide Stata users with robust, user-friendly tools to perform Multi-Criteria Decision Analysis. These methods are essential for ranking or selecting alternatives when multiple, often conflicting, criteria must be considered.

## Methodology: TOPSIS
The first command in this toolkit, `mcda_topsis`, implements the **Technique for Order of Preference by Similarity to Ideal Solution (TOPSIS)**. 

### Core Logic:
1. **Normalization**: Criteria are normalized to a 0-1 scale using Min-Max normalization.
2. **Weighting**: User-defined weights are applied to the normalized criteria.
3. **Ideal Solutions**: The algorithm identifies the Positive Ideal Solution (PIS) and the Negative Ideal Solution (NIS).
4. **Distance Calculation**: The Euclidean distance of each alternative from both PIS and NIS is calculated.
5. **Relative Closeness**: A final score is generated based on the relative closeness to the ideal solution.

## Commands

### `mcda_topsis`
Ranks alternatives based on multiple criteria with support for domain-based weighting and Excel-based configuration.

#### Features
- **Min-Max Normalization**: Standardizes criteria to a 0-1 scale.
- **Domain Weighting**: Allows weights to be assigned to groups of variables (domains), which are then automatically split among members.
- **Excel Integration**: Users can export a template, fill in weights and directions in Excel, and run the analysis directly from the spreadsheet.
- **Automated Output**: Generates scores and ranks as new variables in the dataset.

## Installation

### Via GitHub (Recommended)
You can install the toolkit directly from Stata using the `github` command:
```stata
net install github, from("https://haghish.github.io/github/")
github install emawbgit/MCDA
```

### Via Net Install
Alternatively, use the `net install` command:
```stata
net install mcda_topsis, from("https://raw.githubusercontent.com/emawbgit/MCDA/main/")
```

## Usage

### Standard Syntax
```stata
mcda_topsis varlist [if] [in], weights(numlist) direction(numlist) [options]
```

### Excel Template Workflow
1. **Generate Template**:
   ```stata
   mcda_topsis, export_template("my_config.xlsx")
   ```
2. **Run Analysis**:
   ```stata
   mcda_topsis using "my_config.xlsx"
   ```

## Reporting Bugs
If you run into any issues or bugs, please open an issue on the GitHub repository. Be sure to include your exact Stata version, the command you ran, and a sample of your data (or ideally, reproduce the bug using auto.dta).

## License
MIT
