
The template page containing tags and HTML is parsed in the following
order:

^ Any content in MV_AUTOLOAD is prepended to the template page.

..{{}}

.{{}}

+ Any E<lbracket>{{C[jump="ictags.html#pragma"]pragma}}] tags anywhere
in the text are processed, and the specified pragmas are set.

**Since E<lbracket>{{C[jump="ictags.html#pragma"]pragma}}] tags are
preprocessed before any other content,
{{C[jump="ictags.html#attributes"]reparse}} will not catch them, nor
will they work if included in variables. Also, the specified pragma
will apply to the entire template (not just the section after the tag).

**If you want to apply a pragma with a variable or only to part of a
document, you must use E<lbracket>{{C[jump="ictags.html#tag"]tag}}E<nbspace>pragma="..."]
instead.

.{{}}

+ Variables (macros) are processed in the following order:
++ @@VARNAME@@ global variables
++ @_VARNAME_@ local or global variables
++ __VARNAME__ local variables

.{{}}

+ Interchange comments are stripped.

..{{}}

.{{}}

+ False-endtag macros are expanded (e.g.,
E<lbracket>{{C[jump="ictags.html#page"]/page}}] and
E<lbracket>{{C[jump="ictags.html#order"]/order}}]).

..{{}}

.{{}}

+ '<!--+[tagname]--+>' escapes are converted to E<lbracket>tagname]

..{{}}

.{{}}

+ The main tag parser is called.

** Some tags parse recursively (depending on
{{C[jump="ictags.html#attributes"]reparse}} and
{{C[jump="ictags.html#attributes"]interpolate}} settings, of course).

** Some tags (e.g., E<lbracket>{{C[jump="ictags.html#loop"]loop}}])
process prefix-tags in their contained body text.  The prefix-tags are
not handled recursively.

.{{}}

+ Image paths substitution on the HTML output occurs.
