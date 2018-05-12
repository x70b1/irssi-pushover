use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = "1.0";

%IRSSI = (
    authors => 'x70b1',
    name    => 'pushover.pl',
    description => 'Send a notification when you receive a message and are not attached to screen.',
    url     => 'https://github.com/x70b1/irssi-pushover',
);

sub pushover {
    my ( $title, $message ) = @_;

    my $screen = system("screen -ls | grep ".Irssi::settings_get_str('pushover_screensession')." | grep -q Detached");

    if ( !$screen ) {
        if ( ( $lastmsg + Irssi::settings_get_int('pushover_silence') ) < time() ) {
            system("curl -sf --form-string token='".Irssi::settings_get_str('pushover_apptoken')."' --form-string user='".Irssi::settings_get_str('pushover_usertoken')."' --form-string title='$title' --form-string message='$message' https://api.pushover.net/1/messages.json >> /dev/null");
            $lastmsg = time();
        } else {
            $lastmsg = time();
        }
    }
}

sub push_message {
    my ( $server, $msg, $nick, $address, $target ) = @_;

    pushover( "/msg $nick", "Ping!" );
}

sub push_mention {
    my ( $server, $msg, $nick, $address, $target ) = @_;

    if ( index( $msg, $server->{nick}) != -1 ) {
        pushover( "$target", "$nick: $msg" );
    }
}

Irssi::settings_add_int('pushover', 'pushover_silence', 60);
Irssi::settings_add_str('pushover', 'pushover_screensession', '');
Irssi::settings_add_str('pushover', 'pushover_apptoken', '');
Irssi::settings_add_str('pushover', 'pushover_usertoken', '');

my $lastmsg = time() - Irssi::settings_get_int('pushover_silence');

Irssi::signal_add_last( 'message private', 'push_message' );
Irssi::signal_add_last( 'message public',  'push_mention' );
