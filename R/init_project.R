#' @name init_project
#'
#' @title Initialize a new project for database updates
#'
#' @description
#' A project folder will contain all necessary data and scripts needed to update
#' a database into a new version. This strategy will allow to rebuild the
#' database in a preferential version and document at the same time all the
#' process done on the way.
#'
#' @param dbname A character value with the name of the database to be updated.
#' @param user A character value with the name of the user connecting the
#' @param path A character value indicating the path for the new project.
#' @param main_script A character value with the name of the template used as
#'     main script in the project.
#' @param remarks A character value describing the project.
#' @param rs_project A logical value indicating whether an R Studio project
#'     should be initialized or not. This may be useful to proceed with the
#'     ETL workflow in an own R Studio project.
#' @param overwrite A logical value indicating whether an existing homonymous
#'     project should be overwritten or not.
#' @param ... Further arguments passed to [divDB::do_backup()] and
#'     [divDB::connect_db()] (for instance 'host' and 'port').
#'
#' @export
init_project <- function(
  dbname, user, path, main_script = "main-script", remarks = "",
  rs_project = FALSE, overwrite = FALSE, ...
) {
  # Remind user to restore in advance
  message(paste0(
    "Project initialized from your current database version.\n",
    "Remember to restore your database from last backup in advance.\n"
  ))
  # Check existing directory
  if (file.exists(path)) {
    if (overwrite) {
      unlink(path, recursive = TRUE)
    } else {
      stop(paste0(
        "The directory '", path,
        "' is already existing.\n  You may need to set 'overwrite = TRUE'."
      ))
    }
  }
  # Create new directory
  dir.create(path = path, recursive = TRUE)
  # Retrieve password
  password <- tryCatch(keyring::key_get(service = dbname, username = user),
    error = function(e) {
      stop(paste0(
        "A password for database '", dbname, "' and user '", user,
        "' is not yet set\n  Use credentials() to set it."
      ))
    }
  )
  password <- keyring::key_get(service = dbname, username = user)
  # Do a backup
  divDB::do_backup(
    dbname = dbname, user = user, filepath = path,
    f_timestamp = NULL, ...
  )
  # Connect the database
  conn <- divDB::connect_db(dbname = dbname, user = user, ...)
  # Write a log file
  log <- list(
    database = dbname,
    user = user,
    initialized = format(Sys.time(), format = "%Y-%m-%d %H:%M"),
    dms = DBI::dbGetQuery(conn, "select version()")[[1]],
    server = DBI::dbGetQuery(conn, "show server_version")[[1]],
    remarks = remarks
  )
  yaml::write_yaml(log, file.path(path, "project.yaml"))
  # Copy templates
  copy_template(file.path(path, "main-script.R"), main_script)
  if (rs_project) {
    copy_template(file.path(path, paste0(basename(path), ".Rproj")), "rs_project")
  }
  # Save session info
  sessioninfo::session_info(to_file = file.path(path, "session-info-init.log"))
}
