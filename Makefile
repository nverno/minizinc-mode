wget  ?= wget
emacs ?= emacs

.PHONY: all test
all: test
test: 
	$(emacs) -Q -batch -L . -l ert -l test/minizinc-tests.el \
	-f ert-run-tests-batch-and-exit

README.md: el2markdown.el minizinc.el
	$(emacs) -batch -l $< minizinc.el -f el2markdown-write-readme
	$(RM) $@~

.INTERMEDIATE: el2markdown.el
el2markdown.el:
	$(wget) -q -O $@ "https://github.com/Lindydancer/el2markdown/raw/master/el2markdown.el"
