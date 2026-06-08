# setup_renv.R
# This script sets up renv for the cards_tutorial project, copies the baseline
# lockfile, restores/installs the required R packages, and takes a final snapshot.

message("==================================================")
message("Setting up renv for cards_tutorial...")
message("==================================================")

# 1. Install renv globally if missing
if (!requireNamespace("renv", quietly = TRUE)) {
  message("Installing renv package...")
  install.packages("renv", repos = "https://cloud.r-project.org")
}

# 2. Copy the baseline renv.lock from ARS_Training if available
src_lock <- "C:/Users/tavak/Documents/ARS_Training/renv.lock"
dest_lock <- "renv.lock"
if (file.exists(src_lock)) {
  message("Copying baseline renv.lock from ARS_Training...")
  file.copy(src_lock, dest_lock, overwrite = TRUE)
} else {
  message("No baseline renv.lock found in ARS_Training. Will initialize a new one.")
}

# 3. Initialize renv structure in the current project
message("Initializing renv project environment...")
renv::init(bare = TRUE, restart = FALSE)

# 4. Restore packages from the copied renv.lock
if (file.exists(dest_lock)) {
  message("Restoring packages from renv.lock (this may take a few minutes)...")
  tryCatch({
    renv::restore(prompt = FALSE)
  }, error = function(e) {
    message("Notice during restore: ", e$message)
  })
}

# 5. Check and install any missing packages
required_pkgs <- c(
  "learnr", "gradethis", "pharmaverseadam", "dplyr", "cards", 
  "cardx", "gtsummary", "broom", "parameters", "jsonlite", 
  "glue", "survival", "rmarkdown", "shiny", "haven", "readr", 
  "readxl", "datasetjson", "remotes"
)

# Detect missing packages inside the renv library
missing_pkgs <- c()
for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    missing_pkgs <- c(missing_pkgs, pkg)
  }
}

if (length(missing_pkgs) > 0) {
  message("Installing missing packages: ", paste(missing_pkgs, collapse = ", "))
  
  # Handle gradethis (often installed from GitHub)
  if ("gradethis" %in% missing_pkgs) {
    if (!requireNamespace("remotes", quietly = TRUE)) {
      renv::install("remotes")
    }
    message("Installing gradethis from GitHub...")
    try(renv::install("rstudio/gradethis"))
    missing_pkgs <- setdiff(missing_pkgs, "gradethis")
  }
  
  # Install the rest
  if (length(missing_pkgs) > 0) {
    renv::install(missing_pkgs)
  }
} else {
  message("All required packages are already installed.")
}

# 6. Take a snapshot to update renv.lock
message("Taking renv snapshot to finalize the lockfile...")
renv::snapshot(prompt = FALSE)

message("==================================================")
message("renv setup complete and renv.lock is up-to-date!")
message("==================================================")
