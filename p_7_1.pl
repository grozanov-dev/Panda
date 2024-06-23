#!/usr/bin/perl

use lib './lib';
use utf8;
use feature qw/say state/;
use strict;
use warnings;
use Data::Dumper;
use IO::Socket;

sub http_get($$$$$) {
    my ( $host, $port, $path, $query, $timeout ) = @_;

    local $| = 1;
    my $sock = IO::Socket::INET->new (
         PeerAddr => $host,
         PeerPort => $port,
         Timeout  => $timeout,
         Proto    => 'tcp',
    );

    die "$!\n" unless $sock;

    $sock->autoflush;

    my @params;

    if( ref($query) eq 'HASH' ) {
        for my $key (keys $query->%*) {
            push @params, $key . '=' . $query->{$key};
        }
        $path .= '?' . ( join '&', @params );
    }

    if( $sock ) {
        my $res = '';

        my $req = join "\r\n",
            "GET /$path HTTP/1.0",
            "Host: $host:$port",
            "Accept: text/plain\r\n\r\n";

        $sock->send( $req );
        $sock->recv( $res, 1024 );

        $sock->close;

        print $res;
    }
}

{

    my $params = {
        param => 'value',
    };

    http_get '127.0.0.1', 8181, 'test', $params, 1;

}

1;

=pod

