# $Id: tolatex.pl,v 1.1 2001-03-29 20:31:46 jon Exp $
$VERSION{__FILE__} = '$Revision: 1.1 $';
#
# >>Title::     LaTeX Format Driver
#
# >>Copyright::
# Copyright (c) 1997, Ian Clatworthy (ianc@mincom.com).
# You may distribute under the terms specified in the LICENSE file.
#
# >>History::
# -----------------------------------------------------------------------
# Date      Who     Change
# 30-Oct-98 valerio First Beta release.
# 02-Apr-98 valerio Fixed List closing before Tables.
# 14-Mar-98 valerio Wrote List code.
# 20-Nov-97 valerio Initial rewriting for full use of LaTeX. 
# 12-Aug-97 ianc    Initial writing for Apache Documentation Project
# 14-May-96 ianc    SDF 2.000
# -----------------------------------------------------------------------
#
# >>Purpose::
# This library provides an [[SDF_DRIVER]] which generates
# LaTeX files.
#
# >>Description::
#
# >>Limitations::
#
# >>Resources::
#
# >>Implementation::
#

##### Constants #####

# Default right margin
$_LATEX_DEFAULT_MARGIN = 70;

# Mapping of characters
%_LATEX_CHAR = (
    'backslash'.    '\\',
    'bullet',       '$\bullet$',
    'c',            '\copyright ',
    'cent',         'c',
    'dagger',       '\dagger',
    'doubledagger', '\ddagger',
    'emdash',       '--',
    'endash',       '---',
    'emspace',      '\ \ ',
    'enspace',      '\ ',
    'lbrace',       '{',
    'lbracket',     '[',
    'nbdash',       '-',
    'nbspace',      ' ',
    'nl',           "\n",
    'pound',        '\pounds ',
    'r',            '(r)',
    'rbrace',       '}',
    'rbracket',     ']',
    'tab',          "\t",
    'tm',           '$^{TM}$',
    'yen',          'y',

    # From pod2latex ...

    'amp'	=>	'\\&',	#   ampersand
    'lt'	=>	'$<$',	#   left chevron, less-than
    'gt'	=>	'$>$',	#   right chevron, greater-than
    'quot'	=>	'"',	#   double quote

    "Aacute"	=>	"\\'{A}",	#   capital A, acute accent
    "aacute"	=>	"\\'{a}",	#   small a, acute accent
    "Acirc"	=>	"\\^{A}",	#   capital A, circumflex accent
    "acirc"	=>	"\\^{a}",	#   small a, circumflex accent
    "AElig"	=>	'\\AE',		#   capital AE diphthong (ligature)
    "aelig"	=>	'\\ae',		#   small ae diphthong (ligature)
    "Agrave"	=>	"\\`{A}",	#   capital A, grave accent
    "agrave"	=>	"\\`{a}",	#   small a, grave accent
    "Aring"	=>	'\\u{A}',	#   capital A, ring
    "aring"	=>	'\\u{a}',	#   small a, ring
    "Atilde"	=>	'\\~{A}',	#   capital A, tilde
    "atilde"	=>	'\\~{a}',	#   small a, tilde
    "Auml"	=>	'\\"{A}',	#   capital A, dieresis or umlaut mark
    "auml"	=>	'\\"{a}',	#   small a, dieresis or umlaut mark
    "Ccedil"	=>	'\\c{C}',	#   capital C, cedilla
    "ccedil"	=>	'\\c{c}',	#   small c, cedilla
    "Eacute"	=>	"\\'{E}",	#   capital E, acute accent
    "eacute"	=>	"\\'{e}",	#   small e, acute accent
    "Ecirc"	=>	"\\^{E}",	#   capital E, circumflex accent
    "ecirc"	=>	"\\^{e}",	#   small e, circumflex accent
    "Egrave"	=>	"\\`{E}",	#   capital E, grave accent
    "egrave"	=>	"\\`{e}",	#   small e, grave accent
    "ETH"	=>	'\\OE',		#   capital Eth, Icelandic
    "eth"	=>	'\\oe',		#   small eth, Icelandic
    "Euml"	=>	'\\"{E}',	#   capital E, dieresis or umlaut mark
    "euml"	=>	'\\"{e}',	#   small e, dieresis or umlaut mark
    "Iacute"	=>	"\\'{I}",	#   capital I, acute accent
    "iacute"	=>	"\\'{i}",	#   small i, acute accent
    "Icirc"	=>	"\\^{I}",	#   capital I, circumflex accent
    "icirc"	=>	"\\^{i}",	#   small i, circumflex accent
    "Igrave"	=>	"\\`{I}",	#   capital I, grave accent
    "igrave"	=>	"\\`{i}",	#   small i, grave accent
    "Iuml"	=>	'\\"{I}',	#   capital I, dieresis or umlaut mark
    "iuml"	=>	'\\"{i}',	#   small i, dieresis or umlaut mark
    "Ntilde"	=>	'\\~{N}',	#   capital N, tilde
    "ntilde"	=>	'\\~{n}',	#   small n, tilde
    "Oacute"	=>	"\\'{O}",	#   capital O, acute accent
    "oacute"	=>	"\\'{o}",	#   small o, acute accent
    "Ocirc"	=>	"\\^{O}",	#   capital O, circumflex accent
    "ocirc"	=>	"\\^{o}",	#   small o, circumflex accent
    "Ograve"	=>	"\\`{O}",	#   capital O, grave accent
    "ograve"	=>	"\\`{o}",	#   small o, grave accent
    "Oslash"	=>	"\\O",		#   capital O, slash
    "oslash"	=>	"\\o",		#   small o, slash
    "Otilde"	=>	"\\~{O}",	#   capital O, tilde
    "otilde"	=>	"\\~{o}",	#   small o, tilde
    "Ouml"	=>	'\\"{O}',	#   capital O, dieresis or umlaut mark
    "ouml"	=>	'\\"{o}',	#   small o, dieresis or umlaut mark
    "szlig"	=>	'\\ss',		#   small sharp s, German (sz ligature)
    "THORN"	=>	'\\L',		#   capital THORN, Icelandic
    "thorn"	=>	'\\l',,		#   small thorn, Icelandic
    "Uacute"	=>	"\\'{U}",	#   capital U, acute accent
    "uacute"	=>	"\\'{u}",	#   small u, acute accent
    "Ucirc"	=>	"\\^{U}",	#   capital U, circumflex accent
    "ucirc"	=>	"\\^{u}",	#   small u, circumflex accent
    "Ugrave"	=>	"\\`{U}",	#   capital U, grave accent
    "ugrave"	=>	"\\`{u}",	#   small u, grave accent
    "Uuml"	=>	'\\"{U}',	#   capital U, dieresis or umlaut mark
    "uuml"	=>	'\\"{u}',	#   small u, dieresis or umlaut mark
    "Yacute"	=>	"\\'{Y}",	#   capital Y, acute accent
    "yacute"	=>	"\\'{y}",	#   small y, acute accent
    "yuml"	=>	'\\"{y}',	#   small y, dieresis or umlaut mark
);

