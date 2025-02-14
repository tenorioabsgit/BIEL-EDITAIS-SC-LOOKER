# BIEL - Robô Buscador de Informações em Editais de Licitação

## Descrição
Este projeto contém scripts em R para raspagem e processamento de dados de editais de licitação do portal de compras do Estado de Santa Catarina. O objetivo é extrair, consolidar e armazenar essas informações para análise e consulta.

## Estrutura do Projeto
- **biel.R**: Script principal responsável por realizar a raspagem de dados dos editais, processá-los e armazená-los em um banco de dados.
- **consolida_base.R**: Script para consolidar as bases de dados extraídas e gerar um arquivo CSV consolidado.

## Requisitos
Antes de executar os scripts, certifique-se de ter instalado os seguintes pacotes no R:

```r
install.packages(c("bigrquery", "rvest", "tidyverse", "xml2", "splitstackshape", "fs", "plyr"))
```

Além disso, é necessário configurar credenciais de acesso ao BigQuery.

## Como Usar

### Executando `biel.R`
1. Certifique-se de ter os pacotes necessários instalados.
2. Configure corretamente a conexão com o BigQuery e ajuste os caminhos de diretórios, caso necessário.
3. Execute o script no R:

```r
source("biel.R")
```

### Executando `consolida_base.R`
1. Certifique-se de ter as bases de dados RDS armazenadas no diretório especificado no script.
2. Execute o script para consolidar os dados:

```r
source("consolida_base.R")
```

O script gerará um arquivo CSV consolidado com os dados dos editais.

## Contribuição
Sinta-se à vontade para contribuir com melhorias ou relatar problemas abrindo uma issue.

## Licença
Este projeto está sob a licença MIT.
