#!/usr/bin/perl -w
use strict;
use base "installstep";
use bmwqemu;

sub run()
{
	my $self=shift;

	waitforneedle("inst-welcome", 350); # live cds can take quite a long time to boot
	if($ENV{BETA}) {
		waitforneedle("inst-betawarning", 5);
		sendkey "ret";
	} elsif (checkneedle("inst-betawarning", 2)) {
		mydie("beta warning found in non-beta");
	}

	# animated cursor wastes disk space, so it is moved to bottom right corner
	mouse_hide;
	#sendkey "alt-o"; # beta warning
	#  TODO make the beta warning check more clever
	waitidle;
	# license+lang
	if($ENV{HASLICENSE}) {
		sendkey $cmd{"accept"}; # accept license
	}
	waitforneedle("languagepicked", 2);
	sendkey $cmd{"next"};
	if (checkneedle("langincomplete", 1)) {
	    sendkey "alt-f";
        }
}

1;
