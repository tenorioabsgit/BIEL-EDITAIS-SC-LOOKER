
source(file = '01_instalacao_de_pacotes.R', encoding = 'utf-8')
source(file = '02_lista_orgaos_e_anos.R', encoding = 'utf-8')
df_anos <- df_anos[17,]
#########################

################################################################################
#### captura os parâmetros para compor as URLs de acesso aos repositórios dos editais
#### respositórios contidos nas primeiras 10 páginas

options(warn = -1)

tabela_url <- data.frame()
base_parametros_final <- data.frame()

for (a in 1:length(df_anos)) {
  ano <- df_anos[a]
  i <- 1
  link_base <- paste0('https://sistemas4.sc.gov.br/sea/portaldecompras/acompanha_licitacao_edital.asp?lstOrgaos=1&optNatureza=&lstAno=',ano,'&lstSituacao=4&txtNuEdital=&lstModalidade=0&txtObjeto=&dataInclusao=&descricaoGrupoClasse=&paginaAtual=')
  link <- paste0(link_base,i)
  while (length(try(busca_parametros <- as.data.frame(read_html(link) %>% html_nodes("img") %>% html_attr("onclick"))) >= 1)) {
    #### captura parametros
    print(paste0('Capturando Parâmetros da Página ', i))
    base_parametros_final <- bind_rows(base_parametros_final, busca_parametros)
    
    #### captura tabelas de url
    try(page <- read_html(link) %>% html_table()) 
    print(paste0('Raspando ano: ', ano))
    print(paste0('Link: ', link))
    tabela <- as.data.frame(page[2])
    tabela_url <- bind_rows(tabela_url, tabela)
    i <- i + 1
    link <- paste0(link_base,i)
  }  
}

base_parametros_final <- base_parametros_final %>% mutate_all(as.character)
tabela_url <- tabela_url %>% mutate_all(as.character)

base_parametros_final <- base_parametros_final %>% distinct()
tabela_url <- tabela_url %>% distinct()

print(paste0('Total de Editais encontrados: ', nrow(base_parametros_final)))

rm(busca_parametros)
rm(link)
rm(link_base)
rm(num_pags)
rm(page)
rm(tabela)
rm(a)
rm(i)
rm(df_anos)
rm(ano)

################################################################################
#### tratas as bases capturadas na rotina anterior

colnames(base_parametros_final) <- 'parametros'
base_parametros_final <- cSplit(base_parametros_final, "parametros", sep="'")
base_parametros_final <- base_parametros_final[,c(2,4,6,8)]
base_parametros_final <- base_parametros_final %>% rename("portal" = "parametros_2",
                                                          "processo" = "parametros_4",
                                                          "edital" = "parametros_6",
                                                          "cdo" = "parametros_8")
base_parametros_final$processo[is.na(base_parametros_final$processo)] <- ''
base_parametros_final <- base_parametros_final %>% arrange(edital)

colnames(tabela_url) <- tabela_url[1,]
tabela_url <- tabela_url[-1,]
tabela_url <- clean_names(tabela_url) 
tabela_url <- tabela_url %>% arrange(processo)
tabela_url <- tabela_url %>% rename("edital" = "processo",
                                    "orgao_sigla" = "orgao")


#### cria coluna orgaos com REGEX aplicado na coluna CDO

