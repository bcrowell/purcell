#!/usr/bin/perl

# requires libtext-aspell-perl

use strict;

my $k = 22; # offset of pdf page numbers relative to printed book's arabic pages

# whole book is 4-447
my $aa = 4+$k;
my $bb = 447+$k;

my $missing_page = 292; # this page is missing from the scans

if ($aa-$k>$missing_page) {$aa--}
if ($bb-$k>$missing_page) {$bb--}

my @omit = (1,35,79,109,147,183,225,273,297,351);
my %omit = ();
foreach my $page(@omit) {$omit{$page}=1}

my @files_to_delete = ();

if (1) { #----------------------------------------------------

spud("pdfimages -f $aa -l $bb purcell.pdf b",1);

for (my $i=$aa; $i<=$bb; $i++) {
  my $u = sprintf("%03d",$i-$aa); # used only for name of the ppm file, which is set by pdfimages
  my $p = $i-$k; # page number in printed book
  if ($p>=$missing_page) {$p=$p+1}
  print STDERR "analyzing page $p\n";
  my $v = sprintf("%03d",$p);
  my $left = ($p%2==0);
  my $ppm = "b-$u.ppm";
  my $pgm = "p$p.pgm";
  push @files_to_delete,$pgm;
  next if $omit{$p}==1;
  spud("convert $ppm -depth 8 -compress none $pgm",1) unless $omit{$p}==1;
  my $img = read_pgm($pgm);
  my $w = $img->[0];
  my $h = $img->[1];
  my $e = detect_edges($img); # $e=[top,bot,left,right], where top=[[y,fom],...], ...
  # describe_edges($e); # for debugging
  my $rects = detect_gray_rectangles($img,$e);
  my $i = 0; # which figure within the page
  foreach my $r(sort {$a->[0] <=> $b->[0]} @$rects) {
    my $t = $r->[0];
    my $b = $r->[1];
    my $l = $r->[2];
    my $r = $r->[3];
    #print sprintf("t=%4d b=%4d l=%4d r=%4d\n",$t,$b,$l,$r);
    my $label = detect_figure_number($ppm,$t,$b,$l,$r);
    my $chapter = page_number_to_chapter($p);
    $t='e' if $t==0;
    $b='e' if $b==$h-1;
    $l='e' if $l==0;
    $r='e' if $r==$w-1;
    my $csv =  "$chapter,$label->[0],$label->[1],$p,$i,$t,$b,$l,$r,g\n";
    print $csv;
    print STDERR $csv;
    $i++;
  }
}

} #---------------------------------------------------------

sub describe_edges {
  my $e = shift;
  my $i = 0;
  my @what = ('t','b','l','r');
  my $d = '';
  foreach my $u(@$e) {
    $d = $d . "  $what[$i]\n";
    foreach my $ee(@$u) {
      $d = $d . "    $ee->[0], fom=$ee->[1]\n";
    }
    $i++;
  }
  print STDERR $d;
}

sub page_number_to_chapter {
  my $p = shift;
  my $chapter = 0;
  foreach my $pp(@omit) {
    if ($pp>$p) {return $chapter}
    $chapter++;
  }
  return $chapter;
}

sub detect_figure_number {
  my $ppm = shift;
  my $t = shift;
  my $b = shift;
  my $l = shift;
  my $r = shift;
  my $w = $r-$l+1;
  my $h = $b-$t+1;
  spud("convert $ppm -crop ${w}x$h+$l+$t a.jpg",1);
  spud("mogrify -function polynomial 3,-.8 a.jpg"); # lighten it, because otherwise tesseract gets confused by gray bg
  spud("tesseract a.jpg a 1>/dev/null 2>/dev/null",1);
  open(F,"<a.txt") or printf STDERR "error opening file a.txt, tesseract output, in detect_figure_number, $!";
  local $/;
  my $t = <F>;
  close F;
  if ($t=~/Fig\. +([\dlO]{1,2})\.([\dlO]{1,2})/) { # don't have to worry about 10.7b, etc. -- b isn't in label
    return [$1,$2];
  }
  else {
    return ['',''];
  }
}

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
  $l =~ /(\d+) (\d+)/ or die "line $l isn't width and height";
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

sub detect_gray_rectangles {
  my $img = shift; # [$w,$h,\@r], where r=pixels
  my $e = shift; # edges, $e=[top,bot,left,right], where top=[[y,fom],...], ...
  my $w = $img->[0];
  my $h = $img->[1];
  my $p = $img->[2];
  my $et = $e->[0];
  my $eb = $e->[1];
  my $el = $e->[2];
  my $er = $e->[3];
  my $depth = 255;
  my $white = int(0.95*$depth);
  my @rectangles = ();
  foreach my $tt(@$et) {
    my $t = $tt->[0];
    foreach my $bb(@$eb) {
      my $b = $bb->[0];
      if ($b>$t) {
        foreach my $ll(@$el) {
          my $l = $ll->[0];
          foreach my $rr(@$er) {
            my $r = $rr->[0];
            if ($r>$l) {
              # take a random sample and see what percentage is white; very little should be
              my $fraction_white = sample_rect(1000,$white,1,$p,$t,$b,$l,$r);
              # look for horizontal white strips all the way across, which would mean this is really two figs;
              my $h = 10; # about 1/4 of expected height; such strips seem to be about 63 pixels tall
              my $have_strip = 0;
              for (my $y=$t+$h; $y<$b-$h; $y+=2*$h) {
                my $f = sample_rect(1000,$white,1,$p,$y-$h,$y+$h,$l,$r);
                if ($f>.95) {$have_strip=1}
              }
              if ($fraction_white<0.05 && !$have_strip 
                             && $bb->[1]>50 && $tt->[1]>50 && $ll->[1]>50 && $rr->[1]>50) {
                push @rectangles,[$t,$b,$l,$r];
              }
            }
          }
        }
      }
    }
  }
  # if one rectangle is contained inside another, delete it
  my %kill = ();
  for (my $i=0; $i<@rectangles; $i++) {
    for (my $j=0; $j<@rectangles; $j++) {
      if ($i!=$j && rect_contains($rectangles[$i],$rectangles[$j])) {$kill{$j}=1}
    }
  }
  my @rr = ();
  for (my $i=0; $i<@rectangles; $i++) {
    if (!(exists $kill{$i})) {push @rr,$rectangles[$i]}
  }
  return \@rr;
}

