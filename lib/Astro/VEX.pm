package Astro::VEX;

=head1 NAME

Astro::VEX - VEX (VLBI Experiment Definition) file handling module

=cut

use strict;
use warnings;

use overload '""' => 'stringify';

sub new {
    my $proto = shift; my $class = ref($proto) || $proto;
    my %opt = @_;

    if (exists $opt{'text'}) {
        require Astro::VEX::Parse;
        return Astro::VEX::Parse->parse_vex($opt{'text'});
    }

    return bless {
        VERSION => $opt{'version'} // '1.5',
        CONTENT => $opt{'content'} // [],
    }, $class;
}

sub block {
    my $self = shift;
    my $name = shift;

    for my $item (@{$self->{'CONTENT'}}) {
        if ($item->isa('Astro::VEX::Block')) {
            if ($item->name eq $name) {
                return $item;
            }
        }
    }

    die 'Block not found: ' . $name;
}

sub stringify {
    my $self = shift;

    return join "\n", 'VEX_rev = ' . $self->{'VERSION'} . ';', @{$self->{'CONTENT'}}, '';
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