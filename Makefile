SPHINX_MARKDOWN = ~/sphinx-markdown
LANGS = en zh_CN

.PHONY: all clean

all: html

define makeall
PS1='> ' \
  && . $(SPHINX_MARKDOWN)/bin/activate \
  $(foreach lang,$(LANGS),&& make -C $(lang) $@)
endef

html:
	$(makeall)

pdf:
	$(makeall)

clean:
	$(makeall)
