
source('01_instalacao_de_pacotes.R', encoding = 'utf-8')

base_final <- read.csv('backup_bases/base_final_sem_conteudo_2022_03_23.csv')

lista_pdf <- list.files(path = 'arquivos_downloaded/', pattern = '*.pdf', full.names = TRUE)

lista_pdf <- sort(lista_pdf, decreasing = FALSE)
base_final <- base_final %>% arrange(id)


base_final$conteudo_edital <- NA
base_final$id_arquivo <- NA
for (i in 333:length(lista_pdf)) {
  base_final$conteudo_edital[i] <- str_flatten(pdftools::pdf_text(pdf = lista_pdf[i]))
  base_final$id_arquivo[i] <- lista_pdf[i]
  print(paste0("Carregando conteúdo do Edital ",i, ' de ',length(lista_pdf)))
  print(paste0("ID: ",base_final$id[i],' - ',str_remove(string = lista_pdf[i], pattern = 'arquivos_downloaded/')))
}


table(is.na(base_final$conteudo_edital))

conferencia <- base_final[,c(7,21)]
conferencia <- cSplit(conferencia, "id_arquivo", sep="//")
conferencia <- conferencia[,-c(2)]
conferencia <- conferencia %>% rename("id_arquivo" = "id_arquivo_2")

data <- str_replace_all(string = Sys.Date(), pattern = '-', replacement = '_')
write.csv(base_final, paste0('backup_bases/base_final_com_conteudo_', data, '.csv'))

source('00.sobe_dados_big_query.R', encoding = 'utf-8')
