# EIR Editorial coding unwrapper
# by Richard Burden
# Last updated: Nov. 10, 2004


my $input_path = $ARGV[0];
my $infile = $input_path.'.txt';
my $outfile = $input_path.'.html.txt';
my $pspace = "";
my $titleOpen = '<div style="font-size:180%;line-height:normal;text-align:left;margin-bottom:1em">';
my $titleClose = '</div>'."\n";
my $bodyOpen = '<div class="article_container">'."\n";
my $bodyClose = '<div>'."\n";
my $kickerOpen  = '<div style="font-size:130%;line-height:normal;margin-bottom:1em;text-align:left;margin-bottom:1em">';
my $kickerClose = $titleClose;
my $openFootnoteSection = '<div class="footnote_link">'."\n";
my $closeFootnoteSection = '</div>';
my $imgTemplate = '<div style="text-align: center; clear: both"> <div style="width: 365px; margin: 0px auto"><a href="%%%large_img_url%%%" target="_blank"><img src="%%%img_url%%%" /><br />Ver ampliación</a> <div style="font-size: 90%; line-height: normal; text-align:right">%%%picture_credit%%%</div><div style="font-size: 90%; line-height: normal; text-align: left">%%%caption%%%</div> </div>  </div>';
my $eirespanolImgTemplate = '<div style="text-align: center; clear: both"><div style="margin: 0px auto 1em"><img src="%%%img_url%%%" /><div style="font-size: 90%; line-height: normal; text-align: right">%%%picture_credit%%%</div><div style="font-size: 90%; line-height: normal; text-align: left">%%%caption%%%</div></div></div>';

open (INPUT, $infile) || die "can't open $infile: $!";
open (OUTPUT, "+>$outfile")  || die "can't open $outfile for writing: $!";

 
#store the entire file in $file
$file = "";

my $alpha_doc = "";
my $date = localtime;

while (<INPUT>)
{
    if ($_ =~ m%^\[?[a-z0-9][0-9]\]?[:\-/\.]?[0-9][0-9][0-9][\-\./]?[a-z][a-z][a-z_]\.\d\d\d\s*$%i)
    {
	if ($alpha_doc ne "")
	{	
	    my $line = $_;
	    alpha2html($alpha_doc,$file);
	    $file = "";
	    $_ = $line;
	}
	$alpha_doc = $_; 
	chomp $alpha_doc; 
	$alpha_doc =~ s%\s*$%%;
print OUTPUT "----------------------------------------------------------------------\n\
 $alpha_doc \n\
------------------------------------------------------------------------\n";
	next
    }
    $file .= $_; 
}
    
close INPUT;
alpha2html($alpha_doc,$file);
close OUTPUT;


