load_orgaos_lookup <- function(path = "data-raw/orgaos.csv") {
  readr::read_csv(path, show_col_types = FALSE) |>
    dplyr::mutate(cdo = as.character(cdo))
}

attach_orgao_by_cdo <- function(df, lookup, cdo_col = "cdo") {
  df[[cdo_col]] <- as.character(df[[cdo_col]])
  df |>
    dplyr::left_join(
      lookup |> dplyr::select(cdo, orgao_sigla = sigla, orgao_nome = nome),
      by = setNames("cdo", cdo_col)
    ) |>
    dplyr::mutate(orgao_nome = dplyr::coalesce(orgao_nome, "Outros"))
}

attach_cdo_by_sigla <- function(df, lookup, sigla_col = "orgao") {
  pattern <- paste0("\\b(", paste(lookup$sigla, collapse = "|"), ")\\b")
  df |>
    dplyr::mutate(
      sigla_match = stringr::str_extract(.data[[sigla_col]], pattern)
    ) |>
    dplyr::left_join(
      lookup |> dplyr::select(sigla_match = sigla, cdo, orgao_nome_full = nome),
      by = "sigla_match"
    ) |>
    dplyr::mutate(
      cdo = dplyr::coalesce(cdo, "Outros"),
      orgao_nome_full = dplyr::coalesce(orgao_nome_full, "Outros")
    ) |>
    dplyr::select(-sigla_match)
}
