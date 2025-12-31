# Create database
source("lab/create-iris-db.R")

# Packages loaded and credentials set by previous script

# Load package
devtools::install()
library(SQLVault)

# Project inside of lab (with warning message)
unlink("lab/test-project", recursive = TRUE)

init_project(path = "lab/test-project", dbname = "iris-db", user = "miguel",
    rs_project = TRUE)

# Restore in advance
unlink("lab/test-project", recursive = TRUE)

init_project(path = "lab/test-project", dbname = "iris-db", user = "miguel",
    rs_project = TRUE, restore_from = "lab/iris-backups")
