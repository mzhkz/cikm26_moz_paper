TMPDIR=tmp
OUTDIR=out

MAINFILE=QL_Research_CIKM_Paper.tex

FILENAME=QL_Research_CIKM_Paper
PDFNAME=${FILENAME}.pdf


TEXLIVEIMAGE=texlive/texlive:TL2023-historic
DOCKER=docker run -v $(CURDIR):/work -w /work/tmp ${TEXLIVEIMAGE}


# for english
PDFLATEX=pdflatex
BIBTEX=bibtex

# for japanese
# PDFLATEX=lualatex
# BIBTEX=bibtex


LATEXPAND=latexpand
LATEXDIFF=latexdiff

COMMITHASH=d19716bf60600bab005b89a8cb135b25d8c8a817

.PHONY: all pdf tmp clean diff textlint-ja textlint-en

all: pdf


pdf: tmp
	cd ${TMPDIR} && ${PDFLATEX} ${MAINFILE}
	cd ${TMPDIR} && ${BIBTEX} ${FILENAME}
	cd ${TMPDIR} && ${PDFLATEX}  ${FILENAME}
	cd ${TMPDIR} && ${PDFLATEX}  ${FILENAME}
	cp ${TMPDIR}/${PDFNAME} ${OUTDIR}


tmp:
	mkdir -p ${TMPDIR}
	mkdir -p ${OUTDIR}
	cp -r src ${TMPDIR}
	cp -r figs ${TMPDIR}
	cp ${MAINFILE} ${TMPDIR}
	cp -r bib ${TMPDIR}
	cp -r sty ${TMPDIR}


diff: tmp
	latexdiff-vc -e utf8 --git --flatten --force -r ${COMMITHASH} ${FILENAME}.tex
	mv ${FILENAME}-diff${COMMITHASH}.tex ${TMPDIR}/
	cd ${TMPDIR} && gsed -i 's/\\providecommand{\\DIFadd}\[1\]{{\\protect\\color{blue}\\uwave{#1}}} %DIF PREAMBLE/\\providecommand{\\DIFadd}[1]{{\\protect\\color{blue}#1}} %DIF PREAMBLE/'  ${FILENAME}-diff${COMMITHASH}.tex
	cd ${TMPDIR} && gsed -i 's/\\providecommand{\\DIFdel}\[1\]{{\\protect\\color{red}\\sout{#1}}}                      %DIF PREAMBLE/\\providecommand{\\DIFdel}[1]{}                      %DIF PREAMBLE/'  ${FILENAME}-diff${COMMITHASH}.tex
	cd ${TMPDIR} && ${PDFLATEX} -synctex=1 -shell-escape -file-line-error ${FILENAME}-diff${COMMITHASH}.tex
	cd ${TMPDIR} && ${BIBTEX} ${FILENAME}-diff${COMMITHASH}
	cd ${TMPDIR} && ${PDFLATEX} -synctex=1 -shell-escape -file-line-error ${FILENAME}-diff${COMMITHASH}.tex
	cd ${TMPDIR} && ${PDFLATEX} -synctex=1 -shell-escape -file-line-error ${FILENAME}-diff${COMMITHASH}.tex
	cp ${TMPDIR}/${FILENAME}-diff${COMMITHASH}.pdf ${OUTDIR}/

clean:
	rm -rf ${TMPDIR}/*

# Textlint for Japanese
textlint-ja:
	@echo "Running textlint for Japanese files in src_ja/..."
	@if command -v textlint >/dev/null 2>&1; then \
		textlint --config .textlintrc.ja src_ja/*.tex; \
	else \
		echo "Error: textlint is not installed. Please install it with: npm install -g textlint"; \
		echo "Also install Japanese plugins:"; \
		echo "  npm install -g textlint-rule-preset-ja-technical-writing"; \
		echo "  npm install -g textlint-rule-preset-ja-spacing"; \
		echo "  npm install -g textlint-rule-prh"; \
		exit 1; \
	fi

# Textlint for English
textlint-en:
	@echo "Running textlint for English files in src_en/..."
	@if command -v textlint >/dev/null 2>&1; then \
		textlint --config .textlintrc.en src_en/*.tex; \
	else \
		echo "Error: textlint is not installed. Please install it with: npm install -g textlint"; \
		echo "Also install English plugins:"; \
		echo "  npm install -g textlint-rule-write-good"; \
		echo "  npm install -g textlint-rule-alex"; \
		echo "  npm install -g textlint-rule-rousseau"; \
		echo "  npm install -g textlint-rule-no-dead-link"; \
		exit 1; \
	fi

# Run both textlint checks
textlint: textlint-ja textlint-en
