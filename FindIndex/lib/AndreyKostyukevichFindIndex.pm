package AndreyKostyukevichFindIndex;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;

    return $self;
}

sub direct_find {
    my $self = shift;
    my ( $number, $array ) = @_;

    my @result;
    my $size  = scalar( @{$array} );
    my $steps = 0;

    for ( my $index = 0; $index < $size; ++$index ) {
        $steps++;
        if ( $array->[$index] >= $number ) {
            if ( $array->[$index] == $number ) {
                push @result, $index, $steps;
                return \@result;
            }

            my ( $min, $max ) = ( $array->[$index], $array->[$index] );

            my $j = $index;

            while ( $j > 0 && $min == $max ) {
                $steps++;
                $j--;
                $min = $array->[$j];
            }

            if ( ( $number - $min ) <= ( $max - $number ) ) {
                push @result, $j, $steps;
                return \@result;
            }

            push @result, $index, $steps;
            return \@result;
        }
    }
    push @result, $array->[ $size - 1 ], $steps;
}

sub find {
    my $self = shift;

    my ( $number, $array ) = @_;

    my @result;
    my $steps = 0;
    my $size  = scalar( @{$array} );
    my ( $min, $max ) = ( $array->[0], $array->[ $size - 1 ] );

    return 0 if $number <= $min;
    return $size - 1 if $number >= $max;

    # вычисляем вероятностный индекс
    my $probabilistic_index
        = int( ( $number / ( $max - $min ) ) * ( $size - 1 ) );
    $steps++;

    if ( $array->[$probabilistic_index] == $number ) {
        push @result, $probabilistic_index, $steps;
        return \@result;
    }
    my $j = $probabilistic_index;

   # теперь смотрим в какую сторону смотреть
    if ( $array->[$probabilistic_index] <= $number ) {
        $steps++;
        while ( $array->[$j] < $number ) {
            $steps++;
            $j++;
        }
        if ( $array->[$j] == $number
            || ( $array->[$j] - $number ) < ( $number - $array->[ $j - 1 ] ) )
        {
            push @result, $j, $steps;
            return \@result;
        }
        push @result, $j - 1, $steps;
        return \@result;
    }
    else {
        while ( $array->[$j] > $number ) {
            $steps++;
            $j--;
        }
        if ( $array->[$j] == $number
            || ( $number - $array->[$j] ) > ( $array->[ $j + 1 ] - $number ) )
        {
            push @result, $j, $steps;
            return \@result;
        }
        push @result, $j + 1, $steps;
        return \@result;
    }

    return 0;
}

1;