# Directive mapping table
%_LATEX_HANDLER = (
    'tuning',           '_LatexHandlerTuning',
    'endtuning',        '_LatexHandlerEndTuning',
    'table',            '_LatexHandlerTable',
    'row',              '_LatexHandlerRow',
    'cell',             '_LatexHandlerCell',
    'endtable',         '_LatexHandlerEndTable',
    'import',           '_LatexHandlerImport',
    'inline',           '_LatexHandlerInline',
    'output',           '_LatexHandlerOutput',
    'object',           '_LatexHandlerObject',
);

# Phrase directive mapping table
%_LATEX_PHRASE_HANDLER = (
    'char',             '_LatexPhraseHandlerChar',
    'import',           '_LatexPhraseHandlerImport',
    'inline',           '_LatexPhraseHandlerInline',
    'variable',         '_LatexPhraseHandlerVariable',
);

# List states

$_LATEX_LISTLEVEL  = 0;
@_LATEX_LISTTYPES = ();

# Table states
$_LATEX_INTABLE = 1;
$_LATEX_INROW   = 2;
$_LATEX_INCELL  = 3;



##### Variables #####

# Right margin position
$_latex_margin = $SDF_USER'var{'LATEX_MARGIN'} || $_LATEX_DEFAULT_MARGIN;

# Counters for ordered lists - index is the level
@_latex_list_num = 0;

# Table states and row types
@_latex_tbl_state = ();
@_latex_row_type = ();

# Column number & starting positions for current table
$_latex_col_num = 0;
@_latex_col_posn = ();

# Current column number
$_latex_current_col = 1;

# Number of Table columns
$_latex_tab_cols = 0;

# Table column alignment
@_latex_colaligns = ();

# Location of the first line of the current row
$_latex_first_row = 0;

# The current cell text
$_latex_cell_current = '';

# The current verbatim escape char
$_latex_verbatim_open  = '';
$_latex_verbatim_close = '';

# Global in example;
$_latex_in_example = 0;

##### Routines #####

#
# >>Description::
# {{Y:LatexFormat}} is an SDF driver which outputs plain text files.
#
sub LatexFormat {
    local(*data) = @_;
    local(@result);
    local(@contents);

    # Initialise defaults
    $_latex_margin = $SDF_USER'var{'LATEX_MARGIN'} || $_LATEX_DEFAULT_MARGIN;

    # Format the paragraphs
    @contents = ();
    @result = &_LatexFormatSection(*data, *contents);

    # Turn into final form and return
    return &_LatexFinalise(*result, *contents);
}

