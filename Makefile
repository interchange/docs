VERSION=4.7.2
TARGETS=icadvanced iccattut icconfig icfoundation ictemplates icdatabase ictags icupgrade
SUFFIXES=txt mif html pdf pod 8
SDFBIN=sdf/bin/sdf
FRAMESDIR=frames
FRAMESPARENT=..
DEVDIR=dev
DOCDBNAME=documentation.txt
TARNAME=icdocs.tar.gz
FULLSUFFIXES=txt html
FULLDOCNAME=icfull

.SUFFIXES: .sdf $(addprefix .,$(SUFFIXES))

.sdf.html:
	$(SDFBIN) -2html -DFRAMES_DIR=$(FRAMESDIR)/ $<

.sdf.pod:
	$(SDFBIN) -2pod $<

.sdf.txt:
	$(SDFBIN) -2txt $<

.sdf.mif:
	$(SDFBIN) -2mif $<

.sdf.pdf:
	$(SDFBIN) -2pdf_html $<

.pod.8:
	pod2man --section=8 \
		--release='Interchange $(VERSION)' \
		--center='Interchange' \
		--lax \
		$< > $@

all :: $(SUFFIXES)

docdb :: pod
	perl scripts/makedocdb.pl

tardist :: all dev_html docdb
	@rm -f $(TARNAME)
	@echo packing files into $(TARNAME)
	@( for i in $(TARGETS) ; do \
		for j in $(SUFFIXES) ; do \
			echo $$i.$$j ; \
		done ; \
	done ; \
	echo index.html $(DEVDIR) $(DOCDBNAME) ) | \
	xargs tar czf $(TARNAME)

dev_html:
	@mkdir -p $(DEVDIR)
	@for target in $(addsuffix .sdf,$(TARGETS)) ; do \
		base=`basename $$target .sdf`; \
		echo building $$base; \
		( echo '1s/akopia/developer_site/' ; echo 'wq $(DEVDIR)/'$$target ) | ed $$target > /dev/null 2>&1 ; \
		$(SDFBIN) -2html_topics -DITL_ESCAPE -n2 -k=developer_site -O$(DEVDIR) $$target ; \
	done
	@echo building index
	@( echo '1s/akopia/developer_site/' ; echo 'wq dev_index.sdf' ) | ed index.sdf > /dev/null 2>&1
	@make dev_index.html
	@rm dev_index.sdf
	@mv dev_index.html $(DEVDIR)/index.html

%_toc.html: %.sdf
	@echo making $@
	@mkdir -p $(FRAMESDIR)
	@$(SDFBIN) -2html_topics -n2 -DHTML_FRAMES=1 -DFRAMES_DIR=$(FRAMESDIR)/ -DSDF_ROOT=$(FRAMESPARENT)/ -O$(FRAMESDIR) $<
	@( cd $(FRAMESDIR) ; mv $(basename $<).html $@ )

%_frames.html: %.sdf
	@echo making $@
	@mkdir -p $(FRAMESDIR)
	@echo '\
<html><head>\
  <title>'$$title'</title>\
</head><frameset cols="200,*">\
  <frame name="nav"  src="$(basename $<)_toc.html">\
  <frame name="main" src="$(basename $<)_1.html">\
</frameset></html>\
' > $(FRAMESDIR)/$@

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
	@rm -f $(DOCDBNAME)
	@rm -rf icdocdb
	@rm -f *~
	@for i in $(FULLSUFFIXES) ; do \
		rm -f $(FULLDOCNAME).$$i ; \
	done
	@rm -f $(TARNAME)
	@rm -rf $(DEVDIR)
	@rm -rf $(FRAMESDIR)
