#
##################################################################
#
#    function - a perl script to return winners array_of_creatives
#
##################################################################

package Function;
use 5.010;
BEGIN { $^W = 1; }    # turn on warnings

use vars qw{
    $VERSION
};

use strict;
use JSON;
use JSON::Parse 'assert_valid_json';
use List::Util 'shuffle';
use Data::Dumper;
use DB_File;
use Digest::MD5 qw(md5 md5_hex md5_base64);

BEGIN {
    ( $VERSION = q($Id: Function.pm,v 1.4 2015/06/16 18:56:39 function Exp $) ) =~ s/^.*\s+(\d+)\/(\d+)\/(\d+).*$/$1$2$3/;
}

sub function {

    my ( $array_of_creatives, $number_of_winners, $country_name_to_serve )
        = @_;

    unless ( defined($array_of_creatives) and defined($number_of_winners) ) {
        return "Usage: " . $0
            . " <array_of_creatives as JSON> <number of winners as INT> <country_name_to_serve as STR (optional)>\n";
        exit(1);
    }

    eval { assert_valid_json($array_of_creatives) };
    if ($@) {
        return "Usage: array_of_creatives should be JSON object: $@\n";
        exit(1);
    }

    if ( $number_of_winners !~ /\d+/ or $number_of_winners < 1 ) {
        return "Usage: number of winners chould be int and more then 0\n";
        exit(1);
    }

    my $file
        = md5_hex( $array_of_creatives
            . $number_of_winners
            . (
            defined($country_name_to_serve) ? $country_name_to_serve : "" ) )
        . ".db";

    #print $file."\n";
    my $dir = "../db/";

    my %previous_arrays_of_creatives
        ; # если ранее уже был такой набор победителей, то нужно считать и пометить кто был победителем
    tie %previous_arrays_of_creatives, "DB_File", $dir . $file,
        O_RDWR | O_CREAT, oct(666),
        $DB_HASH;

    my $input = from_json( $array_of_creatives, { utf8 => 1 } );

    my @input = shuffle @{$input}
        ; # считаем, что разные поставшики рекламы делают ставки с разными задержками и при запросе их ставки могут прилететь в разном порядке
    my @output;

    while (@input)
    { # фактически в этом проходе нам уже нужно получить результать, идём по всем ставкам
        my $current_creative = shift @input;

        my $advertiser_id    = $current_creative->{"advertiser_id"};
        my $advertiser_price = $current_creative->{"price"};
        my $advertiser_country_name_to_serve = $current_creative->{"country"};

        next
            if (defined($country_name_to_serve)
            and defined($advertiser_country_name_to_serve)
            and $country_name_to_serve ne $advertiser_country_name_to_serve )
            ; # 1. сразу отбрасываем тех кто не подходит по критерию "страна"

        if ( scalar @output < $number_of_winners )
        { # 2. далее начинаем помаленьку запихивать, будем пихать пока есть место
            my $already_in_output = 0
                ; # список потенциальных победителей смотреть нужно, чтобы пропустить creative от той же компании
            foreach my $index (@output) {
                my $array_advertiser_id = $index->{"advertiser_id"};
                $already_in_output = 1
                    if (defined($advertiser_id)
                    and defined($array_advertiser_id)
                    and $advertiser_id eq $array_advertiser_id )
                    ; # если уже есть компания в списке array_of_creatives победителей значит мы её туда вставили потому что она этого заслужила
            }

            if ( $already_in_output == 1 ) {
                next
                    ; # эта компания уже есть в списке победителей - идём за следующей array_of_creatives
            }
            else {
                # некая другая компания
                my $can_push = 1;
                foreach my $x (@input) {

                    # пропускаем не те страны
                    next
                        if (defined($country_name_to_serve)
                        and defined( $x->{"country"} )
                        and $country_name_to_serve ne $x->{"country"} );

                    my $should_we_skip = 0
                        ; # пропускаем все компании в оставшихся вводных, если уже такие попали в победители
                    foreach my $index (@output) {
                        $should_we_skip = 1
                            if (defined( $index->{"advertiser_id"} )
                            and defined( $x->{"advertiser_id"} )
                            and $index->{"advertiser_id"} eq
                            $x->{"advertiser_id"} );
                    }
                    next if ( $should_we_skip == 1 );

                    next
                        if ( $x->{"price"} ne $current_creative->{"price"} )
                        ; # пропускаем всех у кого цена другая

                    # пропустили

#теперь те кто остались проходят по стране, по компании (нет ещё такой в списке победителей) и по цене (она одинаковая)
# смотрим сколько показов из оставшихся с такой же ценой, и если есть хоть один с большим показом то вставляем

                    if (undef(
                            $previous_arrays_of_creatives{ to_json(
                                    $current_creative) }
                        )
                        )
                    {
                        #вставляем и не паримся
                    }
                    else {
                        $can_push = 0
                            if (
                            (   defined(
                                    $previous_arrays_of_creatives{ to_json(
                                            $current_creative) }
                                )
                                and $previous_arrays_of_creatives{ to_json(
                                        $current_creative) } ne ''
                                and defined(
                                    $previous_arrays_of_creatives{ to_json($x)
                                    }
                                )
                                and
                                $previous_arrays_of_creatives{ to_json($x) }
                                ne ''
                                and
                                $previous_arrays_of_creatives{ to_json($x) }
                                < $previous_arrays_of_creatives{ to_json(
                                        $current_creative) }

                            )
                            or undef(
                                $previous_arrays_of_creatives{ to_json(
                                        $current_creative) }
                            )
                            );
                    }

                    foreach my $index (@output) {
                        $can_push = 0
                            if (
                            defined(
                                $previous_arrays_of_creatives{ to_json($index)
                                }
                            )
                            and
                            $previous_arrays_of_creatives{ to_json($index) }
                            ne ''
                            and defined(
                                $previous_arrays_of_creatives{ to_json(
                                        $current_creative) }
                            )
                            and $previous_arrays_of_creatives{ to_json(
                                    $current_creative) } ne ''
                            and
                            $previous_arrays_of_creatives{ to_json($index) }
                            > $previous_arrays_of_creatives{ to_json(
                                    $current_creative) }
                            );
                    }

                }
                push @output, $current_creative if ( $can_push == 1 );
            }
        }
        else {
            # уже нет свободных мест - happy end
            last;
        }

    }

    foreach my $index (@output) {

        $previous_arrays_of_creatives{ to_json($index) } = 0
            if ( undef( $previous_arrays_of_creatives{ to_json($index) } )
            || $previous_arrays_of_creatives{ to_json($index) } eq '' );

        #print Dumper( to_json($index) );
        #print Dumper( $previous_arrays_of_creatives{ to_json($index) } );
        $previous_arrays_of_creatives{ to_json($index) } += 1;

        #print Dumper( $previous_arrays_of_creatives{ to_json($index) } );

    }
    untie %previous_arrays_of_creatives;

    return to_json( \@output, { utf8 => 1, pretty => 0 } );

}
1;
__END__
