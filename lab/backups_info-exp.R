library(SQLVault)

db_backups <- backups_info("lab/iris-backups")
print(db_backups, cols = c("sort", "released", "remarks"))
