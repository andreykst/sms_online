package AndreyKostyukevichAnyEvent;

use strict;
use warnings;
use constant MAX_URL_LENGTH => 256;
use constant TIMEOUT        => 60;
use constant CONTENT_LENGTH => 100;
use AnyEvent;
use AnyEvent::HTTP;
use Time::HiRes qw(time);

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;

    return $self;
}

sub get {
    my $self = shift;
    my ($urls_string) = @_;

    my @urls = split( /[,| ]/, $urls_string );

    my $cv    = AnyEvent->condvar();
    my $count = 0;

    for my $url (@urls) {
        chomp($url);

        # "нормализуем" ссылку
        $url = "http://$url" if ( $url !~ /^http:\/\//i );
        next if ( length($url) > MAX_URL_LENGTH );

        print "GET request to => $url\n";

        my $guard;
        my $start_time;
        my $timeout;

        $guard = http_get(
            $url,
            timeout    => TIMEOUT,
            persistent => 0,
            on_prepare => sub {
                unless ( defined $start_time ) {
                    $start_time = time;
                }
                $timeout;  
            },
            sub {
                my $total_time = time - $start_time;
                undef $guard;
                my ( $content, $headers ) = @_;
                print "Content of $url:\n "
                    . substr( $content, 0, CONTENT_LENGTH ) . "...\n"
                    if ( defined($content) );
                print "Total time: ".$total_time."\n";
                $count++;
                $cv->send("Success") if $count == scalar @urls;
            },
        );
    }
    my $result = $cv->recv();

    return $result;
}

1;
