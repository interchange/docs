VERSION=4.6.1
TARGETS=icbackoffice icconfig icdatabase icinstall icintro ictemplates

.SUFFIXES: .html .pod .sdf .txt .pdf .8

.sdf.html:
	sdf -2html $<

.sdf.pod:
	sdf -2pod $<

.sdf.txt:
	sdf -2txt $<

.sdf.pdf:
	sdf -2pdf_html $<

.pod.8:
	pod2man --section=8 \
		--release='Interchange $(VERSION)' \
		--center='Akopia Interchange' \
		--lax \
		$< $@

all :: pdf pod txt html man

dev_html:
	@mkdir -p dev
	@for target in ic*.sdf ; do \
		base=`basename $$target .sdf`; \
		echo building $$base; \
		( echo '1s/akopia/developer_site/' ; echo 'wq dev/'$$target ) | ed $$target > /dev/null 2>&1 ; \
		( cd dev ; sdf -2html_topics -n2 -k=developer_site $$target); \
	done
	@echo building index
	@( echo '1s/akopia/developer_site/' ; echo 'wq dev_index.sdf' ) | ed index.sdf > /dev/null 2>&1
	@make dev_index.html
	@rm dev_index.sdf
	mv dev_index.html dev/index.html

%_toc.html: %.sdf
	sdf -2html_topics -n2 -DHTML_FRAMES=1 $<
	mv $(basename $<).html $@

%_frames.html: %.sdf
	@echo making $@
	@echo '\
<html><head>\
  <title>'$$title'</title>\
</head><frameset cols="200,*">\
  <frame name="nav"  src="$(basename $<)_toc.html">\
  <frame name="main" src="$(basename $<)_1.html">\
</frameset></html>\
' > $@

html:: $(addsuffix _frames.html,$(TARGETS))
html:: $(addsuffix _toc.html,$(TARGETS))
html:: $(addsuffix .html,$(TARGETS))
html:: index.html

pod: $(addsuffix .pod,$(TARGETS))

txt: $(addsuffix .txt,$(TARGETS))

man: $(addsuffix .8,$(TARGETS))

pdf: $(addsuffix .pdf,$(TARGETS))

clean:
	rm -f *.html *.pod *.txt *.8 *.pdf
	rm -rf dev
