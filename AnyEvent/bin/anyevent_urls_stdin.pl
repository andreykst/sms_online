#!/usr/bin/env perl

use strict;
use warnings;
use lib '../lib/';
use AndreyKostyukevichAnyEvent;

print "Please type URLS (separated by comma or space):";
my $urls_string = <STDIN>;

my $events = AndreyKostyukevichAnyEvent->new();
$events -> get($urls_string);