base_parametros_final$orgao <- case_when(
  str_detect(string = base_parametros_final$cdo, pattern = '^2300$')==TRUE ~ 'Agência de Desenvolvimento do Turismo - SANTUR',
  str_detect(string = base_parametros_final$cdo, pattern = '^302$')==TRUE ~ 'Agência de Fomento do Estado de Santa Catarina - BADESC',
  str_detect(string = base_parametros_final$cdo, pattern = '^2729$')==TRUE ~ 'Agência de Regulação de Serviços Públicos de Santa Catarina - ARESC',
  str_detect(string = base_parametros_final$cdo, pattern = '^4101$')==TRUE ~ 'Casa Civil - CC',
  str_detect(string = base_parametros_final$cdo, pattern = '^301$')==TRUE ~ 'Centro de Informática e Automação de Santa Catarina - CIASC',
  str_detect(string = base_parametros_final$cdo, pattern = '^2622$')==TRUE ~ 'Companhia de Habitação do Estado de Santa Catarina S/A - COHAB/SC',
  str_detect(string = base_parametros_final$cdo, pattern = '^4422$')==TRUE ~ 'Companhia Integrada de Desenv. Agricola de Santa Catarina - CIDASC',
  str_detect(string = base_parametros_final$cdo, pattern = '^4107$')==TRUE ~ 'Controladoria Geral do Estado',
  str_detect(string = base_parametros_final$cdo, pattern = '^1685$')==TRUE ~ 'Corpo de Bombeiros Militar - CBM/SC - Fundo de Melhoria',
  str_detect(string = base_parametros_final$cdo, pattern = '^1501$')==TRUE ~ 'Defensoria Pública do Estado de Santa Catarina - DPE',
  str_detect(string = base_parametros_final$cdo, pattern = '^5501$')==TRUE ~ 'Defesa Cívil - DC',
  str_detect(string = base_parametros_final$cdo, pattern = '^5325$')==TRUE ~ 'Departamento Estadual de Infraestrutura - DEINFRA',
  str_detect(string = base_parametros_final$cdo, pattern = '^4112$')==TRUE ~ 'Departamento Estadual de Trânsito - DETRAN/SC',
  str_detect(string = base_parametros_final$cdo, pattern = '^9$')==TRUE ~ 'Empresa de Pesquisa Agropecuária e Extensão Rural de Santa Catarina - EPAGRI',
  str_detect(string = base_parametros_final$cdo, pattern = '^2322$')==TRUE ~ 'Fundação Catarinense de Cultura - FCC',
  str_detect(string = base_parametros_final$cdo, pattern = '^4521$')==TRUE ~ 'Fundação Catarinense de Educação Especial - FCEE',
  str_detect(string = base_parametros_final$cdo, pattern = '^2006$')==TRUE ~ 'Fundação Catarinense de Esporte - FCE',
  str_detect(string = base_parametros_final$cdo, pattern = '^4524$')==TRUE ~ 'Fundação de Amparo á Pesquisa  e Inovação do Estado de Santa Catarina - FAPESC',
  str_detect(string = base_parametros_final$cdo, pattern = '^200$')==TRUE ~ 'Fundação de Previdência Complementar do Estado de Santa Catarina - SCPREV',
  str_detect(string = base_parametros_final$cdo, pattern = '^5230$')==TRUE ~ 'Fundação Escola de Governo - ENA',
  str_detect(string = base_parametros_final$cdo, pattern = '^4522$')==TRUE ~ 'Fundação Universidade do Estado de Santa Catarina - UDESC',
  str_detect(string = base_parametros_final$cdo, pattern = '^4201$')==TRUE ~ 'Gabinete do Vice-Governador - GVG',
  str_detect(string = base_parametros_final$cdo, pattern = '^1504$')==TRUE ~ 'Imprensa Oficial do Estado de Santa Catarina - IOESC',
  str_detect(string = base_parametros_final$cdo, pattern = '^4722$')==TRUE ~ 'Instituto de Previdência do Estado de Santa Catarina - IPREV',
  str_detect(string = base_parametros_final$cdo, pattern = '^2721$')==TRUE ~ 'Instituto do Meio Ambiente - IMA',
  str_detect(string = base_parametros_final$cdo, pattern = '^5222$')==TRUE ~ 'Junta Comercial do Estado de Santa Catarina - JUCESC',
  str_detect(string = base_parametros_final$cdo, pattern = '^4301$')==TRUE ~ 'Ministério Público de Contas do Estado de Santa Catarina - MPC',
  str_detect(string = base_parametros_final$cdo, pattern = '^4001$')==TRUE ~ 'Ministério Público do Estado de Santa Catarina Procuradoria Geral de Justiça - MPSC',
  str_detect(string = base_parametros_final$cdo, pattern = '^1699$')==TRUE ~ 'Polícia Científica de Santa Catarina',
  str_detect(string = base_parametros_final$cdo, pattern = '^1605$')==TRUE ~ 'Polícia Civil - PC',
  str_detect(string = base_parametros_final$cdo, pattern = '^1606$')==TRUE ~ 'Polícia Militar do Estado de Santa Catarina - PM/SC',
  str_detect(string = base_parametros_final$cdo, pattern = '^201$')==TRUE ~ 'Procuradoria Geral do Estado de Santa Catarina - PGE',
  str_detect(string = base_parametros_final$cdo, pattern = '^111$')==TRUE ~ 'Santa Catarina Participação e Investimentos S.A.',
  str_detect(string = base_parametros_final$cdo, pattern = '^2323$')==TRUE ~ 'Santa Catarina Turismo S.A. - SCTUR',
  str_detect(string = base_parametros_final$cdo, pattern = '^1823$')==TRUE ~ 'SC Participações e Parcerias S.A. - SCPar',
  str_detect(string = base_parametros_final$cdo, pattern = '^4126$')==TRUE ~ 'SCPAR Porto de Imbituba S/A',
  str_detect(string = base_parametros_final$cdo, pattern = '^4130$')==TRUE ~ 'PSFS Porto de São Francisco do Sul S/A',
  str_detect(string = base_parametros_final$cdo, pattern = '^1700$')==TRUE ~ 'Secretaria de Estado da Administração - SEA',
  str_detect(string = base_parametros_final$cdo, pattern = '^801$')==TRUE ~ 'Secretaria de Estado da Administração Prisional e Socioeducativa - SAP',
  str_detect(string = base_parametros_final$cdo, pattern = '^4401$')==TRUE ~ 'Secretaria de Estado da Agricultura e da Pesca - SAR',
  str_detect(string = base_parametros_final$cdo, pattern = '^4501$')==TRUE ~ 'Secretaria de Estado da Educação - SED',
  str_detect(string = base_parametros_final$cdo, pattern = '^5201$')==TRUE ~ 'Secretaria de Estado da Fazenda - SEF',
  str_detect(string = base_parametros_final$cdo, pattern = '^5301$')==TRUE ~ 'Secretaria de Estado da Infraestrutura e Mobilidade - SIE',
  str_detect(string = base_parametros_final$cdo, pattern = '^4891$')==TRUE ~ 'Secretaria de Estado da Saúde - SES',
  str_detect(string = base_parametros_final$cdo, pattern = '^1601$')==TRUE ~ 'Secretaria de Estado da Segurança Pública - SSP',
  str_detect(string = base_parametros_final$cdo, pattern = '^2700$')==TRUE ~ 'Secretaria de Estado do Desenvolvimento Econômico Sustentável - SDE',
  str_detect(string = base_parametros_final$cdo, pattern = '^2601$')==TRUE ~ 'Secretaria de Estado do Desenvolvimento Social - SDS',
  str_detect(string = base_parametros_final$cdo, pattern = '^1801$')==TRUE ~ 'Secretaria de Estado do Planejamento - SPG',
  str_detect(string = base_parametros_final$cdo, pattern = '^4103$')==TRUE ~ 'Secretaria Executiva de Articulação Nacional - SAI',
  str_detect(string = base_parametros_final$cdo, pattern = '^5801$')==TRUE ~ 'Secretaria Executiva de Comunicação - SEC',
  str_detect(string = base_parametros_final$cdo, pattern = '^1802$')==TRUE ~ 'Superintendência de Desenvolvimento da Região Metropolitana da Grande Florianópolis',
  str_detect(string = base_parametros_final$cdo, pattern = '^4002$')==TRUE ~ 'Tribunal de Contas do Estado de Santa Catarina - TCE',
  str_detect(string = base_parametros_final$cdo, pattern = '^9101$')==TRUE ~ 'Agência de Desenvolvimento Regional - Araranguá',
  str_detect(string = base_parametros_final$cdo, pattern = '^8401$')==TRUE ~ 'Agência de Desenvolvimento Regional - Blumenau',
  str_detect(string = base_parametros_final$cdo, pattern = '^7701$')==TRUE ~ 'Agência de Desenvolvimento Regional - Campos Novos',
  str_detect(string = base_parametros_final$cdo, pattern = '^7301$')==TRUE ~ 'Agência de Desenvolvimento Regional - Chapecó',
  str_detect(string = base_parametros_final$cdo, pattern = '^7501$')==TRUE ~ 'Agência de Desenvolvimento Regional - Concórdia',
  str_detect(string = base_parametros_final$cdo, pattern = '^9001$')==TRUE ~ 'Agência de Desenvolvimento Regional - Criciúma',
  str_detect(string = base_parametros_final$cdo, pattern = '^8001$')==TRUE ~ 'Agência de Desenvolvimento Regional - Curitibanos',
  str_detect(string = base_parametros_final$cdo, pattern = '^8601$')==TRUE ~ 'Agência de Desenvolvimento Regional - Itajaí',
  str_detect(string = base_parametros_final$cdo, pattern = '^9301$')==TRUE ~ 'Agência de Desenvolvimento Regional - Jaraguá do Sul',
  str_detect(string = base_parametros_final$cdo, pattern = '^7601$')==TRUE ~ 'Agência de Desenvolvimento Regional - Joaçaba',
  str_detect(string = base_parametros_final$cdo, pattern = '^9201$')==TRUE ~ 'Agência de Desenvolvimento Regional - Joinville',
  str_detect(string = base_parametros_final$cdo, pattern = '^9601$')==TRUE ~ 'Agência de Desenvolvimento Regional - Lages',
  str_detect(string = base_parametros_final$cdo, pattern = '^9401$')==TRUE ~ 'Agência de Desenvolvimento Regional - Mafra',
  str_detect(string = base_parametros_final$cdo, pattern = '^7101$')==TRUE ~ 'Agência de Desenvolvimento Regional - Maravilha',
  str_detect(string = base_parametros_final$cdo, pattern = '^8101$')==TRUE ~ 'Agência de Desenvolvimento Regional - Rio do Sul',
  str_detect(string = base_parametros_final$cdo, pattern = '^7201$')==TRUE ~ 'Agência de Desenvolvimento Regional - São Lourenço do Oeste',
  str_detect(string = base_parametros_final$cdo, pattern = '^7001$')==TRUE ~ 'Agência de Desenvolvimento Regional - São Miguel do Oeste',
  str_detect(string = base_parametros_final$cdo, pattern = '^8901$')==TRUE ~ 'Agência de Desenvolvimento Regional - Tubarão',
  str_detect(string = base_parametros_final$cdo, pattern = '^7801$')==TRUE ~ 'Agência de Desenvolvimento Regional - Videira',
  str_detect(string = base_parametros_final$cdo, pattern = '^7401$')==TRUE ~ 'Agência de Desenvolvimento Regional - Xanxerê',
  str_detect(string = base_parametros_final$cdo, pattern = '^5323$')==TRUE ~ 'Departamento de Transportes e Terminais - DETER',
  TRUE ~ 'Outros'
)

