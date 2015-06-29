use strict;
use Test::More tests => 8;
use lib '../lib/';

BEGIN {
    diag("****** Testing modules load");
    use_ok('Function');
    use_ok('JSON');
    use_ok('JSON::Parse');
    use_ok('List::Util');
    use_ok('Data::Dumper');
    use_ok('DB_File');
    use_ok('Digest::MD5');
}

diag("****** Testing `Function` version $Function::VERSION");

sub t1 {
    my $input = '[
        {"advertser_id":"4","price":"9","country":"cn"},
        {"advertiser_id":"4","price":"5","country":"ru"},
        {"advertiser_id":"5","price":"5"},
        {"advertiser_id":"5","price":"3","country":"ro"},
        {"advertiser_id":"6","price":"8","country":"bg"},
        {"advertiser_id":"6","price":"5"},
        {"advertiser_id":"6","price":"6"}
        ]';
    my $input_wins = 3;
    my $input_country;

    foreach ( 1 .. 10 ) {
        my $output
            = Function::function( $input, $input_wins, $input_country );

        my %win_companies;
        my $output_as_array = from_json( $output, { utf8 => 1 } );

        #print Dumper($output_as_array);

        foreach my $index ( @{$output_as_array} ) {

            #print Dumper($index);
            if ( defined( $index->{"advertiser_id"} ) ) {
                unless (
                    defined( $win_companies{ $index->{"advertiser_id"} } ) )
                {
                   #print Dumper($win_companies{ $index->{"advertiser_id"} });
                    $win_companies{ $index->{"advertiser_id"} } = 1;
                }
                else {
                   #print Dumper($win_companies{ $index->{"advertiser_id"} });
                    return 0;
                }
            }
        }

    }
    return 1;
}

ok( t1, q[all winners must have unique advertiser_id] );

