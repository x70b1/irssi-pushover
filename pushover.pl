use Irssi;
use vars qw($VERSION %IRSSI);
use LWP::UserAgent;

$VERSION = "1.0";

%IRSSI = (
	authors     => 'x70b1',
	name        => 'pushover.pl',
	description => 'Send a notification when you receive a message and are not attached to screen.',
	url         => 'https://github.com/x70b1/irssi-pushover',
);

sub pushover {
	my ( $title, $message ) = @_;

	my $screen = system( "screen -ls | grep " . Irssi::settings_get_str('pushover_screensession') . " | grep -q Detached" );

	if ( !$screen ) {
		if ( ( $lastmsg + Irssi::settings_get_int('pushover_silence') ) < time() ) {

			my $push = LWP::UserAgent->new()->post(
				'https://api.pushover.net/1/messages.json',
				[
					user    => Irssi::settings_get_str('pushover_usertoken'),
					token   => Irssi::settings_get_str('pushover_apptoken'),
					title   => $title,
					message => $message
				]
			);

			if ( $push->is_success ) {
				Irssi::print("Pushover message sent.");
			} else {
				Irssi::print("A Pushover message failed!");
			}

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

	if ( index( $msg, $server->{nick} ) != -1 ) {
		pushover( "$target", "$nick: $msg" );
	}
}

Irssi::settings_add_int( 'pushover', 'pushover_silence', 60 );
Irssi::settings_add_str( 'pushover', 'pushover_screensession', '' );
Irssi::settings_add_str( 'pushover', 'pushover_apptoken',      '' );
Irssi::settings_add_str( 'pushover', 'pushover_usertoken',     '' );

my $lastmsg = time() - Irssi::settings_get_int('pushover_silence');

Irssi::signal_add_last( 'message private', 'push_message' );
Irssi::signal_add_last( 'message public',  'push_mention' );
