#!/usr/bin/perl

use lib './lib';
use utf8;
use feature qw/say state/;
use strict;
use warnings;

use Data::Dumper;

use IO::Async::Socket;
use IO::Async::Loop;

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

    my $loop  = IO::Async::Loop->new;

    $loop->connect(
        host     => "127.0.0.1",
        service  => "8181",
        socktype => 'stream',

        on_connected => sub {
            my ( $sock ) = @_;
            my $cls = IO::Async::Socket->new(
                handle => $sock,
                on_recv => sub {
                    my ( $self, $data ) = @_;

                    print "\nRecieved from $host:\n$data\n";

                    $loop->stop;
                },
                on_recv_error => sub {
                    my ( $self, $errno ) = @_;
                    die "$errno\n";
                },
            );
            $loop->add( $cls );
            $cls->send( $req );

            print "Send:\n" . $req;
        },
        on_connect_error => sub { die "Connection refused ...\n";   },
        on_resolve_error => sub { die "Host unresolved - $_[-1]\n"; },
    );

    $loop->run;
}

{
    my $params = {
        param => 'value',
    };

    http_get_async '127.0.0.1', 8181, 'test', $params, 1;

}

1;

=pod