#### cria coluna com o código do orgao na tabela_url

tabela_url$cdo <- case_when(
  str_detect(string = tabela_url$orgao, pattern = '^SANTUR$')==TRUE ~ '2300',
  str_detect(string = tabela_url$orgao, pattern = '^BADESC$')==TRUE ~ '302',
  str_detect(string = tabela_url$orgao, pattern = '^ARESC$')==TRUE ~ '2729',
  str_detect(string = tabela_url$orgao, pattern = '^CC$')==TRUE ~ '4101',
  str_detect(string = tabela_url$orgao, pattern = '^CIASC$')==TRUE ~ '301',
  str_detect(string = tabela_url$orgao, pattern = '^COHAB$')==TRUE ~ '2622',
  str_detect(string = tabela_url$orgao, pattern = '^CIDASC$')==TRUE ~ '4422',
  str_detect(string = tabela_url$orgao, pattern = '^Controladoria Geral do Estado$')==TRUE ~ '4107',
  str_detect(string = tabela_url$orgao, pattern = 'CBM')==TRUE ~ '1685',
  str_detect(string = tabela_url$orgao, pattern = '^DPE$')==TRUE ~ '1501',
  str_detect(string = tabela_url$orgao, pattern = '^DC$')==TRUE ~ '5501',
  str_detect(string = tabela_url$orgao, pattern = '^DEINFRA$')==TRUE ~ '5325',
  str_detect(string = tabela_url$orgao, pattern = '^DETRAN$')==TRUE ~ '4112',
  str_detect(string = tabela_url$orgao, pattern = '^EPAGRI$')==TRUE ~ '9',
  str_detect(string = tabela_url$orgao, pattern = '^FCC$')==TRUE ~ '2322',
  str_detect(string = tabela_url$orgao, pattern = '^FCEE$')==TRUE ~ '4521',
  str_detect(string = tabela_url$orgao, pattern = '^FESPORTE$')==TRUE ~ '2006',
  str_detect(string = tabela_url$orgao, pattern = '^FAPESC$')==TRUE ~ '4524',
  str_detect(string = tabela_url$orgao, pattern = '^SCPREV$')==TRUE ~ '200',
  str_detect(string = tabela_url$orgao, pattern = '^ENA$')==TRUE ~ '5230',
  str_detect(string = tabela_url$orgao, pattern = 'UDESC')==TRUE ~ '4522',
  str_detect(string = tabela_url$orgao, pattern = '^GVG$')==TRUE ~ '4201',
  str_detect(string = tabela_url$orgao, pattern = '^IOESC$')==TRUE ~ '1504',
  str_detect(string = tabela_url$orgao, pattern = '^IPREV$')==TRUE ~ '4722',
  str_detect(string = tabela_url$orgao, pattern = '^IMA$')==TRUE ~ '2721',
  str_detect(string = tabela_url$orgao, pattern = '^JUCESC$')==TRUE ~ '5222',
  str_detect(string = tabela_url$orgao, pattern = '^MPC$')==TRUE ~ '4301',
  str_detect(string = tabela_url$orgao, pattern = '^MPSC$')==TRUE ~ '4001',
  str_detect(string = tabela_url$orgao, pattern = '^Polícia Científica de Santa Catarina$')==TRUE ~ '1699',
  str_detect(string = tabela_url$orgao, pattern = '^PCI$')==TRUE ~ '1605',
  str_detect(string = tabela_url$orgao, pattern = '^PC$')==TRUE ~ '1605',
  str_detect(string = tabela_url$orgao, pattern = '^PMSC$')==TRUE ~ '1606',
  str_detect(string = tabela_url$orgao, pattern = '^PGE$')==TRUE ~ '201',
  str_detect(string = tabela_url$orgao, pattern = '^Santa Catarina Participação e Investimentos S.A.$')==TRUE ~ '111',
  str_detect(string = tabela_url$orgao, pattern = '^SCTUR$')==TRUE ~ '2323',
  str_detect(string = tabela_url$orgao, regex(pattern = '^SCPar$', ignore_case = FALSE))==TRUE ~ '1823',
  str_detect(string = tabela_url$orgao, regex(pattern = '^SCPAR$', ignore_case = FALSE))==TRUE ~ '4126',
  str_detect(string = tabela_url$orgao, pattern = '^PSFS$')==TRUE ~ '4130',
  str_detect(string = tabela_url$orgao, pattern = '^SEA-DGLC$')==TRUE ~ '1700',
  str_detect(string = tabela_url$orgao, pattern = 'SAP')==TRUE ~ '801',
  str_detect(string = tabela_url$orgao, pattern = '^SAR$')==TRUE ~ '4401',
  str_detect(string = tabela_url$orgao, pattern = '^SED$')==TRUE ~ '4501',
  str_detect(string = tabela_url$orgao, pattern = '^SEF$')==TRUE ~ '5201',
  str_detect(string = tabela_url$orgao, pattern = '^SIE$')==TRUE ~ '5301',
  str_detect(string = tabela_url$orgao, pattern = '^SES$')==TRUE ~ '4891',
  str_detect(string = tabela_url$orgao, pattern = '^SSP$')==TRUE ~ '1601',
  str_detect(string = tabela_url$orgao, pattern = '^SDE$')==TRUE ~ '2700',
  str_detect(string = tabela_url$orgao, pattern = '^SDS$')==TRUE ~ '2601',
  str_detect(string = tabela_url$orgao, pattern = '^SPG$')==TRUE ~ '1801',
  str_detect(string = tabela_url$orgao, pattern = '^SAI$')==TRUE ~ '4103',
  str_detect(string = tabela_url$orgao, pattern = '^SEC$')==TRUE ~ '5801',
  str_detect(string = tabela_url$orgao, pattern = '^Superintendência de Desenvolvimento da Região Metropolitana da Grande Florianópolis$')==TRUE ~ '1802',
  str_detect(string = tabela_url$orgao, pattern = '^TCE$')==TRUE ~ '4002',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Araranguá$')==TRUE ~ '9101',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Blumenau$')==TRUE ~ '8401',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Campos Novos$')==TRUE ~ '7701',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Chapecó$')==TRUE ~ '7301',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Concórdia$')==TRUE ~ '7501',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Criciúma$')==TRUE ~ '9001',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Curitibanos$')==TRUE ~ '8001',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Itajaí$')==TRUE ~ '8601',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Jaraguá do Sul$')==TRUE ~ '9301',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Joaçaba$')==TRUE ~ '7601',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Joinville$')==TRUE ~ '9201',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Lages$')==TRUE ~ '9601',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Mafra$')==TRUE ~ '9401',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Maravilha$')==TRUE ~ '7101',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Rio do Sul$')==TRUE ~ '8101',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - São Lourenço do Oeste$')==TRUE ~ '7201',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - São Miguel do Oeste$')==TRUE ~ '7001',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Tubarão$')==TRUE ~ '8901',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Videira$')==TRUE ~ '7801',
  str_detect(string = tabela_url$orgao, pattern = '^Agência de Desenvolvimento Regional - Xanxerê$')==TRUE ~ '7401',
  str_detect(string = tabela_url$orgao, pattern = '^DETER$')==TRUE ~ '5323',
  TRUE ~ 'Outros'
)

