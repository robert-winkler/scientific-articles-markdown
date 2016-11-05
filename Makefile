all: outfile.tex outfile.pdf outfile.docx outfile.epub outfile.html

outfile.tex: agile-editing-pandoc.md pandoc-peerj.latex
	pandoc -S -s --columns=10 --template=pandoc-peerj.latex \
				 -M fontsize=10pt -M classoption=fleq -M documentclass=wlpeerj \
				 --natbib --csl=peerj.csl --filter pandoc-citeproc \
				 -o $@ $<

outfile.pdf: agile-editing-pandoc.md pandoc-peerj.latex
	pandoc -S -s --columns=10 --template=pandoc-peerj.latex \
				 -M fontsize=10pt -M classoption=fleq -M documentclass=wlpeerj \
				 --natbib --csl=peerj.csl --filter pandoc-citeproc \
				 -o $@ $<

outfile.docx: agile-editing-pandoc.md
	pandoc -S -s --columns=10 --reference-docx=reference-file.docx --csl=apa.csl \
				 --filter pandoc-citeproc \
				 -o $@ $<

outfile.epub: agile-editing-pandoc.md
	pandoc -S -s --columns=10 --csl=apa.csl --filter pandoc-citeproc \
				 -o $@ $<

outfile.html: agile-editing-pandoc.md
	pandoc -S -s --columns=10 --csl=apa.csl --filter pandoc-citeproc \
				 -o $@ $<

clean:
	rm outfile.*

.PHONY: all clean
