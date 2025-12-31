#' @name release_project
#'
#' @title Pack an update project for release
#'
#' @description
#' A release project includes an initial backup, a main script and all necessary
#' data to update a database starting by the backup.
#'
#' This function will produce a zip file including all the project's content
#' using the name of the database and a time stamp.
#'
#' @param project_path A character value indicating the path to the project
#'     folder. Note that the project folder must be created by [init_project()].
#' @param backup_path A character value indicating the path to the collection
#'     of backup files (usually a sql and a backup file with timestamp).
#' @param vault A character value providing the path to the folder, where copies
#'     of projects as zip files will be stored.
#' @param release_sql The name of the sql file in the project folder used to
#'     update the database.
#' @param f_timestamp A character value indicating the format used for
#'     timestamp. It has to be the same as the one used by [init_project()].
#' @param restore A logical value indicating whether the database should be
#'     first restored from last backup, which is strictly recommended and the
#'     default setting.
#' @param delete_project A logical value indicating whether the used folder
#'     project should be deleted after release or not. If not provided, it will
#'     be interactivelly prompted.
#' @param ... Further arguments passed to [divDB::do_backup()] and
#'     [divDB::do_restore()] (for instance 'host' and 'port').
#'
#' @export
release_project <- function(
  project_path, backup_path, vault, release_sql, f_timestamp = "%Y%m%d-%H%M",
  restore = TRUE, delete_project, ...
) {
  # Get project metadata and tests
  project_files <- list.files(project_path, pattern = ".yaml")
  if (!"project.yaml" %in% project_files) {
    stop(paste0(
      "Metadata file 'project.yaml' is missing in folder '",
      project_path, "'."
    ))
  } else {
    description <- yaml::read_yaml(file.path(project_path, "project.yaml"))
  }
  if (!"type" %in% names(description)) {
    stop(paste0("Folder '", project_path, "' is not a SQLVault project."))
  }
  if (description$type != "SQLVault.project") {
    stop(paste0("Folder '", project_path, "' is not a SQLVault project."))
  }
  # Move project to tempdir
  tmp_files <- list.files(tempdir())
  if ("sqlvault" %in% tmp_files) {
    unlink(file.path(tempdir(), "sqlvault"))
  }
  dir.create(file.path(tempdir(), "sqlvault"))
  file.copy(
    from = project_path, to = file.path(tempdir(), "sqlvault"),
    recursive = TRUE
  )
  project_path2 <- file.path(tempdir(), "sqlvault", basename(project_path))
  # Restore the database
  if (!restore) {
    warning(paste0(
      "It is recommended to restore the database from the last ",
      "backup.\n  Set 'restore = TRUE' for it."
    ))
  } else {
    divDB::do_restore(
      dbname = description$database, user = description$user,
      filepath = backup_path, f_timestamp = f_timestamp, ...
    )
  }
  # Catch release time
  exec_time <- Sys.time()
  base_name <- paste(description$database,
    format(exec_time, format = f_timestamp),
    sep = "_"
  )
  # Run SQL script
  message(paste0(
    "Database '", description$database, "' will be updated by '",
    release_sql, "'.\n  If something goes wrong, ",
    "you may need to restore it from the last backup file.\n"
  ))
  update_query <- divDB::read_sql(file.path(project_path2, release_sql))
  conn <- divDB::connect_db(
    dbname = description$database,
    user = description$user
  )
  divDB::dbSendQuery(conn, update_query)
  # Produce a backup
  divDB::do_backup(
    dbname = description$database, user = description$user,
    filepath = project_path2, filename = base_name, f_timestamp = NULL, ...
  )
  # Complete description
  description$released <- format(exec_time, format = "%Y-%m-%d %H:%M")
  description$backup <- paste0(base_name, ".backup")
  description$sql <- paste0(base_name, ".sql")
  yaml::write_yaml(description, file.path(project_path2, "project.yaml"))
  sessioninfo::session_info(to_file = file.path(
    project_path2,
    "session-info-release.log"
  ))
  # Prompt delete of project
  if (missing(delete_project)) {
    delete_project <- utils::askYesNo(paste0(
      "Do you like to delete the project at '", project_path,
      "' after release?\n"
    ))
  }
  if (is.na(delete_project)) {
    stop("Release was cancelled by the user.")
  }
  # Write sql and backup
  sql_head <- as(
    paste0(
      "/*--- yaml\n",
      paste0(readLines(file.path(project_path2, "project.yaml")),
        collapse = "\n"
      ), "\n---*/\n\n"
    ),
    "sql"
  )
  update_query[1] <- paste0(sql_head, update_query[1])
  divDB::write_sql(update_query, file = file.path(
    project_path2,
    paste0(base_name, ".sql")
  ))
  # Write files in backup folder
  divDB::write_sql(update_query, file = file.path(
    backup_path,
    paste0(base_name, ".sql")
  ))
  file.copy(
    from = file.path(project_path2, paste0(base_name, ".backup")),
    to = backup_path
  )
  # Write the zip file
  filenames <- list.files(project_path2, recursive = TRUE, full.names = TRUE)
  filenames <- gsub(pattern = paste0(project_path2, "/"), "", filenames)
  zip::zip(
    file.path(
      normalizePath(path.expand(vault)),
      paste0(base_name, ".zip")
    ),
    root = project_path2,
    files = filenames
  )
  # Delete current folder
  if (delete_project) {
    unlink(project_path, recursive = TRUE)
  }
  # Indicate
  message(paste0(
    "Project released as '",
    file.path(normalizePath(path.expand(vault)), paste0(base_name, ".zip")), "'"
  ))
}
