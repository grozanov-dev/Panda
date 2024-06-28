#!/usr/bin/perl

use utf8;
use feature qw/say state/;
use strict;
use warnings;
use open qw/:std :encoding(UTF-8)/;

use Data::Dumper;
use Fcntl;

use IO::Socket;
use IO::Select;

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

    # создам сокет - для простоты с помощью IO::Socket
    my $sock = IO::Socket::INET->new (
         PeerAddr => $host,
         PeerPort => $port,
         Proto    => 'tcp',
    );

    die "$!\n" unless $sock;

    # создаём Select
    my $select = IO::Select->new($sock);

    # Делаем сокет неблокирующим
    my $flags = fcntl $sock, F_GETFL, 0;
    fcntl $sock, F_SETFL, $flags | O_NONBLOCK or die "fcntl: $!";

    # посылаем в сокет запрос
    syswrite $sock, $req;

    print "Отправлено:\n" . $req;

    my @collect;

    while (1) {
        # Считаем овец, пока сокет не ответит
        push @collect, int rand 100;

        for my $client ($select->can_read($timeout)) {
            next unless $client == $sock; # сокет всё ещё не ответил

            # читаем в буфер ответ
            my $buf = '';
            my $len = sysread $sock, $buf, 256;

            print "Получено ($len):\n" . $buf;
            print "\n\nПосчитано: " . scalar @collect;
            return 1;
        }
    }
}

{
    my $params = {
        param => 'value',
    };

    http_get_async '127.0.0.1', 8181, 'test', $params, 5; # Если изменить на 1s, то будет сообщение об ошибке (сервер "спит" 2s, прежде чем ответить).

}

1;

=pod

А также написать асинхронную версию этой функции, которая (для
простоты задания) отличается тем, что пока ждет ответа занимается
заполнением какого-нибудь массива числами и выводит на экран
сколько элементов успела добавить пока ждала ответа удаленного
сервера. Программа должна оставаться в рамках 1 процесса и 1 потока
(т.е. без fork и без threads).