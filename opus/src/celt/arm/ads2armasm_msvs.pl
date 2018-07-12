#!/usr/bin/env perl
##
##  Copyright (c) 2013 The WebM project authors. All Rights Reserved.
##
##  Use of this source code is governed by a BSD-style license
##  that can be found in the LICENSE file in the root of the source
##  tree. An additional intellectual property rights grant can be found
##  in the file PATENTS.  All contributing project authors may
##  be found in the AUTHORS file in the root of the source tree.
##

use FindBin;
use lib $FindBin::Bin;
use thumb;
use File::Copy;
use FindBin qw( $RealBin );

print "; This file was created from a .asm file\n";
print ";  using the ads2armasm_ms.pl script.\n";

copy("$RealBin/armopts.s.msvs","$RealBin/armopts.s") or die "Copy failed: $!";

my $filename = 'auxFile.txt';
open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";

while (<>)
{
    undef $comment;
    undef $line;

    s/^IF/\tIF/;
    s/^END/\tEND/;
    s/^ENDIF/\tENDIF/;
    s/REQUIRE8//;
    s/PRESERVE8//;
    s/^\s*ARM\s*$//;
    s/AREA\s+\|\|(.*)\|\|/AREA |$1|/;
    s/qsubaddx/qsax/i;
    s/qaddsubx/qasx/i;

  thumb::FixThumbInstructions($_, 1);

    s/ldrneb/ldrbne/i;
    s/ldrneh/ldrhne/i;
    s/^(\s*)ENDP.*/$&\n$1ALIGN 4/;

    print $fh $_;
}

close $fh;
copy("auxFile.txt","gen/third_party/opus/celt_pitch_xcorr_arm.asm") or die "Copy failed: $!";
unlink $filename;
print "\ncelt_pitch_xcorr_arm.asm created\n";
