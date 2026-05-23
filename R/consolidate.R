consolidar_bases_mensais <- function(pasta_rds,
                                      pasta_saida = pasta_rds,
                                      referencia = NULL) {
  if (is.null(referencia)) {
    data_ref <- seq(Sys.Date(), length.out = 2, by = "-1 month")[2]
    referencia <- format(data_ref, "%m-%Y")
  }

  arquivos <- list.files(pasta_rds, pattern = "\\.rds$", full.names = TRUE)
  if (length(arquivos) == 0) {
    stop("Nenhum arquivo .rds encontrado em: ", pasta_rds)
  }

  info <- fs::file_info(arquivos)
  do_periodo <- arquivos[
    format(info$modification_time, "%m-%Y") == referencia
  ]

  if (length(do_periodo) == 0) {
    warning("Nenhum arquivo encontrado para a referência ", referencia)
    return(invisible(NULL))
  }

  base_consolidada <- purrr::map_dfr(do_periodo, readr::read_rds)

  nome_saida <- sprintf("base_consolidada_%s.csv",
                        gsub("-", "_", referencia))
  caminho_saida <- file.path(pasta_saida, nome_saida)
  readr::write_csv(base_consolidada, caminho_saida)

  message("Base consolidada salva em: ", caminho_saida)
  invisible(caminho_saida)
}
