VERSION=4.5.6
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

all :: pdf pod txt html

dev_html:
	@mkdir -p dev
	@for target in ic*.sdf ; do \
		base=`basename $$target .sdf`; \
		echo building $$base; \
		( echo '1s/akopia/developer_site/' ; echo 'wq dev/'$$target ) | ed $$target > /dev/null 2>&1 ; \
		( cd dev ; sdf -2html_topics -n2 -k=developer_site $$target); \
	done

%_toc.html: %.sdf
	sdf -2html_topics -n2 -DHTML_FRAMES=1 $<
	mv $(basename $<).html $@

html: $(addsuffix _toc.html,$(TARGETS)) $(addsuffix .html,$(TARGETS)) index.html
	@for target in ic*.sdf ; do \
		base=`basename $$target .sdf`; \
		echo building $$base; \
		echo '\
<html><head>\
  <title>'$$title'</title>\
</head><frameset cols="200,*">\
  <frame name="nav"  src="'$$base'_toc.html">\
  <frame name="main" src="'$$base'_1.html">\
</frameset></html>\
' > $${base}_frames.html; \
	done

pod: $(addsuffix .pod,$(TARGETS))

txt: $(addsuffix .txt,$(TARGETS))

man: $(addsuffix .8,$(TARGETS))

pdf: $(addsuffix .pdf,$(TARGETS))

clean:
	rm -f *.html *.pod *.txt *.8 *.pdf
	rm -rf dev