sub rect_contains {
  my $a = shift; # tblr
  my $b = shift;
  return interval_contains($a->[0],$a->[1],$b->[0],$b->[1])
      && interval_contains($a->[2],$a->[3],$b->[2],$b->[3]);
}

sub interval_contains {
  my $a1 = shift;
  my $b1 = shift;
  my $a2 = shift;
  my $b2 = shift;
  return ($a1<=$a2 && $b1>=$b2);
}

sub sample_rect {
  my $nsample = shift;
  my $threshold = shift;
  my $sign = shift;
  my $p = shift; # array of pixels
  my $t = shift;
  my $b = shift;
  my $l = shift;
  my $r = shift;
  my $count = 0;
  for (my $i=1; $i<=$nsample; $i++) {
    my $x = random_in_range($l,$r);
    my $y = random_in_range($t,$b);
    if (($p->[$y]->[$x]-$threshold)*$sign>0) {$count++}
  }
  return $count/$nsample;
}

sub random_in_range {
  my $a = shift;
  my $b = shift;
  return int(rand($b-$a))+$a;
}

sub detect_edges {
  my $img = shift;
  my $w = $img->[0];
  my $h = $img->[1];
  my $p = $img->[2];
  my $transpose;
  my $depth = 255;
  # bracket a range of gray values that are the shade of gray we're looking for
  my $lo = int(0.6*$depth);
  my $hi = int(0.8*$depth);
  # minimum value that's considered white
  my $white = int(0.95*$depth);
  my $blur = 1;
  my $dy = 5; 
  my $ystep = 1;
  my ($top,$bot) = detect_horizontal_edges($img,$lo,$hi,$white,$blur,$dy,$ystep);
  for (my $y=0; $y<$h; $y++) {
    for (my $x=0; $x<$w; $x++) {
      $transpose->[$x][$y] = $p->[$y][$x];
    }
  }
  my ($left,$right) = detect_horizontal_edges([$h,$w,$transpose],$lo,$hi,$white,$blur,$dy,$ystep);
  return [$top,$bot,$left,$right];
}

sub detect_horizontal_edges {
  my $img = shift;
  my $lo = shift;
  my $hi = shift;
  my $white = shift;
  my $blur = shift;
  my $dy = shift;
  my $ystep = shift;
  my $w = $img->[0];
  my $h = $img->[1];
  my $p = $img->[2];
  my @fom_top; # figure of merit for top edges
  my @fom_top_y;
  my @fom_bot;
  my @fom_bot_y;
  for (my $y=$dy; $y<$h-$dy*2; $y+=$ystep) {
    my $r1 = $p->[int($y-$dy/2-.5)];
    my $r2 = $p->[int($y+$dy/2+.5)];
    my $count_top = 0;
    my $count_bot = 0;
    my $xstep = 2*$blur+1;
    my $nx = 0;
    for (my $x=$blur; $x<$w-$blur; $x+=$xstep) {
      ++$nx;
      my $a1 = 0; # avg over blur in r1
      my $a2 = 0;
      for (my $j=-$blur; $j<=$blur; $j++) {
        my $p1 = $r1->[$x+$j];
        my $p2 = $r2->[$x+$j];
        $a1 = $a1 + $p1;
        $a2 = $a2 + $p2;
      }
      $a1 = int($a1/(2.*$blur+1));
      $a2 = int($a2/(2.*$blur+1));
      if ($a2>$lo && $a2<$hi && $a1>$white) {$count_top ++}
      if ($a1>$lo && $a1<$hi && $a2>$white) {$count_bot ++}
    }
    my $fom_top = compute_fom($count_top,$nx,$xstep);
    my $fom_bot = compute_fom($count_bot,$nx,$xstep);
    # print "count_top=$count_top, y=$y\n";
    push @fom_top,$fom_top;
    push @fom_top_y,$y;
    push @fom_bot,$fom_bot;
    push @fom_bot_y,$y;
  }
  my $best_ones_top = find_best_ones(\@fom_top,\@fom_top_y);
  my $best_ones_bot = find_best_ones(\@fom_bot,\@fom_bot_y);
  my @t=([0,9999],@$best_ones_top);
  my @b=([$h-1,9999],@$best_ones_bot);
  return (\@t,\@b);
}

sub compute_fom {
  my $pass = shift;
  my $n = shift;
  my $step = shift;
  if ($pass<150/$step) {$pass = -1000}
  return $pass;
}

sub find_best_ones {
  my $fom = shift;
  my $y = shift;
  my %results = ();
  my @r = ();
  for (my $i=1; $i<=3; $i++) {
    my $best = -999;
    my $best_y;
    for (my $j=0; $j<@$fom; $j++) {
      if ($fom->[$j]>$best) {
        my $already = 0;
        foreach my $found(keys %results) {
          $already = $already || abs($found-$y->[$j])<10;
        }
        if (!$already) {
          $best = $fom->[$j];
          $best_y = $y->[$j];
        }
      }
    }
    $results{$best_y} = 1;
    push @r,[$best_y,$best]
  }
  return \@r;
}
