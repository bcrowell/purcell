BOOK = purcell
TEX_INTERPRETER = pdflatex
DO_PDFLATEX_RAW = $(NICE) $(TEX_INTERPRETER) -interaction=$(MODE) $(BOOK) >$(TERMINAL_OUTPUT)
MAKEINDEX = makeindex $(BOOK).idx >/dev/null
WEB_DIR = /home/bcrowell/Lightandmatter/purcell

book1:
	pdflatex $(BOOK)

book:
	pdflatex $(BOOK)
	pdflatex $(BOOK)
	$(MAKEINDEX)
	pdflatex $(BOOK)

clean:
	rm -f *.aux *.log $(BOOK).pdf a.a *~ ch*/*aux

post:
	cp $(BOOK).pdf $(WEB_DIR)
