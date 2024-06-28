#!/usr/bin/perl

use utf8;
use feature qw/say state/;
use strict;
use warnings;
use open qw/:std :encoding(UTF-8)/;

use Data::Dumper;

use IO::Async::Loop;
use IO::Async::Socket;
use IO::Async::Timer::Countdown;

sub http_get_async($$$$$) {
    my ( $host, $port, $path, $query, $timeout ) = @_;

    my @params;

    if( ref($query) eq 'HASH' ) {
        for my $key (keys $query->%*) {
            push @params, $key . '=' . $query->{$key};
        }
        $path .= '?' . ( join '&', @params );
    }

    my $req = join "\r\n",
        "GET /$path HTTP/1.0",
        "Host: $host:$port",
        "Accept: text/plain\r\n\r\n";

    my $loop = IO::Async::Loop->new;

    my $sock = IO::Socket::INET->new (
         PeerAddr => $host,
         PeerPort => $port,
         Proto    => 'tcp',
    );

    die "$!\n" unless $sock;

    my $timer = IO::Async::Timer::Countdown->new(
       delay => $timeout,
       on_expire => sub {
          print "\nВремя ожидания ответа сервера истекло\n";

          $loop->stop;
       },
       remove_on_expire => 1,
    );

    my $client = IO::Async::Socket->new (
        handle => $sock,
        on_recv => sub {
            my ( $self, $data ) = @_;

            $loop->stop;

            print "\nПолучено от $host:\n$data\n";
        },
        on_recv_error => sub {
            my ( $self, $errno ) = @_;
            die "\nОшибка $errno\n";
        },
        autoflush => 1,
    );

    $loop->add($client);
    $loop->add($timer);

    $timer->start;

    $client->send($req);

    print "Отправлено:\n" . $req;

    $loop->run;
}

{
    my $params = {
        param => 'value',
    };

    http_get_async '127.0.0.1', 8181, 'test', $params, 5; # Если изменить на 1s, то будет сообщение об ошибке (сервер "спит 2s").

}

1;

=pod

А также написать асинхронную версию этой функции, которая (для
простоты задания) отличается тем, что пока ждет ответа занимается
заполнением какого-нибудь массива числами и выводит на экран
сколько элементов успела добавить пока ждала ответа удаленного
сервера. Программа должна оставаться в рамках 1 процесса и 1 потока
(т.е. без fork и без threads).