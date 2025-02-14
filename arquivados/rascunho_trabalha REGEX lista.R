
source('arquivados/01_instalacao_de_pacotes.R', encoding = 'utf-8')

base_final <- read.csv('backup_bases/base_final_com_conteudo_2022_03_28.csv')

base_final <- base_final %>% filter(!is.na(conteudo_edital))

#### carrega lista de materiais em lista com tabelas
base_itens <- tabulizer::extract_tables('arquivados/Plano-Anual-de-Compras-2022.pdf')

#### junta todas as tabelas da lista em uma só
base_final_itens <- data.frame()
for (i in 1:length(base_itens)) {
  base_provisoria_itens <- data.frame(base_itens[[i]])
  base_final_itens <- bind_rows(base_final_itens, base_provisoria_itens)
}

base_final_itens <- base_final_itens[1]
colnames(base_final_itens) <- 'itens'
base_final_itens <- base_final_itens[-c(1,2),]
base_final_itens <- as.data.frame(base_final_itens)
colnames(base_final_itens) <- 'itens'

rm(base_itens)
rm(base_provisoria_itens)
rm(i)

base_final_itens$itens <- str_to_lower(base_final_itens$itens)

base_final_itens$itens <- str_remove_all(string = base_final_itens$itens, pattern = '\\*')
base_final_itens$itens <- str_remove_all(string = base_final_itens$itens, pattern = '\\/')
base_final_itens$itens <- str_remove_all(string = base_final_itens$itens, pattern = '\\(')
base_final_itens$itens <- str_remove_all(string = base_final_itens$itens, pattern = '\\)')
base_final_itens$itens <- str_remove_all(string = base_final_itens$itens, pattern = ',')
base_final_itens$itens <- str_remove_all(string = base_final_itens$itens, pattern = '\\+')
base_final_itens$itens <- str_remove_all(string = base_final_itens$itens, pattern = 'x')
base_final_itens$itens <- str_remove_all(string = base_final_itens$itens, pattern = 'cm')
base_final_itens$itens <- str_remove_all(string = base_final_itens$itens, pattern = 'detalhada')
base_final_itens$itens <- str_remove_all(string = base_final_itens$itens, pattern = '\\.')
base_final_itens$itens <- str_remove_all(string = base_final_itens$itens, pattern = '\\.')
base_final_itens$itens <- str_remove_all(string = base_final_itens$itens, pattern = '\\-')
base_final_itens$itens <- str_remove_all(string = base_final_itens$itens, pattern = 'do estado de santa catarina')
base_final_itens$itens <- str_remove_all(string = base_final_itens$itens, pattern = 'acao judicial eclusivo')


base_final_itens <- base_final_itens %>% arrange(itens)
base_final_itens <- base_final_itens %>% distinct(itens, .keep_all = TRUE)

base_final_itens <- base_final_itens[-c(1:416),] 


lista_string_final <- character()
for (t in 1:nrow(base_final)) {
  texto <- base_final$conteudo_edital[t]
  for (i in 1:length(base_final_itens)) {
    item <- base_final_itens[i]
    if (str_detect(string = texto, pattern = item) == TRUE) {
      lista_string_final <- paste0(lista_string_final,' + ', item)
    }
    print(item)
    print(paste0('Texto ', t,' de ', nrow(base_final)))
  }
  
  base_final$termos_encontrados[t] <- lista_string_final
  lista_string_final <- character()
}




