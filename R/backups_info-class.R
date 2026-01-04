#' @name backups_info-class
#' @docType class
#'
#' @title Extract Backups Metadata
#'
#' @description
#' SQL files produced by [release_project()] contain metadata that can be
#' extracted into a data.frame.
#'
#' @exportClass backups_info
setOldClass(c("backups_info", "data.frame"))