tabela_url$orgao <- case_when(
  str_detect(string = tabela_url$cdo, pattern = '^2300$')==TRUE ~ 'Agência de Desenvolvimento do Turismo - SANTUR',
  str_detect(string = tabela_url$cdo, pattern = '^302$')==TRUE ~ 'Agência de Fomento do Estado de Santa Catarina - BADESC',
  str_detect(string = tabela_url$cdo, pattern = '^2729$')==TRUE ~ 'Agência de Regulação de Serviços Públicos de Santa Catarina - ARESC',
  str_detect(string = tabela_url$cdo, pattern = '^4101$')==TRUE ~ 'Casa Civil - CC',
  str_detect(string = tabela_url$cdo, pattern = '^301$')==TRUE ~ 'Centro de Informática e Automação de Santa Catarina - CIASC',
  str_detect(string = tabela_url$cdo, pattern = '^2622$')==TRUE ~ 'Companhia de Habitação do Estado de Santa Catarina S/A - COHAB/SC',
  str_detect(string = tabela_url$cdo, pattern = '^4422$')==TRUE ~ 'Companhia Integrada de Desenv. Agricola de Santa Catarina - CIDASC',
  str_detect(string = tabela_url$cdo, pattern = '^4107$')==TRUE ~ 'Controladoria Geral do Estado',
  str_detect(string = tabela_url$cdo, pattern = '^1685$')==TRUE ~ 'Corpo de Bombeiros Militar - CBM/SC - Fundo de Melhoria',
  str_detect(string = tabela_url$cdo, pattern = '^1501$')==TRUE ~ 'Defensoria Pública do Estado de Santa Catarina - DPE',
  str_detect(string = tabela_url$cdo, pattern = '^5501$')==TRUE ~ 'Defesa Cívil - DC',
  str_detect(string = tabela_url$cdo, pattern = '^5325$')==TRUE ~ 'Departamento Estadual de Infraestrutura - DEINFRA',
  str_detect(string = tabela_url$cdo, pattern = '^4112$')==TRUE ~ 'Departamento Estadual de Trânsito - DETRAN/SC',
  str_detect(string = tabela_url$cdo, pattern = '^9$')==TRUE ~ 'Empresa de Pesquisa Agropecuária e Extensão Rural de Santa Catarina - EPAGRI',
  str_detect(string = tabela_url$cdo, pattern = '^2322$')==TRUE ~ 'Fundação Catarinense de Cultura - FCC',
  str_detect(string = tabela_url$cdo, pattern = '^4521$')==TRUE ~ 'Fundação Catarinense de Educação Especial - FCEE',
  str_detect(string = tabela_url$cdo, pattern = '^2006$')==TRUE ~ 'Fundação Catarinense de Esporte - FCE',
  str_detect(string = tabela_url$cdo, pattern = '^4524$')==TRUE ~ 'Fundação de Amparo á Pesquisa  e Inovação do Estado de Santa Catarina - FAPESC',
  str_detect(string = tabela_url$cdo, pattern = '^200$')==TRUE ~ 'Fundação de Previdência Complementar do Estado de Santa Catarina - SCPREV',
  str_detect(string = tabela_url$cdo, pattern = '^5230$')==TRUE ~ 'Fundação Escola de Governo - ENA',
  str_detect(string = tabela_url$cdo, pattern = '^4522$')==TRUE ~ 'Fundação Universidade do Estado de Santa Catarina - UDESC',
  str_detect(string = tabela_url$cdo, pattern = '^4201$')==TRUE ~ 'Gabinete do Vice-Governador - GVG',
  str_detect(string = tabela_url$cdo, pattern = '^1504$')==TRUE ~ 'Imprensa Oficial do Estado de Santa Catarina - IOESC',
  str_detect(string = tabela_url$cdo, pattern = '^4722$')==TRUE ~ 'Instituto de Previdência do Estado de Santa Catarina - IPREV',
  str_detect(string = tabela_url$cdo, pattern = '^2721$')==TRUE ~ 'Instituto do Meio Ambiente - IMA',
  str_detect(string = tabela_url$cdo, pattern = '^5222$')==TRUE ~ 'Junta Comercial do Estado de Santa Catarina - JUCESC',
  str_detect(string = tabela_url$cdo, pattern = '^4301$')==TRUE ~ 'Ministério Público de Contas do Estado de Santa Catarina - MPC',
  str_detect(string = tabela_url$cdo, pattern = '^4001$')==TRUE ~ 'Ministério Público do Estado de Santa Catarina Procuradoria Geral de Justiça - MPSC',
  str_detect(string = tabela_url$cdo, pattern = '^1699$')==TRUE ~ 'Polícia Científica de Santa Catarina',
  str_detect(string = tabela_url$cdo, pattern = '^1605$')==TRUE ~ 'Polícia Civil - PC',
  str_detect(string = tabela_url$cdo, pattern = '^1606$')==TRUE ~ 'Polícia Militar do Estado de Santa Catarina - PM/SC',
  str_detect(string = tabela_url$cdo, pattern = '^201$')==TRUE ~ 'Procuradoria Geral do Estado de Santa Catarina - PGE',
  str_detect(string = tabela_url$cdo, pattern = '^111$')==TRUE ~ 'Santa Catarina Participação e Investimentos S.A.',
  str_detect(string = tabela_url$cdo, pattern = '^2323$')==TRUE ~ 'Santa Catarina Turismo S.A. - SCTUR',
  str_detect(string = tabela_url$cdo, pattern = '^1823$')==TRUE ~ 'SC Participações e Parcerias S.A. - SCPar',
  str_detect(string = tabela_url$cdo, pattern = '^4126$')==TRUE ~ 'SCPAR Porto de Imbituba S/A',
  str_detect(string = tabela_url$cdo, pattern = '^4130$')==TRUE ~ 'PSFS Porto de São Francisco do Sul S/A',
  str_detect(string = tabela_url$cdo, pattern = '^1700$')==TRUE ~ 'Secretaria de Estado da Administração - SEA',
  str_detect(string = tabela_url$cdo, pattern = '^801$')==TRUE ~ 'Secretaria de Estado da Administração Prisional e Socioeducativa - SAP',
  str_detect(string = tabela_url$cdo, pattern = '^4401$')==TRUE ~ 'Secretaria de Estado da Agricultura e da Pesca - SAR',
  str_detect(string = tabela_url$cdo, pattern = '^4501$')==TRUE ~ 'Secretaria de Estado da Educação - SED',
  str_detect(string = tabela_url$cdo, pattern = '^5201$')==TRUE ~ 'Secretaria de Estado da Fazenda - SEF',
  str_detect(string = tabela_url$cdo, pattern = '^5301$')==TRUE ~ 'Secretaria de Estado da Infraestrutura e Mobilidade - SIE',
  str_detect(string = tabela_url$cdo, pattern = '^4891$')==TRUE ~ 'Secretaria de Estado da Saúde - SES',
  str_detect(string = tabela_url$cdo, pattern = '^1601$')==TRUE ~ 'Secretaria de Estado da Segurança Pública - SSP',
  str_detect(string = tabela_url$cdo, pattern = '^2700$')==TRUE ~ 'Secretaria de Estado do Desenvolvimento Econômico Sustentável - SDE',
  str_detect(string = tabela_url$cdo, pattern = '^2601$')==TRUE ~ 'Secretaria de Estado do Desenvolvimento Social - SDS',
  str_detect(string = tabela_url$cdo, pattern = '^1801$')==TRUE ~ 'Secretaria de Estado do Planejamento - SPG',
  str_detect(string = tabela_url$cdo, pattern = '^4103$')==TRUE ~ 'Secretaria Executiva de Articulação Nacional - SAI',
  str_detect(string = tabela_url$cdo, pattern = '^5801$')==TRUE ~ 'Secretaria Executiva de Comunicação - SEC',
  str_detect(string = tabela_url$cdo, pattern = '^1802$')==TRUE ~ 'Superintendência de Desenvolvimento da Região Metropolitana da Grande Florianópolis',
  str_detect(string = tabela_url$cdo, pattern = '^4002$')==TRUE ~ 'Tribunal de Contas do Estado de Santa Catarina - TCE',
  str_detect(string = tabela_url$cdo, pattern = '^9101$')==TRUE ~ 'Agência de Desenvolvimento Regional - Araranguá',
  str_detect(string = tabela_url$cdo, pattern = '^8401$')==TRUE ~ 'Agência de Desenvolvimento Regional - Blumenau',
  str_detect(string = tabela_url$cdo, pattern = '^7701$')==TRUE ~ 'Agência de Desenvolvimento Regional - Campos Novos',
  str_detect(string = tabela_url$cdo, pattern = '^7301$')==TRUE ~ 'Agência de Desenvolvimento Regional - Chapecó',
  str_detect(string = tabela_url$cdo, pattern = '^7501$')==TRUE ~ 'Agência de Desenvolvimento Regional - Concórdia',
  str_detect(string = tabela_url$cdo, pattern = '^9001$')==TRUE ~ 'Agência de Desenvolvimento Regional - Criciúma',
  str_detect(string = tabela_url$cdo, pattern = '^8001$')==TRUE ~ 'Agência de Desenvolvimento Regional - Curitibanos',
  str_detect(string = tabela_url$cdo, pattern = '^8601$')==TRUE ~ 'Agência de Desenvolvimento Regional - Itajaí',
  str_detect(string = tabela_url$cdo, pattern = '^9301$')==TRUE ~ 'Agência de Desenvolvimento Regional - Jaraguá do Sul',
  str_detect(string = tabela_url$cdo, pattern = '^7601$')==TRUE ~ 'Agência de Desenvolvimento Regional - Joaçaba',
  str_detect(string = tabela_url$cdo, pattern = '^9201$')==TRUE ~ 'Agência de Desenvolvimento Regional - Joinville',
  str_detect(string = tabela_url$cdo, pattern = '^9601$')==TRUE ~ 'Agência de Desenvolvimento Regional - Lages',
  str_detect(string = tabela_url$cdo, pattern = '^9401$')==TRUE ~ 'Agência de Desenvolvimento Regional - Mafra',
  str_detect(string = tabela_url$cdo, pattern = '^7101$')==TRUE ~ 'Agência de Desenvolvimento Regional - Maravilha',
  str_detect(string = tabela_url$cdo, pattern = '^8101$')==TRUE ~ 'Agência de Desenvolvimento Regional - Rio do Sul',
  str_detect(string = tabela_url$cdo, pattern = '^7201$')==TRUE ~ 'Agência de Desenvolvimento Regional - São Lourenço do Oeste',
  str_detect(string = tabela_url$cdo, pattern = '^7001$')==TRUE ~ 'Agência de Desenvolvimento Regional - São Miguel do Oeste',
  str_detect(string = tabela_url$cdo, pattern = '^8901$')==TRUE ~ 'Agência de Desenvolvimento Regional - Tubarão',
  str_detect(string = tabela_url$cdo, pattern = '^7801$')==TRUE ~ 'Agência de Desenvolvimento Regional - Videira',
  str_detect(string = tabela_url$cdo, pattern = '^7401$')==TRUE ~ 'Agência de Desenvolvimento Regional - Xanxerê',
  str_detect(string = tabela_url$cdo, pattern = '^5323$')==TRUE ~ 'Departamento de Transportes e Terminais - DETER',
  TRUE ~ 'Outros'
)

