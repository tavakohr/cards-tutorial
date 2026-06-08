# Chapter 3 — Stacking and Formatting

## 3.1 Combining ARD Objects

Clinical tables typically present multiple variables and statistical types. For example, a demographics table displays Age (continuous), Sex (categorical), and Race (categorical) in a single display. 

In `{cards}`, you generate a separate ARD object for each section and then combine them into a single, stacked ARD. There are two primary ways to do this:

### 1. `bind_ard()`
`bind_ard()` is the core function used to bind multiple ARD data frames together. It is similar to `{dplyr}`'s `bind_rows()`, but with added safety checks:
- It verifies that all inputs are valid ARD objects.
- It checks for duplicate rows (same grouping, same variable, same statistic) and by default will alert or error if duplicates exist.

```r
ard_age <- ard_continuous(adsl, variables = AGE, by = TRT01A)
ard_sex <- ard_categorical(adsl, variables = SEX, by = TRT01A)

# Bind them together
ard_demog <- bind_ard(ard_age, ard_sex)
```

### 2. `ard_stack()`
`ard_stack()` is a convenient, high-level helper that lets you run multiple types of ARD summaries on a dataset in a single call. You specify which variables get continuous summaries and which get categorical summaries.

```r
ard_demog <- ard_stack(
  data = adsl,
  # Continuous summaries
  ard_continuous(variables = AGE),
  # Categorical summaries
  ard_categorical(variables = c(SEX, RACE)),
  # Grouping variable
  by = TRT01A
)
```

---

## 3.2 Managing Duplicate Rows

An ARD represents a unique set of statistical results. If you bind two ARDs that contain the same analysis (e.g., if you accidentally ran `ard_continuous(adsl, variables = AGE)` twice), you will have duplicate rows.

### Why Duplicates Are Dangerous:
If an ARD contains duplicate rows, downstream reporting tools (like `{gtsummary}`) will get confused about which statistic value to print. It also breaks the traceability chain (one plan should map to one calculated result).

### How `{cards}` Handles Duplicates:
- `bind_ard(..., replace = FALSE)` (default): Will throw an error if duplicates are detected.
- `bind_ard(..., replace = TRUE)`: If duplicate rows are found, the rows from the later argument will overwrite the rows from the earlier argument. Use this carefully when you are purposefully updating or overriding specific statistics.

---

## 3.3 Formatting Stats (`ard_fmt_args`)

While `stat` contains the full-precision numeric value (e.g. `74.38095`), the `stat_fmt` column contains the display string. By default, `{cards}` applies standard decimal rules. However, clinical studies have strict formatting requirements (e.g. "Mean should have 1 decimal place; SD should have 2 decimal places").

You can control formatting using `ard_fmt_args()` or by passing formatting arguments to your ARD generation function.

### Formatting Methods:
1. **Decimal count (integer):** Pass an integer representing the number of decimal places.
2. **Formatting function:** Pass an R formatting function (like `sprintf` or `round`).
3. **String templates:** Pass a format template (like `"XX.X"`).

### Example:
```r
# Custom formatting for Age summaries
ard_age_fmt <- ard_continuous(
  data = adsl,
  variables = AGE,
  by = TRT01A,
  fmt_fn = list(
    # n gets 0 decimals
    AGE = list(
      n = 0,
      mean = 1,
      sd = 2,
      median = 1
    )
  )
)
```

By specifying `fmt_fn` at the calculation step, you ensure that the formatting rules are bound to the raw statistics, making the ARD object fully self-contained.

---

## Chapter 3 Summary

- **`bind_ard()`** binds separate ARD tables, validating that no duplicate analysis results are created unless `replace = TRUE` is explicitly set.
- **`ard_stack()`** is a high-level wrapper to run continuous and categorical functions in one command.
- **Formatting** is defined via `fmt_fn` (which can take decimal integers, custom formatting functions, or template strings) and is stored directly in the `stat_fmt` column.
- Separating calculation-stage formatting from downstream display layout keeps the workflow robust and auditable.
