# Supplement 9 — Broom vs. Parameters Tidiers

This supplement details the structural differences between the `{broom}` and `{parameters}` packages, and how `{broom.helpers}` and `{cardx}` standardize these differences to build regression ARDs.

## 1. Column Mapping Comparison

When tidying a regression model (e.g. `glm()`), the two packages output dataframes with different column names. The table below displays how these columns map to each other and how they are standardized by `{broom.helpers}` before being stored in the ARD:

| Concept | `{broom}::tidy()` Column | `{parameters}::model_parameters()` Column | Standardized Output |
|:---|:---|:---|:---|
| Coefficient/Term Name | `term` | `Parameter` | `term` |
| Point Estimate (Beta) | `estimate` | `Coefficient` or `Estimate` | `estimate` |
| Standard Error | `std.error` | `SE` | `std.error` |
| Test Statistic | `statistic` | `t` or `z` | `statistic` |
| Degrees of Freedom | `df` (if applicable) | `df_error` | `df` |
| p-value | `p.value` | `p` | `p.value` |
| Confidence Interval (Low)| `conf.low` | `CI_low` | `conf.low` |
| Confidence Interval (High)| `conf.high` | `CI_high` | `conf.high` |

---

## 2. Key Package Differences

### `{broom}` (Tidymodels ecosystem):
- **Core Philosophy:** Minimalist, consistent, outputting raw numeric dataframes.
- **Tidier Registration:** Relies on registering specific methods (e.g. `tidy.lm`, `tidy.glm`, `tidy.coxph`). If a package author hasn't written a `tidy` method for their model class, `{broom}` will fail.
- **Reference Rows:** `{broom}` does not include rows for reference levels of categorical variables (e.g., if treatment has Placebo and Xanomeline, `{broom}` only outputs a row for the Xanomeline coefficient; the reference Placebo is implicit in the intercept).

### `{parameters}` (Easystats ecosystem):
- **Core Philosophy:** Rich, detailed, out-of-the-box model coverage.
- **Model Coverage:** Supports a wider range of modern models (Bayesian, mixed models, complex GEEs) because it uses heuristic extraction methods.
- **Reference Rows:** `{parameters}` can optionally output reference rows with coefficient value `0` or Odds Ratio `1` (via helper arguments) which is highly desirable in clinical reporting to match TLF shells.

---

## 3. The Role of `{broom.helpers}`

The `{broom.helpers}` package acts as the bridge. When `{cardx}` calls `ard_regression()`, it uses `broom.helpers::tidy_plus_plus()` to:
1. Call `broom.helpers::tidy_with_broom_or_parameters(x)`. This attempts to call `{broom}` first, and if that fails, calls `{parameters}`.
2. Standardize all column names to the `{broom}` convention (e.g., converting `Parameter` to `term`).
3. Add reference rows for categorical variables automatically, so that the reference levels appear in the final ARD.
4. Add variable labels, source dataset info, and interaction term indicators.

### Customizing the Tidier in `{cardx}`:
If you want to bypass the default behavior and force `{cardx}` to use `{parameters}` explicitly, you can pass a custom tidying function:

```r
# Force cardx to use parameters package explicitly
ard_reg <- ard_regression(
  model_fit,
  tidy_fun = function(x, ...) {
    parameters::model_parameters(x, ...) %>%
      # broom.helpers requires standard column names
      dplyr::rename(term = Parameter, estimate = Coefficient, std.error = SE)
  }
)
```
In practice, the default wrapper `broom.helpers::tidy_with_broom_or_parameters` handles this automatically, making it unnecessary to write custom rename logic.