#### corrige tabela_url em editais com nomes e cria id_unico

tabela_url$id <- gsub(pattern = ".*?([a-z]+).*", x = tabela_url$edital, replacement = NA)
tabela_url$id <- gsub(pattern = ".*?([A-Z]+).*", x = tabela_url$id, replacement = NA)
tabela_url <- tabela_url %>% filter(!is.na(id))
tabela_url$id <- gsub(pattern = '/', replacement = '', tabela_url$id)
tabela_url$id <- paste0(tabela_url$id,'_',tabela_url$cdo)

#### cria id_unico na base_parametros_final

base_parametros_final$id <- gsub(pattern = '/', replacement = '', base_parametros_final$edital)
base_parametros_final$id <- paste0(base_parametros_final$id,'_',base_parametros_final$cdo)

#### corrige falha de raspagem na tabela_url

for (i in 1:nrow(tabela_url)) {
  if (str_detect(pattern = ".*?([A-Z]+).*", string = tabela_url$entrega_de_proposta[i])) {
    tabela_url$entrega_de_proposta[i] <- tabela_url$docs[i]
    tabela_url$situacao[i] <- tabela_url$na[i]
  }else if (str_detect(pattern = ".*?([a-z]+).*", string = tabela_url$entrega_de_proposta[i])) {
    tabela_url$entrega_de_proposta[i] <- tabela_url$docs[i]
    tabela_url$situacao[i] <- tabela_url$na[i]
  }
}
tabela_url <- tabela_url[,-c(7,9)]

