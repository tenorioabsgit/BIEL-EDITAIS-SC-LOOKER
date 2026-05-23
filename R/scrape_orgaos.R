PORTAL_BASE_URL <- "https://sistemas4.sc.gov.br/sea/portaldecompras"

scrape_orgaos_from_portal <- function(base_url = PORTAL_BASE_URL) {
  url <- paste0(base_url, "/pesquisa_editais_p.asp?cdo=**CDO**")
  page <- rvest::read_html(url)

  options <- page |> rvest::html_nodes("option")
  tibble::tibble(
    cdo = options |> rvest::html_attr("value"),
    nome = options |> rvest::html_text()
  ) |>
    dplyr::filter(!is.na(cdo), cdo != "", nchar(cdo) > 0)
}

scrape_anos_disponiveis <- function(base_url = PORTAL_BASE_URL) {
  url <- paste0(base_url, "/pesquisa_editais_p.asp?cdo=**CDO**")
  selects <- rvest::read_html(url) |> rvest::html_nodes("select")
  anos <- selects[[2]] |> rvest::html_nodes("option") |> rvest::html_text()
  as.integer(anos[grepl("^\\d{4}$", anos)])
}
