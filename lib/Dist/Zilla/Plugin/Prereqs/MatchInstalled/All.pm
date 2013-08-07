use strict;
use warnings;

package Dist::Zilla::Plugin::Prereqs::MatchInstalled::All;

# ABSTRACT: Upgrade ALL your dependencies to the ones you have installed.

use Moose;
use Dist::Zilla::Plugin::Prereqs::MatchInstalled v0.1.1;
use MooseX::Types::Moose qw( ArrayRef HashRef Str Bool );

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Dist::Zilla::Plugin::Prereqs::MatchInstalled::All",
    "inherits":"Dist::Zilla::Plugin::Prereqs::MatchInstalled",
    "interface":"class"
}

=end MetaPOD::JSON

=cut

=head1 SYNOPSIS

    [Prereqs::MatchInstalled::All]
    ; upgrade_perl = 1  ; if you want to upgrade to your installed perl
    ; include these too if you don't want to force a perl upgrade indirectly.
    exclude = strict
    exclude = warnings

=cut

=head1 DESCRIPTION

This is a special case of L<<< C<< Dist::Zilla::Plugin::B<Prereqs::MatchInstalled> >>|Dist::Zilla::Plugin::Prereqs::MatchInstalled >>> that automatically upgrades all versions of all dependencies, unless asked not to.

=head2 PITFALLS

Presently, there is one very large gotcha about using this module, in that it will upgrade everything,
even things that don't make sense to upgrade.

For instance:

=head3 Local Versions

If you have a single dependency on your system you might use, which is locally patched, and locally patched in such a way the local version is more recent than any on C<CPAN>, you should either

=over 4

=item a. Not use this module

=item b. Put that module in the exclusion list

=back

=head3 Non-Dual Life modules

This plugin is not very smart, and can't differentiate between modules that do exist on C<CPAN> independent of Perl, and modules that don't.

For instance, if you use C<Autoprereqs>, its very likely your distribution will add a dependency on either C<strict> or C<warnings>

This module will ask your user to upgrade those versions to their latest versions, which will likely require them to upgrade their Perl installation to do so.

Which basically means for the mean time, either

=over 4

=item a. You must be o.k. with end users needing more recent Perls

=item b. You should avoid upgrading those dependencies by either

=over 4

=item a. Not using this plugin

=item b. Adding problematic modules to the exclusion list

=back

=back

=cut

extends 'Dist::Zilla::Plugin::Prereqs::MatchInstalled';

=attr C<exclude>

This parameter can be specified multiple times, and each
time should represent a single package string to exclude from
version upgrades.

    [Prereqs::MatchInstalled::All]
    exclude = foo
    exclude = bar

=cut

has exclude => (
  is => ro =>,
  isa => ArrayRef [Str],
  lazy    => 1,
  default => sub { [] },
);

=p_attr C<_exclude_hash>

=cut

has _exclude_hash => (
  is => ro =>,
  isa => HashRef [Str],
  lazy    => 1,
  builder => '_build__exclude_hash',
);

=attr C<upgrade_perl>

If specified, this will permit upgrades on the dependency on C<perl> to the installed version.

    [Prereqs::MatchInstalled::All]
    upgrade_perl = 1

Note, this has no effect on the modules that may inherently be only available by upgrading Perl.

Default is false.

See L</PITFALLS> for details.

=cut

has upgrade_perl => (
  is      => ro  =>,
  isa     => Bool,
  lazy    => 1,
  default => sub { undef },
);

around mvp_multivalue_args => sub {
  my ( $orig, $self, @args ) = @_;
  return ( 'exclude', $orig->( $self, @args ) );
};

around dump_config => sub {
  my ( $orig, $self, @args ) = @_;
  my $config      = $self->$orig();
  my $this_config = {
    exclude      => $self->exclude,
    upgrade_perl => $self->upgrade_perl,
  };
  $config->{ q{} . __PACKAGE__ } = $this_config;
  return $config;
};

=p_method C<_build__exclude_hash>

=cut

sub _build__exclude_hash {
  my ($self) = @_;
  return { map { ( $_, 1 ) } @{ $self->exclude } };
}

=p_method C<_user_wants_excluded>

=cut

sub _user_wants_excluded {
  my ( $self, $module ) = @_;
  return exists $self->_exclude_hash->{$module};
}

=p_method C<_user_wants_upgrade_on>

=cut

sub _user_wants_upgrade_on {
  my ( $self, $module ) = @_;
  if ( $module eq 'perl' and not $self->upgrade_perl ) {
    $self->log_debug(q[perl is a dependency, but we won't automatically upgrade that without upgrade_perl = 1]);
    return;
  }
  if ( $self->_user_wants_excluded($module) ) {
    return;
  }
  return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
