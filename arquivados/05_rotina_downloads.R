source(file = '/home/pira/google_drive/ciencia_de_dados/R/DOU_SC/01_instalacao_de_pacotes.R', encoding = 'utf-8')

retry <- function(a, max = Inf, init = 0){suppressWarnings( tryCatch({
  if(init<max) a
}, error = function(e){retry(a, max, init = init+1)}))}

#########################
#### rotina para fazer download dos arquivos

base_final_lista_download <- read.csv('/home/pira/google_drive/ciencia_de_dados/R/DOU_SC/backup_bases/base_final_lista_download_sem_conteudo_2022_03_23.csv')

id <- list.files(path = 'arquivos_downloaded/pdfs/', pattern = '*', full.names = TRUE)
id <- str_remove(string = id, pattern = 'arquivos_downloaded/pdfs//')
id <- str_remove(string = id, pattern = '.pdf')
id <- str_remove(string = id, pattern = '.doc')
id <- str_remove(string = id, pattern = '.docx')
lista_pdf <- data.frame(id)
colnames(lista_pdf) <- 'id'
base_final_lista_download <- base_final
base_final_lista_download <- anti_join(x = base_final_lista_download, y = lista_pdf, by = 'id')

while (nrow(base_final_lista_download) > 1) {
  for (i in 1:nrow(base_final_lista_download)) {
    print(paste0('Baixando arquivo ',i, ' de ', nrow(base_final_lista_download)))
    
    if (str_detect(string = base_final_lista_download$link_completo_para_editais[i], pattern = 'pdf')) {
      try(download.file(url = base_final_lista_download$link_completo_para_editais[i],
                        destfile = paste0('/home/pira/google_drive/ciencia_de_dados/R/DOU_SC/arquivos_downloaded/pdfs/',
                                          base_final_lista_download$id[i],
                                          '.pdf')))}
    else if (str_detect(string = base_final_lista_download$link_completo_para_editais[i], pattern = 'doc$')) {
      try(download.file(url = base_final_lista_download$link_completo_para_editais[i],
                        destfile = paste0('/home/pira/google_drive/ciencia_de_dados/R/DOU_SC/arquivos_downloaded/pdfs/',
                                          base_final_lista_download$id[i],
                                          '.doc')))}
    else if (str_detect(string = base_final_lista_download$link_completo_para_editais[i], pattern = 'doc$')) {
      try(download.file(url = base_final_lista_download$link_completo_para_editais[i],
                        destfile = paste0('/home/pira/google_drive/ciencia_de_dados/R/DOU_SC/arquivos_downloaded/pdfs/',
                                          base_final_lista_download$id[i],
                                          '.docx')))}
  }
  id <- list.files(path = 'arquivos_downloaded/pdfs/', pattern = '*', full.names = TRUE)
  id <- str_remove(string = id, pattern = 'arquivos_downloaded/pdfs//')
  id <- str_remove(string = id, pattern = '.pdf')
  id <- str_remove(string = id, pattern = '.doc')
  id <- str_remove(string = id, pattern = '.docx')
  lista_pdf <- data.frame(id)
  colnames(lista_pdf) <- 'id'
  base_final_lista_download <- base_final
  base_final_lista_download <- anti_join(x = base_final_lista_download, y = lista_pdf, by = 'id')
  
}

# base_itens <- tabulizer::extract_tables(base_final_lista_download$link_completo_para_editais[i])
# #### junta todas as tabelas da lista em uma só
# base_final_lista_download_itens <- data.frame()
# for (i in 1:length(base_itens)) {
#   base_provisoria_itens <- data.frame(base_itens[[i]])
#   base_final_lista_download_itens <- bind_rows(base_final_lista_download_itens, base_provisoria_itens)
# }
# # ou
# #  
source(file = '/home/pira/google_drive/ciencia_de_dados/R/DOU_SC/01_instalacao_de_pacotes.R', encoding = 'utf-8')

retry <- function(a, max = Inf, init = 0){suppressWarnings( tryCatch({
  if(init<max) a
}, error = function(e){retry(a, max, init = init+1)}))}

#########################
#### rotina para fazer download dos arquivos

base_final_lista_download <- read.csv('/home/pira/google_drive/ciencia_de_dados/R/DOU_SC/backup_bases/base_final_lista_download_sem_conteudo_2022_03_23.csv')

id <- list.files(path = 'arquivos_downloaded/', pattern = '*.pdf', full.names = TRUE)
id <- str_remove(string = id, pattern = 'arquivos_downloaded//')
id <- str_remove(string = id, pattern = '.pdf')
lista_pdf <- data.frame(id)
colnames(lista_pdf) <- 'id'
base_final_lista_download <- base_final
base_final_lista_download <- anti_join(x = base_final_lista_download, y = lista_pdf, by = 'id')

for (i in 1:nrow(base_final_lista_download_lista_download)) {
  print(paste0('Baixando arquivo ',i, ' de ', nrow(base_final_lista_download)))
  if (str_detect(string = try(html_text(read_html(base_final_lista_download$link_completo_para_editais[i]))), pattern = 'PDF')) 
  {xml2::download_html(url = base_final_lista_download$link_completo_para_editais[i],
                       file =  paste0('/home/pira/google_drive/ciencia_de_dados/R/DOU_SC/arquivos_downloaded/',
                                            base_final_lista_download$id[i],
                                            '.pdf'))}
  else
  {xml2::download_html(url = base_final_lista_download$link_completo_para_editais[i],
                       file =  paste0('/home/pira/google_drive/ciencia_de_dados/R/DOU_SC/arquivos_downloaded/',
                                            base_final_lista_download$id[i],
                                            '.pdf'))}
}

