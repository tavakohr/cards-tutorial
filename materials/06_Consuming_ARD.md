# Chapter 6 — Consuming ARD

## 6.1 The Rationale for Separation

In traditional workflows, table formatting (adding grid lines, bolding headers, indentation, and alignment) and data calculations occur in the same script. If a statistician requests a minor cosmetic change, the programmer must re-run the entire program. If the dataset is large or the model-fitting is computationally intensive (e.g., bootstrapped models or mixed models), this wastes substantial time and computing power.

By using Analysis Results Data (ARD) as a middle layer, we enforce a strict separation of concerns:

```
  ADaM Data 
      │
      ▼  (Calculation Phase: `{cards}` & `{cardx}`)
  ARD Object (JSON / Data Frame)
      │
      ├───────────────────────┐
      ▼                       ▼  (Presentation Phase: `{gtsummary}` / `{rtables}`)
  HTML Table              RTF Table
```

### Advantages of the ARD Middle Layer:
1. **Compute Once, Render Many:** Calculate the statistics once. You can render that exact same ARD to HTML, PDF, RTF, or Word without ever re-running a statistical function.
2. **Simplified QC:** Double-programming QC is done by comparing the flat ARD datasets. If the numbers in the ARD match, the formatting step is guaranteed to display the correct numbers.
3. **Traceability:** The ARD links every displayed cell back to the specific ADaM input, group, and variable.

---

## 6.2 Consuming ARD with `{gtsummary}`

The `{gtsummary}` package is one of the most popular packages for clinical and scientific table generation in R. In recent versions, `{gtsummary}` has been re-engineered to use the ARD schema as its core data model.

When you call `tbl_summary()` in `{gtsummary}`, it runs `{cards}` functions under the hood to build an ARD, and then renders the table. However, you can also bypass `tbl_summary()`'s internal calculations and pass a pre-computed ARD directly to **`tbl_ard_summary()`**.

### Example: Demographics Table
```r
library(gtsummary)
library(cards)

# 1. Calculate the ARD
ard_data <- ard_stack(
  data = adsl,
  ard_continuous(variables = AGE),
  ard_categorical(variables = c(SEX, RACE)),
  .by = TRT01A
)

# 2. Render the table using the pre-computed ARD
table_demog <- tbl_ard_summary(
  cards = ard_data,
  .by = TRT01A,
  variables = c(AGE, SEX, RACE)
) %>%
  add_overall() %>%
  modify_header(label = "**Demographic Characteristic**") %>%
  modify_caption("Table 14.1.1: Demographic Characteristics")
```

Because `tbl_ard_summary()` does not run any calculations itself, it executes instantly. If you need to change the table header, footnote, or caption, you simply re-run the `tbl_ard_summary` block, which takes milliseconds.

---

## 6.3 Consuming ARD with `{rtables}`

`{rtables}` is a powerful layout engine developed by Roche (Insights Engineering) specifically for generating complex, multi-level clinical tables (like adverse event tables with nested SOC/PT rows, or complex efficacy tables).

`{rtables}` uses a grid-based layout specification. It has direct integrations to build table cells by reading values from `{cards}` ARD objects:
- You define the grid layout (columns, rows, nesting).
- You populate the cells by querying the ARD object (using columns like `group1_level`, `variable`, `stat_name`, and `stat`).
- `{rtables}` handles the text wrapping, column widths, page breaks, and rendering to text, RTF, or PDF formats.

This makes ARD the universal exchange format across the entire pharmaverse reporting ecosystem.

---

## Chapter 6 Summary

- **Separation of calculation and display** means statistical calculations are executed once, and rendering is performed downstream.
- **`{gtsummary}`** provides **`tbl_ard_summary()`**, which consumes a pre-computed ARD data frame to render standard clinical tables instantly.
- **`{rtables}`** uses ARD as an input source to populate complex, multi-level clinical trial tables.
- Downstream rendering engines query the ARD's `stat_fmt` for display text and `stat` for raw values, ensuring consistency and auditability.
