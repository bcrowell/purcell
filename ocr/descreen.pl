#!/usr/bin/perl

# requires libtext-aspell-perl

use strict;

# ./descreen.pl p 47
#   for three-color figures, white, gray, and black (p=posterized)
#   pops up gimp to crop out fig
#   writes black.svg and gray.svg
# ./descreen.pl g 13
#   for grayscale figures

# solving problems
#   if black lines look furry, reduce $threshold

if ($ARGV[1]+0<1) {die "provide 2 args"}

my $k = 22; # offset of pdf page numbers relative to printed book's arabic pages

my $type = $ARGV[0]; # see above
my $aa = $k+$ARGV[1]; # page number

my $missing_page = 292; # this page is missing from the scans

if ($aa-$k>$missing_page) {$aa--}

my $ppm = "b-000.ppm";

spud("pdfimages -f $aa -l $aa purcell.pdf b && gimp b-000.ppm",1);
#   ... let user crop out fig

my @files_to_delete = ();

my $opt = '';
############ if ($type eq 'g') { $opt = "-gamma 2.22"}
spud("convert $ppm -depth 8 $opt -compress none x0.pgm",1); 
       # the gamma correction is needed in order to *prevent* darkening
# push @files_to_delete,$ppm;

my $img = read_pgm("x0.pgm");

my $w = $img->[0];
my $h = $img->[1];
my $resolution = 300;  # determined empirically by ruler measurements
print STDERR "dimensions will be ",
  sprintf("%5.1f",($w/$resolution)*25.4),
  " mm by ",
  sprintf("%5.1f",($h/$resolution)*25.4),
  " mm\nStandard width for margin figs is 78.5 mm\n"
;

# This is the gray tone that is in the scans. 
my $mid_gray = 173;
# At the very end we'll lighten it to this:
my $final_gray_hex = "b9b9b9";
my $threshold = 0.05;
   # final threshold for mkbitmap, prepping for potrace
   # if this is too high; lines look furry

write_pgm($img,"x1.pgm");
$img = filter_flyspecks($img);
write_pgm($img,"x2.pgm");
# $img = darken_black($img); # see comments above sub for why not used
write_pgm($img,"x3.pgm");

my $recognized_type = 0;
if ($type eq 'p') {
  $recognized_type = 1;
  process_poster_colors($img,$mid_gray,$resolution,$final_gray_hex,$threshold);
  print STDERR "Use this command line:\n  inkscape gray.svg black.svg\n";
}
if ($type eq 'g') {
  $recognized_type = 1;
  my $no_black = knock_black_to_gray($img,$mid_gray+12); # 12 is chosen to make black text almost invisible
  write_pgm($no_black,"no_black.pgm");
  my $filtered = blur_light_window($no_black,$img,3,240,0.25,250,43,0.25);
  write_pgm($filtered,"shaded.pgm");
  spud("convert shaded.pgm -quality 70 -density 300 shaded.jpg",1);
  process_poster_colors($img,$mid_gray,$resolution,$final_gray_hex,$threshold);
  print STDERR "Use this command line:\n  inkscape gray.svg black.svg shaded.jpg\n";
}

foreach my $f(@files_to_delete) {
  # unlink($f);
}

if (!$recognized_type) {
  die "unrecognized type, $type";
}

