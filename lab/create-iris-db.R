# Create an example database for tests
library(DBI)
library(divDB)

# Connect postgres
#credentials(dbname = "postgres", user = "miguel")
conn <- connect_db(dbname = "postgres", user = "miguel")

# delete database if existing
dbExecute(conn, "drop database if exists \"iris-db\"")

# Prepare data.frame
iris2 <- iris
names(iris2) <- c("sepal_length", "sepal_width", "petal_length", "petal_width",
  "species")

# Create database
dbSendQuery(conn, "create database \"iris-db\"")
dbDisconnect(conn)

# Reconnect and write the table
conn <- connect_db(dbname = "iris-db", user = "miguel")

query <- read_sql("lab/create-iris-db.sql")
dbSendQuery(conn, query)

# Insert data from data.frame
query <- insert_rows(conn, iris2, c("data_frames", "iris"), eval = FALSE)
query

dbSendQuery(conn, query)

# Cross-check
dbGetQuery(conn, "select * from data_frames.iris limit 4")

# Disconnect database
disconnect_db(conn)
