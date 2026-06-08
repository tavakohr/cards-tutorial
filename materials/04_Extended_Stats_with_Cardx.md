# Chapter 4 — Extended Stats with `{cardx}`

## 4.1 Why `{cardx}`?

The `{cards}` package is designed to be lightweight, fast, and have minimal dependencies. It focuses purely on base summaries (counts, means, basic statistics). 

However, clinical reporting requires complex statistical testing and modeling. To perform a t-test, a Chi-square test, or survival analysis, you need external R packages like `{survival}` or the base `{stats}` engine. 

`{cardx}` (Extended ARD Utilities) is an extension package that wraps these statistical engines. It performs the underlying computations, extracts the results, and formats them into the exact same standard ARD schema as `{cards}`. This allows you to stack basic summaries and complex statistical tests into a single ARD data frame.

---

## 4.2 Standard Hypothesis Tests

`{cardx}` provides functions for standard clinical trial hypothesis tests:

### 1. t-test (`ard_stats_t_test`)
Performs a t-test comparing two groups. It returns statistics like the mean difference, confidence intervals, test statistic, and p-value.
```r
library(cardx)
ard_stats_t_test(adsl, variables = AGE, by = TRT01A)
```

### 2. Wilcoxon Test (`ard_stats_wilcox_test`)
Performs non-parametric comparisons (Wilcoxon rank-sum or signed-rank).
```r
ard_stats_wilcox_test(adsl, variables = AGE, by = TRT01A)
```

### 3. Chi-square & Fisher's Exact Tests
For testing independence between categorical variables (e.g. treatment arm vs. response flag).
- `ard_stats_chisq_test()`: Pearson's Chi-square test.
- `ard_stats_fisher_test()`: Fisher's exact test (highly used for rare events or small sample sizes).
```r
ard_stats_fisher_test(adsl, variables = SEX, by = TRT01A)
```

### 4. Cochran-Mantel-Haenszel (`ard_cmh_test`)
For stratified categorical analyses (e.g., comparing response rates between treatments while adjusting for country or baseline disease severity).
```r
# Stratify by SEX (grouping factor)
ard_cmh_test(
  data = adsl,
  variables = COMPLFL,
  by = TRT01A,
  strata = SEX
)
```

---

## 4.3 Formatting Statistics in `{cardx}`

Univariate tests and modeling functions in `{cardx}` return multiple statistic types (like p-values, test statistics, confidence intervals). Standardizing how these statistics display is controlled at two different points in the pipeline:

### A. During Calculation (using `fmt_fn`)
When running a test, you can supply a named list to the `fmt_fn` argument. This maps a specific statistic to either an integer (number of decimal places) or a custom formatting function:

```r
ard_stats_t_test(
  data = adsl_2groups, 
  variables = AGE, 
  by = TRT01A,
  fmt_fn = list(p.value = 3, estimate = 1)
)
```

### B. Post-Calculation (using `update_ard_fmt_fun()`)
If you have an already-calculated ARD and want to modify its formatting functions before printing, you can update them using `update_ard_fmt_fun()`:

```r
ard_ttest %>%
  update_ard_fmt_fun(p.value = 4) %>%  # Change p-value format to 4 decimals
  apply_fmt_fun()
```

### The Rendering Step: `apply_fmt_fun()`
No matter how formatting rules are defined, the raw `{cardx}` output does not contain the formatted string column (`stat_fmt`) by default. You must pipe the ARD object through **`apply_fmt_fun()`** to generate the rounded text representations for display.

### Flattening Hypothesis Test Results (`unlist_ard_columns`)
Because statistical test outputs include descriptive text rows (such as the testing `method` or `alternative` hypothesis) that are not numerical, they do not receive numeric formatting recipes. As a result, the `stat_fmt` column will contain `NULL` for these rows.

If you try to flatten the column using `unlist(stat_fmt)` inside a `mutate()`, you will receive an error:
`! stat_fmt must be size N or 1, not M`
because `unlist()` deletes the `NULL` items.

To flatten the formatted outputs safely, pipe your results through **`unlist_ard_columns()`** or target only `stat_fmt`:
```r
# Perform t-test, apply formats, and flatten only the stat_fmt column
ard_ttest_flat <- ard_stats_t_test(adsl_2groups, variables = AGE, by = TRT01A) %>%
  apply_fmt_fun() %>%
  unlist_ard_columns(columns = stat_fmt)
```

---

## 4.4 Survival Analysis (`ard_survival_survfit`)

In oncology and cardiovascular studies, time-to-event endpoints are standard. The Kaplan-Meier (KM) survival curve estimates survival rates over time.

`{cardx}` provides `ard_survival_survfit()` to compute KM survival estimates (survival probabilities, number at risk, number of events, confidence intervals) at specific time points.

### Syntax:
```r
ard_survival_survfit(
  data,
  variables,
  by = NULL,
  times = NULL,
  start_time = 0,
  ...
)
```

- **`variables`:** Must be a named character vector mapping `time` and `event` columns. E.g., `variables = c(time = "AVAL", event = "1-CNSR")` (note that the event variable should be numeric where 1 represents the event and 0 represents censoring).
- **`times`:** A numeric vector of time points (e.g. `c(6, 12, 18)`) at which to extract survival statistics.

### Example:
```r
library(survival)

# Filter for the primary endpoint parameter (e.g. Overall Survival)
adtte_os <- adtte %>% filter(PARAMCD == "OS")

# Calculate survival estimates at Months 6, 12, and 18
ard_km <- ard_survival_survfit(
  data = adtte_os,
  by = TRT01A,
  variables = c(time = "AVAL", event = "1-CNSR"),
  times = c(6, 12, 18)
)
```
The output is a standard ARD data frame. Each time point and statistic (e.g. survival rate, standard error) gets its own row, labeled by the corresponding time point (stored in `variable_grp_level`).

---

## Chapter 4 Summary

- **`{cardx}`** extends `{cards}` by wrapping statistical engines and returning the results in the standard ARD format.
- Univariate tests include **`ard_stats_t_test()`**, **`ard_stats_wilcox_test()`**, **`ard_stats_chisq_test()`**, **`ard_stats_fisher_test()`**, and **`ard_cmh_test()`**.
- **`ard_survival_survfit()`** performs Kaplan-Meier calculations at specified time points, mapping survival statistics into standard ARD rows.
