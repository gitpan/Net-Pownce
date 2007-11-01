#!/usr/bin/perl

use Net::Pownce;
use Data::Dumper;

$phrase = shift;
my $pownce = Net::Pownce->new();

$result = $pownce->public_note_list({username=>'NetPownce'});

print Dumper $result;

