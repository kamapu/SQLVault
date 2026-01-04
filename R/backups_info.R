#' @name backups_info
#'
#' @title Display Backup Metadata
#'
#' @description
#' Extracting metadata from backups produced by [release_project()] can be
#' displayed in a data frame of class [backups_info-class].
#'
#' Metadata from single SQL file will be extracted by `read_info()`, while
#' `backups_info()` will extract metadata from multiple SQL files.
#'
#' @param sql A character value with the path to a SQL file containing
#'     metadata.
#' @param backup_path A character value with the path to a folder containing
#'     SQL files.
#'
#' @return
#' A data frame of class [backups_info-class].
#'
#' @rdname backups_info
#' @aliases read_info
#'
#' @export
read_info <- function(sql) {
  lines <- readLines(sql, warn = FALSE)
  # Detect head
  start <- grep("^/\\*---\\s*yaml", lines)
  end <- grep("^---\\*/$", lines)
  # Check the head
  if (!length(start)) {
    stop(paste0("The file '", sql, "' does not have a yaml-header."))
  }
  # Import yaml
  yaml_content <- lines[(start + 1):(end - 1)] |>
    paste(collapse = "\n") |>
    yaml::yaml.load() |>
    as.data.frame()
  yaml_content$sort <- 1
  yaml_content$initialized <- strptime(yaml_content$initialized,
    format = "%Y-%m-%d %H:%M"
  )
  yaml_content$released <- strptime(yaml_content$released,
    format = "%Y-%m-%d %H:%M"
  )
  class(yaml_content) <- c("backups_info", "data.frame")
  yaml_content
}

#' @rdname backups_info
#' @export
backups_info <- function(backup_path = ".") {
  backups <- list.files(path = backup_path, pattern = ".sql")
  if (!length(backups)) {
    stop(paste0("No SQL files found in '", backup_path, "'"))
  }
  bckp_info <- list()
  for (i in backups) {
    bckp_info[[i]] <- read_info(file.path(backup_path, i))
  }
  bckp_info <- do.call(rbind, bckp_info)
  rownames(bckp_info) <- NULL
  # Sort and index
  bckp_info <- bckp_info[order(bckp_info$released), ]
  bckp_info$sort <- seq_len(nrow(bckp_info))
  # Retrieve
  bckp_info
}
