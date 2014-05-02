use strict;
use warnings;

use Test::More;
use Path::Tiny;
use File::Copy::Recursive qw( rcopy );
use Test::DZil;
use Test::Fatal;
use FindBin;

my $dist = 'fake_dist_01';

my $source  = path($FindBin::Bin)->parent->child('corpus')->child($dist);
my $tempdir = Path::Tiny->tempdir;

rcopy( "$source", "$tempdir" );

my $distini = $tempdir->child('dist.ini');

BAIL_OUT("test setup failed to copy to tempdir") if not -e $distini or -d $tempdir->child("dist.ini");

is(
  exception {
    my $builder = Builder->from_config(
      {
        dist_root => "$tempdir"
      }
    );
    $builder->build;
  },
  undef,
  'can build dist ' . $dist
);

done_testing;

