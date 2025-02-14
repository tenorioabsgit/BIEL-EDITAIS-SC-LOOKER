
library(tidyverse)
## lista todas as bases armazenadas no diretório
lista_bases <- list.files('/home/pira/Downloads/Arquivos RDS', pattern = '*.rds', full.names = TRUE)

## captura a mês e ano atual, diminui 1 unidade no mes e gera o consolidado_referencia
consolidado_referencia <- format(Sys.Date(), '%m-%Y')
mes <- paste0('0',as.character(as.numeric(str_sub(consolidado_referencia, 1,2))-1))
ano <- str_sub(consolidado_referencia, 4,7)
consolidado_referencia <- paste0(mes, '-', ano)

#
lista_bases_referencia <- list()
for (base in 1:length(lista_bases)) {
  if (str_detect(format(tail(fs::file_info(lista_bases[[base]])$modification_time), '%m-%Y'), consolidado_referencia)==TRUE){
    #lista <- lista_bases[[base]]
    #lista_bases_referencia <- append(lista_bases_referencia, lista)
    print(lista_bases[[base]])
  }
}


format(tail(fs::file_info(lista_bases)$modification_time), '%m-%Y') 


tail(fs::file_info(lista_bases[45])$modification_time)



a = 'a'
b= 'b' 
c= 'a'


str_detect(a, c)


mes <- as.numeric(format(Sys.Date(), '%m')) - 1
ano <- as.numeric(format(Sys.Date(), '%Y'))
nome_arquivo_csv <- paste0('base_consolidada_cni_', mes, '_', ano, '.csv')

base_consolidada <- ldply(lista, read_rds)
write.csv(base_consolidada, paste0('/home/pira/Downloads/rstudio-export/',nome_arquivo_csv))