#
# >>_Description::
# {{Y:_LatexFormatSection}} formats a set of SDF paragraphs into text.
# If a parameter is passed to contents, then that array is populated
# with a generated Table of Contents.
#
sub _LatexFormatSection {
    local(*data, *contents) = @_;
    local(@result);
    local($prev_tag, $prev_indent);
    local($para_tag, $para_text, %para_attrs);
    local($directive);


    # Process the paragraphs
    @result = ();
    $prev_tag = '';
    $prev_indent = '';
    while (($para_text, $para_tag, %para_attrs) = &SdfNextPara(*data)) {

        # handle directives
        if ($para_tag =~ /^__(\w+)$/) {
            $directive = $_LATEX_HANDLER{$1};
            if (defined &$directive) {
                &$directive(*result, $para_text, %para_attrs);
            }
            else {
                &AppMsg("warning", "ignoring internal directive '$1' in LATEX driver");
            }
            next;
        }

        # Add the paragraph
        &_LatexParaAdd(*result, $para_tag, $para_text, *para_attrs, $prev_tag,
          $prev_indent, *contents);
    }

    # Do this stuff before starting next loop iteration
    continue {
        unless ($para_tag eq 'PB') {
            $prev_tag = $para_tag;
            $prev_indent = $para_attrs{'in'};
        }
    }

    # Return result
    return @result;
}
       
