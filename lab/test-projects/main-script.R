library(SQLVault)

# Initialize Project
init_project(dbname = "iris-db", user = "miguel",
    path = "lab/test-projects/new-project",
    restore_from = "lab/test-projects/iris-backups")

# Release Project
release_project(
    project_path = "lab/test-projects/new-project",
    backup_path = "lab/test-projects/iris-backups",
    vault = "lab/test-projects/iris-backups/vault",
    release_sql = "create-iris-db.sql"
)
