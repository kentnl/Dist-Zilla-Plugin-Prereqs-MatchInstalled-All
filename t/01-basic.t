use strict;
use warnings;

use Test::More;
use Dist::Zilla::Util::Test::KENTNL 1.003002 qw( dztest );
use Test::DZil qw( simple_ini );

my $test = dztest();
$test->add_file(
  'dist.ini',
  simple_ini(
    [ 'Prereqs' => { 'Moose' => 0 } ],    #
    ['Prereqs::MatchInstalled::All'],
    ['MetaConfig'],                       #
  )
);
$test->build_ok;

ok( exists $test->distmeta->{prereqs}, '->prereqs' )
  and ok( exists $test->distmeta->{prereqs}->{runtime},                      '->prereqs/runtime' )
  and ok( exists $test->distmeta->{prereqs}->{runtime}->{requires},          '->prereqs/runtime/requires' )
  and ok( exists $test->distmeta->{prereqs}->{runtime}->{requires}->{Moose}, '->prereqs/runtime/requires/Moose' )
  and cmp_ok( $test->distmeta->{prereqs}->{runtime}->{requires}->{Moose}, 'ne', '0', "Moose != 0" );

note explain $test->distmeta;
note explain $test->builder->log_messages;

done_testing;