#
# >>_Description::
# {{Y:_LatexParaAdd}} adds a paragraph.
#
sub _LatexParaAdd {
    local(*result, $para_tag, $para_text, *para_attrs, $prev_tag, $prev_indent, *contents) = @_;
#   local();
    local($in_example);
    local($para_fmt);
    local($para_override);
    local($para);
    local($hdg_level);
    local($toc_jump);
    local($label);

    # Set the example flag
    $in_example = $SDF_USER'parastyles_category{$para_tag} eq 'example';

    if ($in_example) {
       if ($_latex_in_example eq 0) {
          $_latex_in_example = 1;
          $para_text = "\\begin\{verbatim\}\n" . $para_text;
       }
    }
    else {
       if ($_latex_in_example eq 1) {
        $_latex_in_example = 0;
        &_LatexParaAppend(*result, "\n\\end\{verbatim\}\n");
       }
    }

    # Enumerated lists are the same as list paragraphs at the previous level
    if ($para_tag =~ /^LI(\d)$/) {
        $para_tag = $1 > 1 ? "L" . ($1 - 1) : 'N';
    }

    # Get the target format name
    $para_fmt = $SDF_USER'parastyles_to{$para_tag};
    $para_fmt = $para_tag if $para_fmt eq '';

    # Map the attributes
    &SdfAttrMap(*para_attrs, 'latex', *SDF_USER'paraattrs_to,
      *SDF_USER'paraattrs_map, *SDF_USER'paraattrs_attrs,
      $SDF_USER'parastyles_attrs{$para_tag});

    # Build the Table of Contents as we go

    if ($para_tag =~ /^[HAP](\d)$/) {
	$para_fmt = $para_tag;
    }

    # Handle lists (is this needed for text format?)
    elsif ($para_tag =~ /^(L[FUN]?)(\d)$/) {
        $para_attrs{'in'} = $2;
    }

    # Prepend the label, if any (replacing tabs with spaces)
    $label = $para_attrs{'label'};
    $label = 'Note: ' if ($para_tag eq 'Note' || $para_tag eq 'NB') &&
             $label eq '';
    $label =~ s/\\t/ /g;
    $para_text = "{{2:$label}}$para_text" if $label ne '';

    # Indent examples, if necessary
    if ($in_example) {
# do nothing
    }

    # Format the paragraph body
    if ($para_attrs{'verbatim'} || $in_example) {
        $para = $para_text;
        delete $para_attrs{'verbatim'};
    }
    else {
        $para = &_LatexParaText($para_text);
    }

    # If we're in a table, prepend the paragraph onto the current cell
    if (@_latex_tbl_state) {
        if ($para_fmt eq "Line") {
            $_latex_cell_current .= "-" x $_latex_cell_width;
            return;
        }
        $_latex_cell_current .= $para;
        return;
    }

    # Build result
    if ($para_tag eq 'PB') {
        $para = &_LatexElement($para_fmt, $para, %para_attrs);
        &_LatexParaAppend(*result, $para);
    }
    elsif ($in_example && $para_tag eq $prev_tag && !%para_attrs) {
        &_LatexParaAppend(*result, $para);
    }
    else {
        $para = &_LatexElement($para_fmt, $para, %para_attrs);
        push(@result, $para);
    }
}

#
# >>_Description::
# {{Y:_LatexParaText}} converts SDF paragraph text into LATEX.
# 
sub _LatexParaText {
    local($para_text) = @_;
    local($para);
    local($state);
    local($sect_type, $char_tag, $text, %sect_attrs);
    local($added_anchors);
    local(@char_fonts);
    local($char_font);
    local($directive);

    # Process the text
    $para = '';
    $state = 0;
    while (($sect_type, $text, $char_tag, %sect_attrs) =
      &SdfNextSection(*para_text, *state)) {

        # Build the paragraph
        if ($sect_type eq 'special') {
            $directive = $_LATEX_PHRASE_HANDLER{$char_tag};
            if (defined &$directive) {
                &$directive(*para, $text, %sect_attrs);
            }
            else {
                &AppMsg("warning", "ignoring special phrase '$1' in LATEX driver");
            }
	}
        elsif ($sect_type eq 'phrase') {
   

	    if ($char_tag eq 'L') {
                ($text, $url) = &SDF_USER'ExpandLink($text);
                $sect_attrs{'jump'} = $url;
            }

            if ($char_tag ne 'E' 
                && $SDF_USER'phrasestyles_to{$char_tag} ne 'SDF_VERBATIM') {
	      # Escape any special characters
	      $text = &_LatexEscape($text);
	    }

	  if ( $SDF_USER'phrasestyles_to{$char_tag} eq 'SDF_VERBATIM') {
	    _LatexCheckVerbatim($text);
	      $text = $_latex_verbatim_open . $text;
	  }

            # Expand non-breaking spaces, if necessary
	  if ($char_tag eq 'S') {
	    $text =~ s/ /~/g;
	  }
	  
	  
	  # Process formatting attributes
            &SdfAttrMap(*sect_attrs, 'latex', *SDF_USER'phraseattrs_to,
	       *SDF_USER'phraseattrs_map, *SDF_USER'phraseattrs_attrs,
	       $SDF_USER'phrasestyles_attrs{$char_tag});


            # Map the font
            $char_font = $SDF_USER'phrasestyles_to{$char_tag};


            # Add the text for this phrase
            push(@char_fonts, $char_font);
            if ($char_font ne '' && $char_font !~ /^SDF/) {
                $para .= "$char_font$text";
            }
            else {
                $para .= $text;
            }
        }

	  elsif ($sect_type eq 'phrase_end') {
	      $char_font = pop(@char_fonts);
	      $para .= "}}" if $char_font ne '' && $char_font !~ /^SDF/;
              if ($char_font eq 'SDF_VERBATIM') { $para .= $_latex_verbatim_close; }
	  }


        elsif ($sect_type eq 'string') {
            $text = &_LatexEscape($text);
            $para .= $text;
        }

        elsif ($sect_type eq 'phrase') {
        }

        elsif ($sect_type eq 'phrase_end') {
            # do nothing
        }

        else {
            &AppMsg("warning", "unknown section type '$sect_type' in LATEX driver");
        }
    }

    # Return result
    return $para;
}


#
# >>_Description::
# {{Y:_LatexElement}} formats a LATEX element from a
# tag, text and set of attributes.
#
sub _LatexElement {
    local($tag, $text, %attr) = @_;
    local($latex);
    local($prefix, $label);
    local($list_level, $close_list);
    local($cnt);

    # Handle page breaks
    if ($tag eq 'PB') {
        return "\\newpage";
    }

    # For examples, don't word wrap the lines
    if ($tag eq 'E') {
        $latex =  "$text";
    }

    # For lines, output a 'line'
    elsif ($tag eq 'Line') {
        $latex =  ("_" x $_latex_margin) . "\n";
    }

    # For headings, underline the text
    elsif ($tag =~ /^[HAP](\d)/) {
      while ($_LATEX_LISTLEVEL gt 0) {
	$close_list .= "\\end\{$_LATEX_LISTTYPES[$_LATEX_LISTLEVEL]\}\n";
	$_LATEX_LISTLEVEL--;
      }
        $latex = $close_list . "\n" . "$SDF_USER'parastyles_to{$tag}\{$text\}\n"; 
#	    . ($char x length("$SDF_USER'parastyles_to{$tag}\{$text\}\n")) . "\n";
    }


    # For list items, add the necessary "label"
    elsif ($tag =~ /^(L[FUN]?)(\d)$/) {
      
      $ list_level = $2;
      #>        $prefix = " " x ($2 * 5);
      #>        $label  = " " x (($2 - 1) * 5);
      
      if ($1 eq 'LU') {
	if ($_LATEX_LISTLEVEL lt $list_level) {
	  $label = "\\begin\{itemize\} \% Level $list_level\n";
	  $_LATEX_LISTLEVEL = $list_level;
	  @_LATEX_LISTTYPES[$list_level] = "itemize";
	}
	elsif ($_LATEX_LISTLEVEL gt $list_level) {
	  $label = "\\end\{$_LATEX_LISTTYPES[$_LATEX_LISTLEVEL]\}\n";
	  $_LATEX_LISTTYPES[$_LATEX_LISTLEVEL] = "";
	  $_LATEX_LISTLEVEL = $list_level;
	}
      $label .= "\\item ";
      }
        elsif ($1 eq 'L') {
	if ($_LATEX_LISTLEVEL lt $list_level) {
	  $label = "\\begin\{list\}\{\ \}\{\} \% Level $list_level\n";
	  $_LATEX_LISTLEVEL = $list_level;
	  @_LATEX_LISTTYPES[$list_level] = "list";
	}
	elsif ($_LATEX_LISTLEVEL gt $list_level) {
	  $label = "\\end\{$_LATEX_LISTTYPES[$_LATEX_LISTLEVEL]\}\n";
	  $_LATEX_LISTTYPES[$_LATEX_LISTLEVEL] = "";
	  $_LATEX_LISTLEVEL = $list_level;
	}

            $label .= "\\item ";
        }
        elsif ($1 eq 'LF') {
	if ($_LATEX_LISTLEVEL lt $list_level) {
	  $label = "\\begin\{enumerate\} \% Level $list_level\n";
	  $_LATEX_LISTLEVEL = $list_level;
	  @_LATEX_LISTTYPES[$list_level] = "enumerate";
	}
	elsif ($_LATEX_LISTLEVEL gt $list_level) {
	  $label = "\\end\{$_LATEX_LISTTYPES[$_LATEX_LISTLEVEL]\}\n";
	  $_LATEX_LISTTYPES[$_LATEX_LISTLEVEL] = "";
	  $_LATEX_LISTLEVEL = $list_level;
	}

            $label .= "\\item ";
        }
        else {
	if ($_LATEX_LISTLEVEL lt $list_level) {
	  $label = "\\begin\{enumerate\} \% Level $list_level\n";
	  $_LATEX_LISTLEVEL = $list_level;
	  @_LATEX_LISTTYPES[$list_level] = "enumerate";
	}
	elsif ($_LATEX_LISTLEVEL gt $list_level) {
	  $label = "\\end\{$_LATEX_LISTTYPES[$_LATEX_LISTLEVEL]\}\n";
	  $_LATEX_LISTTYPES[$_LATEX_LISTLEVEL] = "";
	  $_LATEX_LISTLEVEL = $list_level;
	}

            $label .= "\\item ";
        }
        $latex = &MiscTextWrap($label . $text, $_latex_margin, $prefix,
          '', 1) . "\n";
    }

    # Otherwise, format as a plain paragraph
    else {
      while ($_LATEX_LISTLEVEL gt 0) {
	$close_list .= "\\end\{$_LATEX_LISTTYPES[$_LATEX_LISTLEVEL]\}\n";
	$_LATEX_LISTLEVEL--;
      }
        $latex = &MiscTextWrap($close_list . "\n" . $text, $_latex_margin, '', '', 1) . "\n";
    }

    # Handle the top attribute
    return $para{'top'} ? "\f\n$latex" : $latex;
}

#
# >>_Description::
# {{Y:_LatexParaAppend}} merges {{para}} into the last paragraph
# in {{@result}}. Both paragraphs are assumed to be examples.
#
sub _LatexParaAppend {
    local(*result, $para) = @_;
#   local();

    $result[$#result] .= "$para\n";
}

#
# >>_Description::
# {{Y:_LatexHandlerTuning}} handles the 'tuning' directive.
#
sub _LatexHandlerTuning {
    local(*outbuffer, $style, %attr) = @_;
#   local();

    # do nothing
}

#
# >>_Description::
# {{Y:_LatexHandlerEndTuning}} handles the 'endtuning' directive.
#
sub _LatexHandlerEndTuning {
    local(*outbuffer, $style, %attr) = @_;
#   local();

    # do nothing
}

#
# >>_Description::
# {{Y:_LatexHandlerTable}} handles the 'table' directive.
#
sub _LatexHandlerTable {
    local(*outbuffer, $columns, %attr) = @_;
    local($tmp, $close_list, $coldim);
    local($tbl_title);

    $_latex_tab_cols = $columns; 
    $coldim = (1 / $columns) - 0.02;

    # Close all yet open lists
    $close_list = "";
    while ($_LATEX_LISTLEVEL gt 0) {
      $close_list .= "\\end\{$_LATEX_LISTTYPES[$_LATEX_LISTLEVEL]\}\n";
      $_LATEX_LISTLEVEL--;
    }
    push(@outbuffer, $close_list . "\n\n");
    

    # Update the state
    push(@_latex_tbl_state, $_LATEX_INTABLE);
    push(@_latex_row_type, '');

    # Calculate the column positions (rounded)

    @_latex_col_posn = &SdfColPositions($columns, $attr{'format'}, $_latex_margin);
    @_latex_colaligns = split(/,/, $attr{'colaligns'});

    # Add the title, if any
    $tbl_title = $attr{'title'};
    if ($tbl_title ne '') {
        push(@outbuffer, "\\begin\{table\}\[H\]\n\\caption\[$tbl_title\]\{$tbl_title\}\n");
    }
    else {
        push(@outbuffer, "\\begin\{table\}\[H\]\n");
      }
    push(@outbuffer, "\\begin\{center\}\n\\begin\{tabular\}");

    $outbuffer[$#outbuffer] .= "\{";
    if ($attr{'style'} ne 'plain' &&  $attr{'style'} ne 'rows') {
      $outbuffer[$#outbuffer] .= "|";
    }
    foreach $tmp (1..$_latex_tab_cols) {
      $outbuffer[$#outbuffer] .= 
	"c";
#	"\@\{\\hspace\{.01\\linewidth\}\}p\{$coldim\\linewidth\}\@\{\\hspace\{.01\\linewidth\}\}";
      if ($attr{'style'} ne 'plain' &&  $attr{'style'} ne 'rows') {
	$outbuffer[$#outbuffer] .= "|";
      }
    }
    $outbuffer[$#outbuffer] .= "\}";

    if ($attr{'style'} ne 'plain') {
      push(@outbuffer, "\\hline");
    }
    push(@outbuffer,"%% -> attribute format = $attr{'format'}");
    push(@outbuffer,"%% -> attribute colaligns = $attr{'colaligns'}");
}

#
# >>_Description::
# {{Y:_LatexHandlerRow}} handles the 'row' directive.
#
sub _LatexHandlerRow {
    local(*outbuffer, $text, %attr) = @_;
#   local();
    local($current_state);

    # Finalise the previous row, if any
    $current_state = $_latex_tbl_state[$#_latex_tbl_state];
    unless ($current_state eq $_LATEX_INTABLE) {
        &_LatexFinalisePrevRow(*outbuffer, $_latex_row_type[$#_latex_row_type]);
    }

    # Start the new row
    push(@outbuffer, "");
    $_latex_col_num = 0;
    $_latex_first_row = $#outbuffer;

    # Update the state
    $_latex_tbl_state[$#_latex_tbl_state] = $_LATEX_INROW;
    $_latex_row_type[$#_latex_row_type] = $text;
#    push(@outbuffer,"%% -> Starting row type $text\n");
}

#
# >>_Description::
# {{Y:_LatexHandlerCell}} handles the 'cell' directive.
#
sub _LatexHandlerCell {
    local(*outbuffer, $text, %attr) = @_;
#   local();
    local($state);
    local($padding);
    local($tmp);

    # Finalise the old cell, if any
    $state = $_latex_tbl_state[$#_latex_tbl_state];
    if ($state eq $_LATEX_INCELL) {
        &_LatexFinishCell(*outbuffer);
#        if ($_latex_col_num > 0) {
#            foreach $tmp ($_latex_first_row .. $#outbuffer) {
#                $padding = $_latex_col_posn[$_latex_col_num - 1] -
#                  length($outbuffer[$tmp]);
#                $padding = 1 if ($padding <= 0);
#                $outbuffer[$tmp] .= " " x $padding;
#            }
#        }
      }

    # Update the state
    $_latex_tbl_state[$#_latex_tbl_state] = $_LATEX_INCELL;
    $_latex_cell_margin = ($_latex_col_num>0?$_latex_col_posn[$_latex_col_num-1]:0);
    $_latex_col_num+=$attr{cols};
    if ($_latex_col_num > $#_latex_col_posn + 1) {
        $_latex_cell_width = $_latex_margin - $_latex_cell_margin - 1;
    } else {
        $_latex_cell_width = $_latex_col_posn[$_latex_col_num-1] -
             $_latex_cell_margin - 1;
    }
    %_latex_cell_attrs = %attr;
    $_latex_cell_current = "";
}

#
# >>_Description::
# {{Y:_LatexFinishCell}} adds the cell text to the output
#
sub _LatexFinishCell {
    local(*outbuffer) = @_;
    $_latex_cell_current =~ s/\s+/ /g;
    local @lines = split(/\n/,
        &MiscTextWrap($_latex_cell_current, $_latex_cell_width,"",'',1));
    local $tmp;
#    foreach $tmp ($#outbuffer+1..$_latex_first_row+$#lines) {
#        push(@outbuffer, " " x $_latex_cell_margin);
#    }

    if ($#lines == 0) {
	if ($_latex_cell_attrs{'align'} eq "Center") {
	  $outbuffer[$#outbuffer] .=
	    "\{\\centering $lines[$#lines]\}";
	} elsif ($_latex_cell_attrs{'align'} eq "Right") {
	  $outbuffer[$#outbuffer] .=
	    "\{\\raggedright  $lines[$#lines]\}";
	} else {
	  $outbuffer[$#outbuffer] .=
	    "\{\\raggedleft  $lines[$#lines]\}";
	}
	if ($_latex_col_num < $_latex_tab_cols) {
	  $outbuffer[$#outbuffer] .= " & ";
	}
    } else {
      if ($_latex_cell_attrs{'align'} eq "Center") {
	$outbuffer[$#outbuffer] .=
	  "\{\\centering ";
      } elsif ($_latex_cell_attrs{'align'} eq "Right") {
	$outbuffer[$#outbuffer] .=
	  "\{\\raggedright ";
      } else {
	  $outbuffer[$#outbuffer] .=
	    "\{\\raggedleft ";
	}
      foreach $tmp (0..$#lines) {
	$outbuffer[$#outbuffer] .= " $lines[$tmp] ";
      }
      $outbuffer[$#outbuffer] .= "\}";
      if ( $_latex_col_num < $_latex_tab_cols ) {
	$outbuffer[$#outbuffer] .= " \& ";
      }
    }
    $_latex_cell_current = "";
    $_latex_current_col++;
}

#
# >>_Description::
# {{Y:_LatexHandlerEndTable}} handles the 'endtable' directive.
#
sub _LatexHandlerEndTable {
    local(*outbuffer, $text, %attr) = @_;
#   local();
    local($state);
    local($row_type);

    # Finalise the table
    $state = pop(@_latex_tbl_state);
    $row_type = pop(@_latex_row_type);
    if ($state eq $_LATEX_INCELL) {
        &_LatexFinalisePrevRow(*outbuffer, $row_type);
        $outbuffer[$#outbuffer] .= "\n";
    }
    elsif ($state eq $_LATEX_INROW) {
        &_LatexFinalisePrevRow(*outbuffer, $row_type);
        $outbuffer[$#outbuffer] .= "\n";
    }
    if ($attr{'style'} ne 'plain') {
      push(@outbuffer,"\\hline\n");
    }
    push(@outbuffer, "\\end\{tabular\}\n\\end\{center\}\n\\end\{table\}\n");
    
}

#
# >>_Description::
# {{Y:_LatexFinalisePrevRow}} finalises the previous row, if any.
#
sub _LatexFinalisePrevRow {
    local(*outbuffer, $row_type) = @_;
#   local();
    local($line_row);
    local($prefix);
    local($tmp);
    local($_);

    &_LatexFinishCell(*outbuffer);
    foreach $tmp ($_latex_first_row..$#outbuffer) {
        $outbuffer[$tmp] =~ s/ *(\n*)$/$1/;
    }

    # If the last row was a heading, underline it
    $outbuffer[$#outbuffer] .= "\\\\";
    if ($row_type ne 'Heading') {
#      while (< $_latex_col_num) {
#	     $outbuffer[$#outbuffer] .= " \& \{\}";
#	     $_latex_col_num++;
#	   }   
    } else {
      $line_row = "";
      if ($attr{'style'} ne 'plain') {
	$line_row = "\\hline";
	if ($attr{'style'} eq 'grid') {
	  $line_row .= "\\hline";
	}
      }
      push(@outbuffer, $line_row);
    }
}

#
# >>_Description::
# {{Y:_LatexHandlerImport}} handles the import directive.
#
sub _LatexHandlerImport {
    local(*outbuffer, $filepath, %attr) = @_;
#   local();
    local($para);

    # Build the result
    &_LatexPhraseHandlerImport(*para, $filepath, %attr);
    push(@outbuffer, "$para\n");
}

#
# >>_Description::
# {{Y:_LatexHandlerInline}} handles the inline directive.
#
sub _LatexHandlerInline {
    local(*outbuffer, $text, %attr) = @_;
#   local();

    # Check we can handle this format
    my $target = $attr{'target'};
    return unless $target eq 'latex' || $target eq 'text';

    # Build the result
    push(@outbuffer, $text);
}

#
# >>_Description::
# {{Y:_LatexHandlerOutput}} handles the 'output' directive.
#
sub _LatexHandlerOutput {
    local(*outbuffer, $text, %attrs) = @_;
#   local();

    # do nothing
}

#
# >>_Description::
# {{Y:_LatexHandlerObject}} handles the 'object' directive.
#
sub _LatexHandlerObject {
    local(*outbuffer, $text, %attrs) = @_;
#   local();

    # Save the margin, if necessary
    if ($text eq 'Variable' && $attrs{'Name'} eq 'LATEX_MARGIN') {
        $_latex_margin = $attrs{'value'};
    }
}

#
# >>_Description::
# {{Y:_LatexPhraseHandlerChar}} handles the 'char' phrase directive.
#
sub _LatexPhraseHandlerChar {
    local(*para, $text, %attr) = @_;
#   local();

    # Map those we know about it
    if (defined($_LATEX_CHAR{$text})) {
        $para .= $_LATEX_CHAR{$text};
    }
    else {
        $para .= $text;
    }
}

#
# >>_Description::
# {{Y:_LatexPhraseHandlerImport}} handles the 'import' phrase directive.
#
sub _LatexPhraseHandlerImport {
    local(*para, $filepath, %attr) = @_;
#   local();
    local($name, $value);

    $para .= "** Unable to import figure $filepath **";
}

#
# >>_Description::
# {{Y:_LatexPhraseHandlerInline}} handles the 'inline' phrase directive.
#
sub _LatexPhraseHandlerInline {
    local(*para, $text, %attr) = @_;
#   local();

    # Build the result
    $para .= $text;
}

#
# >>_Description::
# {{Y:_LatexPhraseHandlerVariable}} handles the 'variable' phrase directive.
#
sub _LatexPhraseHandlerVariable {
    local(*para, $text, %attr) = @_;
#   local();

    # do nothing
}

#
# >>_Description::
# {{Y:_LatexFinalise}} generates the final LaTeX file.
#
sub _LatexFinalise {
    local(*body, *contents) = @_;
#   local(@result);
    local($title, @sdf_title, @title);
    local($version, @head);
    local($body);
    local($macro, @header, @footer);
    local(@dummy);
    local($rec, @html_contents, $toc_posn);

    # Convert the title
    $title = $SDF_USER'var{'DOC_NAME'};
    $author = $SDF_USER'var{'DOC_AUTHOR'};
    $date   = $SDF_USER'var{'DOC_DATE'};

    # Build the HEAD element (and append BODY opening)
    $version = $SDF_USER'var{'SDF_VERSION'};
    @head = (
        '%%% This file was generated using SDF $version by',
        '%%% Ian Clatworthy (ianc@mincom.com) and the 2latex_ driver', 
        '%%% $Id: tolatex.pl,v 1.1 2001-03-29 20:31:46 jon Exp $',
        '%%% written by Valerio Aimale <valerio@svpop.com.dist.unige.it>.',
        '%%% SDF is freely available from http://www.mincom.com/mtr/sdf',
        ''
    );
    push(@head, '\author{'. $author . '}') if $author;
    push(@head, '\date{'. $date . '}') if $date;
    push(@head, '\title{'. $title . '}') if $title;
    push(@head, '','');
    push(@head, '\begin{document}', '');
    push(@head, '\maketitle') if $title;




    # If requested, provide a Table of Contents
    if (@contents) {
    push(@head, '\tableofcontents');
    }

    # Close eventually open lists
      while ($_LATEX_LISTLEVEL gt 0) {
	push(@body, '',  "\\end\{$_LATEX_LISTTYPES[$_LATEX_LISTLEVEL]\}\n");
	$_LATEX_LISTLEVEL--;
      }
    # Return result
    push(@body, '', '\end{document}');
    return (@head, @body);
}

#
# >>_Description::
# {{Y:_LatexEscape}} escapes special symbols in LaTeX text.
# 
sub _LatexEscape {
    local($text) = @_;
#   local($result);
    local($old_match_flag);

    # Enable multi-line matching
    $old_match_flag = $*;
    $* = 1;

    # Escape the special symbols. Note that it isn't exactly clear
    # from the SGML-Tools and/or QWERTZ DTD documentation as to
    # whether all of these are mandatory, but they shouldn't cause
    # any harm (I hope!)
    $text =~ s/\\/\\verb+\\+/g;
    $text =~ s/\&/\\\&/g;
    $text =~ s/\</\$<\$/g;
    $text =~ s/\>/\$>\$/g;
    $text =~ s/\"/"/g;
    $text =~ s/\$/\\\$/g;
    $text =~ s/\~/\\verb+~+/g;
    $text =~ s/\^/\\verb+^+/g;
    $text =~ s/\#/\\\#/g;
    $text =~ s/\%/\\\%/g;
    $text =~ s/_/\\\_/g;
    $text =~ s/\|/\|/g;
    $text =~ s/\[/\$[\$/g;
    $text =~ s/\]/\$]\$/g;
    $text =~ s/\{/\\\{/g;
    $text =~ s/\}/\\\}/g;

    # Reset multi-line matching flag
    $* = $old_match_flag;

    # Return result
    $text;
}

#
# >>_Description::
# {{Y:_LatexCheckVerbatim}} checks for un unsed che in the phrase
#
sub _LatexCheckVerbatim {
  local($text) = @_;
  local($match);
  #   local($_i);
  for (33..127) {
    $match = chr;
    if ($text =~ /$match/) {
      ;
    }
    else {
      $_latex_verbatim_open  = '\verb' . $match;
      $_latex_verbatim_close = $match;
      return;
    }
  }
      $_latex_verbatim_open  = '\begin{verbatim}';
      $_latex_verbatim_close = '\end{verbatim}';
      return;
}


# package return value
1;
