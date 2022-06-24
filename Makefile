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

all:
	@echo "targets:"
	@echo
	@echo "docs             => build $(PROG) documentation"
	@echo "html             => build html documentation"
	@echo "pdf              => build pdf documentation"
	@echo "install          => install $(PROG)"
	@echo "install-doc      => install documentation"
	@echo "install-doc-html => install HTML documentation"
	@echo "install-doc-pdf  => install PDF documentation"
	@echo
	@echo To install $(PROG) in a different location use PREFIX=
	@echo make install PREFIX=/abc/123
	@echo

docs/html/index.html:
	@echo generate html
	(cd docs && doxygen 1>/dev/null)

docs/latex/refman.pdf:
	@echo generate pdf
	(cd docs && make -C latex 1>/dev/null)

html: $(HTML_OBJ)

pdf: $(PDF_OBJ)

docs: html pdf

install: install-bin install-framework

install-doc: install-doc-html install-doc-pdf

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
