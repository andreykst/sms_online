use strict;
use warnings;
use Test::More tests => 2;
use lib '../lib/';
use Data::Dumper;

BEGIN {
    diag("**** Testing modules load ********");
    use_ok('AndreyKostyukevichAnyEvent');
}
diag("**** Testing AnyEvent ************");
ok( &t1, q[AnyEvent check] );

sub t1 {
    my $urls_string = generate_urls_string( $ARGV[1] || 0 );

    my $function = AndreyKostyukevichAnyEvent->new();
    my $result   = $function->get($urls_string);

    if ($result eq "Success") {
        return 1;
    }
    else {
        return 0;
    }
}

sub generate_urls_string {
    my @urls = shift
        || (
        "ya.ru",         "mail.ru",    "3dnews.ru", "microsoft.com",
        "perlmonks.org", "google.com", "vesti.ru",  "rambler.ru"
        );
    my @separator = ( " ", "," );

    my $string;
    $string
        .= ( $_ > 1 ? $separator[ rand @separator ] : '' )
        . $urls[ rand @urls ]
        for 1 .. 5;

    return $string;
}
