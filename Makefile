VERSION=4.7.2
TARGETS=icadvanced iccattut icconfig icfoundation ictemplates icdatabase ictags icupgrade
SUFFIXES=txt mif html pdf pod 8
SDFBIN=sdf/bin/sdf
FRAMESDIR=frames
FRAMESPARENT=..
DEVDIR=dev
DOCDBNAME=documentation.txt
TARNAME=icdocs.tar.gz

.SUFFIXES: .sdf .frames $(addprefix .,$(SUFFIXES))

.sdf.html:
	$(SDFBIN) -2html -DFULL_TARGETS="$(TARGETS)" -DFRAMES_DIR=$(FRAMESDIR)/ $<

.sdf.frames:
	@make $(basename $<)_frames.html $(basename $<)_toc.html

.sdf.pod:
	$(SDFBIN) -2pod -DFULL_TARGETS="$(TARGETS)" $<
	@perl -ni -e 'if ($$f > 2 or ! /^=head1/) { print; next; } ++$$f; unless ($$f == 2) { print; next; } print qq{=head1 DESCRIPTION\n\n$$_};' $@

.sdf.txt:
	$(SDFBIN) -2txt -DFULL_TARGETS="$(TARGETS)" $<

.sdf.mif:
	$(SDFBIN) -2mif -DFULL_TARGETS="$(TARGETS)" $<

.sdf.pdf:
	$(SDFBIN) -2pdf_html -DFULL_TARGETS="$(TARGETS)" $<

.pod.8:
	pod2man --section=8 --release='Interchange $(VERSION)' --center='Interchange' --lax $< > $@ || true

all :: $(SUFFIXES) frames_html icfull

docdb :: pod
	perl scripts/makedocdb.pl

tardist :: all dev_html docdb
	@rm -f $(TARNAME)
	@echo packing files into $(TARNAME)
	@( for i in $(TARGETS) icfull ; do \
		for j in $(SUFFIXES) ; do \
			echo $$i.$$j ; \
		done ; \
	done ; \
	echo index.html $(DEVDIR) $(FRAMESDIR) $(DOCDBNAME) ) | \
	xargs tar czf $(TARNAME)

dev_html:
	@mkdir -p $(DEVDIR)
	@for target in $(addsuffix .sdf,$(TARGETS)) ; do \
		base=`basename $$target .sdf`; \
		echo building $$base; \
		( echo '1s/OPT_LOOK="akopia"/OPT_LOOK="developer_site"/' ; echo 'wq $(DEVDIR)/'$$target ) | ed $$target > /dev/null 2>&1 ; \
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
	@$(SDFBIN) -2html_topics -n2 -DFULL_TARGETS="$(TARGETS)" -DHTML_FRAMES=1 -DFRAMES_DIR=$(FRAMESDIR)/ -DSDF_ROOT=$(FRAMESPARENT)/ -O$(FRAMESDIR) $<
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

icfull: $(addprefix icfull.,$(SUFFIXES))

$(TARGETS):
	@for i in $(SUFFIXES) frames ; do \
		$(MAKE) $@.$$i ; \
	done

clean:
	@for i in $(TARGETS) icfull ; do \
		for j in $(SUFFIXES) ; do \
			rm -f $$i.$$j ; \
		done ; \
		rm -f $${i}_*.html ; \
	done
	@rm -f index.html
	@rm -f $(DOCDBNAME)
	@rm -rf icdocdb
	@rm -f *~
	@rm -f $(TARNAME)
	@rm -rf $(DEVDIR)
	@rm -rf $(FRAMESDIR)
