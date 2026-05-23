load_config <- function(path = "config/config.local.yml",
                         fallback = "config/config.example.yml") {
  caminho <- if (file.exists(path)) path else fallback
  message("Carregando configuração de: ", caminho)
  cfg <- yaml::read_yaml(caminho)
  validar_config(cfg)
  cfg
}

validar_config <- function(cfg) {
  obrigatorios <- list(
    "portal$base_url"     = cfg$portal$base_url,
    "raspagem$anos"       = cfg$raspagem$anos,
    "paths$pdfs"          = cfg$paths$pdfs,
    "paths$backups"       = cfg$paths$backups,
    "bigquery$project"    = cfg$bigquery$project
  )
  faltando <- names(obrigatorios)[purrr::map_lgl(obrigatorios, is.null)]
  if (length(faltando) > 0) {
    stop("Configuração inválida. Campos ausentes: ",
         paste(faltando, collapse = ", "))
  }
  invisible(TRUE)
}
