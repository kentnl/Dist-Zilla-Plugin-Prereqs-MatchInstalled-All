
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.4007"
  },
  "configure_requires" => {
    "Module::Build" => "0.4007"
  },
  "dist_abstract" => "Upgrade ALL your dependencies to the ones you have installed.",
  "dist_author" => [
    "Kent Fredric <kentfredric\@gmail.com>"
  ],
  "dist_name" => "Dist-Zilla-Plugin-Prereqs-MatchInstalled-All",
  "dist_version" => "0.1.3",
  "license" => "perl",
  "module_name" => "Dist::Zilla::Plugin::Prereqs::MatchInstalled::All",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Dist::Zilla::Plugin::Prereqs::MatchInstalled" => "v0.1.4",
    "Moose" => "2.1005",
    "MooseX::Types::Moose" => "0.38",
    "perl" => "v5.10.0",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => [],
  "test_requires" => {
    "Cwd" => 0,
    "File::Copy::Recursive" => "0.38",
    "File::Spec" => 0,
    "IO::Handle" => 0,
    "IPC::Open3" => 0,
    "Path::FindDev" => "v0.3.1",
    "Path::Tiny" => "0.037",
    "Test::DZil" => "4.300039",
    "Test::Fatal" => "0.013",
    "Test::More" => "0.98"
  }
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  my $tr = delete $module_build_args{test_requires};
  my $br = $module_build_args{build_requires};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
