configurar_bigquery_auth <- function(email, key_path) {
  if (!file.exists(key_path)) {
    stop("Arquivo de credenciais não encontrado: ", key_path)
  }
  httr::set_config(httr::config(ssl_verifypeer = 0L))
  httr::set_config(httr::config(http_version = 0))
  options(httr_oob_default = TRUE)
  bigrquery::bq_auth(email = email, path = key_path)
}

upload_para_bigquery <- function(df, project, dataset, tablename,
                                  overwrite = TRUE) {
  if (nrow(df) == 0) {
    message("DataFrame vazio, nada a enviar.")
    return(invisible(NULL))
  }

  con <- DBI::dbConnect(
    bigrquery::bigquery(),
    project = project,
    dataset = dataset,
    billing = project
  )
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  df_char <- df |> dplyr::mutate(dplyr::across(dplyr::everything(), as.character))

  bigrquery::dbWriteTable(
    con, tablename, df_char,
    append = FALSE,
    overwrite = overwrite,
    row.names = FALSE
  )
  message(sprintf("Upload concluído: %s.%s (%d linhas)",
                  dataset, tablename, nrow(df_char)))
  invisible(df_char)
}
