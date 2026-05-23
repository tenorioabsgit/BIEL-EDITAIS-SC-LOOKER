extrair_conteudo_pdf <- function(caminho) {
  tryCatch(
    stringr::str_flatten(pdftools::pdf_text(caminho)),
    error = function(e) NA_character_
  )
}

attach_conteudo_editais <- function(df,
                                     pasta_pdfs = "arquivos_downloaded/pdfs",
                                     verbose = TRUE) {
  lista_pdf <- list.files(pasta_pdfs, pattern = "\\.pdf$", full.names = TRUE)
  if (length(lista_pdf) == 0) {
    df$conteudo_edital <- NA_character_
    df$id_arquivo <- NA_character_
    return(df)
  }

  pdfs <- tibble::tibble(
    id_arquivo = lista_pdf,
    id = tools::file_path_sans_ext(basename(lista_pdf))
  )

  pdfs$conteudo_edital <- purrr::map_chr(
    pdfs$id_arquivo,
    function(p) {
      if (verbose) message("Extraindo: ", basename(p))
      extrair_conteudo_pdf(p)
    }
  )

  df |>
    dplyr::left_join(pdfs, by = "id") |>
    dplyr::filter(!is.na(conteudo_edital))
}
