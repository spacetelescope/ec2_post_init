PROG=ec2_post_init
DESTDIR=
PREFIX=/usr/local
BINDIR=$(PREFIX)/bin
DATADIR=$(PREFIX)/share
DOCDIR=$(DATADIR)/doc

F_OBJ=$(wildcard framework/*.inc.sh)
B_OBJ=$(wildcard bin/*.inc.sh)
HTML_OBJ=docs/html/index.html
PDF_OBJ=docs/latex/refman.pdf

.PHONY: clean

all: docs
	@echo Build complete. Install using:
	@echo make install PREFIX=$(PREFIX)

docs/html/index.html:
	@echo generate html
	(type -p doxygen && (cd docs && doxygen 1>/dev/null))

docs/latex/refman.pdf:
	@echo generate pdf
	(type -p pdflatex && (cd docs && make -C latex 1>/dev/null))

html: $(HTML_OBJ)

pdf: $(PDF_OBJ)

docs: html pdf

install: install-doc-html install-doc-pdf install-bin install-framework

install-bin: $(B_OBJ)
	mkdir -p $(DESTDIR)$(BINDIR)
	@for x in $(B_OBJ); do \
		echo installing $$x; \
		install -m644 $$x $(DESTDIR)$(BINDIR); \
	done

install-framework: $(F_OBJ)
	mkdir -p $(DESTDIR)$(DATADIR)/$(PROG)/framework
	@for x in $(F_OBJ); do \
		echo installing $$x; \
		install -m644 $$x $(DESTDIR)$(DATADIR)/$(PROG)/framework; \
	done

install-doc-html: html
	mkdir -p $(DESTDIR)$(DOCDIR)/$(PROG)
	@echo installing html docs
	cp -a docs/html $(DESTDIR)$(DOCDIR)/$(PROG)

install-doc-pdf: pdf
	mkdir -p $(DESTDIR)$(DOCDIR)/$(PROG)
	@echo installing pdf docs
	cp -a docs/latex/refman.pdf $(DESTDIR)$(DOCDIR)/$(PROG)/$(PROG).pdf

clean:
	rm -rf docs/html docs/latex
