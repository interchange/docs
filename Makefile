VERSION=4.7.0
TARGETS=icintro icinstall iccattut icconfig ictemplates icdatabase ictags icbackoffice icupgrade
SUFFIXES=txt mif html pdf pod 8
TARNAME=icdocs.tar.gz
FULLSUFFIXES=txt html
FULLDOCNAME=icfull

.SUFFIXES: .sdf $(addprefix .,$(SUFFIXES))

.sdf.html:
	sdf -2html $<

.sdf.pod:
	sdf -2pod $<

.sdf.txt:
	sdf -2txt $<

.sdf.mif:
	sdf -2mif $<

.sdf.pdf:
	sdf -2pdf_html $<

.pod.8:
	pod2man --section=8 \
		--release='Interchange $(VERSION)' \
		--center='Interchange' \
		--lax \
		$< > $@

all :: $(SUFFIXES)

tardist :: all dev_html
	@rm -f $(TARNAME)
	@echo packing files into $(TARNAME)
	@( for i in $(TARGETS) ; do \
		for j in $(SUFFIXES) ; do \
			echo $$i.$$j ; \
		done ; \
	done ; \
	echo index.html dev ) | \
	xargs tar czf $(TARNAME)

dev_html:
	@mkdir -p dev
	@for target in ic*.sdf ; do \
		base=`basename $$target .sdf`; \
		echo building $$base; \
		( echo '1s/akopia/developer_site/' ; echo 'wq dev/'$$target ) | ed $$target > /dev/null 2>&1 ; \
		( cd dev ; sdf -2html_topics -DITL_ESCAPE -n2 -k=developer_site $$target); \
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

frames_html:: $(addsuffix _frames.html,$(TARGETS))
frames_html:: $(addsuffix _toc.html,$(TARGETS))

frames_html html:: index.html

html:: $(addsuffix .html,$(TARGETS))

pod: $(addsuffix .pod,$(TARGETS))

txt: $(addsuffix .txt,$(TARGETS))

mif: $(addsuffix .mif,$(TARGETS))

8: $(addsuffix .8,$(TARGETS))
man: 8

pdf: $(addsuffix .pdf,$(TARGETS))

$(TARGETS):
	@for i in $(SUFFIXES) ; do \
		$(MAKE) $@.$$i ; \
	done

full :: txt
	@for i in $(FULLSUFFIXES) ; do \
		echo "" > $(FULLDOCNAME).$$i ; \
		echo "Interchange $(VERSION)" >> $(FULLDOCNAME).$$i ; \
		echo "Complete reference documentation in one file" >> $(FULLDOCNAME).$$i ; \
		echo "Generated `date`" >> $(FULLDOCNAME).$$i ; \
		for j in $(TARGETS) ; do \
			perl -e "print qq{\n\n\n\n}, '-' x 78, qq{\n\n\n$$j\n\n\n}, '-' x 78, qq{\n\n\n}" >> $(FULLDOCNAME).$$i ; \
			cat $$j.$$i >> $(FULLDOCNAME).$$i ; \
		done ; \
	done

clean:
	@for i in $(TARGETS) ; do \
		for j in $(SUFFIXES) ; do \
			rm -f $$i.$$j ; \
		done ; \
		rm -f $${i}_*.html ; \
	done
	@rm -f index.html
	@for i in $(FULLSUFFIXES) ; do \
		rm -f $(FULLDOCNAME).$$i ; \
	done
	@rm -f $(TARNAME)
	@rm -rf dev
