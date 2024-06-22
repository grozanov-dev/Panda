#!/usr/bin/perl

use utf8;
use strict;
use warnings;
use feature qw/say state/;
use open qw/:std :encoding(UTF-8)/;
use Data::Dumper;

# масти и достоинства карт
use constant SUITS => qw/♠ ♥ ♦ ♣/;
use constant RANKS => qw/A K Q J 10 9 8 7 6 5 4 3 2/;

# параметры раздачи
use constant DEAL => {
    handsNum      => 9, # количеств рук
    cardsPerHand  => 2, # сколько карт сдавать на руку
    buyIn         => 5, # условно - прикуп, но может быть что угодно, например покерный стол
};

sub createAndShuffleDeck {
    my @deck;

    for my $suit (SUITS()) {
        for my $rank (RANKS) {
            push @deck, $rank.$suit;
        }
    }

    # в принципе я бы тут применил List::Utils qw/shuffle/
    for ( my $i = @deck; --$i; ) {
        my $r = int rand ($i + 1);
        next if $i == $r;
        @deck[$i, $r] = @deck[$r, $i];
    }

    my $idx = int rand @deck;
    my $lst = @deck - 1;

    # подсъём
    # массив мелкий, можно вернуть по значению для большей однородности кода
    return ( @deck[$idx .. $lst], @deck[0 .. $idx - 1] );

}

{
    # распаковка новой колоды
    my @deck = createAndShuffleDeck;

    # раздача
    # сдаём cardsPerHand курогов на handsNum рук
    # проверки на окончание колоды нет, т.к. сдаётся всего 23 карты из 52-х.
    my @hands;

    for ( 0 .. DEAL()->{cardsPerHand} - 1 ) {
        for my $hand ( 0 .. DEAL()->{handsNum} - 1 ) {
            push $hands[$hand]->@*, shift @deck;
        }
    }

    # прикуп
    my @buyIn = splice @deck, 0, DEAL()->{buyIn};

    # визуализация
    # splice тут удобнее слайсов, т.к. удаляет элементы, что исключает повторы автоматически
    my $i;
    for my $hand ( @hands ) {
        say sprintf "Hand %i:\t\t%s", ++$i, ( join "\t", $hand->@* )
    }
    print "\n";
    say sprintf "Buy-In:\t\t%s", join "\t", ( splice @deck, 0, DEAL()->{buyIn} );
}

1;

=pod

Есть стандартная колода из 52 карт. Надо перемешать и раздать на 9
человек по 2 карты и положить 5 карт отдельно. Приведите код, который
выполнит данные действия
