#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 3;
use lib '../lib/';
use Data::Dumper;

BEGIN {
    diag("**** Testing modules load ***************************");
    use_ok('AndreyKostyukevichFindIndex');
}
diag("**** Generate array and value to search *************");
my $array = generate_array( $ARGV[1] || 0 );
my $value_to_search = $ARGV[0]
    || int rand( scalar(@$array) );

diag("**** Testing Direct find and Probabilistic find *****");
ok( &t1, q[Direct find] );
ok( &t2, q[Probablistic find] );

sub t1 {
    my $function = AndreyKostyukevichFindIndex->new();
    my $result = $function->direct_find( $value_to_search, $array );

    print Dumper($result);

    if ( ref($result) eq 'ARRAY' && scalar( @{$result} ) == 2 ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub t2 {
    my $function = AndreyKostyukevichFindIndex->new();
    my $result = $function->find( $value_to_search, $array );

    print Dumper($result);

    if ( ref($result) eq 'ARRAY' && scalar( @{$result} ) == 2 ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub generate_array {
    my $size = shift || 999999;

    my @array = sort { $a <=> $b } map { int rand($size); } ( 0 .. $size );
    return \@array;
}
