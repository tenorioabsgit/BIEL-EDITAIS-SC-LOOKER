build_listagem_url <- function(ano, pagina,
                                situacao = 4,
                                base_url = PORTAL_BASE_URL) {
  sprintf(
    paste0(
      "%s/acompanha_licitacao_edital.asp?",
      "lstOrgaos=1&optNatureza=&lstAno=%s&lstSituacao=%s",
      "&txtNuEdital=&lstModalidade=0&txtObjeto=",
      "&dataInclusao=&descricaoGrupoClasse=&paginaAtual=%s"
    ),
    base_url, ano, situacao, pagina
  )
}

scrape_pagina_listagem <- function(url) {
  page <- tryCatch(rvest::read_html(url), error = function(e) NULL)
  if (is.null(page)) return(NULL)

  parametros <- page |>
    rvest::html_nodes("img") |>
    rvest::html_attr("onclick") |>
    purrr::discard(is.na)

  if (length(parametros) == 0) return(NULL)

  tabelas <- page |> rvest::html_table()
  tabela_editais <- if (length(tabelas) >= 2) as.data.frame(tabelas[[2]]) else NULL

  list(parametros = tibble::tibble(parametros = parametros),
       tabela = tabela_editais)
}

scrape_editais_do_ano <- function(ano, situacao = 4,
                                   base_url = PORTAL_BASE_URL,
                                   max_paginas = 500,
                                   verbose = TRUE) {
  parametros_acc <- list()
  tabela_acc <- list()

  for (pagina in seq_len(max_paginas)) {
    url <- build_listagem_url(ano, pagina, situacao, base_url)
    if (verbose) message(sprintf("[ano %s] página %s", ano, pagina))

    resultado <- scrape_pagina_listagem(url)
    if (is.null(resultado)) break

    parametros_acc[[pagina]] <- resultado$parametros
    if (!is.null(resultado$tabela)) tabela_acc[[pagina]] <- resultado$tabela
  }

  list(
    parametros = dplyr::bind_rows(parametros_acc) |> dplyr::distinct(),
    tabela_editais = dplyr::bind_rows(tabela_acc) |> dplyr::distinct()
  )
}

parse_parametros <- function(parametros_df) {
  parametros_df |>
    splitstackshape::cSplit("parametros", sep = "'") |>
    dplyr::transmute(
      portal   = as.character(parametros_2),
      processo = dplyr::coalesce(as.character(parametros_4), ""),
      edital   = as.character(parametros_6),
      cdo      = as.character(parametros_8)
    ) |>
    dplyr::arrange(edital)
}

clean_tabela_editais <- function(tabela) {
  if (nrow(tabela) == 0) return(tabela)

  colnames(tabela) <- as.character(tabela[1, ])
  tabela <- tabela[-1, , drop = FALSE]
  tabela <- janitor::clean_names(tabela)

  tabela |>
    dplyr::rename(edital = processo, orgao_sigla = orgao) |>
    dplyr::arrange(edital) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character)) |>
    fix_column_alignment()
}

# Algumas linhas da tabela raspada vêm com colunas deslocadas (entrega_de_proposta
# vira texto e o conteudo real fica em "docs"/"na"). Esta função corrige.
fix_column_alignment <- function(tabela) {
  required <- c("entrega_de_proposta", "docs", "situacao", "na")
  if (!all(required %in% names(tabela))) return(tabela)

  desloc <- !is.na(tabela$entrega_de_proposta) &
    stringr::str_detect(tabela$entrega_de_proposta, "[A-Za-z]")

  tabela$entrega_de_proposta[desloc] <- tabela$docs[desloc]
  tabela$situacao[desloc]            <- tabela$na[desloc]

  tabela |> dplyr::select(-dplyr::any_of(c("docs", "na")))
}

build_edital_id <- function(edital, cdo) {
  paste0(gsub("/", "", edital), "_", cdo)
}
