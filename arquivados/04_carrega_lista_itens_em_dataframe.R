
source('01_instalacao_de_pacotes.R', encoding = 'utf-8')

options(warn = -1)

#### carrega lista de materiais em lista com tabelas
base_itens <- tabulizer::extract_tables('Plano-Anual-de-Compras-2022.pdf')

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
# base_final_itens <- base_final_itens %>% filter()
# colnames(base_final_itens) <- 'itens'
# base_final_itens <- base_final_itens %>% filter(itens != '')
# base_final_itens <- cSplit(base_final_itens, "itens", sep=" ")
# base_final_itens <- cSplit(base_final_itens, "itens_01", sep=",")
# base_final_itens <- base_final_itens[,itens_01_1]
# base_final_itens <- as.data.frame(base_final_itens)
# base_final_itens <- base_final_itens %>% distinct()

rm(base_itens)
rm(base_provisoria_itens)
rm(i)
