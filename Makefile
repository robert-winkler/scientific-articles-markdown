MARKDOWN_FILE = agile-editing-pandoc.md
AFFILIATIONS_JSON_FILE = outfile.affiliations.json
DEFAULT_JSON_FILE = outfile.json
PANDOC_READER_OPTIONS = --smart
PANDOC_WRITER_OPTIONS = --standalone

PANDOC_LATEX_OPTIONS = --template=pandoc-peerj.latex
PANDOC_LATEX_OPTIONS += --latex-engine=xelatex
PANDOC_LATEX_OPTIONS += -M fontsize=10pt
PANDOC_LATEX_OPTIONS += -M classoption=fleqn
PANDOC_LATEX_OPTIONS += -M documentclass=wlpeerj
PANDOC_LATEX_OPTIONS += --csl=peerj.csl

# LATEX code will produce with the --natbib option, which also enables the
# extraction of citations using BibTool PDF generation uses the --filter
# pandoc-citeproc option.
PANDOC_NONTEX_OPTIONS = --filter pandoc-citeproc --csl=plos.csl

LUA_PATH := panlunatic/?.lua;scripts/?.lua;?.lua;
export LUA_PATH

all: outfile.tex outfile.pdf outfile.docx outfile.odt outfile.epub outfile.html outfile.txt

$(AFFILIATIONS_JSON_FILE): $(MARKDOWN_FILE) scripts/affiliations.lua
	pandoc $(PANDOC_READER_OPTIONS) \
	       -t scripts/affiliations.lua \
	       -o $@ $<

$(DEFAULT_JSON_FILE): $(MARKDOWN_FILE) scripts/default.lua
	pandoc $(PANDOC_READER_OPTIONS) \
	       -t scripts/default.lua \
	       -o $@ $<

outfile.tex: $(AFFILIATIONS_JSON_FILE) $(MARKDOWN_FILE) pandoc-peerj.latex
	pandoc $(PANDOC_WRITER_OPTIONS) \
	       $(PANDOC_LATEX_OPTIONS) \
	       --natbib \
	       -o $@ $<

outfile.pdf: $(AFFILIATIONS_JSON_FILE) $(MARKDOWN_FILE) pandoc-peerj.latex agile-markdown.bib
	pandoc $(PANDOC_WRITER_OPTIONS) \
	       $(PANDOC_LATEX_OPTIONS) \
	       --filter pandoc-citeproc \
	       -o $@ $<

outfile.docx: $(DEFAULT_JSON_FILE)
	pandoc $(PANDOC_WRITER_OPTIONS) \
	       $(PANDOC_NONTEX_OPTIONS) \
	       --reference-docx=pandoc-manuscript.docx \
	       -o $@ $<

outfile.odt: $(DEFAULT_JSON_FILE)
	pandoc $(PANDOC_WRITER_OPTIONS) \
	       $(PANDOC_NONTEX_OPTIONS) \
				 --reference-odt=pandoc-manuscript.odt \
				 -o $@ $<

outfile.epub: $(DEFAULT_JSON_FILE)
	pandoc $(PANDOC_WRITER_OPTIONS) \
	       $(PANDOC_NONTEX_OPTIONS) \
	       --toc \
	       -o $@ $<

outfile.html: $(DEFAULT_JSON_FILE)
	pandoc $(PANDOC_WRITER_OPTIONS) \
	       $(PANDOC_NONTEX_OPTIONS) \
	       --toc \
				 --mathjax \
				 -c pandoc.css \
	       -o $@ $<

outfile.jsonld: $(MARKDOWN_FILE)
	pandoc -t scripts/jsonld.lua -o $@ $<

outfile.txt: $(MARKDOWN_FILE)
	pandoc -s -S -o $@ $<

clean:
	rm -f outfile.*

.PHONY: all clean
