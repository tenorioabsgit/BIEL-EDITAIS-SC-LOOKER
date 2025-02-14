#devtools::install_github("r-dbi/bigrquery")

httr::set_config(httr::config(ssl_verifypeer = 0L))
httr::set_config(httr::config(http_version = 0))
options(httr_oob_default = TRUE)

bq_auth(email = 'tenorioabs@gmail.com', path = "/home/pira/google_drive/Estudo/json/dou-sc.json")

billing <- "auspicious-crow-344115"

library(DBI)

con <- dbConnect(
  bigrquery::bigquery(),
  project = "auspicious-crow-344115",
  dataset = "projeto_dou_sc",
  billing = billing
)
con

if(nrow(base_final)>0){
  tablename <- "tabela_dou_sc"

  base_final <- base_final %>% mutate_all(as.character)

  bigrquery::dbWriteTable(con, tablename, base_final, append=F, verbose = T, row.names=F, overwrite=T, fields=base_final)
  print("Dataframe Ocorrencias Uploaded")
}

# if(nrow(itens)>0){
#   tablename <- "tabela_itens"
#   
#   tabela_itens <- tabela_itens %>% mutate_all(as.character)
#   
#   bigrquery::dbWriteTable(con, tablename, itens, append=F, verbose = T, row.names=F, overwrite=T, fields=itens)
#   print("Dataframe Ocorrencias Uploaded")
# }
