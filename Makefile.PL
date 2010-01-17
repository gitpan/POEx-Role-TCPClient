
use strict;
use warnings;



use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'POEx-Role-TCPClient',
  NAME      => 'POEx::Role::TCPClient',
  AUTHOR    => "Nicholas\ Perez\ \<nperez\@cpan\.org\>",
  ABSTRACT  => "Moose\ Role\ for\ turning\ ordinary\ objects\ into\ POE\ TCP\ Clients",
  VERSION   => '0.100170',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'gpl') : ()),
  PREREQ_PM    => {
    "POEx::Role::SessionInstantiation" => '0.092800',
    "MooseX::Declare" => '0.32',
    "POE" => '1.281',
    "Moose" => '0.93',
  },
  test => {TESTS => 't/*.t'}
);

