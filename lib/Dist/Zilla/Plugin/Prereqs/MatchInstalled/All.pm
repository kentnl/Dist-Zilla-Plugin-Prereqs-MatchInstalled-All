use strict;
use warnings;

package Dist::Zilla::Plugin::Prereqs::MatchInstalled::All;
BEGIN {
  $Dist::Zilla::Plugin::Prereqs::MatchInstalled::All::AUTHORITY = 'cpan:KENTNL';
}
{
  $Dist::Zilla::Plugin::Prereqs::MatchInstalled::All::VERSION = '0.1.0';
}

# ABSTRACT: Upgrade ALL your dependencies to the ones you have installed.

use Moose;
use Dist::Zilla::Plugin::Prereqs::MatchInstalled v0.1.1;
use MooseX::Types::Moose qw( ArrayRef HashRef Str Bool );

extends 'Dist::Zilla::Plugin::Prereqs::MatchInstalled';

has exclude => (
    is => ro =>,
    isa => ArrayRef[ Str ],
    lazy => 1, 
    default => sub { [] }
);
has _exclude_hash => (
    is => ro =>,
    isa => HashRef[ Str ],
    lazy => 1,
    builder => '_build__exclude_hash',
);


around mvp_multivalue_args => sub {
    my ( $orig, $self, @args ) = @_;
    return ( 'exclude' , $orig->($self, @args) );
};

has upgrade_perl => ( 
    is => ro =>,
    isa => Bool,
    lazy => 1, 
    default => sub { undef }
);

sub _build__exclude_hash {
   my ( $self ) = @_;
   return { map { ( $_ , 1 ) } @{ $self->exclude } };
}

sub _user_wants_excluded {
    my ( $self, $module ) = @_;
    return exists $self->_exclude_hash->{ $module };
}

sub _user_wants_upgrade_on {
    my ( $self, $module ) = @_;
    if ( $module eq 'perl' and not $self->upgrade_perl ) {
        $self->log_debug(q[perl is a dependency, but we won't automatically upgrade that without upgrade_perl = 1]);
        return;
    }
    if ( $self->_user_wants_excluded( $module ) ) { 
        return;
    }
    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Dist::Zilla::Plugin::Prereqs::MatchInstalled::All - Upgrade ALL your dependencies to the ones you have installed.

=head1 VERSION

version 0.1.0

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
