ARTICLE_FILE        = agile-editing-pandoc.md
#BIBLIOGRAPHY_FILE   = agile-markdown.bib

PANDOC_LATEX_OPTIONS  = --latex-engine=xelatex
PANDOC_LATEX_OPTIONS += --csl=peerj.csl
PANDOC_LATEX_OPTIONS += --filter=pandoc-citeproc
PANDOC_LATEX_OPTIONS += -M fontsize=10pt
PANDOC_LATEX_OPTIONS += -M classoption=fleqn

PANDOC_HTML_OPTIONS   = --toc
PANDOC_EPUB_OPTIONS   = --toc

DOCX_REFERENCE_FILE   = pandoc-manuscript.docx
ODT_REFERENCE_FILE    = pandoc-manuscript.odt
TEMPLATE_FILE_LATEX   = pandoc-peerj.latex

PANDOC_SCHOLAR_PATH = pandoc-scholar
-include $(PANDOC_SCHOLAR_PATH)/Makefile

LUA_PATH = $(PANDOC_SCHOLAR_PATH)/scholarly-metadata/?.lua;;
export LUA_PATH

## Pandoc Scholar download
PANDOC_SCHOLAR_VERSION = v1.1.0
PANDOC_SCHOLAR_URL = https://github.com/pandoc-scholar/pandoc-scholar/releases/download

pandoc-scholar:
	curl --location --remote-name \
		$(PANDOC_SCHOLAR_URL)/$(PANDOC_SCHOLAR_VERSION)/pandoc-scholar.tar.gz
	tar zvxf pandoc-scholar.tar.gz
	@echo "================================================================"
	@echo "pandoc-scholar has been installed."
	@echo "Run 'make' again to build the article"

.PHONY: all clean
