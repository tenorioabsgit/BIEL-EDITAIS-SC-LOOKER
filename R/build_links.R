build_link_repositorio <- function(portal, processo, cdo, edital,
                                    base_url = PORTAL_BASE_URL) {
  sprintf(
    "%s/docsl.asp?portal=%s&processo=%s&cdo=%s&edital=%s",
    base_url, portal, processo, cdo, edital
  )
}

scrape_link_final_edital <- function(link_repositorio, max_retries = 3) {
  for (attempt in seq_len(max_retries)) {
    result <- tryCatch({
      page <- rvest::read_html(link_repositorio)
      links <- page |> rvest::html_nodes("a") |> rvest::html_attr("href")
      links[1]
    }, error = function(e) NULL)

    if (!is.null(result)) return(result)
    Sys.sleep(2 ^ attempt)
  }
  NA_character_
}

attach_links_editais <- function(df, base_url = PORTAL_BASE_URL,
                                  verbose = TRUE) {
  df$link_repositorio_edital <- purrr::pmap_chr(
    list(df$portal, df$processo, df$cdo, df$edital),
    build_link_repositorio,
    base_url = base_url
  )

  df$final_url_edital <- purrr::map_chr(
    df$link_repositorio_edital,
    function(link) {
      if (verbose) message("Raspando link final: ", link)
      scrape_link_final_edital(link)
    }
  )

  df$link_completo_para_editais <- paste0(
    base_url, "/", df$final_url_edital
  )
  df
}
