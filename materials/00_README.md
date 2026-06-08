# `{cards}` & `{cardx}` Analysis Results Data (ARD) — Training Curriculum

**Author:** Prepared for Hamid Tavakoli, MD, MSc  
**Purpose:** Self-study curriculum to build a comprehensive working knowledge of the `{cards}` and `{cardx}` R packages (including `{broom}` and `{parameters}` tidiers) for clinical reporting.  
**Date:** June 2026

---

## How to Use This Curriculum

Work through the chapters in order. Each chapter builds on the previous one. By Chapter 7 you will be able to design custom statistical summaries and map ARDs directly to CDISC ARS structures.

| Chapter | Title | What You Will Know After |
|---------|-------|--------------------------|
| 01 | Intro to ARD and `{cards}` | The philosophy of Analysis Results Data (ARD), tidy vs display data, and the standard `{cards}` schema |
| 02 | Core `{cards}` Operations | How to compute continuous, categorical, dichotomous, missing, and total N summaries |
| 03 | Stacking and Formatting | How to bind multiple ARD objects, handle duplicates, and apply display formatting |
| 04 | Extended Stats with `{cardx}` | How to run univariate statistical tests (t-tests, Wilcoxon, CMH) and Kaplan-Meier survival analysis |
| 05 | Models, `{broom}`, and `{parameters}` | How R statistical models are tidied; the roles of `{broom}`, `{parameters}`, and how `{cardx}` wraps them |
| 06 | Consuming ARD | How downstream packages like `{gtsummary}` and `{rtables}` consume ARD to render tables |
| 07 | Advanced Workflows | How to write custom statistics functions and map flat ARDs to CDISC ARS `OperationResult` JSON |

### Reference Supplements

These supplements expand on specific topics and are referenced throughout the chapters.

| File | Topic | What you will know after |
|------|-------|--------------------------|
| 08 | [ARD Structure Reference](08_ARD_Structure_Reference.md) | A complete column-by-column breakdown of the standard ARD data frame structure |
| 09 | [Broom vs Parameters Tidiers](09_Broom_vs_Parameters_Tidiers.md) | How the `{broom}` and `{parameters}` packages tidy statistical model summaries and their differences |
| 10 | [Common Custom Functions](10_Common_Custom_Functions.md) | Reusable recipes for custom statistics (geometric mean, percentiles, confidence intervals) in `{cards}` |

---

## Prerequisites

- Experience in clinical trial programming (ADaM structure: `ADSL`, `ADAE`, `ADTTE`, etc.)
- Basic R programming (specifically `{dplyr}` and the tidyverse pipe `%>%` or `|>`)
- No prior experience with `{cards}` or `{cardx}` is required.

---

## Key References

- [cards R package Documentation](https://insightsengineering.github.io/cards/)
- [cardx R package Documentation](https://insightsengineering.github.io/cardx/)
- [broom R package Documentation](https://broom.tidymodels.org/)
- [parameters R package Documentation](https://easystats.github.io/parameters/)
- [gtsummary R package Documentation](https://www.danieldsjoberg.com/gtsummary/)
- [CDISC Analysis Results Standard (ARS)](https://cdisc-org.github.io/analysis-results-standard/)
