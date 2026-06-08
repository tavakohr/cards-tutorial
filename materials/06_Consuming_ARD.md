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
  HTML Table              Word/RTF Table
```

### Advantages of the ARD Middle Layer:
1. **Compute Once, Render Many:** Calculate the statistics once. You can render that exact same ARD to HTML, PDF, RTF, or Word without ever re-running a statistical function.
2. **Simplified QC:** Double-programming QC is done by comparing the flat ARD datasets. If the numbers in the ARD match, the formatting step is guaranteed to display the correct numbers.
3. **Traceability:** The ARD links every displayed cell back to the specific ADaM input, group, and variable.

---

## 6.2 How an ARD Transforms to `{gtsummary}`

The `{gtsummary}` package has been re-engineered to use the ARD schema as its core data model. 

When you pass an ARD to **`tbl_ard_summary()`**, `{gtsummary}` queries the ARD object to construct the table:
1. **Row Creation:** It reads the `variable` and `variable_level` columns to generate the table's rows and indented sub-rows.
2. **Column Creation:** It reads the grouping variables (e.g., `group1_level`) to generate the table columns (e.g., Treatment A, Treatment B).
3. **Cell Population:** It reads the `stat_name` (e.g., `"mean"`) and pulls the pre-formatted display text directly from the `stat_fmt` column. 

Because `tbl_ard_summary()` does not run any calculations itself, it executes instantly.

---

## 6.3 Comprehensive `{gtsummary}` Workflows

Once the table is generated, you can style, format, and export it.

### 1. Generating the Base Table
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

# 2. Render the base table using the pre-computed ARD
base_table <- tbl_ard_summary(
  cards = ard_data,
  by = TRT01A,
  include = c(AGE, SEX, RACE)
) %>%
  add_overall()
```

### 2. Setting Global Themes
Before generating your table, you can set a global theme to adhere to specific journal or organizational standards. Themes automatically adjust padding, borders, and number formatting.

```r
# Apply a compact theme (reduces padding, good for large tables)
theme_gtsummary_compact()

# Apply a journal-specific theme (e.g., JAMA, Lancet, NEJM)
theme_gtsummary_journal("jama")

# Reset to default
reset_gtsummary_theme()
```

### 3. Aesthetic Modifiers
`{gtsummary}` provides a suite of modifier functions to change table text, headers, and footnotes instantly.

```r
styled_table <- base_table %>%
  # Modify main column headers (use markdown ** for bold)
  modify_header(
    label = "**Demographic Characteristic**",
    all_stat_cols() ~ "**{level}**  \n(N = {n})"
  ) %>%
  # Add a spanning header over all statistic columns
  modify_spanning_header(all_stat_cols() ~ "**Treatment Group**") %>%
  # Add footnotes
  modify_footnote(all_stat_cols() ~ "Data collected at baseline.") %>%
  modify_caption("Table 14.1.1: Demographic Characteristics") %>%
  # Bold the variable names (AGE, SEX)
  bold_labels() %>%
  # Italicize the variable levels (Male, Female)
  italicize_levels()
```

### 4. Exporting the Table
Clinical outputs are rarely delivered as R consoles or interactive HTMLs. `{gtsummary}` tables can be easily exported using external rendering engines.

**To Microsoft Word (via `{flextable}`):**
```r
library(flextable)

styled_table %>%
  as_flex_table() %>%
  flextable::save_as_docx(path = "table_14_1_1.docx")
```

**To RTF or HTML (via `{gt}`):**
```r
library(gt)

styled_table %>%
  as_gt() %>%
  gtsave(filename = "table_14_1_1.rtf")
```

---

## 6.4 Consuming ARD with `{rtables}`

While `{gtsummary}` is excellent for standard summaries and regressions, `{rtables}` is a powerful layout engine developed by Roche (Insights Engineering) specifically for generating complex, multi-level clinical tables (like adverse event tables with nested SOC/PT rows).

`{rtables}` uses a grid-based layout specification. It has direct integrations to build table cells by reading values from `{cards}` ARD objects:
- You define the grid layout (columns, rows, nesting).
- You populate the cells by querying the ARD object's `stat_fmt` column.
- `{rtables}` handles the text wrapping, column widths, page breaks, and rendering to text, RTF, or PDF formats.

This makes ARD the universal exchange format across the entire pharmaverse reporting ecosystem.

---

## Chapter 6 Summary

- **Separation of Concerns:** Calculate once in `{cards}`, render multiple times downstream.
- **Internal Mapping:** `{gtsummary}` builds rows from `variable_level`, columns from `group1_level`, and populates cells using `stat_fmt`.
- **Theming & Styling:** Use `theme_gtsummary_*()` globally, and `modify_*()` functions on the pipeline to control aesthetics.
- **Exporting:** Convert to `{flextable}` for Word (`.docx`), or `{gt}` for RTF/HTML outputs.
