package Astro::VEX::Param::String;

=head1 NAME

Astro::VEX::Param::String - VEX (VLBI Experiment Definition) string parameter class

=cut

use strict;
use warnings;

our $VERSION = '0.001';

use parent qw/Astro::VEX::Param::Value/;

use overload '""' => 'stringify';

sub new {
    my $proto = shift; my $class = ref($proto) || $proto;
    my $value = shift;
    my $quoted = shift;

    return bless {
        VALUE => $value,
        QUOTED => $quoted,
    }, $class;
}

sub stringify {
    my $self = shift;

    my $value = $self->{'VALUE'};
    my $quote = $self->{'QUOTED'};

    unless (defined $quote) {
        $quote = 1 if $value =~ /[ \t\n]/
            || $value =~ /^"/;
    }

    return $value unless $quote;

    $value =~ s/\\/\\\\/;

    $value =~ s/(["])/\\$1/g;

    return sprintf '"%s"', $value;
}

1;

__END__

=head1 COPYRIGHT

Copyright (C) 2021 East Asian Observatory
All Rights Reserved.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful,but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc.,51 Franklin
Street, Fifth Floor, Boston, MA  02110-1301, USA

=cut