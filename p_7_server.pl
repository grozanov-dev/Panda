#!/usr/bin/perl

use utf8;
use strict;
use warnings;

use IO::Socket;

use constant HELLO => 'Hello, Panda!';

{
    # Create listener
    my $sock = new IO::Socket::INET (
        LocalHost => '127.0.0.1',
        LocalPort => '8181',
        Proto => 'tcp',
        Listen => 2,
        Reuse => 1,
    );

    die "$!\n" unless $sock;
    print "Сервер слушает порт 8181 ...\n";

    $SIG{INT} = sub {
        $sock->close;

        print "Сервер остановлен ...";
        exit 0;
    };

    while( my $cls = $sock->accept ) {

        my $req = '';
        my $res = join "\r\n",
            "HTTP/1.0 200 Ok",
            "Content-Length: " . length HELLO(),
            "Accept: text/plain",
            '','', HELLO();

        $cls->recv($req, 1024);

        sleep 2;

        $cls->send($res);

        print $req;
    }
}

1;