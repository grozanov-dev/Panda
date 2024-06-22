#!/usr/bin/perl

use utf8;
use strict;
use warnings;
use feature qw/ say state /;
use Benchmark qw/ :all / ;

use constant COUNT => 1e7;

sub _cur ($$) {
    my ($first, $last) = @_;

    return $first + int ( ($last - $first + 1) / 2); # avoid overflow on huge arrays
}

# Оптимизированный под задачу алгоритм бинарного поиска, сложность O(log N)
#
# find ( ArrayRef, Int )
#
# Возвращает значения индекса, соответствующее максимально близкому к Int значению в исходм массиве

sub find_bin ($$) {
    my ($arr, $num) = @_;

    my $first = 0;
    my $last  = (scalar $arr->@*) - 1;
    my $cur   = _cur $first, $last;

    while (1) {
        if ($arr->[$cur] < $num) {
            $first = $cur;
            $cur = _cur $first, $last;
        } else {
            $last = $cur;
            $cur = _cur $first, $last;
        }
        last if $last - $first == 1;
    }

    return $num < $arr->[$first] + int (($arr->[$last] - $arr->[$first]) / 2) ? $first : $last;
}

# никак не оптимизированный линейный поиск, сложность O(N)

sub find_lin ($$) {
    my ($arr, $num) = @_;
    my $n = $arr->@*;

    for ( my $i = 1; $i < $n; $i++) {
        my $med = int ( $arr->[$i - 1] + $arr->[$i] ) / 2;

        if ($num <= $arr->[$i] && $num >= $med) {
            return $i;
        } elsif ( $num < $med && $arr->[ $i - 1 ] <= $num ) {
            return $i - 1;
        }
    }
}

{

    my @a = qw/-1 1 5 7 12 15 18 24 31 100/;

    say 'Binary:';
    say 15, ' -> ', find_bin \@a, 15; # точное совпадение -> 5 (15)
    say 21, ' -> ', find_bin \@a, 21; # точно посередине между 18 и 24 -> 7 (24): спорный случай, но регулируется знаком неравества в return фунции find_bin()
    say 33, ' -> ', find_bin \@a, 33; # ближе к 31 -> 8 (31)
    say 88, ' -> ', find_bin \@a, 88; # ближе к 100 -> 9 (100)

    say 'Linear:';
    say 15, ' -> ', find_lin \@a, 15;
    say 21, ' -> ', find_lin \@a, 21;
    say 33, ' -> ', find_lin \@a, 33;
    say 88, ' -> ', find_lin \@a, 88;

    cmpthese(
        COUNT,
        {
            'Binary' => sub { find_bin \@a, 50 },
            'Linear' => sub { find_lin \@a, 50 },
        }
    )
}

1;

=pod

Дан массив из большого числа элементов (числа), отсортированный по
возрастанию. Необходимо написать функцию, которая быстро найдет
индекс элемента массива, значение по которому наиболее близко к
переданному в аргументах функции числу.
Используйте модуль Benchmark, чтобы оценить скорость написанного
решения и оптимизировать его.
