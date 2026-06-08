# Chapter 5 — Models, `{broom}`, and `{parameters}`

## 5.1 The R Model Challenge

When you fit a statistical model in R, such as a linear regression (`lm()`), logistic regression (`glm()`), or Cox proportional hazards model (`coxph()`), the resulting object is a complex, deeply nested list:

```r
fit <- glm(RESPONSE ~ TRT01A + AGE, family = binomial(), data = adsl)
class(fit) # "glm" "lm"
names(fit) # 30+ components (coefficients, residuals, fitted.values, family, etc.)
```

To include these results in a clinical table, you need to extract specific elements (like coefficient estimates, standard errors, confidence intervals, and p-values) and format them as a table. Historically, clinical programmers wrote verbose, custom code to slice and dice these model objects:

```r
# The old, fragile way
coef_table <- summary(fit)$coefficients
odds_ratios <- exp(coef_table[, "Estimate"])
p_values <- coef_table[, "Pr(>|z|)"]
```

This ad-hoc approach is error-prone, hard to scale, and breaks easily if the model class or options change.

---

## 5.2 What is `{broom}`?

The `{broom}` R package (part of the tidymodels ecosystem) solves this by converting statistical analysis objects into tidy data frames. Instead of navigating lists manually, `{broom}` provides three core generic functions:

1. **`tidy()`:** Summarizes information about model components (e.g. coefficients, estimates, standard errors, test statistics, p-values).
2. **`glance()`:** Summarizes information about the model as a whole (e.g. R-squared, AIC, BIC, log-likelihood).
3. **`augment()`:** Adds information about individual observations back to the original dataset (e.g. residuals, fitted values, cook's distance).

In clinical reporting, we are primarily interested in **`tidy()`**. When called on a model, it returns a standardized tibble:

```r
library(broom)
tidy(fit, conf.int = TRUE, exponentiate = TRUE)
```

| term | estimate | std.error | statistic | p.value | conf.low | conf.high |
|:---|:---|:---|:---|:---|:---|:---|
| `(Intercept)` | `0.142` | `0.456` | `0.311` | `0.755` | `0.058` | `0.347` |
| `TRT01AXanomeline`| `2.413` | `0.321` | `7.517` | `<0.001`| `1.291` | `4.561` |
| `AGE` | `0.982` | `0.012` | `-1.500`| `0.134` | `0.959` | `1.005` |

---

## 5.3 What is `{parameters}`?

The `{parameters}` R package (part of the `easystats` suite) serves a very similar role to `{broom}`. It provides the `model_parameters()` function to extract a dataframe of model coefficients.

### Why do we need `{parameters}` alongside `{broom}`?
- **Model Support:** `{parameters}` supports a wider variety of complex models (e.g. mixed-effects models, Bayesian models, zero-inflated models) than `{broom}`.
- **Detailed Output:** It often extracts more auxiliary information (like degrees of freedom, standardized coefficients, or random effects parameters) by default.
- **Robustness:** `{parameters}` is actively maintained to be highly robust across R version changes and package updates.

Because of this, modern pharmaverse tools are designed to support both packages as backends.

---

## 5.4 How `{cardx}` Integrates Tidiers

The `{cardx}` package provides `ard_regression()`, which fits a regression model and formats its tidied parameters directly into the standard ARD format.

Under the hood, `{cardx}` does not call `{broom}` or `{parameters}` directly. Instead, it uses the **`{broom.helpers}`** package. `{broom.helpers}` acts as an abstraction layer that:
1. Calls **`broom.helpers::tidy_with_broom_or_parameters()`**.
2. This function attempts to use `broom::tidy()` first. If that fails or if the model class is not supported by `{broom}`, it automatically falls back to `parameters::model_parameters()`.
3. It standardizes variable names, labels, reference levels, and interaction terms.

This means that as a programmer, you get the best of both worlds: a single function `ard_regression()` that works seamlessly on almost any R model object, using whichever underlying tidier is best suited.

```
                  +--------------------------------+
                  |    cardx::ard_regression()     |
                  +--------------------------------+
                                  |
                                  v
                  +--------------------------------+
                  |  broom.helpers::tidy_with...() |
                  +--------------------------------+
                                  |
                 +----------------+----------------+
                 | (try broom first)               | (fallback)
                 v                                 v
        +------------------+              +------------------+
        |   broom::tidy()  |              |    parameters::  |
        |                  |              | model_parameters|
        +------------------+              +------------------+
```

---

## 5.5 Using `ard_regression`

To generate a regression ARD, you pass the fitted model object to `ard_regression()`.

### Syntax:
```r
ard_regression(
  x,
  tidy_fun = broom.helpers::tidy_with_broom_or_parameters,
  stats_to_select = NULL,
  ...
)
```

- **`x`:** A fitted model object (e.g. from `lm()`, `glm()`, `coxph()`).
- **`stats_to_select`:** You can specify exactly which statistics to keep in the ARD (e.g. coefficients, confidence intervals, p-values). By default, it captures everything returned by the tidier.
- **`...`:** Additional arguments passed directly to the tidying function (such as `exponentiate = TRUE` to get Odds Ratios or Hazard Ratios, or `conf.level = 0.95`).

### Example: Logistic Regression
```r
library(cardx)
library(survival)

# Fit model: Response vs. Treatment and Age
fit_logistic <- glm(
  COMPLFL ~ TRT01A + AGE, 
  data = adsl, 
  family = binomial()
)

# Convert to ARD
ard_reg <- ard_regression(
  x = fit_logistic,
  exponentiate = TRUE,
  conf.int = TRUE
)
```

The resulting ARD will contain rows for each coefficient (`(Intercept)`, `TRT01A`, `AGE`), with statistics like `estimate` (the Odds Ratio), `std.error`, `conf.low`, `conf.high`, and `p.value` properly mapped to standard ARD columns.

---

## Chapter 5 Summary

- R models are complex, nested lists; **tidying** is the process of flattening them into standard data frames.
- **`{broom}`** provides `tidy()` to extract coefficient tables.
- **`{parameters}`** provides a robust, comprehensive alternative for model parameter extraction.
- **`{cardx}`** uses **`{broom.helpers}`** to wrap both tidiers, giving a uniform interface `ard_regression()`.
- **`ard_regression()`** preserves full numeric precision in `stat_value` while generating standard ARD rows for model coefficients, confidence intervals, and significance tests.
