#!/usr/bin/perl

use Getopt::Std;

getopts('d:t:') or die "$@\n";;

$dir = $opt_d || '.';

$head_title = $opt_t || 'Interchange Documentation';

$fr_toc = <<EOF;
<html>
<head>
<title>$head_title</title>
</head>
<frameset cols="200,*">
<frame name="nav"  src="nav.html">
<frame name="main" src="intro.html">
</frameset>
</html>
EOF

$nav_base = <<EOF;
<HTML>
<HEAD>
<BASE TARGET="main">
<TITLE>Table of Contents</TITLE>
</HEAD>
<BODY BGCOLOR="#FFFFFF">
<H1>Table of Contents</H1>
(<A HREF="all.html">all in one file</A>)
<P>
EOF

for( $dir ) {
	unless (-d $_) {
		die "$_ not a directory.\n" if -e $_;
		mkdir $_, 0777 or die "mkdir $_: $!\n";
	}
}

{ 
	local($/) = undef;
	$html = <>;
}

(@chunks) = split /<H1>/, $html;

shift(@chunks);

my $i = 1;

	open(FRTOC, ">$dir/frtoc.html") or die "open nav.html: $!\n";
	print FRTOC $fr_toc;
	close FRTOC;
	open(NAV, ">$dir/nav.html") or die "open nav.html: $!\n";
	print NAV $nav_base;

for(@chunks) {
	/<a\s+name\s*=\s*"([^"]+)">([^<]+)/i;
	$secname[$i] = $1;
	$secname[$i] =~ s/([^-.\w])/'%' . sprintf("%02x", ord($1))/eg;
	$title[$i] = $2;
	$i++;
}

my @overview;
my @items;
$i = 1;
for(@chunks) {
	$chunk = $_;
	$section = sprintf ("%02d", $i);
	my $mainbar = '';
	$head = <<EOF;
<HTML>
<HEAD>
<TITLE>$title[$i]</TITLE>
</HEAD>
<BODY BGCOLOR="#FFFFFF">
EOF

	print NAV qq{<P><A HREF="$section.00.$secname[$i].html"><B>$title[$i]</B></A>};

	$mainbar .= qq{<A HREF="index.html"><B>Index</B></A>&nbsp;&nbsp;};
	my $n;
	my $ov = sprintf("%02d", $i);
	if($i > 1) {
		$n = sprintf("%02d", $i - 1);
		$mainbar .= qq{<A HREF="$n.00.$secname[$i - 1].html">};
		$mainbar .= qq{<B>Previous:</B> $title[$i - 1]</A>&nbsp;&nbsp;&nbsp;};
	}
	if($i < scalar @chunks) {
		$n = sprintf("%02d", $i + 1);
		$mainbar .= qq{<A HREF="$n.00.$secname[$i + 1].html">};
		$mainbar .= qq{<B>Next:</B> $title[$i + 1]</A>};
	}
	$head .= $mainbar;
	$head .= "<HR><H1>";
	$foot = '</BODY></HTML>';

	($rest,@bits) = split /<H2>/i, $chunk;
	my $dbtitle = $title[$i];
	my $sectype = 'overview';
	if($dbtitle =~ /^\s*NAME\s*$/) {
		$sectype = 'filler';
	}
	elsif($dbtitle =~ /^\s*DESCRIPTION\s*$/) {
		$dbtitle = 'General Information';
	}
	$overview = <<EOF;
$ENV{DOCUMENT}$ov.00
%%
$ENV{DOCUMENT}
%%
$secname[$i]
%%
$sectype
%%
$dbtitle
%%

$rest
%%%
EOF
	push(@overview, $overview);
	$head .= $rest;
	$head .= '<UL>';

	open(OUT1, ">$dir/$section.00.$secname[$i].html")
		or die "creat $dir/$section.00.$secname[$i].html: $!\n";
	my $j = 1;

	for(@bits) {
		/<a\s+name\s*=\s*"([^"]+)">([^<]+)/i;
		$subname[$j] = $1;
		$subname[$j] =~ s/([^-.\w])/'%' . sprintf("%02x", ord($1))/eg;
		$subtitle[$j] = $2;
		$j++;
	}

	$j = 1;
	for(@bits) {
		$sub = sprintf ("%02d", $j);
print "$ENV{DOCUMENT}$sub\n";
		$head .= qq|<LI><A HREF="$section.$sub.$subname[$j].html">$subtitle[$j]</A></LI>\n|;
		open(OUT2, ">$dir/$section.$sub.$subname[$j].html")
			or die "creat $dir/$section.$sub.$subname[$j].html: $!\n";
		my $bar = '<H3>';
		$bar .= qq{<A HREF="index.html">Index</A>&nbsp;&nbsp;};
		$bar .= qq{<A HREF="$section.00.$secname[$i].html">Up</A>&nbsp;&nbsp;};
		my $n;
		if($j > 1) {
			$n = sprintf("%02d", $j - 1);
			$bar .= qq{<A HREF="$section.$n.$subname[$j - 1].html">};
			$bar .= qq{&lt;&lt;</A>&nbsp;&nbsp;};
		}
		if($j < scalar @bits) {
			$n = sprintf("%02d", $j + 1);
			$bar .= qq{<A HREF="$section.$n.$subname[$j + 1].html">};
			$bar .= qq{&gt;&gt;</A>&nbsp;&nbsp;};
		}
		$bar .= "</H3>";

		print NAV qq{<BR><IMG VSPACE=4 SRC="bullet.gif"><FONT SIZE="-1"><A HREF="$section.$sub.$subname[$j].html">$subtitle[$j]</A></FONT>};
		$item = <<EOF;
$ENV{DOCUMENT}$section.$sub
%%
$ENV{DOCUMENT}
%%
$secname[$i]
%%
item
%%
$subtitle[$j]
%%
$_
%%%
EOF
		s!<DD>\s*<P>(.*?)(?:</DD>\s*)?(</DL>|<DT>)!<DD>$1</DD><P>$2!gs;
		print OUT2 <<EOF;
<HTML>
<HEAD>
<TITLE>$subtitle[$j]</TITLE>
</HEAD>
<BODY BGCOLOR="#FFFFFF">
$bar
<HR>
<H2>$_
<P ALIGN=CENTER>$bar$foot
EOF
		push(@items, $item);
		close OUT2;
		$j++;
	}
	$head .= '</UL><BR><HR>';
	print OUT1 $head;
	print OUT1 $mainbar;
	print OUT1 $foot;
	close OUT1;
	$i++;
}

print NAV $foot;

chomp(@overview);
chomp(@items);
my %location;
for (@overview, @items) {
	/^(.*)/ or next;
	my $code = $1;
	while( /<A NAME="([^"]+)"/g) {
		$location{$1} = $location{$1} ? "$location{$1} $code" : $code;
	}
}
for (@overview, @items) {
	s/<A HREF="#([^"]+)"/<A HREF="_DOCURL_$location{$1}#$1"/g;
}
open(DOCDB, ">$dir/docdb.txt") or die "create $dir/docdb.txt: $!\n";
print DOCDB join "\n", sort(@overview, @items), '';
