##############################################################################
# Net::Pownce - Perl OO interface to www.pownce.com
# v1.00
# Copyright (c) 2007 Chris Thompson
##############################################################################

package Net::Pownce;
$VERSION ="1.00";
use warnings;
use strict;

use LWP::UserAgent;
use JSON::Any;

sub new {
    my $class = shift;
    my %conf = @_;
    
    $conf{apiurl} = 'http://api.pownce.com' unless defined $conf{apiurl};
    $conf{pownceapiver} = '1.0' unless defined $conf{pownceapiver};


    ### NO LOGIN YET, AS THIS IS A READONLY API
    # $conf{apihost} = 'pownce.com:80' unless defined $conf{apihost};
    # $conf{apirealm} = 'Pownce API' unless defined $conf{apirealm};

    $conf{useragent} = "Net::Pownce/$Net::Pownce::VERSION (PERL)" unless defined $conf{useragent};
    $conf{clientname} = 'Perl Net::Pownce' unless defined $conf{clientname};
    $conf{clientver} = $Net::Pownce::VERSION unless defined $conf{clientver};
    $conf{clienturl} = "http://x4.net/pownce/meta.xml" unless defined $conf{clienturl};

    $conf{ua} = LWP::UserAgent->new();

    ### NO LOGIN YET, AS THIS IS A READONLY API
    #$conf{ua}->credentials($conf{apihost},
    #	  		   $conf{apirealm},
    #		   $conf{username},
    #		   $conf{password}
    #		);
	
    $conf{ua}->agent($conf{useragent});
    $conf{ua}->default_header( "X-Pownce-Client:" => $conf{clientname} );
    $conf{ua}->default_header( "X-Pownce-Client-Version:" => $conf{clientver} );
    $conf{ua}->default_header( "X-Pownce-Client-URL:" => $conf{clienturl} );

    $conf{ua}->env_proxy();

    return bless {%conf}, $class;
}

########################################################################
#### METHODS
########################################################################

sub public_note_list {
    my ( $self, $args ) = @_;

    my $url = $self->{apiurl} . "/" . $self->{pownceapiver} . "/public_note_lists.json";

	if (defined $args->{username}) {
		my $rel = (defined $args->{rel}) ? $args->{rel} : 'from';
		$url = $self->{apiurl} . "/" . $self->{pownceapiver} . "/public_note_lists/$rel/" . $args->{username} . ".json";
	}
	
	if ((defined $args->{type}) || (defined $args->{limit}) || (defined $args->{limit})) {
		$url .= "?";
	}
    $url .= (defined $args->{type}) ? "type=" . $args->{type} . "&" : "";
    $url .= (defined $args->{limit}) ? "limit=" . $args->{limit} . "&" : "";
    $url .= (defined $args->{page}) ? "page=" . $args->{page} : "";

    print "$url\n";

    my $req=$self->{ua}->get($url);

    return ($req->is_success) ?  JSON::Any->jsonToObj($req->content) : undef;
}

sub public_note {
    my ( $self, $args ) = @_;

    my $url = $self->{apiurl} . "/" . $self->{pownceapiver} . "/notes/" .  $args->{id} . ".json";

	if (((defined $args->{replies}) && (! $args->{replies})) || (defined $args->{limit}) ) {
		$url .= "?";
	}
	
    $url .= ((defined $args->{replies}) && (! $args->{replies})) ? "show_replies=false&" : "";
    $url .= (defined $args->{limit}) ? "type=" . $args->{limit} : "";

    my $req=$self->{ua}->get($url);
    return ($req->is_success) ?  JSON::Any->jsonToObj($req->content) : undef;
}

sub recipient_list {
    my ( $self, $args ) = @_;

    my $url = $self->{apiurl} . "/" . $self->{pownceapiver} . "/notes/" .  $args->{id} . "/recipients.json";

	if ((defined $args->{page}) || (defined $args->{limit}) ) {
		$url .= "?";
	}

    $url .= (defined $args->{limit}) ? "limit=" . $args->{limit} . "&" : "";
    $url .= (defined $args->{page}) ? "type=" . $args->{page} : "";
	
    my $req=$self->{ua}->get($url);
    return ($req->is_success) ?  JSON::Any->jsonToObj($req->content) : undef;
}

sub user_profile {
    my ( $self, $username ) = @_;

    my $url = $self->{apiurl} . "/" . $self->{pownceapiver} . "/users/$username.json";

    my $req=$self->{ua}->get($url);
    return ($req->is_success) ?  JSON::Any->jsonToObj($req->content) : undef;
}

