TEXFILES = $(wildcard *.tex)
PDFFILES = $(TEXFILES:.tex=.pdf)
PNGFILES = $(PDFFILES:.pdf=.png)

all: png

png: $(PNGFILES)
pdf: $(PDFFILES)

%.pdf: %.tex
	@rubber --pdf $<
%.png: %.pdf
	@echo "creating $@..."
	@convert -density 1200 -scale 10\% -quality 80 $< $@
clean:
	@rubber --clean --pdf $(TEXFILES:.tex=)
	@rm -f *.png *.vrb

.PHONY: png pdf clean all

