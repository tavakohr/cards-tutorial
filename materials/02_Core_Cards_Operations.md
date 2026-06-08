# Chapter 2 — Core `{cards}` Operations

## 2.1 Continuous Summaries (`ard_continuous`)

For continuous variables (such as age, vital signs, and laboratory parameters), `{cards}` provides `ard_continuous()`. By default, this function calculates a standard set of summary statistics: `n`, `mean`, `sd`, `median`, `min`, `max`, and quantiles (p25, p75).

### Syntax:
```r
ard_continuous(
  data,
  variables,
  by = NULL,
  statistics = NULL,
  fmt_fun = NULL
)
```

- **`variables`:** The variables to summarize. Supports tidyselect helpers (e.g. `c(AGE, WEIGHT)` or `where(is.numeric)`).
- **`by`:** Grouping variables. Results will be calculated separately for each level of these variables (e.g. `TRT01A`).
- **`statistics`:** Custom list of functions if you want to override the default set.

### Example:
```r
library(cards)
ard_continuous(adsl, variables = AGE, by = TRT01A)
```

---

## 2.2 Categorical Summaries (`ard_categorical`)

For categorical variables (such as race, sex, and adverse event preferred terms), `{cards}` provides `ard_categorical()`. It calculates frequencies (`n`), denominators (`N`), and percentages (`p`).

### Key Columns populated by `ard_categorical()`:
- `variable`: Name of the categorical variable (e.g., `"RACE"`).
- `variable_grp`: Replicates the variable name (e.g., `"RACE"`).
- `variable_grp_level`: The category level (e.g., `"WHITE"`, `"BLACK OR AFRICAN AMERICAN"`).
- `stat_name`: `"n"` (frequency) or `"p"` (fraction) or `"N"` (denominator).

### Example:
```r
ard_categorical(adsl, variables = SEX, by = TRT01A)
```

---

## 2.3 Dichotomous Summaries (`ard_dichotomous`)

A common subset of categorical summaries is dichotomous variables—variables that take only two values (such as flags like `SAFFL = "Y"` or response flags). 

If you use `ard_categorical()`, you get a row for every level of the variable (e.g. one row for `"Y"` and one row for `"N"`). If you only want to display the positive response (e.g. `"Y"`), use `ard_dichotomous()`.

### Example:
```r
# Summarize only subjects who completed the study (SAFFL == "Y")
ard_dichotomous(
  data = adsl,
  variables = SAFFL,
  value = list(SAFFL = "Y"),
  by = TRT01A
)
```
- **`value`:** A named list specifying which level to keep. Only rows corresponding to this level are retained in the ARD.

---

## 2.4 Missingness (`ard_missing`)

Clinical reports often require summarizing missing data. `{cards}` provides `ard_missing()`, which calculates:
- `n_missing`: Number of missing values (`NA`).
- `n_nonmissing`: Number of non-missing values.
- `p_missing`: Percentage of missing values.
- `p_nonmissing`: Percentage of non-missing values.

### Example:
```r
# Track missing lab values
ard_missing(adlb, variables = AVAL, by = PARAMCD)
```

---

## 2.5 Total N (`ard_total_n`)

To calculate percentages for a table, you need the total denominator (usually the total population count per treatment arm). `{cards}` provides `ard_total_n()`, which calculates the total number of rows in the dataset (or per grouping level).

### Example:
```r
# Get the total denominator for each treatment arm
ard_total_n(adsl, by = TRT01A)
```
This returns an ARD containing a single statistic row per treatment arm: `stat_name = "N"` and `stat` containing the total count.

---

## 2.6 Grouping variables (`by`)

The `by` argument is the standard way to group analyses in `{cards}`:
- You can pass multiple grouping variables, such as `by = c(TRT01A, SEX)`.
- `{cards}` will cross-classify all combinations of grouping variables that exist in the data and calculate the statistics for each cell.
- The resulting ARD will populate columns `group1`, `group1_level`, `group2`, `group2_level`, etc., maintaining perfect traceability.

---

## Chapter 2 Summary

- Continuous summaries are generated using **`ard_continuous()`** (defaults to `n`, `mean`, `sd`, etc.).
- Categorical summaries are generated using **`ard_categorical()`** (frequencies and percentages for all levels).
- Dichotomous summaries are generated using **`ard_dichotomous()`** (keeps only a specific value, e.g., `"Y"`).
- Missingness summaries are generated using **`ard_missing()`** (missing vs non-missing counts/rates).
- Denominators are generated using **`ard_total_n()`**.
- Grouping is handled uniformly across all functions via the **`by`** argument.
