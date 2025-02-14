#!/bin/bash

cd /home/pira/google_drive/ciencia_de_dados/R/DOU_SC/arquivos_downloaded/docs/
lowriter --convert-to pdf *.doc
lowriter --convert-to pdf *.docx

mv *.pdf /home/pira/google_drive/ciencia_de_dados/R/DOU_SC/arquivos_downloaded/pdfs
rm *