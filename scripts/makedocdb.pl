#!/usr/bin/perl

use Getopt::Std; 
use Cwd;
use File::Path;
use File::Spec;

my $curdir = cwd();

my $tried;

CHECKPATH: {

	$POD2  = "$curdir/scripts/pod2html.custom";
	$BREAK = "$curdir/scripts/breakdown.pl";

	if(! -f $POD2) {
		if(! $tried++) {
			chdir '..';
			$curdir = cwd();
			redo CHECKPATH;
		}
		die "Must be in documentation directory.\n";
	}
}

my $DOCDEST= "$curdir/icdocdb";

getopt('n');

my $NOTOC = $opt_n;

my $DOCDIR = $curdir;

my $DBDEST = "$DOCDIR/documentation.txt";

if(-d $DOCDEST) {
	File::Path::rmtree($DOCDEST)
		or die "Couldn't clean $DOCDEST: $!\n";
}

File::Path::mkpath($DOCDEST)
	or die "Couldn't clean $dest: $!\n";

open(DBDEST, ">$DBDEST")
	or die "create $DBDEST: $!\n";
print DBDEST <<EOF;
code
%%
document
%%
section
%%
type
%%
title
%%
body
%%%
EOF

close DBDEST;

%dont = qw/
	mvfaq 1
	mvdocs 1
	deprecated 1
/;
foreach $pod (glob("$DOCDIR/*.pod")) {
	my ($vol, $dir, $file) = File::Spec->splitpath($pod);
	my $base = $file;
	$base =~ s/\.pod$//;

	next if $dont{$base};

	my $dest = "$DOCDEST/$base";
	File::Path::mkpath($dest)
		or die "Couldn't make directory $dest: $!\n";

	system "perl $POD2 --netscape --noindex $pod > $DOCDEST/$base.html 2>/dev/null";

	$ENV{DOCUMENT} = $base;
	system "perl $BREAK -d $dest $DOCDEST/$base.html > /dev/null";
	system "cat $dest/docdb.txt >> $DBDEST";
}