#### transforma a tabela_url setando os valores correspondentes existentes em base_parametros_final
base_parametros_final <- semi_join(x = base_parametros_final, y = tabela_url, by = 'id')

################################################################################
#### monta as URLs dos repositórios baseado nos parâmetros

base <- 'https://sistemas4.sc.gov.br/sea/portaldecompras/docsl.asp?'
portal <- 'portal='
processo <- '&processo='
cdo <- '&cdo='
edital <- '&edital='

base_parametros_final$link_repositorio_edital <- NA
for (i in 1:nrow(base_parametros_final)) {
  print(paste0('Montando Link ', i, ' de ', nrow(base_parametros_final)))
  link_repositorio_edital <- paste0(base,
                                    portal, base_parametros_final$portal[i],
                                    processo, base_parametros_final$processo[i],
                                    cdo, base_parametros_final$cdo[i],
                                    edital, base_parametros_final$edital[i])
  base_parametros_final$link_repositorio_edital[i] <- link_repositorio_edital
}

rm(base)
rm(portal)
rm(processo)
rm(cdo)
rm(edital)
rm(busca_links)
rm(link_repositorio_edital)

################################################################################
#### salva base_parametros_final na base_final

base_final <- base_parametros_final

rm(base_parametros_final)
rm(base_links_direto)

