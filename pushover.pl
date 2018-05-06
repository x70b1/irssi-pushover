use strict;
use warnings;
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = "1.0";

%IRSSI = (
    authors => 'x70b1',
    name    => 'pushover.pl',
    description => 'Send a notification to Pushover when you receive a new private message and are not attached to screen.',
    url     => 'https://github.com/x70b1/irssi-pushover',
);

my $username = "{{ username }}";
my $silence  = 30;

my $timestamp = time() - $silence;

sub pushover {
    my ( $title, $message ) = @_;

    my $screen = system("screen -ls | grep -q Detached");

    if ( !$screen ) {
        if ( ( $timestamp + $silence ) < time() ) {
            system("curl -sf --form-string token='{{ application }}' --form-string user='{{ user }}' --form-string title='$title' --form-string message='$message' https://api.pushover.net/1/messages.json >> /dev/null");
            $timestamp = time();
        } else {
            $timestamp = time();
        }
    }
}

sub push_message {
    my ( $server, $msg, $nick, $address, $target ) = @_;

    pushover( "/msg $nick", "Ping!" );

}

sub push_mention {
    my ( $server, $msg, $nick, $address, $target ) = @_;

    if ( index( $msg, $username ) != -1 ) {
        pushover( "$target", "$nick: $msg" );
    }
}

Irssi::signal_add_last( 'message private', 'push_message' );
Irssi::signal_add_last( 'message public',  'push_mention' );
