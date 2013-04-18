package tinycv;

use strict;
use warnings;

require Exporter;
require DynaLoader;

our @ISA = qw(Exporter DynaLoader);
our @EXPORT = qw();

our $VERSION = '1.0';

bootstrap tinycv $VERSION;

package tinycv::Image;

# returns area of last matched
sub search_($$) {
    my $self = shift;
    my $needle = shift;
    my ($sim, $xmatch, $ymatch, $d1, $d2);
    my (@exclude, @match, @ocr);

    my $img = $self->copy;

    for my $a (@{$needle->{'area'}}) {
	push @exclude, $a if $a->{'type'} eq 'exclude';
	push @match, $a if $a->{'type'} eq 'match';
	push @ocr, $a if $a->{'type'} eq 'ocr';
    }

    for my $a (@exclude) {
	$img->replacerect($a->{'xpos'}, $a->{'ypos'},
	    $a->{'width'}, $a->{'height'});
    }
    my $area;
    for $area (@match) {
	my $c = $needle->get_image($area);
	($sim, $xmatch, $ymatch, $d1, $d2) = $img->search_needle($c);
	printf "MATCH(%s:%.2f): $xmatch $ymatch\n", $needle->{name}, $sim;
	if ($sim < $area->{match} - 0.005) {
	    return undef
	}
    }

    my $ret = {
	similarity => $sim, x => $xmatch, y => $ymatch,
	w => $area->{'width'},
	h => $area->{'height'},
	needle => $needle
    };

    for my $a (@ocr) {
	$ret->{'ocr'} ||= [];
	my $ocr = ocr::tesseract($img, $a);
	push @{$ret->{'ocr'}}, $ocr;
    }

    return $ret;
}

sub search($) {
    my $self = shift;
    my $needle = shift;
    return undef unless $needle;
    if (ref($needle) eq "ARRAY") {
	for my $n (@$needle) {
	    my $ret = $self->search_($n);
	    return $ret if $ret;
	}
    } else {
	return $self->search_($needle);
    }
}

sub write_optimized($$) {
	my $self = shift;
	my $filename = shift;
	$self->write($filename);
	# TODO make a thread for running optipng one after the other (Thread::Queue)
	system("optipng", "-quiet", $filename);
}

1;

# Local Variables:
# tab-width: 8
# cperl-indent-level: 8
# End:
