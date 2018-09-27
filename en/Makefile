# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SOURCEDIR     = .
BUILDDIR      = _build
MDPP          = markdown-pp
MDPP_TARGET   = $(addsuffix .md,$(basename $(wildcard *.mdpp)))

.PHONY: all help Makefile FORCE_MAKE mdpp

# Put it first so that "make" without argument is like "make html".
all: html

help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
html latex: Makefile mdpp
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

mdpp: $(MDPP_TARGET)

%.md: %.mdpp FORCE_MAKE
	@$(MDPP) -e latexrender $< -o $@

pdf: latex
	rm -f "$(BUILDDIR)"/latex/*.pdf
	make -C "$(BUILDDIR)"/latex PDFLATEX="xelatex" LATEXMKOPTS="-interaction=nonstopmode" all || :
	make -C "$(BUILDDIR)"/latex PDFLATEX="xelatex" LATEXMKOPTS="-interaction=nonstopmode" all || :
	ls "$(BUILDDIR)"/latex/*.pdf

clean:
	rm -rf "$(BUILDDIR)"
	rm -f $(MDPP_TARGET)
