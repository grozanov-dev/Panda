#!/usr/bin/perl

use lib './lib';
use utf8;
use feature qw/say state/;
use strict;
use warnings;
use Data::Dumper;
use Benchmark qw/ :all /;

use constant COUNT => 1e6; # 1 billion records

{

    for ( 1 .. COUNT() ) {
        my $val = int rand ( int COUNT() );
        print "key_$_\tval_$val\n";
    }
}
1;

=pod

Дан хеш %h. Необходимо удалить из него лишние пары, у которых
значения повторяются (т.е. только 1 такую пару оставить) наиболее
эффективным методом. В хеше может быть миллион пар, так что
приоритет – процессорное время
