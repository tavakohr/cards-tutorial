# `{cards}` and `{cardx}` — Interactive R Tutorial

> Hands-on **learnr** tutorial covering `{cards}` and `{cardx}` R packages — from basic continuous/categorical summaries to regression modeling with `{broom}` and `{parameters}`, with live exercises on real **pharmaverse** datasets.

A seven-chapter interactive course that takes a clinical R programmer from "what is Analysis Results Data (ARD)?" all the way to writing custom statistics, handling model tidying, and mapping flat ARD records directly to the CDISC ARS JSON schema.

Every chapter mixes narrative theory with **runnable code exercises** (graded with `{gradethis}`) and **knowledge-check quizzes**. All exercises use real pharmaverse ADaM datasets (`adsl`, `adtte`) and a sample ARD JSON file (`data/adsl_demog_ard.json`).

---

## Who This Is For

- **Clinical R programmers** who want to learn the standard pharmaverse packages for generating Analysis Results Data (ARD).
- **Lead programmers and statisticians** preparing for ARS-conformant submissions and standardized reporting workflows.
- **R package authors** building downstream reporting tools (like `{gtsummary}` or `{rtables}`) that consume statistical outputs.

---

## Chapter Overview

| # | Chapter | What you learn / build |
|---|---------|------------------------|
| 1 | [Intro to ARD and `{cards}`](cards_tutorial_ch1.Rmd) | The concept of Analysis Results Data (ARD); unrounded raw values vs formatted values; standard ARD schema. |
| 2 | [Core `{cards}` Operations](cards_tutorial_ch2.Rmd) | Generating statistics for continuous, categorical, and dichotomous variables, plus denominators (N) and missingness. |
| 3 | [Stacking and Formatting](cards_tutorial_ch3.Rmd) | Combining multiple ARD tables using `bind_ard()` or `ard_stack()`; resolving duplicate rows; applying custom decimal formatting. |
| 4 | [Extended Stats with `{cardx}`](cards_tutorial_ch4.Rmd) | Generating ARDs for hypothesis tests (t-tests, Fisher's exact, CMH) and Kaplan-Meier survival analysis. |
| 5 | [Models, `{broom}`, and `{parameters}`](cards_tutorial_ch5.Rmd) | Slicing complex R model objects; the roles of `{broom}` and `{parameters}`; generating regression ARDs with `ard_regression()`. |
| 6 | [Consuming ARD](cards_tutorial_ch6.Rmd) | Passing pre-calculated ARDs to downstream rendering tools like `{gtsummary}` (`tbl_ard_summary()`) and `{rtables}`. |
| 7 | [Advanced Workflows](cards_tutorial_ch7.Rmd) | Implementing custom statistics (geometric mean/CV); mapping flat ARD columns directly to CDISC ARS `OperationResult` structures. |

The original chapter study materials live in [`materials/`](materials/).

---

## Quick Start

### 1 — Install the R dependencies

#### Option A: Reproducible Setup with `{renv}` (Recommended)
This project uses `{renv}` to manage reproducible R package environments. To automatically initialize `renv` and restore all required packages (including `{cards}`, `{cardx}`, `{gtsummary}`, and `{gradethis}`) from the lockfile:

1. Open R or RStudio in the `cards_tutorial` folder.
2. Run the setup script:
   ```r
   source("setup_renv.R")
   ```

#### Option B: Manual Installation
If you prefer to install packages in your user library manually:

```r
install.packages(c(
  "learnr",           # interactive tutorial engine
  "gradethis",        # exercise grading
  "pharmaverseadam",  # ADaM datasets (ADSL, ADAE, ADTTE, etc.)
  "dplyr",            # data manipulation
  "cards",            # core ARD generation
  "cardx",            # extended ARD calculations
  "gtsummary",        # tables from ARD
  "broom",            # model tidying
  "parameters",       # model parameters
  "jsonlite",         # JSON reading/writing
  "glue",
  "survival"          # survival analysis models
))
```

If `pharmaverseadam` is not on CRAN in your region, install it from GitHub:

```r
remotes::install_github("pharmaverse/pharmaverseadam")
```

### 2 — Run a chapter

In R:

```r
rmarkdown::run("cards_tutorial_ch1.Rmd")
```

Or in RStudio: open any `cards_tutorial_ch*.Rmd` and click **"Run Document"** in the editor toolbar.

Each chapter opens in your browser as a self-contained interactive tutorial with a violet-accented sidebar, code boxes with live evaluation, hints, solutions, and quizzes.

---

## Repository Structure

```
cards_tutorial/
├── cards_tutorial_ch1.Rmd      ← Chapter 1: Intro to ARD and cards
├── cards_tutorial_ch2.Rmd      ← Chapter 2: Core cards Operations
├── cards_tutorial_ch3.Rmd      ← Chapter 3: Stacking and Formatting
├── cards_tutorial_ch4.Rmd      ← Chapter 4: Extended Stats with cardx
├── cards_tutorial_ch5.Rmd      ← Chapter 5: Models, broom, and parameters
├── cards_tutorial_ch6.Rmd      ← Chapter 6: Consuming ARD
├── cards_tutorial_ch7.Rmd      ← Chapter 7: Advanced Workflows
│
├── data/
│   └── adsl_demog_ard.json     ← Sample flat ARD JSON
│
├── www/
│   └── custom.css            ← White background, violet accents
│
├── materials/                  ← Study guide markdown files
│   ├── 00_README.md
│   ├── 01_Intro_to_ARD_and_Cards.md
│   ├── 02_Core_Cards_Operations.md
│   ├── 03_Stacking_and_Formatting.md
│   ├── 04_Extended_Stats_with_Cardx.md
│   ├── 05_Models_Broom_and_Parameters.md
│   ├── 06_Consuming_ARD.md
│   ├── 07_Advanced_Workflows.md
│   ├── 08_ARD_Structure_Reference.md
│   ├── 09_Broom_vs_Parameters_Tidiers.md
│   └── 10_Common_Custom_Functions.md
│
├── setup_renv.R                ← Renv initialization script
├── renv.lock                   ← Renv locked dependencies file
├── .gitignore
├── .Rprofile
└── README.md                   ← This documentation file
```

---

## License

This tutorial is released under the **MIT License**.
