#!/usr/bin/perl -w
use strict;
use base "installstep";
use bmwqemu;

sub run()
{
	my $self=shift;
        
        my @tags = (@{needle::tags("inst-welcome")}, @{needle::tags("inst-betawarning")});
        
	# we can't just wait for the needle as the beta popup may appear delayed and we're doomed
	waitidle(350);
	my $ret = waitforneedle(\@tags, 350); # live cds can take quite a long time to boot

        if( $ret->{needle}->has_tag("inst-betawarning") ) {
            sendkey "ret";
            waitforneedle("inst-welcome", 5);
        }

#	if($ENV{BETA}) {
#		waitforneedle("inst-betawarning", 5);
#		sendkey "ret";
#	} elsif (checkneedle("inst-betawarning", 2)) {
#		mydie("beta warning found in non-beta");
#	}

	# animated cursor wastes disk space, so it is moved to bottom right corner
	mouse_hide;
	#sendkey "alt-o"; # beta warning
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
