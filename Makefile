all :: html pod txt

html:
	sdf -2 html *.sdf

pod:
	sdf -2 pod *.sdf

txt:
	sdf -2 txt *.sdf

clean:
	rm -f *.html *.pod *.txt
