
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'POEx-Role-TCPClient',
  NAME      => 'POEx::Role::TCPClient',
  AUTHOR    => 'Nicholas\ Perez\ \<nperez\@cpan\.org\>',
  ABSTRACT  => 'Moose\ Role\ for\ turning\ ordinary\ objects\ into\ POE\ TCP\ Clients',
  VERSION   => '0.092340',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'gpl') : ()),
  PREREQ_PM    => {
    "POEx::Role::SessionInstantiation" => '0.092280',
  },
);