# doesn't return anything; has the side-effect of making black.svg and gray.svg
sub process_poster_colors {
  my $img = shift;
  my $mid_gray = shift;
  my $resolution = shift;
  my $final_gray_hex = shift;
  my $threshold = shift;
  my $extreme_hi_gray = int(255.0-0.372*(255.0-$mid_gray)+0.5); # for mid_gray=118, gives 204

  $img = filter_gray_window($img,1,43,$mid_gray,$extreme_hi_gray,80,220); # gray regions
  write_pgm($img,"x4.pgm");
  $img = filter_gray_window($img,1,173,255,255,-1,256); # white regions

  write_pgm($img,"x5.pgm");
  my $po_opts = "--resolution $resolution";
  # -f 4 option on mkbitmap misbehaves, e.g., on p. 13, fig. 1.6
  spud("convert x5.pgm -function polynomial 3,-.4 x6.pgm",1);
  spud("mkbitmap -x -t $threshold <x6.pgm >x7.pgm",1);
  spud("potrace $po_opts --svg --turdsize 20 <x7.pgm >black.svg",1);

  my $gray = gray_layer($img,1,$mid_gray,250);
  write_pgm($gray,"gray.pgm"); # all white or gray
  spud("cat gray.pgm | mkbitmap -x  -t 0.7 | potrace $po_opts --svg -t 5 --color \\#$final_gray_hex "
      ." > gray.svg",1);
}

sub spud {
  my $cmd = shift;
  my $silent = shift;
  print "$cmd\n" unless $silent;
  system($cmd);
}

# P2
# 2269 2685
# 255
# 237 237 237 237 237 237 237 237 237 237 237 237 237 237 237 237 237 237 237

