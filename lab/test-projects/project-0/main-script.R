# Create an example database for tests
library(DBI)
library(divDB)

# Connect postgres
#credentials(dbname = "postgres", user = "miguel")
conn <- connect_db(dbname = "postgres", user = "miguel")

# delete database if existing
dbExecute(conn, "drop database if exists \"iris-db\" with (force)")

# Create database
dbSendQuery(conn, "create database \"iris-db\"")

# Do a backup
do_backup(dbname = "iris-db", user = "miguel", filepath = "lab/test-projects/iris-backups",
  f_timestamp = "%Y%m%d-%H%M")

do_restore(dbname = "iris-db", user = "miguel",
  filepath = "lab/test-projects/iris-backups")

dbDisconnect(conn)
