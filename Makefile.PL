
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'A Moose Role that provides TCPClient behavior',
  'AUTHOR' => 'Nicholas Perez <nperez@cpan.org>',
  'BUILD_REQUIRES' => {
    'POE' => '0',
    'Test::More' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'POEx-Role-TCPClient',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'POEx::Role::TCPClient',
  'PREREQ_PM' => {
    'MooseX::Declare' => '0',
    'MooseX::Types::Moose' => '0',
    'POE::Filter::Line' => '0',
    'POE::Wheel::ReadWrite' => '0',
    'POE::Wheel::SocketFactory' => '0',
    'POEx::Role::SessionInstantiation' => '0',
    'POEx::Types' => '0',
    'aliased' => '0'
  },
  'VERSION' => '1.102740',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