#### executa join para inserir colunas da tabela_url na base_parametros_final

tabela_url$data_abertura <- str_sub(tabela_url$abertura, 1 , 10)
tabela_url$data_entrega_proposta <- str_sub(tabela_url$entrega_de_proposta, 1 , 10)

base_final <- base_final %>% mutate_all(as.character)
tabela_url <- tabela_url %>% mutate_all(as.character)

tabela_url <- tabela_url %>% distinct(id, .keep_all = TRUE)

base_final <- left_join(base_final, tabela_url, by = "id")

base_final <- base_final %>% distinct()

base_final$base_final[is.na(base_final$data_abertura)] <- NA
base_final$base_final[is.na(base_final$data_entrega_proposta)] <- NA


################################################################################
#### captura parte final dos links dos arquivos dos editais

base_final$final_url_edital <- NA
for (i in 1:nrow(base_final)) {
  print(paste0('Raspando link ', i, ' de ', nrow(base_final)))
  try(lista <- (read_html(base_final$link_repositorio_edital[i]) %>% html_nodes('a') %>% html_attr('href')))
  base_final$final_url_edital[i] <- lista[1]
  print(base_final$final_url_edital[i])
}

rm(i)
rm(lista)

################################################################################
#### cria a coluna link_completo_para_editais
#### a partir da junção da base da url + final_url_edital
#### atualiza a base_final com o dataframe completo criado na rotina anterior