sub alpha2html
{
 

    my  ($alpha_doc, $file) = @_;
    my $footnote_link_section = 0;
    my $parasFound = 0;

    if ($file !~ m%\n$%)
    {
	$file .= "\n";
    }
#writing the string to a file and then reading it is necessary to make
#the return characters visible.  Without this step, it is not possible
#to form the paragraphs.
    open (TEMP, "+>temp") || die "can't open temp for writing: $!";
    print TEMP $file;
    close TEMP;
    open (TEMP, "temp") || die "can't open temp: $!";


    while (<TEMP>)
    {
	my $savedLine = $_;

	s/<jf1>fmt:colwidth\d+<cm//g;
	s/&/&amp;/g;
	s/\"/&quot;/g;

	if ($_ =~ /^\[\[\[(.*)/)
	{ 
	    print OUTPUT $savedLine;
	    $_ = $titleOpen.$1.$titleClose;
	}
	elsif ($_ =~ /^\[\[k\[(.*)/)
	{ 
	    print OUTPUT $savedLine;
	    $_ = $kickerOpen.$1.$kickerClose;
	}
	elsif ($_ =~ /\[\d+ líneas/)
	{
	    $lookForTitle = 1;
	    next;
	}

# 1-, 2-, and 3-digit footnote refs
	s/\@s(\d)<fu\d>/<a name="fnB$1" id="fnB$1"><\/a><a href="#fn$1">\[$1\]<\/a>/g;
	s/\@s(\d)\@s(\d)<fu\d\d>/<a name="fnB$1$2" id="fnB$1$2"><\/a><a 
href="#fn$1$2">\[$1$2\]<\/a>/g;
	s/\@s(\d)\@s(\d)\@s(\d)<fu\d\d\d>/<a name="fnB$1$2$3" id=name="fnB$1$2$3"><\/a><a 
href="#fn$1$2$3">\[$1$2$3\]<\/a>/g;

# footnotes
	s/<jf90>//g;
	s/<fo(\d+)>\d+\./<a name="fn$1" id="fn$1"><\/a><a href="#fnB$1">\[$1\]<\/a>/g;
	s/<fe//g;

# odds and ends
	s/<\+>//g;
	s/<\$>//g;
	s/<\$//g;
	s/\t/\n/g;
	s/<ql/<br>/g;
	s/<cc\d+?><cm//g;
	s/<cc\d+?>//g;

# headings
	s/<jf1>fmt:colwidth\d+<cm//g;
	s/^ *- (.+) - *$/<h4><strong>$1<\/strong><\/h4>/ig;
	s/<jf15>//ig;
	s/<jf10>(.+?)<cm/<b>$1:<\/b> /i;
	s/^<cm(.+?)<cm/<b>$1:<\/b> /i;
	s/<jf\d+?>(.+?)<cm/<h3><strong>$1<\/strong><\/h3>/ig;
	s/<jf27>//g;
	s/<jf\d+?>//ig;
	s/<cm/<br>/ig;

# superscripts and subscripts
	s/<cf11>(.*?)<cf1>/<sup>$1<\/sup>/ig;
	s/\@s(\d)\@s(\d)\@s(\d)/<sup>$1$2$3<\/sup>/ig;
	s/\@s(\d)\@s(\d)/<sup>$1$2<\/sup>/ig;
	s/\@s(\d)/<sup>$1<\/sup>/ig;

	s/<cf15>(.*?)<cf1>/<sub>$1<\/sub>/ig;
	s/\@i(\d)\@i(\d)\@i(\d)/<sub>$1$2$3<\/sub>/ig;
	s/\@i(\d)\@i(\d)/<sub>$1$2<\/sub>/ig;
	s/\@i(\d)/<sub>$1<\/sub>/ig;

# formatting tags
	s/{{/<strong>/ig;
	s/}}/<\/strong>/ig;
	s%\[\[\[(.*?)\]\[(.*?)\]\]\]%<a href="$2" target="_blank">$1</a>%ig;
	s%\[\[\[(.*?)\](.*?)\]\]%<a href="$1$2" target="_blank">$2</a>%ig;
	s%\[\[/(.*?)\]\]%<a href="http://$1" target="_blank">$1</a>%ig;
	s%\[\[(.*?)\]\]%<a href="$1" target="_blank">$1</a>%ig;
	s/{/<em>/ig;
	s/}/<\/em>/ig;
	s/<cf20>(.*?)<cf1>/<strong>$1<\/strong>/ig;
	s/<cf20>(.*?)<cf2>/<em>$1<\/em>/ig;
	s/<ql/<br \/>/ig;
	s/<pa/<br \/>/ig;
	s/<cf2>(.*?)<cf1>/<em>$1<\/em>/ig;


#Format footnote links
	if ($_ =~ /^(Vínculos?:?|Enlaces?:?|Links?:?)/i)
	{print OUTPUT $openFootnoteSection;
	 $footnote_link_section = 1;
	}

# Format all regular text paras
	if ($lookForTitle)
	{
	    print OUTPUT $savedLine;
	    s/^([^<\r])(.+)$/$titleOpen$1$2$titleClose/g;
	    s/^(<[abi])(.+)$/$titleOpen$1$2$titleClose/g;
	    s/^(<em)(.+)$/$titleOpen$1$2$titleClose/g;
	    s/^(<strong)(.+)$/$titleOpen$1$2$titleClose/g;
	    $lookForTitle = 0;
	    $parasFound += 1;
	}
	my $matches = s/^([^<\r])(.+)$/<p>$1$2<\/p>$pspace/g;
	$matches += s/^(<[abi])(.+)$/<p>$1$2<\/p>$pspace/g;
	$matches += s/^(<em)(.+)$/<p>$1$2<\/p>$pspace/g;
	$matches += s/^(<strong)(.+)$/<p>$1$2<\/p>$pspace/g;
        if ($matches)
	{if ($parasFound == 1) {$_ = $bodyOpen.$_}
	 $parasFound++}
# entities
s/``/&ldquo;/g;
s/''/&rdquo;/g;
s/`/&lsquo;/g;
s/'/&rsquo;/g;
	s/[\|\^]/&nbsp;/g;
	s/\@nh/-/g;
	s/\@am//g;
	s/\@nd/\//g;
	s/\@eD/&iexcl;/g;
	s/\@ct/&cent;/g;
	s/\@bp/&pound;/g;
	s/\@cR/&curren;/g;
	s/\@yn/&yen;/g;
	s/\@vb/&brkbar;/g;
	s/\@st/&sect;/g;
	s/\@cw/&copy;/g;
	s/\@oF/&ordf;/g;
	s/\@Gl/&laquo;/g;
	s/\@ln/&not;/g;
	s/\@dh/&shy;/g;
	s/\@rm/&reg;/g;
	s/\@dg/&deg;/g;
	s/\@pm/&plusmn;/g;
	s/\@gm/&micro;/g;
	s/\@pg/&para;/g;
	s/\@mx/&middot;/g;
	s/\@oM/&ordm;/g;
	s/\@Gr/&raquo;/g;
	s/\@c1/&frac14;/g;
	s/\@c2/&frac12;/g;
	s/\@c3/&frac34;/g;
	s/\@iQ/&iquest;/g;
	s/([AEIOUaeiou])\@ag/&$1grave;/g;
	s/([AEIOUYaeiouy])\@aa/&$1acute;/g;
	s/([AEIOUaeiou])\@af/&$1circ;/g;
	s/([ANOano])\@at/&$1tilde;/g;
	s/([AEIOUaeiouy])\@au/&$1uml;/g;
	s/([Aa])\@ab/&$1ring;/g;
	s/\@AE/&AElig;/g;
	s/([Cc])\@al/&$1cedil;/g;
	s/\@ts/&times;/g;
	s/\@OS/&Oslash;/g;
	s/\@ds/&szlig;/g;
	s/\@aE/&aelig;/g;
	s/\@dv/&divide;/g;
	s/\@oS/&oslash;/g;
	s/\@sb/*/g;
	s/~n/&#150;/g;
	s/--/&#151;/g;

# Translate DEC multinational chars to HTML entities
	s/\xA1/&iexcl;/g;
	s/\xA2/&cent;/g;
	s/\xA3/&pound;/g;
	s/\xA5/&yen;/g;
	s/\xA7/&sect;/g;
	s/\xA8/&curren;/g;
	s/\xA9/&copy;/g;
	s/\xAA/&ordf;/g;
	s/\xAB/&laquo;/g;
	s/\xB0/&deg;/g;
	s/\xB1/&plusmn;/g;
	s/\xB2/&sup2;/g;
	s/\xB3/&sup3;/g;
	s/\xB5/&micro;/g;
	s/\xB6/&para;/g;
	s/\xB7/&middot;/g;
	s/\xB9/&sup1;/g;
	s/\xBA/&ordm;/g;
	s/\xBB/&raquo;/g;
	s/\xBC/&frac14;/g;
	s/\xBD/&frac12;/g;
	s/\xBF/&iquest;/g;
	s/\xC0/&Agrave;/g;
	s/\xC1/&Aacute;/g;
	s/\xC2/&Acirc;/g;
	s/\xC3/&Atilde;/g;
	s/\xC4/&Auml;/g;
	s/\xC5/&Aring;/g;
	s/\xC6/&AElig;/g;
	s/\xC7/&Ccedil;/g;
	s/\xC8/&Egrave;/g;
	s/\xC9/&Eacute;/g;
	s/\xCA/&Ecirc;/g;
	s/\xCB/&Euml;/g;
	s/\xCC/&Igrave;/g;
	s/\xCD/&Iacute;/g;
	s/\xCE/&Icirc;/g;
	s/\xCF/&Iuml;/g;
	s/\xD1/&Ntilde;/g;
	s/\xD2/&Ograve;/g;
	s/\xD3/&Oacute;/g;
	s/\xD4/&Ocirc;/g;
	s/\xD5/&Otilde;/g;
	s/\xD6/&Ouml;/g;
	s/\xD7/OE/g;
	s/\xD8/&Oslash;/g;
	s/\xD9/&Ugrave;/g;
	s/\xDA/&Uacute;/g;
	s/\xDB/&Ucirc;/g;
	s/\xDC/&Uuml;/g;
	s/\xDD/Y/g;
	s/\xDF/&szlig;/g;
	s/\xE0/&agrave;/g;
	s/\xE1/&aacute;/g;
	s/\xE2/&acirc;/g;
	s/\xE3/&atilde;/g;
	s/\xE4/&auml;/g;
	s/\xE5/&aring;/g;
	s/\xE6/&aelig;/g;
	s/\xE7/&ccedil;/g;
	s/\xE8/&egrave;/g;
	s/\xE9/&eacute;/g;
	s/\xEA/&ecirc;/g;
	s/\xEB/&euml;/g;
	s/\xEC/&igrave;/g;
	s/\xED/&iacute;/g;
	s/\xEE/&icirc;/g;
	s/\xEF/&iuml;/g;
	s/\xF1/&ntilde;/g;
	s/\xF2/&ograve;/g;
	s/\xF3/&oacute;/g;
	s/\xF4/&ocirc;/g;
	s/\xF5/&otilde;/g;
	s/\xF6/&ouml;/g;
	s/\xF7/oe/g;
	s/\xF8/&oslash;/g;
	s/\xF9/&ugrave;/g;
	s/\xFA/&uacute;/g;
	s/\xFB/&ucirc;/g;
	s/\xFC/&uuml;/g;
	s/\xFD/y/g;

	#insert source file name in comment after every paragraph
        s%</p>%</p><!-- $alpha_doc $date -->%g;


	if ($footnote_link_section)
	{
	    while ($_ =~ s%(.*?)(https?://)([^\s<>\[\]]*)%%g)
	    {
		my $prefix = $1;
		my $linked_text = $2.$3;
		my $url = $linked_text;
		$url =~  s%&amp;%&%g;
		print OUTPUT "$prefix<a href=\"$url\" target=\"_blank\">$linked_text</a>";
	    }
	} 
#Format image
	if ($_ =~ /^<%%img/i)
	{
	    my $line1 = $_;
	    $line1 =~ s/^<%%img//;
	    my $line2 = $line1;
	    my ($img_url,$img_hash,$img_extn,$picture_credit,$caption) = split /%\#\#%/,$line1;
	    $line1 = $imgTemplate;
	    $line2 = $eirespanolImgTemplate;
	    if (defined $img_url)
	    {
		$line2 =~ s/%%%img_url%%%/$img_url/;
	    }
	    if (defined $img_hash and defined $img_extn)
	    {
		$line1 =~ s/%%%large_img_url%%%/\/files\/pictures\/$img_hash\/original.$img_extn/;
		$line1 =~ s/%%%img_url%%%/\/files\/pictures\/$img_hash\/feature.$img_extn/;
	    }
	    if (defined $picture_credit) 
	    {
		$line1 =~ s/%%%picture_credit%%%/$picture_credit/;
		$line2 =~ s/%%%picture_credit%%%/$picture_credit/;
	    }
	    if (defined $caption) 
	    {
		$line1 =~ s/%%%caption%%%/$caption/;
		$line2 =~ s/%%%caption%%%/$caption/;
	    }
	    $_ = $line1."\n".$line2;
	}
 #reveal tags that were protected from paragraph formatting     
	if ($_ =~ /^<%%/)
	{
	    $_ =~ s/<%%/</;
	}
	print OUTPUT $_;
    }
    if ($footnote_link_section) {print OUTPUT $closeFootnoteSection}

    print OUTPUT '<!-- '.$alpha_doc.' '.$date.' -->'."\n\n\n";
    print OUTPUT '</div>'."\n"; 
    close TEMP;
}
