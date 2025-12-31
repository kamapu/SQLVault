library(divDB)
library(SQLVault)

project_path = "lab/test-project-example"
backup_path = "lab/iris-backups"
vault = "lab/iris-backups/vault"
f_timestamp = "%Y%m%d-%H%M"
release_sql = "update-iris-db.sql"
restore = TRUE



# divDB::do_backup(dbname = "iris-db", user = "miguel",
#     filepath = "lab/iris-backups")



ans <- utils::askYesNo("Do you want to set x <- TRUE?")