base_final$link_completo_para_editais <- paste0('https://sistemas4.sc.gov.br/sea/portaldecompras/',base_final$final_url_edital)

rm(link_documento)
#rm(links_documentos_final)

################################################################################
#### acessa cada link de arquivo dos editais e salva o conteudo dos editais
### nos Dataframes - SEM TRATAMENTO DAS INFORMAÇÕES
# pdf <- 0
# doc <- 0
# erro <- 0
# lista_erros <- list()
# posicao_lista = 1
# base_final$conteudo_edital <- NA
# for (i in 1:nrow(base_final)) {
#   print(paste0('Inserindo na tabela o conteúdo do documento: ',i, ' de ',nrow(base_final)))
#   if (str_detect(string = try(html_text(read_html(base_final$link_completo_para_editais[i]))), pattern = 'PDF')) {
#     print('Documento em PDF')
#     base_final$conteudo_edital[i] <- str_flatten(pdftools::pdf_text(pdf = base_final$link_completo_para_editais[i]))
#     pdf <- pdf + 1
#   }else if (str_detect(string = try(html_text(read_html(base_final$link_completo_para_editais[i]))), pattern = 'doc')) {
#     base_final$conteudo_edital[i] <- textreadr::read_doc(base_final$link_completo_para_editais[i])
#     print('Documento em DOC')
#     doc <- doc + 1
#   }else{
#     erro <- erro +1
#     lista_erros[posicao_lista] <- print(base_final$link_completo_para_editais[i])
#     posicao_lista <- posicao_lista + 1
#     print('Formato de documento desconhecido')
#   }
# }
# 
# print(paste0('Total de documentos em PDF: ', pdf))
# print(paste0('Total de documentos em DOC: ', doc))
# print(paste0('Total de documentos de ERROS: ', erro))

base_final <- base_final[,-c(8,15,16)]
base_final <- base_final %>% rename("edital" = "edital.x",
                                    "cdo" = "cdo.x",
                                    "orgao" = "orgao.x")

data <- str_replace_all(string = Sys.Date(), pattern = '-', replacement = '_')
write.csv(base_final, paste0('backup_bases/base_final_sem_conteudo_', data, '.csv'))

######## Upload file to Big Query #############

#source(file = '00.sobe_dados_big_query.R', encoding = 'utf-8')
