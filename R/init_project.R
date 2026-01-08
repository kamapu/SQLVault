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
#' @param remarks A character value describing the project.
#' @param restore_from A character value. The path to the acummulated backups.
#'     If not provided a warning as reminder will be retrieved.
#' @param r_script A logical value indicating whether a template R script
#'     should be included in the project or not. The default is 'TRUE'.
#' @param rs_project A logical value indicating whether an R Studio project
#'     should be initialized or not. This may be useful to proceed with the
#'     ETL workflow in an own R Studio project. The default is 'FALSE'.
#' @param overwrite A logical value indicating whether an existing homonymous
#'     project should be overwritten or not.
#' @param ... Further arguments passed to [divDB::connect_db()],
#'     [divDB::do_backup()] and [divDB::do_restore()] (for instance 'host' and
#'     'port').
#'
#' @export
init_project <- function(
  dbname, user, path, remarks = "", restore_from, r_script = TRUE,
  rs_project = FALSE, overwrite = FALSE, ...
) {
  # Restore in advance
  if (missing(restore_from)) {
    warning(paste0(
      "It is recommended to restore the database from the last ",
      "backup.\n  Set 'restore_from' for it."
    ))
  } else {
    divDB::do_restore(
      dbname = dbname, user = user, filepath = restore_from,
      ...
    )
  }
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
  # Connect the database
  conn <- divDB::connect_db(dbname = dbname, user = user, ...)
  on.exit(divDB::disconnect_db(conn), add = TRUE)
  # Write a log file
  log <- list(
    type = "SQLVault.project",
    database = dbname,
    user = user,
    initialized = format(Sys.time(), format = "%Y-%m-%d %H:%M"),
    dms = DBI::dbGetQuery(conn, "select version()")[[1]],
    server = DBI::dbGetQuery(conn, "show server_version")[[1]],
    remarks = remarks
  )
  yaml::write_yaml(log, file.path(path, "project.yaml"))
  # Copy templates
  if (r_script) {
    copy_template(file.path(path, "main-script.R"), "main-script")
  }
  if (rs_project) {
    copy_template(
      file.path(path, paste0(basename(path), ".Rproj")),
      "rs_project"
    )
  }
  # Save session info
  sessioninfo::session_info(to_file = file.path(path, "session-info-init.log"))
}
