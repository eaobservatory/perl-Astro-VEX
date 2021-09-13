package Astro::VEX::Parse;

=head1 NAME

Astro::VEX::Parse - VEX (VLBI Experiment Definition) parser module

=cut

use strict;
use warnings;

use Parse::RecDescent;

use Astro::VEX;
use Astro::VEX::Block;
use Astro::VEX::Comment;
use Astro::VEX::Def;
use Astro::VEX::Link;
use Astro::VEX::Param;
use Astro::VEX::Ref;
use Astro::VEX::Scan;

my $grammar = q{
    vex: header content(s?)
        {new Astro::VEX(version => $item[1], content => $item[2]);}

    header: 'VEX_rev' '=' /\d+\.\d+/ ';' {$item[3];}

    content: comment | block

    comment: '*' <skip:'[ \t]*'> /.*/
        {new Astro::VEX::Comment($item[3]);}

    block: block_header block_content(s?)
        {new Astro::VEX::Block($item[1], $item[2]);}

    block_header: '$' block_name ';' {$item[2];}

    block_content: comment | statement_ref | statement_def | statement_scan | parameter_assignment

    statement_ref: 'ref' reference '=' parameter_values ';'
        {new Astro::VEX::Ref($item[2], $item[4]);}

    statement_def: 'def' identifier ';' def_content(s?) 'enddef' ';'
        {new Astro::VEX::Def($item[2], $item[4]);}

    def_content: comment | statement_ref | parameter_assignment

    statement_scan: 'scan' identifier ';' scan_content(s?) 'endscan' ';'
        {new Astro::VEX::Scan($item[2], $item[4]);}

    scan_content: comment | parameter_assignment

    parameter_assignment: parameter_name '=' parameter_values ';'
        {new Astro::VEX::Param($item[1], $item[3]);}

    parameter_values: parameter_value parameter_values_tail(s?)
        {my $tail = $item[2]->[0]; [$item[1], ref $tail ? @$tail : ()];}

    parameter_values_tail: ':' parameter_values
        {$item[2]}

    parameter_value: parameter_value_link | parameter_value_plain | parameter_value_quoted


    block_name: /[!"#$%&'()*+,\\-.\/0-9:<>?\@A-Z\\[\\\\\\]^_`a-z{|}~]+/

    # TODO: Needs correct character set.
    reference: /\$[_A-Z]+/ {substr $item[1], 1;}

    parameter_name: /[!"#%'()+,\\-.\/0-9:<>?\@A-Z\\[\\\\\\]^_`a-z{|}~][!"#$%&'()*+,\\-.\/0-9:<>?\@A-Z\\[\\\\\\]^_`a-z{|}~]*/

    # TODO: Needs correct character set.
    parameter_value_link: /&[_a-zA-Z0-9]+/
        {new Astro::VEX::Link(substr $item[1], 1);}

    parameter_value_plain: /[ !#%'()+,\\-.\/0-9<>?\@A-Z\\[\\\\\\]^_`a-z{|}~\][ !#%'()+,\\-.\/0-9<>?\@A-Z\\[\\\\\\]^_`a-z{|}~\\n"]*/

    parameter_value_quoted: /"[ !#%'()+,\\-.\/0-9:<>?\@A-Z\\[\\\\\\]^_`a-z{|}~]+"/

    # TODO: Needs correct character set.
    identifier: /[-_+a-zA-Z0-9<#.@]+/

    # Example (not used).
    anychar: /[ !"#$%&'()*+,\\-.\/0-9:;<=>?\@A-Z\\[\\\\\\]^_`a-z{|}~]/
};


sub parse_vex {
    my $cls = shift;
    my $text = shift;

    my $parser = new Parse::RecDescent($grammar)
        or die 'Failed to prepare parser';

    # Parse text as reference so that we are left with whatever didn't match.
    my $result = $parser->vex(\$text);

    chomp $text;
    $text =~ s/^\s//;
    $text =~ s/\s$//;
    die "Failed to parse VEX at: '" . (substr $text, 0, 60) . "'"
        if $text;

    return $result;
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
