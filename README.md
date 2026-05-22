# MCDA Toolkit for Stata

This repository contains Stata commands for Multi-Criteria Decision Analysis (MCDA). 

## Commands

### `mcda_topsis`

The `mcda_topsis` command implements the Technique for Order of Preference by Similarity to Ideal Solution (TOPSIS). It allows users to rank alternatives based on multiple criteria, with support for domain-based weighting and Excel-based configuration.

#### Features
- **Min-Max Normalization**: Standardizes criteria to a 0-1 scale.
- **Domain Weighting**: Allows weights to be assigned to groups of variables (domains), which are then automatically split among members.
- **Excel Integration**: Users can export a template, fill in weights and directions in Excel, and run the analysis directly from the spreadsheet.
- **Automated Output**: Generates scores and ranks as new variables in the dataset.

## Installation

```stata
* Download the files and place them in your personal ado folder or current directory.
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

## License
MIT
