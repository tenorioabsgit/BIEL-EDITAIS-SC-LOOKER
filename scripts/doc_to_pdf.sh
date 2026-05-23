#!/usr/bin/env bash
# ============================================================================
# Converte todos os .doc/.docx baixados para PDF usando LibreOffice (lowriter).
#
# Uso:
#   ./scripts/doc_to_pdf.sh [PASTA_BASE]
#
#   PASTA_BASE padrão = ./arquivos_downloaded
#   Espera subpastas `docs/` (entrada) e `pdfs/` (saída).
#
# Requisitos: LibreOffice instalado (`lowriter` no PATH).
# ============================================================================
set -euo pipefail

BASE="${1:-./arquivos_downloaded}"
DOCS_DIR="$BASE/docs"
PDFS_DIR="$BASE/pdfs"

if [ ! -d "$DOCS_DIR" ]; then
  echo "Pasta de documentos não encontrada: $DOCS_DIR" >&2
  exit 1
fi

mkdir -p "$PDFS_DIR"

cd "$DOCS_DIR"

shopt -s nullglob
for ext in doc docx; do
  files=( *."$ext" )
  if [ ${#files[@]} -gt 0 ]; then
    lowriter --headless --convert-to pdf "${files[@]}"
  fi
done

# Move PDFs convertidos e limpa os originais
mv -f *.pdf "$PDFS_DIR/" 2>/dev/null || true
rm -f *.doc *.docx
