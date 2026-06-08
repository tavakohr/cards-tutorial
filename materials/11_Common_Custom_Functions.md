# Supplement 10 — Common Custom Functions

This supplement provides reusable R code recipes for custom statistics functions that can be passed to `{cards}`'s `ard_continuous()` function.

## 1. Geometric Statistics (PK/PD summaries)

Clinical pharmacology reports (PK/PD) require geometric mean and geometric CV:

```r
# Geometric Mean
geom_mean <- function(x) {
  # Handle negative or zero values by ignoring them
  x_pos <- x[!is.na(x) & x > 0]
  if (length(x_pos) == 0) return(NA_real_)
  exp(mean(log(x_pos)))
}

# Geometric Coefficient of Variation (CV%)
geom_cv <- function(x) {
  x_pos <- x[!is.na(x) & x > 0]
  if (length(x_pos) < 2) return(NA_real_)
  sqrt(exp(var(log(x_pos))) - 1) * 100
}

# Usage in cards:
# ard_continuous(
#   data = adsl,
#   variables = AGE,
#   statistic = list(AGE = list(gmean = geom_mean, gcv = geom_cv))
# )
```

---

## 2. Confidence Intervals for the Mean

If you need the 95% Confidence Interval for a continuous variable (t-distribution based):

```r
# CI Lower Limit
mean_ci_lower <- function(x, conf.level = 0.95) {
  x_clean <- x[!is.na(x)]
  n <- length(x_clean)
  if (n < 2) return(NA_real_)
  mean(x_clean) - qt(1 - (1 - conf.level)/2, df = n - 1) * (sd(x_clean) / sqrt(n))
}

# CI Upper Limit
mean_ci_upper <- function(x, conf.level = 0.95) {
  x_clean <- x[!is.na(x)]
  n <- length(x_clean)
  if (n < 2) return(NA_real_)
  mean(x_clean) + qt(1 - (1 - conf.level)/2, df = n - 1) * (sd(x_clean) / sqrt(n))
}

# Usage in cards:
# ard_continuous(
#   data = adsl,
#   variables = AGE,
#   statistic = list(AGE = list(
#     mean = mean,
#     ci_lower = mean_ci_lower,
#     ci_upper = mean_ci_upper
#   ))
# )
```

---

## 3. Custom Percentiles

By default, `{cards}` reports p25 and p75. If you need specific percentiles like p10 and p90:

```r
# p10 Percentile
p10 <- function(x) {
  quantile(x, probs = 0.10, na.rm = TRUE, names = FALSE)
}

# p90 Percentile
p90 <- function(x) {
  quantile(x, probs = 0.90, na.rm = TRUE, names = FALSE)
}

# Usage in cards:
# ard_continuous(
#   data = adsl,
#   variables = AGE,
#   statistic = list(AGE = list(
#     p10 = p10,
#     median = median,
#     p90 = p90
#   ))
# )
```

---

## 4. Integration Recipe

Here is a complete template for integrating these custom statistics and defining their formatting rules:

```r
library(cards)

# Calculate ARD with custom statistics
ard_results <- ard_continuous(
  data = adsl,
  variables = AGE,
  by = TRT01A,
  statistic = list(
    AGE = list(
      n = function(x) sum(!is.na(x)),
      mean = mean,
      ci_low = function(x) mean_ci_lower(x, conf.level = 0.95),
      ci_high = function(x) mean_ci_upper(x, conf.level = 0.95)
    )
  ),
  fmt_fn = list(
    AGE = list(
      n = 0,
      mean = 1,
      ci_low = 1,
      ci_high = 1
    )
  )
)
```
