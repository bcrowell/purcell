#!/usr/bin/perl

# requires libtext-aspell-perl

use strict;

use Text::Aspell;
my $speller = Text::Aspell->new;
die unless $speller;
$speller->set_option('lang','en_US');


my $k = 22; # offset of pdf page numbers relative to printed book's arabic pages

my $a = 2+$k;
my $b = 399+$k;

my $missing_page = 292; # this page is missing from the scans

my @omit = (1,35,79,109,147,183,225,273,297,351);
my %omit = ();
foreach my $page(@omit) {$omit{$page}=1}

my @files_to_delete = ();

if (1) { #----------------------------------------------------

spud("pdfimages -f $a -l $b purcell.pdf b",0);

for (my $i=$a; $i<=$b; $i++) {
  my $u = sprintf("%03d",$i-$a);
  my $p = $i-$k; # page number in printed book
  if ($p>=$missing_page) {$p=$p+1}
  my $v = sprintf("%03d",$p);
  my ($w,$h,$x0,$y0) = (848,2650,0,0); # y0 set to 0 because of, e.g., p. 208
  if ($p%2==0) {
    # even, left page
    $x0 = 0;
  }
  else {
    $x0 = 1468;
  }
  my $ppm = "b-$u.ppm";
  my $jpg = "p$v.jpg";
  spud("convert $ppm -crop ${w}x$h+$x0+$y0 $jpg",0) unless $omit{$p}==1;
  spud("mogrify -function polynomial 3,-.8 $jpg"); # lighten it, because otherwise tesseract gets confused by gray bg
  push @files_to_delete,$ppm;
  next if $omit{$p}==1;
  spud("tesseract $jpg p$v");
}

} #---------------------------------------------------------

my $text = '';

foreach my $f(<p*.txt>) {
  my $p;
  if ($f=~/p(\d\d\d)/) {
    push @files_to_delete,$f;
    push @files_to_delete,"p$1.jpg";
    $p = $1+0;
  }
  else {
    die $f;
  }
  $text = $text . "% p. $p\n";
  local $/;
  open(F,"<$f") or die $!;
  my $t = <F>;
  close F;
  # get rid of garbage lines
    my $tt = '';
    foreach my $l(split("\n",$t)) {
      my $garbage = 0;
      my $d = '';
      # <30 char and not ending in .
        my $g = (length($l)<30 && !($l=~/\.$/));
        do_garbage(\$garbage,\$d,$g,'<30 char and not ending in .');
      # IIIIII, ///////, etc.
        #my $g = ($l=~m@(III|\+\+\+|\.\.\.|\/\/\/|___)@);
        my $g = ($l=~m@III@);
        do_garbage(\$garbage,\$d,$g,'long string of repeated character');
      # few alphabetic characters
        my $min = 0.3;
        my $alpha = $l;
        $alpha =~ s/[^A-Za-z]//g;
        my $nonalpha = $l;
        $nonalpha =~ s/[A-Za-z]//g;
        my $g = (length($nonalpha)>1 && length($alpha)<$min*(length($alpha)+length($nonalpha)));
        do_garbage(\$garbage,\$d,$g,"less than $min alphabetic");
      if ($garbage) {
        print sprintf "discarded: %-50s, %s\n",$l,$d;
      }
      else {
        # print sprintf "kept:      %-50s ********************* \n",$l;
        $tt = $tt . $l . "\n";
      }
    }
      
  # print "read from $f:\n$t\n";
  $text = $text . $tt;
}

# clean up ligatures, etc.
$text =~ s/\357\254\201/fi/g;
$text =~ s/\357\254\202/fl/g; # sometimes occurs for ff?
$text =~ s/\342\200\234/``/g;
$text =~ s/\342\200\235/''/g;
$text =~ s/\342\200\231/'/g;
$text =~ s/\342\200\224/ ___EM_DASH___ /g; # spaces are to prevent multiple ones from running together

# eliminate hyphenation; this will cause some errors, but will be what I want in most cases;
# be conservative to avoid, e.g., doing things to equations
$text =~ s/( ([a-z]+)\-\n([a-z]+) )/(is_a_word("$2$3") ? " $2$3\n" : $1)/ge;

$text =~ s/___EM_DASH___/---/g;

open(F,">raw_captions_ocr.txt");

print F $text;

close F;

exit(-1);

foreach my $f(@files_to_delete) {
  unlink($f);
}

sub spud {
  my $cmd = shift;
  my $silent = shift;
  print "$cmd\n" unless $silent;
  system($cmd);
}

sub is_a_word {
  my $x = shift;
  return $speller->check($x);
}

sub do_garbage {
  my $r = shift;
  my $rd = shift;
  my $is_garbage = shift;
  my $description = shift;
  if (!$$r && $is_garbage) {$$rd = $description; die if $description eq ''}
  $$r = $$r || $is_garbage;
}
