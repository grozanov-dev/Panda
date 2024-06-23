#!/usr/bin/perl

use utf8;
use strict;
use warnings;

use HTTP::Daemon;
use HTTP::Response;
use HTTP::Status;

use Data::Dumper;

use constant HELLO => 'Hello, Panda!';

{
    # Create listener
    my $sock = new IO::Socket::INET (
        LocalHost => '127.0.0.1',
        LocalPort => '8181',
        Proto => 'tcp',
        Listen => 5,
        Reuse => 1,
    );

    die "$!\n" unless $sock;
    print "Server started ...\n";

    $SIG{INT} = sub {
        $sock->close;

        print "Server interrupted ...";
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
        $cls->send($res);
    }
}

1;