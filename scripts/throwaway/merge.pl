#!/usr/bin/perl -w
#---------------------------------------------------------------------
# merges tagref file given in its argument with STDIN stream
# (see tagformat)
#
# For example, from your shell:
#
# tagformat < tags.to.do > tagformat.out
# merge ictags.sdf < tagformat.out > ictags.reformatted.sdf
#---------------------------------------------------------------------
use strict;

my $fn = shift;
open( MRG, "<$fn" ) or die "Open $fn\: $!\n";
open( LIST, ">$fn.merged" ) or die "Open $fn.merged: $!\n";

my %tags;
my $tag;

while (<STDIN>) {
	if ( /^\!\!+ (\w+) \!+$/ ) {
		$tags{$1} = '';
		$tag = \$tags{$1};

	} elsif (ref $tag) {
		$$tag .= $_;

	} else {
		print STDERR "bad line: \[$_\]\n";
	}
}

my $off = 0;
while (<MRG>) {
	if ( /^h2:\s+(.+?)\s*$/i ) {
		if ( exists($tags{$1}) ) {
			print $tags{$1};
			print LIST "$1\n";
			$off = 1;
		} else {
			$off = 0;
		}

	} elsif ( /^[hHaA]1:\s+\S/ ) {
		$off = 0;
	}

	print unless $off;
}
