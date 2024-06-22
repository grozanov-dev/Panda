#!/usr/bin/perl

use lib './lib';
use utf8;
use feature qw/say state/;
use strict;
use warnings;
use Data::Dumper;
use Benchmark qw/ :all /;

{

    my %h;
    open FP, 'data.tsv';

    for ( <FP> ) {
        chomp;
        my ($key, $val) = split "\t";
        $h{ $key } = $val;
    }

    timethese (
        1, # 1 iteration for 1 billion records in dataset, see p_1.txt for details
        {
            'Map rehash O(2N)' => sub {

                my %tmp = map { $h{$_}   => $_ } keys %h;
                   %tmp = map { $tmp{$_} => $_ } keys %tmp;

                my $num = scalar keys %h;

                say 'Records in dataset: ', $num;
                say 'Removed duplicates: ', $num - scalar keys %tmp;
                say Dumper \%tmp;
            },
        }
    );
}

1;

=pod

Дан хеш %h. Необходимо удалить из него лишние пары, у которых
значения повторяются (т.е. только 1 такую пару оставить) наиболее
эффективным методом. В хеше может быть миллион пар, так что
приоритет – процессорное время
