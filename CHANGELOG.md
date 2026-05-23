# Changelog

Todas as mudanças relevantes deste projeto são documentadas neste arquivo.
Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/)
e o versionamento segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [2.0.0] — 2024-05

Refatoração arquitetural completa, transformando o protótipo monolítico em um
projeto modular, configurável e reprodutível.

### Added
- Estrutura modular `R/` com funções dedicadas por etapa do pipeline
  (`scrape_orgaos`, `scrape_editais`, `build_links`, `download_editais`,
  `read_pdfs`, `upload_bigquery`, `consolidate`).
- `scripts/run_pipeline.R` como orquestrador único do pipeline.
- `config/config.example.yml` + `R/config.R` para parametrização externa.
- `data-raw/orgaos.csv` como fonte única de verdade dos 73 órgãos do governo
  de SC, substituindo as ~150 linhas de `case_when` duplicadas no script
  original.
- `data-raw/lista_situacoes.txt` com as situações possíveis de um edital.
- `DESCRIPTION` declarando dependências do projeto.
- `.Rprofile` ativando `renv` quando presente.
- `LICENSE` (MIT) explícito.
- `CHANGELOG.md` (este arquivo).
- GitHub Actions: workflow de lint + style check (`.github/workflows/lint.yml`).
- `.lintr` com regras do projeto.

### Changed
- `consolida_base.R` reescrito como wrapper de função, aceita argumentos
  posicionais (`Rscript scripts/consolida_base.R <pasta> [referencia]`).
- `doc_to_pdf.sh` agora portátil: aceita pasta base por argumento, com
  modo headless do LibreOffice e flags seguras (`set -euo pipefail`).
- README reescrito com badges, diagrama mermaid do pipeline, seção de
  destaques técnicos e troubleshooting.

### Removed
- Caminhos absolutos hardcoded (`/home/pira/google_drive/...`) em scripts R
  e bash.
- `options(warn = -1)` (silenciava todos os warnings — anti-padrão).
- `teste_bash.sh` (script de exploração não usado no pipeline).
- 17 chamadas `rm()` para variáveis fantasma (`num_pags`, `busca_links`,
  `base_links_direto`, `link_documento`, `links_documentos_final`).
- Duplicação do `case_when` órgão↔código (mantida em CSV único).
- `biel.pdf` versionado (disponível via DOI da publicação acadêmica).

### Fixed
- Loop de raspagem do ano: condição `while (length(try(...) >= 1))` era
  efetivamente infinita por bug de precedência de parênteses.
- `for (i in 11:length(lista_pdf))` começava em 11 sem justificativa — agora
  itera o conjunto completo.
- Slicing por índice mágico (`tabela_url[,-c(7,9)]`, `base_final[,-c(8,15,16)]`)
  substituído por seleção nomeada explícita.
- Concatenação `bind_rows` dentro de `for` (O(n²)) substituída por acumulação
  em lista + `bind_rows` ao final.

## [1.0.0] — 2022

Versão original publicada, base para o artigo
*"Data Science in Promoting the Participation of SMEs in Public Biddings"*,
Public Administration Research, v. 13, n. 2, 2024 —
[DOI: 10.5539/par.v13n2p52](https://doi.org/10.5539/par.v13n2p52).
