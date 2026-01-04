library(SQLVault)

# Initialize Project
init_project(dbname = "iris-db", user = "miguel",
    path = "lab/test-projects/new-project-2",
    restore_from = "lab/test-projects/iris-backups")

# Release Project
release_project(
    project_path = "lab/test-projects/new-project-2",
    backup_path = "lab/test-projects/iris-backups",
    vault = "lab/test-projects/iris-backups/vault",
    release_sql = "update_query.sql"
)

# Update Project
do_restore()
