all :: html pod txt

html:
	@echo '\
<HTML><HEAD>\
  <TITLE>Interchange Documentation Index</TITLE>\
</HEAD><BODY BGCOLOR="#FFFFFF">\
<H2>Interchange Documentation</H2>\
<UL>\
' > index.html
	@for target in *.sdf ; do \
		base=`basename $$target .sdf`; \
		echo building $$base; \
		mkdir -p $$base; \
		sdf -2html $$target; \
		mv $${base}.html $$base/index.html; \
		title=`grep -i '<TITLE>' $$base/index.html | head -1 | perl -pe 'm|<TITLE>(.*?)</TITLE>|i && ($$_ = $$1)'`; \
		(cd $$base; sdf -2html_topics -n2 -DHTML_FRAMES=1 ../$$target); \
		mv $$base/$${base}.html $$base/nav.html; \
		echo '\
<html><head>\
  <title>'$$title'</title>\
</head><frameset cols="200,*">\
  <frame name="nav"  src="nav.html">\
  <frame name="main" src="'$$base'_1.html">\
</frameset></html>\
' > $$base/frtoc.html; \
	echo '<LI>'$$title' (<A HREF="'$$base'/frtoc.html">frames</A>) (<A HREF="'$$base'/">no frames</A>)</LI>' >> index.html; \
	done
	@echo '\
</UL></BODY></HTML>\
' >> index.html

pod:
	sdf -2pod *.sdf

man: pod
	@for target in *.pod ; do \
		echo "Manifying $$target" ; \
		base=`basename $$target .pod` ; \
		pod2man --section=8 \
			--release='Interchange 4.5.6' \
			--center='Akopia Interchange' \
			--lax \
			$$target \
			$$base.8 ; \
	done

txt:
	sdf -2txt *.sdf

pdf:
	sdf -2pdf_html *.sdf

clean:
	rm -f *.html *.pod *.txt *.8 *.pdf
	@for target in *.sdf ; do \
		base=`basename $$target .sdf`; \
		echo rm -rf $$base; \
		rm -rf $$base; \
	done
