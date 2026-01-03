#' @name print-methods
#' @docType methods
#' @rdname print
#'
#' @title Print Methods
#'
#' @description
#' Print methods for objects of class [backups_info-class].
#'
#' @param x An object of class [backups_info-class].
#' @param cols A character vector with the names of columns selected for the
#'     printed output.
#' @param ... Further arguments passed to next method.
#'
#' @aliases print,backups_info-method
#' @method print backups_info
#' @export
print.backups_info <- function(x, cols, ...) {
  if (missing(cols)) {
    x <- x[c("sort", "released", "backup", "sql", "remarks")]
  } else {
    x <- x[cols]
  }
  NextMethod("print")
}
