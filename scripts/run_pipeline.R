# ============================================================================
# BIEL — Pipeline principal
# ============================================================================
# Executa as etapas: descoberta -> raspagem -> tratamento -> downloads ->
# leitura de conteúdo -> carga no BigQuery.
#
# Uso:
#   source("scripts/run_pipeline.R")
#
# Configuração: edite `config/config.local.yml` (copiado de config.example.yml).
# ============================================================================

source("R/setup.R")
ensure_packages()

source("R/config.R")
source("R/lookup_orgaos.R")
source("R/scrape_orgaos.R")
source("R/scrape_editais.R")
source("R/build_links.R")
source("R/download_editais.R")
source("R/read_pdfs.R")
source("R/upload_bigquery.R")

cfg <- load_config()

fs::dir_create(cfg$paths$backups)

orgaos_lookup <- load_orgaos_lookup(
  file.path(cfg$paths$data_raw, "orgaos.csv")
)

# --- Raspagem ---------------------------------------------------------------

raspagem <- purrr::map(cfg$raspagem$anos, function(ano) {
  scrape_editais_do_ano(
    ano        = ano,
    situacao   = cfg$raspagem$situacao,
    base_url   = cfg$portal$base_url,
    max_paginas = cfg$raspagem$max_paginas
  )
})

parametros_raw   <- purrr::map_dfr(raspagem, "parametros")
tabela_editais_raw <- purrr::map_dfr(raspagem, "tabela_editais")

message(sprintf("Total de parâmetros raspados: %d", nrow(parametros_raw)))

# --- Tratamento -------------------------------------------------------------

parametros <- parse_parametros(parametros_raw) |>
  dplyr::mutate(id = build_edital_id(edital, cdo)) |>
  attach_orgao_by_cdo(orgaos_lookup)

tabela_editais <- clean_tabela_editais(tabela_editais_raw) |>
  attach_cdo_by_sigla(orgaos_lookup, sigla_col = "orgao_sigla") |>
  dplyr::mutate(id = build_edital_id(edital, cdo)) |>
  dplyr::filter(!is.na(id)) |>
  dplyr::mutate(
    data_abertura         = stringr::str_sub(abertura, 1, 10),
    data_entrega_proposta = stringr::str_sub(entrega_de_proposta, 1, 10)
  ) |>
  dplyr::distinct(id, .keep_all = TRUE)

base <- dplyr::semi_join(parametros, tabela_editais, by = "id") |>
  attach_links_editais(base_url = cfg$portal$base_url) |>
  dplyr::left_join(tabela_editais, by = "id") |>
  dplyr::distinct()

# --- Persistência intermediária ---------------------------------------------

data_tag <- format(Sys.Date(), "%Y_%m_%d")
backup_sem_conteudo <- file.path(
  cfg$paths$backups,
  sprintf("base_final_sem_conteudo_%s.csv", data_tag)
)
readr::write_csv(base, backup_sem_conteudo)
message("Backup intermediário: ", backup_sem_conteudo)

# --- Download e leitura -----------------------------------------------------

download_editais(
  base,
  pasta_pdfs = cfg$paths$pdfs,
  pasta_docs = cfg$paths$docs
)

base_com_conteudo <- attach_conteudo_editais(
  base,
  pasta_pdfs = cfg$paths$pdfs
)

backup_com_conteudo <- file.path(
  cfg$paths$backups,
  sprintf("base_final_com_conteudo_%s.csv", data_tag)
)
readr::write_csv(base_com_conteudo, backup_com_conteudo)
message("Backup com conteúdo: ", backup_com_conteudo)

# --- BigQuery ---------------------------------------------------------------

if (!is.null(cfg$bigquery$email) &&
    cfg$bigquery$email != "seu-email@exemplo.com") {
  configurar_bigquery_auth(cfg$bigquery$email, cfg$bigquery$key_path)
  upload_para_bigquery(
    base_com_conteudo,
    project   = cfg$bigquery$project,
    dataset   = cfg$bigquery$dataset,
    tablename = cfg$bigquery$table
  )
} else {
  message("BigQuery não configurado em config.local.yml — etapa de upload pulada.")
}
