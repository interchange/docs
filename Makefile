all :: html pod txt

dev_html:
	@for target in ic*.sdf ; do \
		base=`basename $$target .sdf`; \
		echo building $$base; \
		mkdir -p dev/$$base; \
		( echo '1s/akopia/developer_site/' ; echo 'wq dev/'$$base'/'$$target ) | ed $$target > /dev/null 2>&1 ; \
		(cd dev/$$base; sdf -2html_topics -n2 -k=developer_site $$target); \
	done

html:
	@for target in ic*.sdf ; do \
		base=`basename $$target .sdf`; \
		echo building $$base; \
		mkdir -p $$base; \
		sdf -2html $$target; \
		mv $${base}.html $$base/index.html; \
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
	done
	sdf -2html index.sdf

pod:
	sdf -2pod ic*.sdf

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
	sdf -2txt ic*.sdf

pdf:
	sdf -2pdf_html ic*.sdf

clean:
	rm -f *.html *.pod *.txt *.8 *.pdf
	rm -rf dev
	@for target in ic*.sdf ; do \
		base=`basename $$target .sdf`; \
		echo rm -rf $$base; \
		rm -rf $$base; \
	done
