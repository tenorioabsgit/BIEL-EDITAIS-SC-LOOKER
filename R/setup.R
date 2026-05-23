required_packages <- function() {
  c("bigrquery", "rvest", "tidyverse", "xml2",
    "splitstackshape", "janitor", "fs", "plyr",
    "DBI", "httr", "pdftools", "readxl", "yaml")
}

ensure_packages <- function(pkgs = required_packages(), quiet = TRUE) {
  missing <- pkgs[!pkgs %in% rownames(installed.packages())]
  if (length(missing) > 0) {
    message("Installing missing packages: ", paste(missing, collapse = ", "))
    install.packages(missing, dependencies = TRUE)
  }
  invisible(lapply(pkgs, function(p) {
    suppressPackageStartupMessages(require(p, character.only = TRUE, quietly = quiet))
  }))
}