sub read_pgm {
  my $f = shift;
  open(F,"<$f") or die "error opening $f for input, $!";
  my $l = <F>;
  if ($l ne "P2\n") {die "line $l isn't P2"}
  $l = <F>;
  if ($l=~/^#/) {$l=<F>} # GIMP writes a comment line
  if (!($l=~/\d/)) {$l=<F>} # old versions of GIMP writes a blank line as well
  $l =~ /(\d+) (\d+)/ or die "reading file $f, line $l isn't width and height";
  my ($w,$h) = ($1,$2);
  #print "w=$w, h=$h\n";
  $l = <F>; # maxval
  $l==255 or die "wrong maxval";
  my ($x,$y) = ($w-1,-1);
  my @r;
  while ($l=<F>) {
    next if $l=~/^#/;
    my @d = split(' ',$l);
    foreach my $d(@d) {
      $x = $x+1;
      if ($x>=$w) {
        $x=0;
        $y = $y+1;
        $r[$y] = [];
      }
      $r[$y][$x] = $d;
    }
  }
  close F;
  return [$w,$h,\@r];
}

sub write_pgm {
  my $img = shift;
  my $w = $img->[0];
  my $h = $img->[1];
  my $pixels = $img->[2];
  my $out_pgm = shift; # filename
  open(F,">$out_pgm") or die "error opening $out_pgm for output, $!";
  print F "P2\n$w $h\n255\n";
  for (my $y=0; $y<$h; $y++) {
    for (my $x=0; $x<$w; $x++) {
      print F $pixels->[$y]->[$x],' ';
    }
   print F "\n";
  }
  close F;
}

# don't use, causes flyspecks to be made into black dots in svg in p. 36, fig 2.1
sub darken_black {
  my $img = shift;
  my $w = $img->[0];
  my $h = $img->[1];
  my $pixels = $img->[2];
  my $filtered = [];
  for (my $y=0; $y<$h; $y++) {
    for (my $x=0; $x<$w; $x++) {
      my $p = $pixels->[$y]->[$x];
      if ($p<100) {
        $p = 4.0*($p-75.0);
        if ($p<0) {$p=0}
      }
      $filtered->[$y]->[$x] = $p;
    }
  }
  return [$w,$h,$filtered];
}

sub knock_black_to_gray {
  my $img = shift;
  my $gray = shift;

  my $w = $img->[0];
  my $h = $img->[1];
  my $pixels = $img->[2];
  my $filtered = [];
  my $count = 0;
  print STDERR "knock_black_to_gray...\n";
  for (my $y=0; $y<$h; $y++) {
    for (my $x=0; $x<$w; $x++) {
      my $p = $pixels->[$y]->[$x];
      if ($p<$gray) {
        $filtered->[$y]->[$x] = $gray;
        ++$count;
      }
      else {
        $filtered->[$y]->[$x] = $p;
      }
    }
  }
  print STDERR "...changed $count pixels\n";
  return [$w,$h,$filtered];
}

# from y.pgm, create an additional image gray.pgm that is just gray bg
# if a pixel is...
#   lighter than gray -> white
#   darker than gray
#     no white nearby -> gray
#     white nearby -> white
# run gray.pgm through potrace to create bg layer

sub gray_layer {
  my $img = shift;
  my $d = shift;
  my $mid_gray = shift;
  my $min_white = shift; # higher than this is white

  my $w = $img->[0];
  my $h = $img->[1];
  my $pixels = $img->[2];
  my $filtered = [];
  my $count = 0;
  print STDERR "gray_layer...\n";
  for (my $y=0; $y<$h; $y++) {
    for (my $x=0; $x<$w; $x++) {
      $filtered->[$y]->[$x] = $pixels->[$y]->[$x]
    }
  }
  for (my $y=$d; $y<$h-$d; $y++) {
    for (my $x=$d; $x<$w-$d; $x++) {
      my $p = $pixels->[$y]->[$x];
      if ($p==$mid_gray) {next}
      if ($p>$mid_gray) {$filtered->[$y]->[$x] = 255; next }
      # if there's no white nearby, make it gray, else white
      my $white_nearby = 0;
      for (my $i=-$d; $i<=$d; $i++) {
        for (my $j=-$d; $j<=$d; $j++) {
          $white_nearby = $white_nearby || ($pixels->[$y+$i]->[$x+$j] > $min_white);
        }
      }
      $filtered->[$y]->[$x] = ($white_nearby ? 255 : $mid_gray);
    }
  }
  print STDERR "...done\n";
  return [$w,$h,$filtered];
}

sub filter_flyspecks {
  my $img = shift;

  my $w = $img->[0];
  my $h = $img->[1];
  my $pixels = $img->[2];
  my $d = 1;
  my $filtered = [];
  print STDERR "gray_layer...\n";
  for (my $y=0; $y<$h; $y++) {
    for (my $x=0; $x<$w; $x++) {
      $filtered->[$y]->[$x] = $pixels->[$y]->[$x]
    }
  }
  my $count = 0;
  print STDERR "filter_flyspecks...\n";
  for (my $y=0; $y<$h; $y++) {
    for (my $x=0; $x<$w; $x++) {
      my $avg = 0;
      my $n = 0;
      for (my $i=-$d; $i<=$d; $i++) {
        for (my $j=-$d; $j<=$d; $j++) {
          if ($i!=0 || $j!=0) {
            my $p = $pixels->[$y+$i]->[$x+$j];
            $avg = $avg+$p;
            $n++;
          }
        }
      }
      $avg = $avg/$n;
      if (abs($pixels->[$y]->[$x]-$avg)>60) {
        $filtered->[$y]->[$x] = int($avg+0.5);
        $count++;
      }
    }
  }
  print STDERR "...done, changed $count pixels\n";
  return [$w,$h,$filtered];
}

# find windows that are completely lighter than gray, and blur them
# also, lighten it to be consistent with the svg layers
sub blur_light_window {
  my $img = shift; # with black knocked out
  my $orig = shift; # before knocking out black
  my $d = shift;
  my $max_pixel = shift;
  my $max_frac_white = shift;
  my $max_avg = shift;
  my $min_pixel = shift;
  my $max_frac_black = shift;
  my $w = $img->[0];
  my $h = $img->[1];
  my $pixels = $img->[2];
  my $orig_pixels = $orig->[2];
  my $count = 0;
  # lighten it to be consistent with the svg layers:
  my $from = 133;
  my $to = 185;
  my $a = (255-$to)/(255-$from);
  my $b = 255-$a*255;
  print STDERR "blur_light_window...\n";
  #print "  a=$a, b=$b\n";
  my $filtered = [];
  for (my $y=0; $y<$h; $y++) {
    for (my $x=0; $x<$w; $x++) {
      $filtered->[$y]->[$x] = int($a*($pixels->[$y]->[$x])+$b+0.5);
    }
  }
  for (my $y=$d; $y<$h-$d; $y++) {
    for (my $x=$d; $x<$w-$d; $x++) {
      my $n_white = 0;
      my $n_black = 0;
      my $avg = 0;
      my $norm = 0;
      my $n = 0;
      for (my $i=-$d; $i<=$d; $i++) {
        for (my $j=-$d; $j<=$d; $j++) {
          my $p = $pixels->[$y+$i]->[$x+$j];
          my $p_orig = $orig_pixels->[$y+$i]->[$x+$j];
          ++$n;
          my $weight = 1+2*$d-abs($i)-abs($j);
          if ($weight>$d) {$weight=$d} # trapezoid shape
          $norm+=$weight;
          $avg = $avg+$p*$weight;
          if ($p>$max_pixel) {$n_white++}
          if ($p_orig<$min_pixel) {$n_black++}
        }
      }
      $avg = int($avg/$norm+.5);
      my $change_to = $pixels->[$y]->[$x];
      if ($n_white<$max_frac_white*$n && $n_black<$max_frac_black*$n && $avg<$max_avg) {
        ++$count;
        $change_to = $avg;
      }
      my $z = int($a*$change_to+$b+0.5);
      if ($z<0) {$z=0}
      if ($z>255) {$z=255}
      if ($z<$change_to) {die "change_to=$change_to, z=$z, a=$a, b=$b"}
      $filtered->[$y]->[$x] = $z;
    }
  }
  print STDERR "...changed $count pixels\n";
  return [$w,$h,$filtered];
}

sub filter_gray_window {
my $img = shift;
my $d = shift;
my $extreme_lo_gray = shift;
my $mid_gray = shift;
my $extreme_hi_gray = shift;
my $adjacent = shift; # don't do it if the window contains two adjacent pixels darker than this
my $adjacent2 = shift; # ...or brighter than this

my $w = $img->[0];
my $h = $img->[1];
my $pixels = $img->[2];
my $filtered = [];

for (my $y=0; $y<$h; $y++) {
  for (my $x=0; $x<$w; $x++) {
    $filtered->[$y]->[$x] = $pixels->[$y]->[$x]
  }
}

print STDERR "filter_gray_window...\n";
my $count = 0;
my $step = 1; # or (2*$d+1)
for (my $y=$d; $y<$h-$d; $y+=$step) {
  for (my $x=$d; $x<$w-$d; $x+=$step) {
    my $gray = 1;
    my $avg = 0;
    my $n = 0;
    for (my $i=-$d; $i<=$d; $i++) {
      for (my $j=-$d; $j<=$d; $j++) {
        my $p = $pixels->[$y+$i]->[$x+$j];
        $avg = $avg+$p;
        $n++;
        $gray = $gray && ($p>=$extreme_lo_gray && $p<=$extreme_hi_gray);
      }
    }
    $avg = $avg/$n;
    my $adj = 0;
    if ($gray) {
      for (my $i=-$d; $i<$d; $i++) {
        for (my $j=-$d; $j<$d; $j++) {
          my $p = $pixels->[$y+$i]->[$x+$j];
          my $r = $pixels->[$y+$i]->[$x+$j+1];
          my $b = $pixels->[$y+$i+1]->[$x+$j];
          $adj = $adj || ($p<=$adjacent && $r<=$adjacent) || ($p<=$adjacent && $b<=$adjacent)
                      || ($p>=$adjacent2 && $r>=$adjacent2) || ($p>=$adjacent2 && $b>=$adjacent2);
       }
      }
    }
    if ($gray && (!$adj) && $avg>$mid_gray-30 && $avg<$mid_gray+30) {
      $count++;
      for (my $i=-$d; $i<=$d; $i++) {
        for (my $j=-$d; $j<=$d; $j++) {
          $filtered->[$y+$i]->[$x+$j] = $mid_gray;
        }
      }
    }
  }
}
print STDERR "...done, changed $count windows\n";
return [$w,$h,$filtered];
}
