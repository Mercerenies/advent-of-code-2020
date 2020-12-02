#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

open my $fh, '<', 'input.txt';

my $total = 0;
while (<$fh>) {
    m(^(\d+)-(\d+) (.): (.*)$) or die("Invalid line at $.");
    my($p1, $p2, $char, $pass) = ($1, $2, $3, $4);
    my $s = substr($pass, $p1 - 1, 1) . substr($pass, $p2 - 1, 1);
    my $matches = () = $s =~ /\Q$char\E/g;
    $total++ if $matches == 1;
}
say $total;
