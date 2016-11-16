pandoc -S -s --columns=10 --reference-docx=pandoc-manuscript.docx --csl=apa.csl --filter pandoc-citeproc -o pandoc-manuscript.docx agile-editing-pandoc.md

