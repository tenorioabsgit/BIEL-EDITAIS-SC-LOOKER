infer_extensao <- function(url) {
  dplyr::case_when(
    stringr::str_detect(url, "\\.pdf$|pdf\\b")   ~ "pdf",
    stringr::str_detect(url, "\\.docx$|docx\\b") ~ "docx",
    stringr::str_detect(url, "\\.doc$|doc\\b")   ~ "doc",
    TRUE                                          ~ NA_character_
  )
}

destino_arquivo <- function(id, extensao, pasta_pdfs, pasta_docs) {
  pasta <- if (extensao == "pdf") pasta_pdfs else pasta_docs
  file.path(pasta, paste0(id, ".", extensao))
}

ids_ja_baixados <- function(pasta_pdfs) {
  arquivos <- list.files(pasta_pdfs, pattern = "\\.(pdf|doc|docx)$",
                         full.names = FALSE)
  tools::file_path_sans_ext(arquivos)
}

download_editais <- function(df,
                              pasta_pdfs = "arquivos_downloaded/pdfs",
                              pasta_docs = "arquivos_downloaded/docs",
                              max_retries = 3,
                              verbose = TRUE) {
  fs::dir_create(c(pasta_pdfs, pasta_docs))

  ja_baixados <- ids_ja_baixados(pasta_pdfs)
  pendentes <- df |>
    dplyr::filter(!id %in% ja_baixados,
                  !is.na(link_completo_para_editais))

  if (nrow(pendentes) == 0) {
    message("Nenhum edital novo para baixar.")
    return(invisible(df))
  }

  for (i in seq_len(nrow(pendentes))) {
    url <- pendentes$link_completo_para_editais[i]
    id  <- pendentes$id[i]
    ext <- infer_extensao(url)

    if (is.na(ext)) {
      if (verbose) message("Extensão desconhecida, pulando: ", id)
      next
    }

    destino <- destino_arquivo(id, ext, pasta_pdfs, pasta_docs)
    if (verbose) message(sprintf("[%d/%d] %s", i, nrow(pendentes), destino))

    for (tentativa in seq_len(max_retries)) {
      ok <- tryCatch({
        utils::download.file(url, destfile = destino, mode = "wb", quiet = TRUE)
        TRUE
      }, error = function(e) FALSE)
      if (ok) break
      Sys.sleep(2 ^ tentativa)
    }
  }
  invisible(df)
}
