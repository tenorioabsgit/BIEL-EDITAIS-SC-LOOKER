# ============================================================================
# BIEL — Consolidação de bases mensais
# ============================================================================
# Junta os arquivos .rds gerados pelo pipeline mensal em um único CSV.
#
# Uso:
#   Rscript scripts/consolida_base.R <pasta_rds> [referencia_mm-yyyy]
#
# Exemplo:
#   Rscript scripts/consolida_base.R ./backup_bases 04-2024
# ============================================================================

source("R/setup.R")
ensure_packages(c("tidyverse", "fs"))
source("R/consolidate.R")

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1) {
  stop("Uso: Rscript scripts/consolida_base.R <pasta_rds> [referencia_mm-yyyy]")
}

pasta_rds  <- args[1]
referencia <- if (length(args) >= 2) args[2] else NULL

consolidar_bases_mensais(
  pasta_rds  = pasta_rds,
  pasta_saida = pasta_rds,
  referencia = referencia
)