sub get_relationships {
    my ( $self, $args ) = @_;
	
	my $rel = (defined $args->{rel}) ? $args->{rel} : 'fans';
	
    my $url = $self->{apiurl} . "/" . $self->{pownceapiver} . "/users/" . $args->{username} . "/$rel.json";

	if ((defined $args->{page}) || (defined $args->{limit}) ) {
		$url .= "?";
	}
	
    $url .= (defined $args->{limit}) ? "limit=" . $args->{limit} . "&" : "";
    $url .= (defined $args->{page}) ? "type=" . $args->{page} : "";
	
    my $req=$self->{ua}->get($url);
    return ($req->is_success) ?  JSON::Any->jsonToObj($req->content) : undef;
}
1;
__END__

=head1 NAME

Net::Pownce - Perl OO interface to pownce.com

=head1 VERSION

This document describes Net::Pownce version 1.00

=head1 SYNOPSIS

   #!/usr/bin/perl

   use lib './lib';

   use Net::Pownce;

   my $pownce = Net::Pownce->new();

   $result = $pownce->public_note_list({username=>'cthompson', rel=>'from'});

   $result = $pownce->public_note({id=>$note_id, replies=>1, limit=>20});

   $result = $pownce->get_relationships({username=>'cthompson', rel=>'fan_of'});

=head1 DESCRIPTION

From: L<http://www.pownce.com/about/>

   Pownce is a way to send stuff to your friends. What kind of stuff? 
   You can send just about anything: music, photos, messages, links, events, 
   and more.

This module implements v1.0 of the Pownce API as defined at L<http://pownce.pbwiki.com/API+Documentation>

This API is an extremely minimal implimentation which currently only reads public
information. It has no ability to log in, nor to send messages.

As the API matures, future versions of this module will add new 
functionality.

You can view the latest status of Net::Pownce on it's own Pownce account
at L<http://pownce.com/NetPownce/>

=head1 INTERFACE

=over

=item C<new()>

Creates the Pownce object. Currently takes no arguments due to the state of the
Pownce API.

=item C<public_note_list(...)>

Returns a list of public notes as a hashref.

If no args are specified, this will return all public notes, regardless of user.

This method accepts an optional hashref containing arguments:

=over

=item C<username>

Returns only public notes "from" this uers

=item C<rel>

Valid values for this argument are "for", "from" or "to". "from" returns notes from the user, "to" returns
notes to the user, and "for" returns a combination of both.

If this argument is not specified, it defautls to "from".

=item C<limit>

Limit the number of notes returned. Default is 20 and max is 100.

=item C<page>

Page number to display.

=back

=item C<public_note(...)>

Returns a public note by its ID.

This method accepts a hashref containing arguments:

=over

=item C<id>

REQUIRED: ID of the desired note.

=item C<replies>

By default the replies will be included. To get the note without replies, pass a false value for this argument.

=item C<limit>

Limit the number of recipients returned. Default is 20 and max is 100.

=back

=item C<recipient_list(...)>

Returns a list of note recipients, without the note.

=over

=item C<id>

REQUIRED: ID of the desired note.

=item C<limit>

Limit the number of notes returned. Default is 20 and max is 100.

=item C<page>

Page number to display.

=back

=item C<user_profile>

Retrieve a profile for a specific user.

=over

=item C<username>

REQUIRED: Username of the profile to retrieve.

=back

=item C<get_relationships(...)>

Returns a hashref containing relationships for a specific user.

=over

=item C<username>

REQUIRED: Username of the profile to retrieve.

=item C<rel>

Valid values for this argument are "friends", "fans" or "fan_of". "friends" returns
Users who have a mutual relationship with this user. "fans" returns users who are fans of the user.
"fan_of" returns a list of users for which the username is a fan.

=item C<limit>

Limit the number of users returned. Default is 20 and max is 100.

=item C<page>

Page number to display.

=back

=back

=head1 CONFIGURATION AND ENVIRONMENT
  
Net::Pownce uses LWP internally. Any environment variables that LWP
supports should be supported by Net::Pownce. I hope.

=head1 DEPENDENCIES

=over

=item L<LWP::UserAgent>

=item L<JSON::Any>

=back

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-net-pownce@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 THIS IS

SPARTAAAAAAA!

=head1 AUTHOR

Chris Thompson <cpan@cthompson.com>

The framework of this module is taken from my own L<Net::Twitter>, which was
shamelessly stolen from L<Net::AIML>. Big ups to Chris "perigrin" Prather for that.
       
=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, Chris Thompson <cpan@cthompson.com>. All rights
reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
