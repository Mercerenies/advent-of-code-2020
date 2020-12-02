#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

open my $fh, '<', 'input.txt';

my $total = 0;
while (<$fh>) {
    m(^(\d+)-(\d+) (.): (.*)$) or die("Invalid line at $.");
    my($min, $max, $char, $pass) = ($1, $2, $3, $4);
    my $count = () = $pass =~ /\Q$char\E/g;
    $total++ if ($count >= $min) && ($count <= $max);
}
say $total;
