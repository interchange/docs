#!/usr/bin/perl

for $filename (@ARGV) {
	open IN, "<$filename.sdf" or die "open $filename.sdf: $!\n";
	print "line:\n";
	while (<IN>) {
		next if /^\s*!build_title/;
		next if /^\s*!init/;
		s/^\s*!define\s+DOC_NAME\s+"([^"]+)".*$/P1: $1/;
		#s/^\s*!define\s+DOC_CODE\s+"([^"]+)".*$/N: $1/;
		next if /^\s*!define\s+DOC_/;
		print;
	}
	close IN;
}
