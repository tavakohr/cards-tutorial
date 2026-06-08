# Chapter 7 — Advanced Workflows

## 7.1 Custom Statistics in `{cards}`

While `{cards}` provides a comprehensive set of default summary statistics, clinical study protocols often require custom calculations (e.g. geometric mean, geometric coefficient of variation, specific percentiles, or custom confidence intervals).

You can define custom statistics by passing a named list of functions to the `statistics` argument of `ard_continuous()`.

### Rules for Custom Statistic Functions:
1. The function must take a numeric vector as its first argument.
2. The function should handle missing values (`NA`) appropriately.
3. The function must return a single, scalar value (which will be stored in `stat`).

### Example: Geometric Mean and Coefficient of Variation
```r
# Define custom functions
geom_mean <- function(x) {
  exp(mean(log(x[x > 0]), na.rm = TRUE))
}

geom_cv <- function(x) {
  sqrt(exp(var(log(x[x > 0]), na.rm = TRUE)) - 1) * 100
}

# Run ARD with custom statistics
ard_custom <- ard_continuous(
  data = adsl,
  variables = AGE,
  by = TRT01A,
  statistics = list(
    AGE = list(
      n = function(x) sum(!is.na(x)),
      gmean = geom_mean,
      gcv = geom_cv
    )
  ),
  fmt_fn = list(
    AGE = list(
      n = 0,
      gmean = 1,
      gcv = 2
    )
  )
)
```

By adding these custom statistics, the resulting ARD will contain rows with `stat_name = "gmean"` and `stat_name = "gcv"`, fully formatted according to the specifications.

---

## 7.2 Mapping ARD to CDISC ARS

One of the key motivations for using `{cards}` ARD is its close alignment with the **CDISC Analysis Results Standard (ARS)**. 

In CDISC ARS, the calculated results are stored as a list of **`OperationResult`** objects. There is a direct, field-by-field mapping between a row of a flat `{cards}` ARD and the formal ARS JSON schema:

| Flat ARD Column | CDISC ARS Field | Role |
|:---|:---|:---|
| `group1` / `group2` | `resultGroups[i].groupingId` | Identifies which grouping factor was applied (e.g. Treatment) |
| `group1_level` | `resultGroups[i].groupId` | Identifies the specific group/level (e.g. Placebo) |
| `variable` | `Analysis.variable` | The variable being analyzed (binds results to the Analysis spec) |
| `stat_name` | `OperationResult.operationId` | References the operation defined in the AnalysisMethod |
| `stat` | `OperationResult.rawValue` | Unformatted result value (numeric/object) |
| `stat_fmt` | `OperationResult.formattedValue` | Rounded character string displayed in outputs |

### JSON Serialization Example:
A row of a flat ARD:
```r
# group1 = "TRT01A", group1_level = "Placebo", variable = "AGE", stat_name = "mean", stat = 75.21, stat_fmt = "75.2"
```

Maps to the following CDISC ARS JSON element inside `Analysis.results`:
```json
{
  "operationId": "O_MEAN",
  "resultGroups": [
    {
      "groupingId": "G_TRT",
      "groupId": "G_PLACEBO"
    }
  ],
  "rawValue": 75.21,
  "formattedValue": "75.2"
}
```

This direct relationship is why `{cards}` has been adopted as the primary calculation engine in the CDISC ARS open-source ecosystem.

---

## 7.3 Traceability Auditing

Because ARD maintains the explicit mapping above, we can write programmatic auditors to verify the integrity of our clinical trial summaries:

1. **Plan vs. Execution Check:** Compare the ARM-TS specification (what analyses were planned) against the generated ARD data frame. We can write an R function to check if there are any planned analyses that are missing from the ARD, or if the ARD contains calculations that were not in the plan (untraced analyses).
2. **Format-Consistency Check:** Verify that the formatted values in `stat_fmt` match the `resultPattern` defined in the ARM-TS. For example, if the plan specifies that the mean should be formatted as `XXX.X`, the auditor checks that the value has exactly one decimal place.

This level of automated quality control is impossible when results are trapped inside static RTF or PDF documents.

---

## Chapter 7 Summary

- **Custom statistics** are implemented by passing a named list of functions to the `statistics` argument in `ard_continuous()`.
- `{cards}` ARD columns map directly to the CDISC ARS **`OperationResult`** JSON structure, where `group1_level` corresponds to `groupId`, `stat_name` maps to `operationId`, and raw/formatted values map to `rawValue`/`formattedValue`.
- **Traceability auditing** leverages this structured layout to automatically verify that the generated results exactly match the planned analysis specifications.
