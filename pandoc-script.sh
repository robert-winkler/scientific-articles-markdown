pandoc -S -s --columns=10 --template=pandoc-peerj.latex -M fontsize=10pt --natbib --csl=peerj.csl --filter pandoc-citeproc -o outfile.tex agile-editing-pandoc.md
pandoc -S -s --columns=10 --template=pandoc-peerj.latex -M fontsize=10pt --csl=peerj.csl --filter pandoc-citeproc -o outfile.pdf agile-editing-pandoc.md
pandoc -S -s --columns=10 --reference-docx=outfile.docx --csl=apa.csl --filter pandoc-citeproc -o outfile.docx agile-editing-pandoc.md
pandoc -S -s --columns=10 --toc --csl=apa.csl --filter pandoc-citeproc -o outfile.epub agile-editing-pandoc.md
pandoc -S -s --columns=10 --toc --csl=apa.csl --filter pandoc-citeproc -o outfile.html agile-editing-pandoc.md

